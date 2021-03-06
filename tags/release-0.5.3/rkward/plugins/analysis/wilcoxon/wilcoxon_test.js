// globals
var y;

function preprocess () {
	y = getValue ("y");
	if (y != "") y = ", " + y;

	echo ('names = rk.get.description (' + getValue ("x") + y + ')\n');
}

function calculate () {
	var exact_setting = getValue ("exact");
	var exact_opt = "";
	if (exact_setting == "yes") {
		exact_opt = ", exact=TRUE";
	} else if (exact_setting == "no") {
		exact_opt = ", exact=FALSE";
	}
	var paired_opt = "";
	if (y != "") paired_opt = ", paired = " + getValue ("paired");
	var conflevel = "";
	var conflevel_opt = "";
	if (getValue ("confint") == "TRUE") {
		if ((conflevel = getValue("conflevel")) != "0.95") conflevel_opt = ", conf.level=" + conflevel;
	}

	echo ('result <- wilcox.test (' + getValue ("x") + y + ', alternative = "' + getValue ("alternative") + '", mu = ' + getValue ("mu") + paired_opt + exact_opt + ', correct = ' + getValue ("correct") + ', conf.int = ' + getValue ("confint") + conflevel_opt + ')\n');
	echo ('\n');
}

function printout () {
	echo ('rk.header (result$method,\n');
	echo ('	parameters=list ("Comparing", paste (names, collapse=" against "),\n');
	echo ('	"H1", rk.describe.alternative (result),\n');
	echo ('	"Continuity correction in normal approximation for p-value", "' + getValue ("correct") + '",\n');
	echo ('	"Compute exact p-value", "' + getValue ("exact") + '", "Paired test", "' + getValue ("paired") + '",\n');
	echo ('	"mu", "' + getValue ("mu") + '"))\n');
	echo ('\n');
	echo ('rk.results (list (\n');
	echo ('	\'Variable Names\'=names,\n');
	echo ('	\'statistic\'=result$statistic,\n');
	echo ('	\'Location Shift\'=result$null.value,\n');
	echo ('	\'Hypothesis\'=result$alternative,\n');
	echo ('	p=result$p.value');
	if (getValue ("confint") == "TRUE") {
		echo (',\n');
		echo ('	\'confidence interval percent\'=(100 * attr(result$conf.int, "conf.level")),\n');
		echo ('	\'confidence interval of difference\'=result$conf.int,\n');
		echo ('	\'Difference in Location\' = result$estimate');
	}
	echo ('))\n');
}

