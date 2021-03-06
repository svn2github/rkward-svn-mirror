local({
## Prepare
## Compute
result <- (pbeta (q = c (0.95), shape1 = 1.00, shape2 = 1.00, ncp = 0.00, lower.tail=TRUE, log.p = FALSE))
## Print result
rk.header ("Beta probability", list ("Vector of quantiles", "c (0.95)", "Shape 1", "1.00", "Shape 2", "1.00", "non-centrality parameter (ncp)", "0.00", "Tail", "lower.tail=TRUE", "Probabilities p are given as", "log.p = FALSE"));
rk.results (result, titles="Beta probability")
})
.rk.rerun.plugin.link(plugin="rkward::beta_probabilities", settings="logp.string=log.p = FALSE\nncp.real=0.00\nq.text=0.95\nshape1.real=1.00\nshape2.real=1.00\ntail.string=lower.tail=TRUE", label="Run again")
.rk.make.hr()
local({
## Prepare
## Compute
result <- (pbeta (q = c (0.96), shape1 = 1.01, shape2 = 1.01, ncp = 0.02, lower.tail=FALSE, log.p = TRUE))
## Print result
rk.header ("Beta probability", list ("Vector of quantiles", "c (0.96)", "Shape 1", "1.01", "Shape 2", "1.01", "non-centrality parameter (ncp)", "0.02", "Tail", "lower.tail=FALSE", "Probabilities p are given as", "log.p = TRUE"));
rk.results (result, titles="Beta probability")
})
.rk.rerun.plugin.link(plugin="rkward::beta_probabilities", settings="logp.string=log.p = TRUE\nncp.real=0.02\nq.text=0.96\nshape1.real=1.01\nshape2.real=1.01\ntail.string=lower.tail=FALSE", label="Run again")
.rk.make.hr()
