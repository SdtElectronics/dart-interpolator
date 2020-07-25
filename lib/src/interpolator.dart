import 'exception.dart';

///Class to parse and cache format string for later interpolation
///
///Initialization with a format String:
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
	final Map<String, dynamic> _defaultVal;
	///Cache for parsed format string
	final List<String> _bodySegs;
	///Cache for parsed format string
	final List<String> _subs;

	///Get interpolation keys from format string
	get keys {
		Set<String> ret = Set.from(_subs);
		//Escape characters are not keys
		ret.remove("pre");
		ret.remove("suf");
		return ret;
	}

	///Get input format string from cache
	get format {
		List<String> ret = [_bodySegs[0]];
		//Assemble the format string from segments and keys
		int index = 0;
		for(final sub in _subs){
			ret.addAll(["{${sub}}", _bodySegs[++index]]);
		}

		return ret.join();
	}

	Interpolator._(this._bodySegs, this._subs, this._defaultVal);

	///Create an [Interpolator] with [format] and an optional map [defaultVal] to set
	///the default values of keys.
	///Set the value of key [null] in the [defaultVal] to designate a placeholder to 
	///substitute the keys in the format string which do not exist in the provided map,
	///otherwise a [FormatException] will be thrown when fail to find a key in the map.
	factory Interpolator(String format, [Map<String, dynamic> defaultVal = const {}]){
		//Escape the braces
		const escapeChar = {"pre": "{", "suf": "}"};
		return Interpolator.noEscape(format, {}..addAll(escapeChar)..addAll(defaultVal));
	}

	///All the same to the [Interpolator] constructor except this one crates an
	///interpolator which does not escape the braces.
	factory Interpolator.noEscape(String format, [Map<String, dynamic> defaultVal]){
		//Break the format string into
		//[segment 0] { [segment 1] { [segment 2] ... { [segment n-1]
		final segments = "$format".split(_prefix);

		List<String> bodySegs = [];
		List<String> subs = [];

		//Add [segment 0] to body segments
		bodySegs.add(segments[0] ?? "");

		//Parse interpolations of [segment 1]
		for(final segPairStr in segments.sublist(1)){
			//A segPair is in the form [interpolation] } [trailing string]
			final segPair = segPairStr.split(_suffix);
			
			//If the '}' matching the previous '{' is missing, throw an Exception
			if(segPair[0].length == segPairStr.length){
				throw FormatException("Expected '$_suffix' to match '$_prefix' at "
									  "${formatLocation(segPairStr == segments.last?
									  	'{$format{' : format, '{$segPairStr{')}");
			}

			//Add the interpolation to subs
			subs.add(segPair[0]);
			//Add the trailing string to body segments
			bodySegs.add(segPair[1]);

		};

		return Interpolator._(bodySegs, subs, defaultVal);
	}

	///Perform interpolation on early parsed format string with [subs]
	String call<V>(Map<String, V> subs) {

		final subCopy = _defaultVal != null						? 
						({}..addAll(_defaultVal)..addAll(subs)) : 
						subs;

		String ret = "";

		//Assemble the result string from segments and substitutions
		int index = 0;
		for(final unsub in _subs){
			ret += _bodySegs[index++];
			ret += (subCopy[unsub] ?? subCopy[null] ??
						(
							//If no laceholder specified
							//throw an Exception
							throw FormatException("No match with key \"$unsub\" at " 
											   "${formatLocation(format, 
											   					 RegExp(unsub))} "
							   					"and no placeholder specified")
						)
					).toString();
		}
		
		return ret += _bodySegs[index];
	}

	///Retrieve values from an interpolated string [input]
	///Use with care since values may contain the same patterns that divide values
	Map<String, String> retrieve(String input){
		int index = 0;
		Map<String, String> ret = {};
		var inputCopy = input.toString();
		for(final key in _subs){
			ret[key] = RegExp("(?<=${_bodySegs[index]}).*?(?=${_bodySegs[index + 1]})")
					   .firstMatch(inputCopy)?.group(0);
			inputCopy = inputCopy.replaceFirst(
				RegExp("${_bodySegs[index]}.*?(?=${_bodySegs[++index]})"), ""
			);
		}

		//Escape characters are not keys
		ret.remove("pre");
		ret.remove("suf");
		return ret;
	}

	///Give useful information when debugging
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
