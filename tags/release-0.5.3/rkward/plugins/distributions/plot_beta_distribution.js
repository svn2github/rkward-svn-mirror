// globals
var options;

include ('plot_dist_common.js');

function getParameters () {
	options['a'] = getValue ("a");
	options['b'] = getValue ("b");
	options['ncp'] = getValue ("ncp");
	getContRangeParameters ();

	if (options['is_density']) {
		options['fun'] = "dbeta";
	} else {
		options['fun'] = "pbeta";
	}
}

function doHeader () {
	echo ('rk.header ("Beta ' + options['label'] + ' function", list ("Number of Observations", "' + options['n'] + '", "Lower quantile", "' + options['min'] + '", "Upper quantile", "' + options['max'] + '", "Shape1", "' + options['a'] + '", "Shape2", "' + options['b'] + '", "Non-centrality parameter", "' + options['ncp'] + '"' + options['log_label'] + options['tail_label'] + ', "Function", "' + options['fun'] + '"));' + "\n");
}

function doFunCall () {
	echo (options['fun'] + '(x, shape1=' + options['a'] + ', shape2=' + options['b'] + ', ncp=' + options['ncp'] + options['log_option'] + options['tail_option'] + ')');
}

