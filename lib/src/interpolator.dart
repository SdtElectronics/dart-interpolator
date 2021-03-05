import 'exception.dart';

///Class to parse and cache string template for later interpolation
///
///Initialization with a string template:
///```
///const format = "substitution: {sub}; escaping braces: {pre}{suf} placeholder:{unmatched}";
///final interpolator = Interpolator(format, {null: "null"});
///print(interpolator({"sub": "substituted"}));
///
/////substitution: substituted; escaping braces: {} placeholder:null
///```
class Interpolator{

	static const _prefix = "{";
	static const _suffix = "}";

	///Placeholder to substitute unmatched keys
	final Map<String?, dynamic> _defaultVal;
	///Cache for parsed string template
	final List<String> _bodySegs;
	///Cache for parsed string template
	final List<String> _subs;

	///Interpolation keys of string template
	get keys {
		Set<String> ret = Set.from(_subs);
		//Escape characters are not keys
		return ret..remove("pre")..remove("suf");
	}

	///The input string template 
	get format {
		final ret = StringBuffer();
		//Assemble the string template from segments and keys
		int index = 0;
		for(final sub in _subs){
			ret..write(_bodySegs[index++])..write("{${sub}}");
		}

		return (ret..write(_bodySegs[index])).toString();
	}

	Interpolator._(this._bodySegs, this._subs, this._defaultVal);

	///Create an [Interpolator] with [format] and an optional map [defaultVal] to set
	///the default values of keys.
	///Set the value of key [null] in the [defaultVal] to designate a placeholder to 
	///substitute the keys in the string template which do not exist in the provided map,
	///otherwise a [FormatException] will be thrown when fail to find a key in the map.
	factory Interpolator(String format, [Map<String?, dynamic> defaultVal = const {}]){
		//Escape the braces
		const escapeChar = {"pre": "{", "suf": "}"};
		return Interpolator.noEscape(format, {}..addAll(escapeChar)..addAll(defaultVal));
	}

	///All the same to the [Interpolator] constructor except this one crates an
	///interpolator which does not escape the braces.
	factory Interpolator.noEscape(String format, [Map<String?, dynamic> defaultVal  = const {}]){
		//Break the string template into
		//[segment 0] { [segment 1] { [segment 2] ... { [segment n-1]
		final segments = "$format".split(_prefix);

		List<String> bodySegs = [];
		List<String> subs = [];

		//Add [segment 0] to body segments
		bodySegs.add(segments[0]);

		//Parse interpolations of [segment 1]
		for(final segPairStr in segments.sublist(1)){
			//A segPair is in the form [interpolation] } [trailing string]
			final segPair = segPairStr.split(_suffix);
			//Add the interpolation to subs
			subs.add(segPair[0]);
			//Add the trailing string to body segments
			try{
				bodySegs.add(segPair[1]);
			}on RangeError{
				//If the '}' matching the previous '{' is missing, throw an Exception
				throw FormatException("Expected '$_suffix' to match '$_prefix' at "
									  "${formatLocation(segPairStr == segments.last?
									  	'{$format{' : format, '{$segPairStr{')}");
			}
		};

		return Interpolator._(bodySegs, subs, defaultVal);
	}

	///Perform interpolation on early parsed string template with [subs]
	String call<V>(Map<String?, V> subs) {

		final subCopy = {}..addAll(_defaultVal)..addAll(subs);

		final ret = StringBuffer();

		//Assemble the result string from segments and substitutions
		int index = 0;
		for(final unsub in _subs){
			ret.write(_bodySegs[index++]);
			ret.write(subCopy[unsub] ?? subCopy[null] ??
						(
							//If no placeholder specified
							//throw an Exception
							throw FormatException("No match with key \"$unsub\" at " 
											   "${formatLocation(format, 
											   					 RegExp(unsub))} "
							   					"and no placeholder specified")
						)
					);
		}
		return (ret..write(_bodySegs[index])).toString();
	}

	///Retrieve values from an interpolated string [input]
	///Use with care since values may contain the same patterns that divide values
	Map<String, String> retrieve(String input){
		int index = 0;
		int start = 0;
		Map<String, String> ret = {};
		for(final key in _subs){
			final prefix = _bodySegs[index];
			start +=  prefix.length;
			final val = RegExp("(?<=${prefix}).*?(?=${_bodySegs[++index]})")
					   .matchAsPrefix(input, start)?.group(0);
			ret[key] = val ?? (throw FormatException("Corrupted input String"));
			start += val.length;
		}

		//Escape characters are not keys
		return ret..remove("pre")..remove("suf");
	}

	@override
	String toString(){
		final defValCopy = Map.from(_defaultVal);
		defValCopy.remove("pre");
		defValCopy.remove("suf");
		return "Interpolator: {\n"
			   "	format: $format,\n"
			   "	Default Values: ${defValCopy.toString()}\n"
			   "}";
	}
}
