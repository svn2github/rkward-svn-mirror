local({
## Prepare
  require(ltm)
## Compute
estimates.3pl <<- tpm(LSAT)
## Print result
rk.header ("3PL parameter estimation")
rk.print (estimates.3pl)
})
.rk.rerun.plugin.link(plugin="rkward::par_est_3pl", settings="constraint.available=\nepshess.real=0.00100000\nghk_3pl.real=21.000000\nirtparam.state=TRUE\niterqn_3pl.real=1000.000000\nmaxguess.real=1.00000000\nnaaction.state=\noptimeth.string=BFGS\noptimizer.string=optim\nstartval.string=NULL\ntype.state=\nverbose.state=\nx.available=LSAT", label="Run again")
.rk.make.hr()
