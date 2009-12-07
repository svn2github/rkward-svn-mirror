/* ------- This file generated by php2js from PHP code. --------
Please check this file by hand, and remove this notice, afterwards.
Messages:

---------------------------- */

// globals
var q;
var undefined;


function calculate () {
	q = "c (" + preg_replace ("/[, ]+/", ", ", getValue ("q")) + ")";


	echo ('result <- (pexp (q = ' + q + ', rate = ' + getValue ("rate") + ', ' + getValue ("tail") + ', ' + getValue("logp") + '))\n');
}

function printout () {
	echo ('rk.header ("Exponential probabilities", list ("Vector of quantiles", "' + q + '", "Rate", "' + getValue ("rate") + '", "Tail", "' + getValue ("tail") + '", "Probabilities p are given as", "' + getValue ("logp") + '"))\n');
	echo ('rk.results (result, titles="Exponential probabilities")\n');
}

