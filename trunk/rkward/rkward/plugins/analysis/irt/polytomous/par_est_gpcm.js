/* ------- This file generated by php2js from PHP code. --------
Please check this file by hand, and remove this notice, afterwards.
Messages:
Warning: '$' inside '"'-delimited string. This might be a variable name. Please check by hand!
Note: Control statement without braces. This is bad style.
Note: Control statement without braces. This is bad style.
Note: Control statement without braces. This is bad style.
Note: Control statement without braces. This is bad style.
Note: Control statement without braces. This is bad style.
Note: Control statement without braces. This is bad style.

---------------------------- */

// globals
var undefined;

function preprocess () {
	// we'll need the ltm package, so in case it's not loaded...

	echo ('  require(ltm)\n');
}

function calculate () {
	var data = "";
	var chk_select = "";
	var inp_items = "";
	var constraint = "";
	var startval = "";
	var startval_lst = "";
	var naaction = "";
	var irtparam = "";
	var optimeth = "";
	var verbose = "";
	var ghk_gpcm = "";
	var iterqn_gpcm = "";
	var optimizer = "";
	var numrderiv = "";
	var epshess = "";
	var control = "";
	// let's read all values into php variables for the sake of readable code
	data         = getValue("x");
	chk_select   = getValue("chk_select");
	inp_items    = getValue("inp_items");
	// reformat $inp_items
	if (inp_items)
		inp_items       = str_replace("\n", ", ", preg_replace("/(.+)\[\[(.+)\]\]/", "$2", inp_items));

	constraint   = getValue("constraint");
	startval     = getValue("startval");
	startval_lst = getValue("startval_lst");
	naaction     = getValue("naaction");
	irtparam     = getValue("irtparam");
	optimeth     = getValue("optimeth");
	verbose      = getValue("verbose");
	// these are gpcm specific
	ghk_gpcm     = getValue("ghk_gpcm");
	iterqn_gpcm  = getValue("iterqn_gpcm");
	optimizer    = getValue("optimizer");
	numrderiv    = getValue("numrderiv");
	epshess      = getValue("epshess");
	// $parscale     = getRK_val("parscale"); not implemented yet...

	///////////////////////////////////
	// check for selected advanced control options
	control = new Array) ;
	if (iterqn_gpcm != "150")
	control[] = "iter.qN="+iterqn_gpcm ;
	if (ghk_gpcm != "21")
		control[] = "GHk="+ghk_gpcm ;
		if (optimizer != "optim")
			control[] = "optimizer=\"nlminb\"" ;
			if (optimizer == "optim" && optimeth != "BFGS")
				control[] = "optimMethod=\""+optimeth+"\"" ;
				if (numrderiv != "fd")
					control[] = "numrDeriv=\"cd\"" ;
					if (epshess != "1e-06")
						control[] = "epsHes="+epshess ;
						if (verbose == "TRUE")
							control[] = "verbose=TRUE" ;

							echo ('estimates.gpcm <- gpcm(');
							if (data && chk_select && inp_items)
								echo ("subset("+data+", select=c("+inp_items+"))");
								else
									echo (data);
									// any additional options?
									if (constraint != "gpcm") echo(", constraint=\""+constraint+"\"");
										if (irtparam != "TRUE") echo(", IRT.param=FALSE");
											if (startval == "list" && startval_lst) echo(", start.val="+startval_lst);
												if (startval == "random") echo(", start.val=\"random\"");
													if (naaction) echo(", na.action="+naaction);
														// finally check if any advanced control options must be inserted
														if (control) echo(", control=list("+join(", ", control)+")");
																echo (')\n');
															}

function printout () {
	var save = "";
	var save_name = "";
	// check whether parameter estimations should be kept in the global enviroment
	save         = getValue("chk_save");
	save_name    = getValue("save_name");

	echo ('rk.header ("GPCM parameter estimation")\n');
	echo ('rk.print (paste("Call: <code>",deparse(estimates.gpcm$call, width.cutoff=500),"</code>"))\n');
	echo ('rk.print ("<h4>Coefficients:</h4>")\n');
	echo ('rk.print (coef(estimates.gpcm))\n');
	echo ('rk.print (paste("Log-likelihood value at convergence:",round(estimates.gpcm$log.Lik, digits=1)))\n');
// check if results are to be saved:
	if (save && save_name) {

		echo ('# keep results in current workspace\n');
		echo (save_name + ' <<- estimates.gpcm\n');
	}
}
