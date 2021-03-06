local({
## Prepare
require(car)
## Compute
result <- levene.test (warpbreaks[["breaks"]], warpbreaks[["tension"]])
## Print result
names <- rk.get.description (warpbreaks[["breaks"]], warpbreaks[["tension"]])

rk.header ("Levene's Test", list ("response variable", names[1], "groups", names[2]))

rk.print (result)
})
.rk.rerun.plugin.link(plugin="rkward::levene_test", settings="group.available=warpbreaks[[\\\"tension\\\"]]\ny.available=warpbreaks[[\\\"breaks\\\"]]", label="Run again")
.rk.make.hr()
