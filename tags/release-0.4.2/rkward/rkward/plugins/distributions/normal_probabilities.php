<?
function preprocess () {
}

function calculate () {
	global $q;
	$q = "c (" . preg_replace ("/[, ]+/", ", ", getRK_val ("q")) . ")";
?>
rk.temp = (pnorm (q = <? echo ($q); ?>, mean = <? getRK ("mean"); ?>, sd = <? getRK ("sd"); ?>, <? getRK ("tail"); ?>, <? getRK ("logp"); ?>))
<?
}

function printout () {
	global $q;
?>
rk.header ("Normal probability", list ("Vector of quantiles", "<? echo ($q); ?>", "mu", "<? getRK ("mean"); ?>", "sigma", "<? getRK ("sd"); ?>", "Tail", "<? getRK ("tail"); ?>", "Probabilities p are given as", "<? getRK ("logp"); ?>"));
cat ("<h3>Normal probabilities:  ", rk.temp, "</h3>")
<?
}

function cleanup () {
?>
rm (rk.temp)
<?
}
?>
