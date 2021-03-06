<?
function preprocess () {
  // we'll need the ltm package, so in case it's not loaded...
?>
  require(ltm)
<?}

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
        // this function takes care of generating the code for the printout() section. If $final is set to true,
        // it generates the full code, including headers. If $final is set to false, only the essentials will
        // be generated.

  // let's read all values into php variables for the sake of readable code
  $plot_type        = getRK_val("plot_type");
  $plot_type_item   = getRK_val("plot_type_item");
  $inp_items        = getRK_val("inp_items");
  $spin_from        = getRK_val("spin_from");
  $spin_to          = getRK_val("spin_to");
  $annotation       = getRK_val("annotation");
  $spin_categ       = getRK_val("spin_categ");

  // in case there are generic plot options defined:
  $plot_options     = getRK_val("plotoptions.code.printout");
  $plot_ops_main    = getRK_val("plotoptions.main");
  $plot_ops_type    = getRK_val("plotoptions.pointtype");
  $plot_ops_xlab    = getRK_val("plotoptions.xlab");
  $plot_ops_ylab    = getRK_val("plotoptions.ylab");

  ///////////////////////////////////
  // check for selected options
  $options = array() ;
  if($plot_type == "items" && $plot_type_item == "ICC")
    $options[] = "type=\"ICC\"" ;
  if($plot_type == "items" && $plot_type_item == "IIC")
    $options[] = "type=\"IIC\"" ;
  if($plot_type == "items" && $plot_type_item == "OCCu")
    $options[] = "type=\"OCCu\"" ;
  if($plot_type == "items" && $plot_type_item == "OCCl")
    $options[] = "type=\"OCCl\"" ;
    // plot all items?
    if($plot_type == "items" && $inp_items) {
      // for user convenience, we replace "-", ";" and space, split all input into an array
      // and join it again, separated by commas:
      $inp_items = str_replace("-",":",$inp_items);
      $arr_items = split('[ ;]', $inp_items);
      $options[] = "items=c(".join(",", $arr_items).")"; }
    // plot all categories?
    if($plot_type == "items" && $spin_categ != "0")
      $options[] = "category=$spin_categ" ;

  // for the test information curve, items must be set to "0":
  if($plot_type == "TIC")
    $options[] = "type=\"IIC\", items=0" ;
  // there is no option for standard error curves yet, so we need some extra magic
  // (see the "SEC" section in the plotting function below as well!)
  if($plot_type == "SEC")
    $options[] = "type=\"IIC\", items=0, plot=FALSE" ;

  // more advanced options
  // user defined zrange? we'll round it to two digits
  if($spin_from != "-3.8" || $spin_to != "3.8")
    $options[] = "zrange=c(".round($spin_from,2).",".round($spin_to,2).")" ;
  // annotate lines and show legend?
  if($annotation == "legend")
    $options[] = "legend=TRUE" ;
  if($annotation == "plain")
    $options[] = "annot=FALSE" ;

        if ($final) { ?>
rk.header("Graded response model plot")

rk.graph.on()
<?       }
        // only the following section will be generated for $final==false

        // first we'll check wheter standard error curves should be plotted,
        // because it takes two steps to draw them:
       if ($plot_type == "SEC") { ?>
# two steps are needed to plot standard error curves
# first some values are generated...
res <- try(plot(<? getRK("x");
              if($options) echo(", ".join(", ", $options));
          ?>))

# ... and then they're used to plot the curves:
try(plot(res[,"z"], 1/sqrt(res[,"test.info"]), lwd=2<?
              // we give come defaults, but they can be changed via the embedded plot options:
              if(!$plot_ops_type) echo(", type=\"l\"");
              if(!$plot_ops_xlab) echo(", xlab=\"Ability\"");
              if(!$plot_ops_ylab) echo(", ylab=\"Standard Error\"");
              if(!$plot_ops_main) echo(", main=\"Stadard Error of Measurement\"");
              if($plot_options) echo($plot_options);
  ?>))
<? }
        // and this will be plotted if anything else than stadard error curves are chosen:
        else { ?>
try(plot(<? getRK("x");
              if($options) echo(", ".join(", ", $options));
              if($plot_options) echo($plot_options);
          ?>))
<? }
        if ($final) { ?>
rk.graph.off()
<? }
}
?>