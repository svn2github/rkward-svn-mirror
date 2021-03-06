## intro
if (!isClass ("RKTestSuite")) source ("test_framework.R")

## definition of the test suite
suite <- new ("RKTestSuite", id="item_response_theory",
        # initCalls are run *before* any tests. Use this to set up the environment
        initCalls = list (
                function () {
                        library ("R2HTML")
                        library ("ltm") # load ltm library (Rasch, 2PL, 3PL)
                        library ("eRm") # load eRm library (LLTM)
                },
                function () {
			## these are example data sets from the ltm package
			# dichotomous data:
                        data("LSAT")		# Rasch & 3 parameter model, Cronbach's alpha
			data("WIRS")		# 2 parameter model
			# polytomous data:
			data("Environment")	# graded response model
			## these are example data sets from the eRm package
			# dichotomous data:
			data("lltmdat1")	# linear logistic test model
			# polytomous data:
			data("rsmdat")		# rating scale model
			data("pcmdat")		# partial credit model
			data("lrsmdat")		# linear rating scale model
			data("lpcmdat")		# linear partial credit model
                },
		function () {
			# some tests depend on results of earlier tests,
			# so we'll store those in a list in .GlobalEnv
			estimates <<- list ()
		}
        ## the tests
        ), tests = list (
		## first, let's test all parameter estimations
		## some parameters are later recycled for fitting tests and plotting
                new ("RKTest", id="Rasch_parameter_estimation", call=function () {
                        rk.call.plugin ("rkward::par_est_rasch", constraint.available="", ghk_rasch.real="21.000000", irtparam.state="TRUE", iterqn_rasch.real="150.000000", naaction.state="", optimeth.string="BFGS", startval.string="NULL", verbose.state="", x.available="LSAT", submit.mode="submit")
			estimates$rasch <<- estimates.rasch
                }),
                new ("RKTest", id="2PL_parameter_estimation", call=function () {
			rk.call.plugin ("rkward::par_est_2pl", constraint.available="", ghk_2pl.real="15.000000", interact.state="TRUE", irtparam.state="TRUE", iterem.real="40.000000", iterqn_2pl.real="150.000000", naaction.state="", optimeth.string="BFGS", startval.string="NULL", verbose.state="", x.available="WIRS", submit.mode="submit")
			estimates$"2pl" <<- estimates.2pl
                }),
                new ("RKTest", id="3PL_parameter_estimation", call=function () {
			rk.call.plugin ("rkward::par_est_3pl", constraint.available="", epshess.real="0.00100000", ghk_3pl.real="21.000000", irtparam.state="TRUE", iterqn_3pl.real="1000.000000", maxguess.real="1.00000000", naaction.state="", optimeth.string="BFGS", optimizer.string="optim", startval.string="NULL", type.state="", verbose.state="", x.available="LSAT", submit.mode="submit")
			estimates$"3pl" <<- estimates.3pl
                }),
                new ("RKTest", id="LLTM_parameter_estimation", call=function () {
			rk.call.plugin ("rkward::par_est_lltm", design.string="auto", etastart.string="NULL", groups.string="1", mpoints.real="2.000000", stderr.state="se", sumnull.state="sum0", x.available="lltmdat1", submit.mode="submit")
                }),
                new ("RKTest", id="GRM_parameter_estimation", call=function () {
			rk.call.plugin ("rkward::par_est_grm", constraint.state="", dig_abbrv.real="6.000000", ghk_grm.real="21.000000", hessian.state="", irtparam.state="TRUE", iterqn_grm.real="150.000000", naaction.state="", optimeth.string="BFGS", startval.string="NULL", verbose.state="", x.available="Environment", submit.mode="submit")
			estimates$grm <<- estimates.grm
                }),
                new ("RKTest", id="RSM_parameter_estimation", call=function () {
			rk.call.plugin ("rkward::par_est_rsm", design.string="auto", etastart.string="NULL", stderr.state="se", sumnull.state="sum0", x.available="rsmdat", submit.mode="submit")
			estimates$rsm <<- estimates.rsm
                }),
                new ("RKTest", id="PCM_parameter_estimation", call=function () {
			rk.call.plugin ("rkward::par_est_pcm", design.string="auto", etastart.string="NULL", stderr.state="se", sumnull.state="sum0", x.available="pcmdat", submit.mode="submit")
			estimates$pcm <<- estimates.pcm
                }),
                new ("RKTest", id="LRSM_parameter_estimation", call=function () {
			rk.call.plugin ("rkward::par_est_lrsm", design.string="auto", etastart.string="NULL", groups.string="1", mpoints.real="2.000000", stderr.state="", sumnull.state="", x.available="lrsmdat", submit.mode="submit")
                }),
                new ("RKTest", id="LPCM_parameter_estimation", call=function () {
			G <<- c(rep(1,10),rep(2,10))	# group vector, see example section of help("LPCM")
			rk.sync.global ()
			rk.call.plugin ("rkward::par_est_lpcm", design.string="auto", etastart.string="NULL", group_vec.available="G", groups.string="contrasts", mpoints.real="2.000000", stderr.state="se", sumnull.state="sum0", x.available="lpcmdat", submit.mode="submit")
                }),

		## testing cronbach's alpha
                new ("RKTest", id="Cronbach_alpha", call=function () {
			rk.call.plugin ("rkward::ltm_cronbach_alpha", chk_bsci.state="bsci", chk_na.state="", chk_standard.state="", spin_ci.real="0.95000000", spin_samples.real="500.000000", x.available="LSAT", submit.mode="submit")
                }, fuzzy_output=TRUE), # calculating the bootstrap confidence interval isn't always that accurate

		## now that our estimates are calculated, let's have a look at goodnes of fit
                new ("RKTest", id="goodnes-of-fit_Rasch", call=function () {
			estimates.rasch <<- estimates$rasch
			rk.sync.global ()
			rk.call.plugin ("rkward::ltm_gof_rasch", spin_samples.real="49.000000", x.available="estimates.rasch", submit.mode="submit")
                }, fuzzy_output=TRUE), # p values tend to be a little fuzzy here (.8-.9)
                new ("RKTest", id="unidimensional", call=function () {
			estimates.rasch <<- estimates$rasch
			rk.sync.global ()
			rk.call.plugin ("rkward::ltm_unidimensional", spin_samples.real="100.000000", x.available="estimates.rasch", submit.mode="submit")
		}, fuzzy_output=TRUE), # average of second eigenvalues in monte carlo samples (~ .25) and p values (~ .65) vary from time to time
                new ("RKTest", id="item_fit_statistics", call=function () {
			estimates.rasch <<- estimates$rasch
			rk.sync.global ()
			rk.call.plugin ("rkward::ltm_item_fit", drop_sumgroups.string="median", rad_pvalue.string="chi2", spin_groups.real="10.000000", x.available="estimates.rasch", submit.mode="submit")
                }),
                new ("RKTest", id="person_fit_statistics", call=function () {
			estimates.rasch <<- estimates$rasch
			rk.sync.global ()
			rk.call.plugin ("rkward::ltm_person_fit", rad_hypot.string="less", rad_pvalue.string="normal", rad_resppat.string="observed", x.available="estimates.rasch", submit.mode="submit")
                }),
                new ("RKTest", id="Wald_test", call=function () {
			estimates.rsm <<- estimates$rsm
			rk.sync.global ()
			# this test should eliminate four items and give a warning!
			rk.call.plugin ("rkward::eRm_waldtest", rad_splitcr.string="median", x.available="estimates.rsm", submit.mode="submit")
                }),
                new ("RKTest", id="Andersen_LR_plot", call=function () {
			estimates.pcm <<- estimates$pcm
			rk.sync.global ()
			rk.call.plugin ("rkward::eRm_plotLR", annotation.string="items", chk_confint.state="conf", chk_ctrline.state="ctrline", chk_se.state="se", inp_items.text="", plotoptions.add_grid.state="0", plotoptions.asp.real="0.00000000", plotoptions.main.text="", plotoptions.pointcolor.color.string="", plotoptions.pointtype.string="", plotoptions.sub.text="", plotoptions.xaxt.state="", plotoptions.xlab.text="", plotoptions.xlog.state="", plotoptions.xmaxvalue.text="", plotoptions.xminvalue.text="", plotoptions.yaxt.state="", plotoptions.ylab.text="", plotoptions.ylog.state="", plotoptions.ymaxvalue.text="", plotoptions.yminvalue.text="", rad_splitcr.string="median", spin_abilfrom.real="-3.00000000", spin_abilto.real="3.00000000", spin_confint.real="0.95000000", spin_ctrline.real="0.95000000", x.available="estimates.pcm", submit.mode="submit")
                }),

		 ## finally, test the plot functions
                new ("RKTest", id="plot_Rasch", call=function () {
			estimates.rasch <<- estimates$rasch
			rk.sync.global ()
			rk.call.plugin ("rkward::plot_rasch", annotation.string="legend", inp_items.text="", plot_type.string="items", plot_type_item.string="ICC", plotoptions.add_grid.state="0", plotoptions.asp.real="0.00000000", plotoptions.main.text="", plotoptions.pointcolor.color.string="", plotoptions.pointtype.string="", plotoptions.sub.text="", plotoptions.xaxt.state="", plotoptions.xlab.text="", plotoptions.xlog.state="", plotoptions.xmaxvalue.text="", plotoptions.xminvalue.text="", plotoptions.yaxt.state="", plotoptions.ylab.text="", plotoptions.ylog.state="", plotoptions.ymaxvalue.text="", plotoptions.yminvalue.text="", spin_from.real="-3.80000000", spin_to.real="3.80000000", x.available="estimates.rasch", submit.mode="submit")
                }),
                new ("RKTest", id="plot_2PL", call=function () {
			estimates.2pl <<- estimates$"2pl"
			rk.sync.global ()
			rk.call.plugin ("rkward::plot_ltm", annotation.string="annot", inp_items.text="1", plot_type.string="items", plot_type_item.string="ICC", plotoptions.add_grid.state="0", plotoptions.asp.real="0.00000000", plotoptions.main.text="", plotoptions.pointcolor.color.string="", plotoptions.pointtype.string="", plotoptions.sub.text="", plotoptions.xaxt.state="", plotoptions.xlab.text="", plotoptions.xlog.state="", plotoptions.xmaxvalue.text="", plotoptions.xminvalue.text="", plotoptions.yaxt.state="", plotoptions.ylab.text="", plotoptions.ylog.state="", plotoptions.ymaxvalue.text="", plotoptions.yminvalue.text="", spin_from.real="-3.80000000", spin_to.real="3.80000000", x.available="estimates.2pl", submit.mode="submit")
                }),
                new ("RKTest", id="plot_3PL", call=function () {
			estimates.3pl <<- estimates$"3pl"
			rk.sync.global ()
			# this time, plot the test information curve
			rk.call.plugin ("rkward::plot_tpm", annotation.string="annot", plot_type.string="TIC", plotoptions.add_grid.state="0", plotoptions.asp.real="0.00000000", plotoptions.main.text="", plotoptions.pointcolor.color.string="", plotoptions.pointtype.string="", plotoptions.sub.text="", plotoptions.xaxt.state="", plotoptions.xlab.text="", plotoptions.xlog.state="", plotoptions.xmaxvalue.text="", plotoptions.xminvalue.text="", plotoptions.yaxt.state="", plotoptions.ylab.text="", plotoptions.ylog.state="", plotoptions.ymaxvalue.text="", plotoptions.yminvalue.text="", spin_from.real="-3.80000000", spin_to.real="3.80000000", x.available="estimates.3pl", submit.mode="submit")
                }),
                new ("RKTest", id="plot_GRM", call=function () {
			estimates.grm <<- estimates$grm
			rk.sync.global ()
			rk.call.plugin ("rkward::plot_grm", annotation.string="annot", inp_items.text="6", plot_type.string="items", plot_type_item.string="ICC", plotoptions.add_grid.state="0", plotoptions.asp.real="0.00000000", plotoptions.main.text="", plotoptions.pointcolor.color.string="", plotoptions.pointtype.string="", plotoptions.sub.text="", plotoptions.xaxt.state="", plotoptions.xlab.text="", plotoptions.xlog.state="", plotoptions.xmaxvalue.text="", plotoptions.xminvalue.text="", plotoptions.yaxt.state="", plotoptions.ylab.text="", plotoptions.ylog.state="", plotoptions.ymaxvalue.text="", plotoptions.yminvalue.text="", spin_categ.real="0.000000", spin_from.real="-3.80000000", spin_to.real="3.80000000", x.available="estimates.grm", submit.mode="submit")
                }),
                new ("RKTest", id="plot_RSM", call=function () {
			estimates.rsm <<- estimates$rsm
			rk.sync.global ()
			# plot the first three items in one image
			rk.call.plugin ("rkward::plot_rsm", annotation.string="legend", chk_ask.state="", chk_mplot.state="mplot", inp_items.text="1:3", plotoptions.add_grid.state="0", plotoptions.asp.real="0.00000000", plotoptions.main.text="", plotoptions.pointcolor.color.string="", plotoptions.pointtype.string="", plotoptions.sub.text="", plotoptions.xaxt.state="", plotoptions.xlab.text="", plotoptions.xlog.state="", plotoptions.xmaxvalue.text="", plotoptions.xminvalue.text="", plotoptions.yaxt.state="", plotoptions.ylab.text="", plotoptions.ylog.state="", plotoptions.ymaxvalue.text="", plotoptions.yminvalue.text="", spin_abilfrom.real="-4.00000000", spin_abilto.real="4.00000000", spin_probfrom.real="0.00000000", spin_probto.real="1.00000000", x.available="estimates.rsm", submit.mode="submit")
                }),
                new ("RKTest", id="plot_PCM", call=function () {
			estimates.pcm <<- estimates$pcm
			rk.sync.global ()
			# here we plot items 3 to 6
			rk.call.plugin ("rkward::plot_pcm", annotation.string="legend", chk_ask.state="", chk_mplot.state="mplot", inp_items.text="3:6", plotoptions.add_grid.state="0", plotoptions.asp.real="0.00000000", plotoptions.main.text="", plotoptions.pointcolor.color.string="", plotoptions.pointtype.string="", plotoptions.sub.text="", plotoptions.xaxt.state="", plotoptions.xlab.text="", plotoptions.xlog.state="", plotoptions.xmaxvalue.text="", plotoptions.xminvalue.text="", plotoptions.yaxt.state="", plotoptions.ylab.text="", plotoptions.ylog.state="", plotoptions.ymaxvalue.text="", plotoptions.yminvalue.text="", spin_abilfrom.real="-4.00000000", spin_abilto.real="4.00000000", spin_probfrom.real="0.00000000", spin_probto.real="1.00000000", x.available="estimates.pcm", submit.mode="submit")
                })

        ),
        # like initCalls: run after all tests to clean up.
	postCalls = list (
		function(){
			rm(list=c("LSAT","WIRS","lltmdat1","Environment","pcmdat","rsmdat","lrsmdat","lpcmdat","estimates"), envir=globalenv())
		}
	)
)

## always store the result in "results" and print it
results <- rktest.runRKTestSuite (suite)
print (results)
