local({
## Prepare
## Compute
result <- (pchisq (q = c (0.97, 0.65), df = 3.00,  ncp = 0.05, lower.tail=TRUE, log.p = FALSE))
## Print result
rk.header ("Chi-squared probability", list ("Vector of quantiles", "c (0.97, 0.65)", "Degrees of Freedom", "3.00", "non-centrality parameter", "0.05", "Tail", "lower.tail=TRUE", "Probabilities p are given as", "log.p = FALSE"));
rk.results (result, titles="Chi-squared probabilities")
})
.rk.rerun.plugin.link(plugin="rkward::chi_squared_probabilities", settings="df.real=3.00\nlogp.string=log.p = FALSE\nncp.real=0.05\nq.text=0.97 0.65\ntail.string=lower.tail=TRUE", label="Run again")
.rk.make.hr()
local({
## Prepare
## Compute
result <- (pchisq (q = c (1), df = 1.01,  ncp = 0.02, lower.tail=FALSE, log.p = TRUE))
## Print result
rk.header ("Chi-squared probability", list ("Vector of quantiles", "c (1)", "Degrees of Freedom", "1.01", "non-centrality parameter", "0.02", "Tail", "lower.tail=FALSE", "Probabilities p are given as", "log.p = TRUE"));
rk.results (result, titles="Chi-squared probabilities")
})
.rk.rerun.plugin.link(plugin="rkward::chi_squared_probabilities", settings="df.real=1.01\nlogp.string=log.p = TRUE\nncp.real=0.02\nq.text=1\ntail.string=lower.tail=FALSE", label="Run again")
.rk.make.hr()
