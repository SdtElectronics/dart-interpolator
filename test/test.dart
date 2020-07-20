import 'package:interpolator/interpolator.dart';
import 'package:test/test.dart';

void main() {
  	group("String Interpolation:", () {
    	const format = "{Part Name} CMOS Micropower {Type} {pre}{Abbr}{suf}"
					   "consists of a low power linear voltage-controlled"
					   "oscillator (VCO) and two different {Component}";
		const result = "CD4046 CMOS Micropower Phase-Locked Loop {PLL}"
					   "consists of a low power linear voltage-controlled"
					   "oscillator (VCO) and two different phase comparators";
		const subs_full = {
				"Part Name": "CD4046",
				"Type":		 "Phase-Locked Loop",
				"Abbr":		 "PLL",
				"Component": "phase comparators"
				};

		test("Interpolation on format String with full "
			 "match and no placeholder provided", () {
      		final interpolator = Interpolator(format);
      		expect(interpolator(subs_full) ,equals(result));
    	});

		test("Interpolation on format String with null "
			 "match and a placeholder provided", () {
      		final interpolator = Interpolator(format, placeholder: "PLL");
			const subs_part = {
				"Part Name": "CD4046",
				"Type":		 "Phase-Locked Loop",
				"Component": "phase comparators"
				};

      		expect(interpolator(subs_part) ,equals(result));
    	});

		test("Get input format String", () {
      		final interpolator = Interpolator(format);
      		expect(interpolator.format ,equals(format));
    	});

		test("Get interpolation List", () {
      		final interpolator = Interpolator(format);
      		expect(interpolator.subs,
			  	   equals(subs_full.entries.map((e) => e.key.toString()).toList()));
    	});
 	});

	group('Syntax Error Check:', () {

		test("Exception handling on format String with "
			 "unmatched '{'", () {

			try{
				Interpolator("Unmatched '{pre}' at 2:2\n {");
			}on FormatException catch(e){
				expect(e.message, "Expected '}' to match '{' at the end");
			}

			
    	});

		test("Exception handling on format String with null "
			 "match and no placeholder provided", () {
			const format = "{nullMatch}";
      		final interpolator = Interpolator(format);

			try{
				interpolator(const{});
			}on FormatException catch(e){
				expect(e.message, "No match with key "
				  				  "\"nullMatch\" at 1:1 and "
								  "no placeholder specified");
			}
													   
		});
 	});
}