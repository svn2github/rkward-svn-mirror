<?
function preprocess () {
}

function calculate () {
$vars = str_replace ("\n", "','", trim (getRK_val ("data"))) ;
?>
package.skeleton(name="<? getRK("name"); ?>", list=c('<? echo ($vars); ?>'), path="<? getRK("path"); ?>", force= <? getRK("force"); ?>)
<?
}

function printout () {
	makeHeaderCode ("Create package skeleton", array ("Name" => getRK_val ("name"), "Directory" => getRK_val ("path")));
}
?>
