/* ------- This file generated by php2js from PHP code. --------
Please check this file by hand, and remove this notice, afterwards.
Messages:
Warning: multiline comments are not handled! Check by hand!
Note: Control statement without braces. This is bad style.
Note: Control statement without braces. This is bad style.

---------------------------- */

// globals
var undefined;

/* NOTE: This file is currently not used by the color_chooser plugin+ It remains here, as it illustrates the functionality better than the hack that is actually in effect+

*/


function printout () {
	var col = "";
	col = getValue ("color");
	if (empty (col)) col = getValue ("default_color");
	if (!empty (col)) col = getValue ("argument") + "\"" + col + "\"";

	echo (col);
}