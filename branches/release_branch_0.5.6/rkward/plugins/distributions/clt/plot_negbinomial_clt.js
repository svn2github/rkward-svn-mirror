// globals
var paramTag;
var nAvg;
var nDist;

include ('plot_clt_common.js');

function doParameters () {
	if ( getValue ("param") == "pprob") {
		paramTag = ", prob=prob";
		echo ('size <- ' + getValue ("size_trial") + '; prob <- ' + getValue ("prob") + ';\n');
	} else {
		paramTag = ", mu=mu";
		echo ('size <- ' + getValue ("size_disp") + '; mu <- ' + getValue ("mu") + '; prob <- size/(size+mu);\n');
	}
}

function doExpVar () {
	echo ('avg.exp <- size*(1-prob)/prob;\n');
	echo ('avg.var <- (size*(1-prob)/prob^2)/' + nAvg + ';\n');
}

function doGenerateData () {
	echo ('data <- matrix(rnbinom(n=' + nAvg*nDist + ', size=size' + paramTag + '), nrow=' + nAvg + ');\n');
}

