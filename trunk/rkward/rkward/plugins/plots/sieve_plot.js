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
	calculate ();
	doPrintout (false);
}

function doPrintout (full) {
	var vars = "";
	var shade = "";
	var sievetype = "";
	var plotpre = "";
	var plotpost = "";
	vars = getValue ("x");
	shade = getValue ("shade");
	sievetype = getValue ("sievetype");
	{
		echo ('x <- ' + vars);
	}
	echo ('\n');
	if (full) {
		echo ('rk.header ("Extended Sieve Plot", parameters=list ("Variable", rk.get.description (' + vars + '), "shade", ' + shade + '))\n');
		echo ('\n');
		echo ('rk.graph.on ()\n');
	}

	echo ('try ({\n');
	if (!empty (plotpre)) printIndented ("\t", plotpre);


	echo ('	sieve(x, shade = ' + shade + ', sievetype = "' + sievetype + '" ' + getValue ("plotoptions.code.printout") + ')\n');
	if (!empty (plotpost)) printIndented ("\t", plotpost);
	echo ('})\n');
	if (full) {
		echo ('rk.graph.off ()\n');
	}
}
