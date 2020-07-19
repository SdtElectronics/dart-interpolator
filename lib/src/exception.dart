List<int> _locateStr(String str, RegExp pattern){
	print(str);
	final frontSegs = str.split(pattern)[0].split("\n");
	print(frontSegs);
	return [frontSegs.length, frontSegs.removeLast().length];
}

String formatLocation(String str, RegExp pattern){
	final location = _locateStr(str, pattern);
	return "${location[0]}:${location[1]}";
}