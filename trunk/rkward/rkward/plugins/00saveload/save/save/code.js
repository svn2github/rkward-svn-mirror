/* ------- This file generated by php2js from PHP code. --------
Please check this file by hand, and remove this notice, afterwards.
Messages:
Warning: please check correctness of conversion of '=>' in arrays by hand
Warning: please check correctness of conversion of '=>' in arrays by hand

---------------------------- */

// globals
var vars;
var undefined;


function calculate () {
	vars = str_replace ("\n", ",", trim (getValue ("data")));

	echo ('save (' + vars + ', file="' + getValue("file") + '", ascii=' + getValue("ascii") + ', compress=' + getValue("compress") + ')\n');
}

function printout () {
	makeHeaderCode ("Save R objects", new Array("File" ,  getValue ("file"), "Variables" ,  vars));
}

