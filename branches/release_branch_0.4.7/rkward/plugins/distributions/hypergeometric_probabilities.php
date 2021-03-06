<?
function preprocess () {
}

function calculate () {
	global $q;
	$q = "c (" . preg_replace ("/[, ]+/", ", ", getRK_val ("q")) . ")";
?>
result <- (phyper (q = <? echo ($q); ?>, m = <? getRK ("m"); ?>, n = <? getRK ("n"); ?>, k = <? getRK ("k"); ?>, <? getRK ("tail"); ?>, <? getRK("logp"); ?>))
<?
}

function printout () {
	global $q;
?>
rk.header ("Hypergeometric probability", list ("Vector of quantiles", "<? echo ($q); ?>", "Number of white balls in the urn", "<? getRK ("m"); ?>", "Number of black balls in the urn", "<? getRK ("n"); ?>", "Number of balls drawn from the urn", "<? getRK ("k"); ?>", "Tail", "<? getRK ("tail"); ?>", "Probabilities p are given as", "<? getRK ("logp"); ?>"))
rk.results (result, titles="Hypergeometric probabilities")
<?
}
?>
