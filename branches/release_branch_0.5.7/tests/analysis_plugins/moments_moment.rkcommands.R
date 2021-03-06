local({
## Prepare
require(moments)
## Compute
vars <- rk.list (test50z, test50y, test50x, test10z, test10y, test10x)
results <- data.frame ('Variable Name'=I(names (vars)), check.names=FALSE)
for (i in 1:length (vars)) {
	var <- vars[[i]]
	try (results[i, 'Moment'] <- moment (var, order = 1, central = FALSE, absolute = FALSE, na.rm = TRUE))
}
## Print result
rk.header ("Statistical Moment",
	parameters=list ("Order", "1", "Compute central moments", "FALSE", "Compute absolute moments", "FALSE", "Remove missing values", "TRUE"))
rk.results (results)
})
