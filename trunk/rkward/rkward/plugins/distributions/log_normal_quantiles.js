/* ------- This file generated by php2js from PHP code. --------
Please check this file by hand, and remove this notice, afterwards.
Messages:

---------------------------- */

// globals
var p;
var undefined;


function calculate () {
	p = "c (" + preg_replace ("/[, ]+/", ", ", getValue ("p")) + ")";

	echo ('result <- (qlnorm (p = ' + p + ', meanlog = ' + getValue ("meanlog") + ', sdlog = ' + getValue ("sdlog") + ', ' + getValue ("tail") + ', ' + getValue ("logp") + '))\n');
}

function printout () {
	echo ('rk.header ("Log Normal quantile", list ("Vector of probabilities", "' + p + '", "meanlog", "' + getValue ("meanlog") + '", "sdlog", "' + getValue ("sdlog") + '", "Tail", "' + getValue ("tail") + '", "Probabilities p are given as", "' + getValue ("logp") + '"))\n');
	echo ('rk.results (result, titles="Log Normal quantiles")\n');
}
