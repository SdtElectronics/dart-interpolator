import 'package:interpolator/interpolator.dart';
import 'package:test/test.dart';

void main() {
  	group("String Interpolation:", () {
    	const format = "";
		const result = "";

		test("Interpolation on format String with full "
			 "match and no placeholder provided", () {
      		final interpolator = Interpolator(format);
			final subs_full = {};

      		expect(interpolator(subs_full) ,equals(result));
    	});

		test("Interpolation on format String with null "
			 "match and a placeholder provided", () {
      		final interpolator = Interpolator(format);
			final subs_part = {};

      		expect(interpolator(subs_part) ,equals(result));
    	});

		test("Get input format String", () {
      		final interpolator = Interpolator(format);
			final subs_part = {};

      		expect(interpolator(subs_part) ,equals(result));
    	});

		test("Get interpolation List", () {
      		final interpolator = Interpolator(format);
			final subs_part = {};

      		expect(interpolator(subs_part) ,equals(result));
    	});
 	});

	group('Syntax Error Check:', () {

		test("Exception handling on format String with "
			 "unmatched '{'", () {
			const formatUnclosed = "";
      		final interpolator = Interpolator(formatUnclosed);
			final subs_full = {};
			final unclosedException = FormatException();

      		expect(interpolator(subs_full) ,throwsA(unclosedException));
    	});

		test("Exception handling on format String with null "
			 "match and no placeholder provided", () {
			const format = "";
      		final interpolator = Interpolator(format);
			final subs_part = {};
			final nullmatchException = FormatException();

      		expect(interpolator(subs_part) ,throwsA(nullmatchException));
    	});
 	});
}