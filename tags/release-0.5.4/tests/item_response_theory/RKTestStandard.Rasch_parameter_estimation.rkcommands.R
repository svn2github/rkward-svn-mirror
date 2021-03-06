local({
## Prepare
require(ltm)
## Compute
estimates.rasch <- rasch(LSAT)
## Print result
rk.header ("Rasch parameter estimation")
rk.print ("Call:")
rk.print.literal (deparse(estimates.rasch$call, width.cutoff=500))
rk.header ("Coefficients:", level=4)
rk.print (coef(estimates.rasch))
rk.print (paste("Log-likelihood value at convergence:",round(estimates.rasch$log.Lik, digits=1)))
# keep results in current workspace
.GlobalEnv$estimates.rasch <- estimates.rasch
})
.rk.rerun.plugin.link(plugin="rkward::par_est_rasch", settings="constraint.available=\nghk_rasch.real=21.00\nirtparam.state=TRUE\niterqn_rasch.real=150.00\nnaaction.state=\noptimeth.string=BFGS\nsave_name.active=1\nsave_name.objectname=estimates.rasch\nsave_name.parent=.GlobalEnv\nstartval.string=NULL\nverbose.state=\nx.available=LSAT", label="Run again")
.rk.make.hr()
