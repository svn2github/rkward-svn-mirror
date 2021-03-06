function preprocess () {
	echo ('require(exactRankTests)\n');
	echo ('\n');
	echo ('names <- rk.get.description (' + getValue ("x") + ', ' + getValue ("y") + ')\n');
}

function calculate () {
	var exact_opt = "";
	var exact_setting = getValue ("exact");
	if (exact_setting == "yes") {
		exact_opt = ", exact=TRUE";
	} else if (exact_setting == "no") {
		exact_opt = ", exact=FALSE";
	}

	var conflevel_opt = "";
	if (getValue ("confint") == "TRUE") {
		var conflevel = getValue("conflevel");
		if (conflevel != "0.95") conflevel_opt = ", conf.level=" + conflevel;
	}

	echo ('result <- ansari.exact (' + getValue ("x") + ', ' + getValue ("y") + ', alternative = "' + getValue ("alternative") + '"' + exact_opt + ', conf.int = ' + getValue ("confint") + conflevel_opt + ')\n');
	echo ('\n');
}

function printout () {
	echo ('rk.header (result$method,\n');
	echo ('	parameters=list ("Comparing", paste (names[1], "against", names[2]),\n');
	echo ('	\'H1\', rk.describe.alternative (result),\n');
	echo ('	"Compute exact p-value", "' + getValue ("exact") + '"');
	if (getValue ("confint")== "TRUE") {
		echo (',\n');
		echo ('	"Confidence Level", "' + getValue ("conflevel") + '" ');
	}
	echo ('))\n');
	echo ('\n');
	echo ('rk.results (list (\n');
	echo ('	\'Variable Names\'=names,\n');
	echo ('	\'statistic\'=result$statistic,\n');
	echo ('	\'null.value\'=result$null.value,\n');
	echo ('	p=result$p.value');
	if (getValue ("confint")== "TRUE") {
		echo (',\n');
		echo ('	\'confidence interval percent\'=(100 * attr(result$conf.int, "conf.level")),\n');
		echo ('	\'confidence interval of difference\'=result$conf.int,\n');
		echo ('	\'estimate of the ratio of scales\'=result$estimate');
	}
	echo ('))\n');
}

