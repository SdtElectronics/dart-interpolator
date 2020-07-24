import 'package:interpolator/interpolator.dart';

void main() {
	const format = "{Name} is a chemical element with the symbol {Symbol} and atomic number {No.}.";
	final element = Interpolator(format);
	const map = {
    "Name":     "Chromium",
    "Symbol":   "Cr",
    "No.":      24
	};
	print(element(map));

	//Chromium is a chemical element with the symbol Cr and atomic number 24.


	const formatWithBraces = "Need format string includes '{pre}' and '{suf}'? No problem!";
	final escaped = Interpolator(formatWithBraces);
	print(escaped(const {}));

	//Need format string includes '{' and '}'? No problem!

	//TODO: add example for default values

	try{
		Interpolator("Unmatched '{pre}' at 2:2\n { ");
	}on FormatException catch(e){
		print(e);
	}
		
	//FormatException: Expected '}' to match '{' at 2:2


	final nullMatch = Interpolator("{nullMatch}");
	try{
		nullMatch(const{});
	}on FormatException catch(e){
		print(e);
	}
	
	//FormatException: No match with key "nullMatch" at 1:2 and no placeholder specified
}