import 'exception.dart';

///Class to parse and cache format string for later interpolation
///
///Initialization with a format String:
///```
///const format = "substitution: {sub}; escaping braces: {pre}{suf} placeholder:{unmatched}";
///final interpolator = Interpolator(format, "null");
///print(interpolator({"sub": "substituted"}));
///
/////substitution: substituted; escaping braces: {} placeholder:null
///```
class Interpolator{

	static const _prefix = "{";
	static const _suffix = "}";

	///Placeholder to substitute unmatched keys
	final String _placeholder;
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

	Interpolator._(this._bodySegs, this._subs, this._placeholder);

	///Create an [Interpolator] with [format] and an optional [placeholder].
	///If [placeholder] is set to null(by default), performing interpolation with a
	/// map failed to provide all keys in the [format] will throw a [FormatException].
	factory Interpolator(String format, [String placeholder = null]){
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

		return Interpolator._(bodySegs, subs, placeholder);
	}

	///Perform interpolation on early parsed format string with [subs]
	String call<V>(Map<String, V> subs) {
		//Make a copy since sub need to be modified 
		var subCopy = Map.from(subs);

		//Escape the braces
		subCopy["pre"] = _prefix;
		subCopy["suf"] = _suffix;

		String ret = "";

		//Assemble the result string from segments and substitutions
		int index = 0;
		for(final unsub in _subs){
			ret += _bodySegs[index++];
			ret += (subCopy[unsub] ?? 
						//If an interpolation references to a key does not exists
						//in the provided Map, substitute it with _placeholder
					    (_placeholder ?? 
							(
								//If no laceholder specified
								//throw an Exception
								throw FormatException("No match with key \"$unsub\" at " 
												   "${formatLocation(format, 
												   					 RegExp(unsub))} "
								   					"and no placeholder specified")
							)
						)
					).toString();
		}
		
		return ret += _bodySegs[index];
	}

	///Give useful information when debugging
	@override
	String toString(){
		return "Interpolator: {\n"
			   "	format: $format,\n"
			   "	placeholder: ${_placeholder.toString()}\n"
			   "}";
	}
}
