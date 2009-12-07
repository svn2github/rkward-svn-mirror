/* ------- This file generated by php2js from PHP code. --------
Please check this file by hand, and remove this notice, afterwards.
Messages:

---------------------------- */

// globals
var options;
var undefined;

include ('plot_dist_common.js');

function getParameters () {
	options['loc'] = getValue ("loc");
	options['scale'] = getValue ("scale");
	getContRangeParameters ();

	if (options['is_density']) {
		options['fun'] = "dcauchy";
	} else {
		options['fun'] = "pcauchy";
	}
}

function doHeader () {
	echo ('rk.header ("Cauchy ' + options['label'] + ' function", list ("Number of Observations", "' + options['n'] + '", "Lower quantile", "' + options['min'] + '", "Upper quantile", "' + options['max'] + '", "Location", "' + options['loc'] + '", "Scale", "' + options['scale'] + '"' + options['log_label'] + options['tail_label'] + ', "Function", "' + options['fun'] + '"));' + "\n");
}

function doFunCall () {
	echo (options['fun'] + '(x, location=' + options['loc'] + ', scale=' + options['scale'] + options['log_option'] + options['tail_option'] + ')');
}

