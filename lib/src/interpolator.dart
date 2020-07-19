import 'exception.dart';

class Interpolator{

	static const _prefix = "{";
	static const _suffix = "}";

	final String placeholder;
	final List<String> _bodySegs;
	final List<String> _subs;
	get subs => _subs;
	///Get input format string
	get format{
		List<String> bodyCopy = List.from(_bodySegs);

		int index = 0;
		for(final sub in _subs){
			bodyCopy.insert(++index, "{$sub}");
		}

		return bodyCopy.join();
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
									  "${formatLocation(format, RegExp(segPair[0]))}");
			}

			//Add the interpolation to subs
			subs.add(segPair[0]);
			//Add the trailing string to body segments
			bodySegs.add(segPair[1]);

		};

		return Interpolator._(bodySegs, subs, placeholder);
	}

	String call(Map<String, String> sub) {
		//Make a copy since sub need to be modified
		var subCopy = Map.from(sub);
		//Escape the brackets
		subCopy["pre"] = _prefix;
		subCopy["suf"] = _suffix;

		String ret = "";
		int index = 0;

		//Assemble the result string from segments and substitutions
		for(final unsub in _subs){
			ret += _bodySegs[index++];
			ret += (subCopy[unsub] ?? 
					   (placeholder ?? 
							(throw FormatException("No match with key \"$unsub\" at " 
												   "${formatLocation(format, 
												   					 RegExp(unsub))} "
								   					"and no placeholder specified"))
						)
					);
		}
		
		return ret += _bodySegs[index];
	}

}
