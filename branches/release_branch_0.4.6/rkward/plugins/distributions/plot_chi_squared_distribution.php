<?
	function preprocess () {
	}

	function calculate () {
	}

	function printout () {
	doPrintout (true);
}

function cleanup () {
}

function preview () {
	preprocess ();
	calculate ();
	doPrintout (false);
	cleanup ();
}

function doPrintout ($final) {

	$fun = getRK_val ("function");
	$log_option = "";
	if ($fun == "dchisq") {
		$label = "density";
		$lower_tag = "";
		$tail_tag = "";
		if (getRK_val ("log")) $log_option = ", log=TRUE";
	} else {
		$label = "distribution";
		if (getRK_val("lower") == "1") {
			$lower_tag = ", lower.tail = TRUE";
			$tail_tag = ", \"Tail\",\"Lower\"";
		} else {
			$lower_tag = ", lower.tail = FALSE";
			$tail_tag = ", \"Tail\",\"Upper\"";
		}
		if (getRK_val ("log")) $log_option = ", log.p=TRUE";
	}
	if (getRK_val ("log") == "1") $log_label="logarithmic";
	else $log_label="normal";
	$n = getRK_val ("n");
	$min = getRK_val ("min");
	$max = getRK_val ("max");
  $ncp = getRK_val ("ncp");
	$df = getRK_val ("df");

	if ($final) { ?>
rk.header ("Chisquare <? echo ($label); ?> function", list ("Number of Observations", "<? echo ($n); ?>", "Lower quantile", "<? echo ($min); ?>", "Upper quantile", "<? echo ($max); ?>", "Degrees of freedom", "<? echo ($df); ?>", "Non-centrality", "<? echo ($ncp); ?>", "Scaling", "<? echo ($log_label); ?>"<? echo ($tail_tag); ?>, "Function", "<? echo ($fun); ?>"));

rk.graph.on ()
<? }
?>
try (curve (<? echo ($fun); ?> (x, df = <? echo ($df); ?>, ncp = <? echo ($ncp); ?><? echo ($log_option) ?><? echo ($lower_tag); ?>), from=<? echo ($min); ?>, to=<? echo ($max); ?>, n=<? echo ($n); ?><? getRK ("plotoptions.code.printout"); ?>))

<?	if ($final) { ?>
rk.graph.off ()
<? }
}
?>
