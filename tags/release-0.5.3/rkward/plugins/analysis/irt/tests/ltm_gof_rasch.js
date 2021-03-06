function preprocess () {
	// we'll need the ltm package, so in case it's not loaded...
	echo ('require(ltm)\n');
}

function calculate () {
	// let's read all values into php variables for the sake of readable code
	var spin_samples    = getValue("spin_samples");

	echo ('GoFRasch.res <- GoF.rasch(' + getValue("x"));
		// check if any advanced control options must be inserted
		if (spin_samples != 49) echo(", B="+spin_samples);
	echo (')\n');
}

function printout () {
	echo ('rk.header ("Goodness of Fit for Rasch Models (' + getValue("x") + ')")\n');
	echo ('rk.print (GoFRasch.res)\n');
}
