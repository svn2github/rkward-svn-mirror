local({
## Prepare
  require(ltm)
## Compute
unidim.res <<- unidimTest(estimates.rasch)
## Print result
rk.header ("Unidimensionality check (estimates.rasch)")
rk.print (unidim.res)
})
.rk.rerun.plugin.link(plugin="rkward::ltm_unidimensional", settings="spin_samples.real=100.000000\nx.available=estimates.rasch", label="Run again")
.rk.make.hr()
