import 'package:interpolator/interpolator.dart';
import 'package:test/test.dart';

void main() {
  	group("String Interpolation:", () {
    	const format = "{Part Name} CMOS Micropower {Type} {pre}{Abbr}{suf}"
					   "consists of a low power linear voltage-controlled"
					   "oscillator (VCO) and {Count} different {Component}";
		const result = "CD4046 CMOS Micropower Phase-Locked Loop {PLL}"
					   "consists of a low power linear voltage-controlled"
					   "oscillator (VCO) and 2 different phase comparators";
		const subs_full = {
			"Part Name": "CD4046",
			"Type":		 "Phase-Locked Loop",
			"Abbr":		 "PLL",
			"Count":	 2,
			"Component": "phase comparators"
		};

		const subs_part = {
				"Part Name": "CD4046",
				"Type":		 "Phase-Locked Loop",
				"Abbr":		 "PLL",
				"Component": "phase comparators"
				};

		test("Interpolation on string template with full "
			 "match and no placeholder provided", () {
      		final interpolator = Interpolator(format);
      		expect(interpolator(subs_full) ,equals(result));
    	});

		test("Interpolation on string template with null "
			 "match and a default value provided", () {
      		final interpolator = Interpolator(format, {"Count": "2"});
      		expect(interpolator(subs_part) ,equals(result));
    	});

		test("Interpolation on string template with null "
			 "match and a placeholder provided", () {
      		final interpolator = Interpolator(format, {null: "2"});
      		expect(interpolator(subs_part) ,equals(result));
    	});

 	});

	group("Information retrieval", (){
		const format = "{Part Name} CMOS Micropower {Type} {pre} {Abbr} {suf} consists "
					   "of a low power linear voltage-controlled"
					   "oscillator  and {Count} different {Component} ";
		const result = "CD4046 CMOS Micropower Phase-LockedLoop { PLL } consists"
					   " of a low power linear voltage-controlled"
					   "oscillator  and 2 different phasecomparators ";
		const subs_full = {
			"Part Name": "CD4046",
			"Type":		 "Phase-LockedLoop",
			"Abbr":		 "PLL",
			"Count":	 "2",
			"Component": "phasecomparators"
		};
		final interpolator = Interpolator(format);

		test("Get input string template", () {
      		expect(interpolator.format ,equals(format));
    	});

		test("Get interpolation List", () {
      		expect(interpolator.keys,
			  	   equals(subs_full.entries.map((e) => e.key.toString()).toSet()));
    	});

		test("Retrieve values", () {
      		expect(interpolator.retrieve(result) ,equals(subs_full));
    	});

		test("toString method", () {
			const str = "Interpolator: {\n"
			   			"	format: $format,\n"
			   			"	Default Values: {}\n"
			   			"}";
      		expect(interpolator.toString() ,equals(str));
    	});
	});

	group('Syntax Error Check:', () {
		test("Exception handling on string template with "
			 "unmatched '{'", () {

			try{
				Interpolator("Unmatched '{pre}' at 2:2\n { ");
			}on FormatException catch(e){
				expect(e.message, "Expected '}' to match '{' at 2:2");
			}	
    	});

		test("Exception handling on string template with null "
			 "match and no placeholder provided", () {
			const format = "{nullMatch}";
      		final interpolator = Interpolator(format);

			try{
				interpolator(const{});
			}on FormatException catch(e){
				expect(e.message, "No match with key "
				  				  "\"nullMatch\" at 1:2 and "
								  "no placeholder specified");
			}
													   
		});
 	});
}