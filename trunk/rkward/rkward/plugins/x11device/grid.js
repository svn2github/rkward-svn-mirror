/* ------- This file generated by php2js from PHP code. --------
Please check this file by hand, and remove this notice, afterwards.
Messages:
Warning: '$' inside '"'-delimited string. This might be a variable name. Please check by hand!
Note: Control statement without braces. This is bad style.
Note: Control statement without braces. This is bad style.
Note: Control statement without braces. This is bad style.
Note: Control statement without braces. This is bad style.

---------------------------- */

// globals
var undefined;

function preprocess () {
	if (getValue ("is_embed")) {
		echo ('dev.set (' + getValue ("devnum") + ')\n');
	}
}


function printout () {
	var nx = "";
	var gridoptions = "";
	var ny = "";
	var lty = "";
	nx = getValue ("nx");
	if (nx == "other") gridoptions = 'nx=' + getValue ("nx_cells");
	else gridoptions = 'nx=' + nx;

	ny = getValue ("ny");
	if (ny == "other") gridoptions += ', ny=' + getValue ("ny_cells");
	else gridoptions += ', ny=' + ny;

	gridoptions += getValue ("col.code.printout");

	if (getValue("custlwd")) gridoptions += ', lwd=' + round(getValue ("lwd"),1);

	lty = getValue("linetype");
	if (lty != "") gridoptions += ", lty=\"{$lty}\"";

	if (!getValue("equilogs")) gridoptions += ', equilogs=FALSE';

	echo ('grid(' + gridoptions + ');\n');
}