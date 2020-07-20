List<int> _locateStr(String str, Pattern pattern){
	final frontSegs = str.split(pattern)[0].split('\n');
	return [frontSegs.length, frontSegs.removeLast().length];
}

String formatLocation(String str, Pattern pattern){
	final location = _locateStr(str, pattern);
	return "${location[0]}:${location[1]}";
}