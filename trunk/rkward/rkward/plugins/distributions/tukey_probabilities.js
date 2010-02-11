/* ------- This file generated by php2js from PHP code. --------
Please check this file by hand, and remove this notice, afterwards.
Messages:

---------------------------- */

// globals
var q;
var undefined;


function calculate () {
	q = "c (" + preg_replace ("/[, ]+/", ", ", getValue ("q")) + ")";

	echo ('result <- (ptukey (q = ' + q + ', nmeans = ' + getValue ("nmeans") + ', df = ' + getValue ("df") + ', nranges = ' + getValue ("nranges") + ', ' + getValue ("tail") + ', ' + getValue ("logp") + '))\n');
}

function printout () {
	echo ('rk.header ("Studentized Range probability", list ("Vector of quantiles", "' + q + '", "Sample size for range", "' + getValue ("nmeans") + '", "Degrees of freedom for s", "' + getValue ("df") + '", "Number of groups whose maximum range is considered", "' + getValue ("nranges") + '", "Tail", "' + getValue ("tail") + '", "Probabilities p are given as", "' + getValue ("logp") + '"));\n');
	echo ('rk.results (result, titles="Studentized Range probabilities")\n');
}
