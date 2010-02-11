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
	echo ('llim <- ' + getValue ("llim") + '; ulim <- ' + getValue ("ulim") + ';\n');
}

function doExpVar () {
	echo ('avg.exp <- (llim+ulim)/2;\n');
	echo ('avg.var <- ((ulim-llim)^2/12)/' + nAvg + ';\n');
}

function doGenerateData () {
	echo ('data <- matrix(runif(n=' + nAvg*nDist + ', min=llim, max=ulim), nrow=' + nAvg + ');\n');
}
