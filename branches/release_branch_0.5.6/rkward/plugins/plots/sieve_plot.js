/* ------- This file generated by php2js from PHP code. --------
Please check this file by hand, and remove this notice, afterwards.
Messages:
Note: Control statement without braces. This is bad style.
Note: Control statement without braces. This is bad style.

---------------------------- */

// globals
var undefined;

function preprocess () {
	echo ('require(vcd)\n');
}


function printout () {
	doPrintout (true);
}

function preview () {
	preprocess ();
	doPrintout (false);
}

function doPrintout (full) {
	var vars = getValue ("x");
	var shade = getValue ("shade");
	var sievetype = getValue ("sievetype");
	{
		echo ('x <- ' + vars);
	}
	echo ('\n');
	if (full) {
		echo ('rk.header ("Extended Sieve Plot", parameters=list ("Variable", rk.get.description (' + vars + '), "shade", ' + shade + '))\n');
		echo ('\n');
		echo ('rk.graph.on ()\n');
	}

	var plotpre = getValue ("plotoptions.code.preprocess");
	var plotpost = getValue ("plotoptions.code.calculate");

	echo ('try ({\n');
	if (plotpre.length > 0) printIndented ("\t", plotpre);


	echo ('	sieve(x, shade = ' + shade + ', sievetype = "' + sievetype + '" ' + getValue ("plotoptions.code.printout") + ')\n');
	if (plotpost.length > 0) printIndented ("\t", plotpost);
	echo ('})\n');
	if (full) {
		echo ('rk.graph.off ()\n');
	}
}
