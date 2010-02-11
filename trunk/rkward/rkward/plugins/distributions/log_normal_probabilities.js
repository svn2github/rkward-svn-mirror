/* ------- This file generated by php2js from PHP code. --------
Please check this file by hand, and remove this notice, afterwards.
Messages:

---------------------------- */

// globals
var q;
var undefined;


function calculate () {
	q = "c (" + preg_replace ("/[, ]+/", ", ", getValue ("q")) + ")";

	echo ('result <- (plnorm (q = ' + q + ', meanlog = ' + getValue ("meanlog") + ', sdlog = ' + getValue ("sdlog") + ', ' + getValue ("tail") + ', ' + getValue ("logp") + '))\n');
}

function printout () {
	echo ('rk.header ("Log Normal probability", list ("Vector of quantiles", "' + q + '", "meanlog", "' + getValue ("meanlog") + '", "sdlog", "' + getValue ("sdlog") + '", "Tail", "' + getValue ("tail") + '", "Probabilities p are given as", "' + getValue ("logp") + '"))\n');
	echo ('rk.results (result, titles="Log Normal probabilities")\n');
}
