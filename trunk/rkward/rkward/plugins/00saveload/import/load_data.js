/* ------- This file generated by php2js from PHP code. --------
Please check this file by hand, and remove this notice, afterwards.
Messages:
Warning: please check correctness of conversion of '=>' in arrays by hand
Warning: please check correctness of conversion of '=>' in arrays by hand

---------------------------- */

// globals
var envir;
var undefined;


function calculate () {
	var other_env = "";
	if (getValue ("other_env")) {
		other_env = true;
		envir = getValue ("envir");
	} else {
		envir = "globalenv()";
	}

	if (other_env) {
		echo ('assign ("' + envir + ', new.env (parent=globalenv()), envir=globalenv())\n');
	}
	echo ('load (file="' + getValue("file") + '", envir=' + envir + ')\n');
}

function printout () {
	makeHeaderCode ("Load data", new Array("File" ,  getValue ("file"), "Import to environment" ,  envir));
}

