<?
function preprocess () {
?>
require(car)
<?
}

function calculate () {
}

function printout () {
	doPrintout (true);
}

function preview () {
	preprocess ();
	calculate ();
	doPrintout (false);
}

function doPrintout ($final) {
	$vars = str_replace ("\n", ",", trim (getRK_val ("x"))) ;
?>
data <- data.frame (<? echo ($vars); ?>)

<? 	if ($final) { ?>
rk.header ("Scatterplot Matrix", parameters=list ("Diagonal Panels", "<? getRK("diag") ?>", "Plot points", "<? getRK ("plot_points"); ?>", "Smooth", "<? getRK ("smooth"); ?>", "Ellipses", "<? getRK ("ellipse"); ?> at 0.5 and 0.9 levels."))

rk.graph.on ()
<?	} ?>
try (scatterplot.matrix(data, diagonal="<? getRK("diag") ?>", plot.points=<? getRK ("plot_points"); ?>, smooth=<? getRK ("smooth"); ?>, ellipse=<? getRK ("ellipse"); ?>))
<?	if ($final) { ?>
rk.graph.off ()
<?	}
}
?>
