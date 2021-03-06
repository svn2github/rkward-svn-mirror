local({
## Compute
result <- (qtukey (p = c (0.95), nmeans = 2, df = 2:11, nranges = 1, lower.tail=TRUE, log.p = FALSE))
## Print result
rk.header ("Studentized Range quantiles", list ("Vector of probabilities", "c (0.95)", "Sample size for range", "2", "Degrees of freedom for s", "2:11", "Number of groups whose maximum range is considered", "1", "Tail", "lower.tail=TRUE", "Probabilities p are given as", "log.p = FALSE"));
rk.results (result, titles="Studentized Range quantiles")
})
