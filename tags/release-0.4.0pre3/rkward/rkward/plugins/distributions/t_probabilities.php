<?
function preprocess () {
}

function calculate () {
	global $q;
	$q = "c (" . preg_replace ("/[, ]+/", ", ", getRK_val ("q")) . ")";
?>
rk.temp = (pt (q = <? echo ($q); ?>, df = <? getRK ("df"); ?>, <? getRK ("tail"); ?>))
<?
}

function printout () {
	global $q;
?>
rk.header ("t probability", list ("Variable value", "<? echo ($q); ?>", "Degrees of Freedom", "<? getRK ("df"); ?>", "Tail", "<? getRK ("tail"); ?>"));
cat ("<h3>t probability:  ", rk.temp, "</h3>")
<?
}

function cleanup () {
?>
rm (rk.temp)
<?
}
?>
