local({
## Compute
result <- (phyper (q = c (0, 1, 2, 3, 4, 5), m = 5, n = 4, k = 4, lower.tail=FALSE, log.p = FALSE))
## Print result
rk.header ("Hypergeometric probability", list ("Vector of quantiles", "c (0, 1, 2, 3, 4, 5)", "Number of white balls in the urn", "5", "Number of black balls in the urn", "4", "Number of balls drawn from the urn", "4", "Tail", "lower.tail=FALSE", "Probabilities p are given as", "log.p = FALSE"))
rk.results (result, titles="Hypergeometric probabilities")
})
