function preview () {
	doPrintout (false);
}

function printout () {
	doPrintout (true);
}

function doPrintout (full) {
	var grouped_mode = getValue ("data_mode_grouped.numeric");
	var dodged = grouped_mode && getValue ("dodges");
	var names_mode = getValue ("names_mode");
	var mean = getValue ("mean");
	var pch_mean = getValue ("pch_mean");
	var sd = getValue ("sd");
	var pch_sd_high = getValue ("pch_sd_high");
	var pch_sd_low = getValue ("pch_sd_low");
	var horizontal = getValue ("orientation") == "TRUE";
	var plot_adds = getValue ("plotoptions.code.calculate"); //add grid and alike
	var boxwex = getValue ("boxwex");
	if (!dodged && (Number (boxwex) != .8)) boxwex = ", boxwex=" + boxwex;
	else boxwex = "";
	var positions = "";

	if (grouped_mode) {
		var groups_a = getValue ("groups").split ("\n");
		var n_dodges = getValue ("dodges");
		var dodges = groups_a.slice (0, n_dodges);
		var groups = groups_a.slice (n_dodges);
		echo ('groups <- rk.list (' + dodges.concat (groups).join (", ") + ')\n');
		echo ('data_list <- split (' + getValue ("outcome") + ', groups)		#split sample by grouping variables\n');
		if (dodged) {
			echo ('# adjust width and position of boxes to achieve dodging\n');
			echo ('dodge_size <- nlevels (interaction (' + dodges.join (", ") + '))\n');
			echo ('box_width <- ' + getValue ("boxwex") + ' / dodge_size\n');
			boxwex = ', boxwex=box_width';
			echo ('box_positions <- (rep (1:(length (data_list) / dodge_size), each=dodge_size) + (1:dodge_size)*(box_width))\n')
			positions = ', at=box_positions, xlim=c(min(box_positions)-box_width, max(box_positions)+box_width)';
		}
	} else {
		echo ('data_list <- rk.list (' + getValue ("x").split ("\n").join (", ") + ')		#convert single sample variables to list\n');
	}
	if (names_mode == "rexp") {
		echo ("names(data_list) <- " + getValue ("names_exp") + "\n");
	} else if (names_mode == "custom") {
		echo ("names(data_list) <- c (\"" + str_replace (";", "\", \"", trim (getValue ("names_custom"))) + "\")\n");
	}

	if (full) {
		if (grouped_mode) {
			echo ('rk.header ("Boxplot", list ("Outcome variable", rk.get.description (' + getValue ("outcome") + '), "Grouping variable(s)", paste (names (groups), collapse=", ")))\n');
		} else {
			echo ('rk.header ("Boxplot", list ("Variable(s)", paste (names (data_list), collapse=", ")))\n');
		}
		echo ('rk.graph.on()\n');
	}
	echo ('try (boxplot (data_list' + boxwex + positions + ', notch = ' + getValue ("notch") + ', outline = ' + getValue("outline") + ', horizontal = ' + getValue("orientation") + getValue ("plotoptions.code.printout") + ')) #actual boxplot function\n');
	if (mean == "TRUE") {
		if (horizontal) {
			echo ('	try (points(1:length(data_list) ~ sapply(data_list,mean,na.rm = TRUE),pch=' + pch_mean + ', cex = ' + getValue ("cex_sd_mean") + getValue ("sd_mean_color.code.printout") + ')) #calculates the mean for all data and adds a point at the corresponding position\n');
		} else {
			echo ('	try (points(sapply(data_list,mean,na.rm = TRUE),pch=' + pch_mean + ', cex = ' + getValue ("cex_sd_mean") + getValue ("sd_mean_color.code.printout") + ')) #calculates the mean for all data and adds a point at the corresponding position\n');
		}
	}

	if (sd == "TRUE") {
		echo ('	sd_low <- (sapply(data_list,mean,na.rm = TRUE)) - (sapply(data_list,sd,na.rm = TRUE))\n');
		echo ('	sd_high <- (sapply(data_list,mean,na.rm = TRUE)) + (sapply(data_list,sd,na.rm = TRUE))\n');
		if (horizontal) {
			echo ('	points(1:length(data_list) ~ sd_low,pch=' + pch_sd_low + ', cex = ' + getValue ("cex_sd_mean") + getValue ("sd_mean_color.code.printout") + ')\n');
			echo ('	points(1:length(data_list) ~ sd_high,pch=' + pch_sd_high + ', cex = ' + getValue ("cex_sd_mean") + getValue ("sd_mean_color.code.printout") + ')\n');
		} else {
			echo ('	points(sd_low,pch=' + pch_sd_low + ', cex = ' + getValue ("cex_sd_mean") + getValue ("sd_mean_color.code.printout") + ')\n');
			echo ('	points(sd_high,pch=' + pch_sd_high + ', cex = ' + getValue ("cex_sd_mean") + getValue ("sd_mean_color.code.printout") + ')\n');
		}
	}

	if (plot_adds.length > 0) {
		echo ('\n');
		// print the grid() related code
		printIndented ("\t", plot_adds);
	}

	if (full) {
		echo ('rk.graph.off ()\n');
	}
}

