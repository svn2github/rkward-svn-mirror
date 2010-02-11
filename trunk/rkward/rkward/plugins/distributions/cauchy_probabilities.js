/* ------- This file generated by php2js from PHP code. --------
Please check this file by hand, and remove this notice, afterwards.
Messages:

---------------------------- */

// globals
var q;
var undefined;


function calculate () {
	q = "c (" + preg_replace ("/[, ]+/", ", ", getValue ("q")) + ")";

	echo ('result <- (pcauchy (q = ' + q + ', location = ' + getValue ("location") + ', scale = ' + getValue ("scale") + ', ' + getValue ("tail") + ', ' + getValue("logp") + '))\n');
}

function printout () {
	echo ('rk.header ("Cauchy probabilities", list ("Vector of quantiles", "' + q + '", "Location", "' + getValue ("location") + '", "Scale", "' + getValue ("scale") + '", "Tail", "' + getValue ("tail") + '", "Probabilities p are given as", "' + getValue ("logp") + '"))\n');
	echo ('rk.results (result, titles="Cauchy probabilities")\n');
}
