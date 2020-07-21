import 'exception.dart';

class Interpolator{

	static const _prefix = "{";
	static const _suffix = "}";

	final String placeholder;
	final List<String> _bodySegs;
	final List<String> _subs;

	///Get interpolation keys
	get keys {
		List<String> ret = List.from(_subs);
		while(ret.remove("pre"));
		while(ret.remove("suf"));
		return ret;
	}

	///Get input format string
	get format {
		List<String> ret = [_bodySegs[0]];

		int index = 0;
		for(final sub in _subs){
			ret.addAll(["{${sub}}", _bodySegs[++index]]);
		}

		return ret.join();
	}

	Interpolator._(this._bodySegs, this._subs, this.placeholder);

	factory Interpolator(String format, {String placeholder = null}){
		//Break the format string into
		//[segment 0] { [segment 1] { [segment 2] ... { [segment n-1]
		final segments = "$format".split(_prefix);

		List<String> bodySegs = [];
		List<String> subs = [];

		//Add [segment 0] to body segments
		bodySegs.add(segments[0] ?? "");

		//Parse interpolations from [segment 1]
		for(final segPairStr in segments.sublist(1)){
			//A segPair is like [interpolation] } [trailing string]
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

	String call<V>(Map<String, V> sub) {
		//Cast if necessary and make a copy since sub need to be modified 
		Map<String, String> subCopy;
		if(V is String){
			subCopy = Map.from(sub);
		}else{
			subCopy = sub.map((key, val) => MapEntry(key, val.toString()));
		}

		//Escape the brackets
		subCopy["pre"] = _prefix;
		subCopy["suf"] = _suffix;

		String ret = "";

		//Assemble the result string from segments and substitutions
		int index = 0;
		for(final unsub in _subs){
			ret += _bodySegs[index++];
			ret += (subCopy[unsub] ?? 
					    (placeholder ?? 
							(
								throw FormatException("No match with key \"$unsub\" at " 
												   "${formatLocation(format, 
												   					 RegExp(unsub))} "
								   					"and no placeholder specified")
							)
						)
					);
		}
		
		return ret += _bodySegs[index];
	}

}
