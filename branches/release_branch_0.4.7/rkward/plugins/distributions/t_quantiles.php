<?
function preprocess () {
}

function calculate () {
	global $p;
	$p = "c (" . preg_replace ("/[, ]+/", ", ", getRK_val ("p")) . ")";
?>
result <- (qt (p = <? echo ($p); ?>, df = <? getRK ("df"); ?>, ncp = <? getRK ("ncp"); ?>, <? getRK ("tail"); ?>))
<?
}

function printout () {
	global $p;
?>
rk.header ("t quantile", list ("Vector of probabilities", "<? echo ($p); ?>", "Degrees of freedom", "<? getRK ("df"); ?>", "non-centrality parameter", "<? getRK ("ncp"); ?>", "Tail", "<? getRK ("tail"); ?>"));
rk.results (result, titles="t quantiles")
<?
}
?>
