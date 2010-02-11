/* ------- This file generated by php2js from PHP code. --------
Please check this file by hand, and remove this notice, afterwards.
Messages:

---------------------------- */

// globals
var nAvg;
var nDist;
var undefined;

include ('plot_clt_common.js');

function doParameters () {
	echo ('mean <- ' + getValue ("mean") + ';\n');
}

function doExpVar () {
	echo ('avg.exp <- mean;\n');
	echo ('avg.var <- (mean)/' + nAvg + ';\n');
}

function doGenerateData () {
	echo ('data <- matrix(rpois(n=' + nAvg*nDist + ', lambda=mean), nrow=' + nAvg + ');\n');
}
