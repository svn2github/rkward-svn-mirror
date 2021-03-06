local({
## Prepare
require (foreign)
## Compute
data <- read.dta ("import_export_plugins_testfile.dta", convert.dates=TRUE, convert.factors=TRUE, missing.type=FALSE, convert.underscore=FALSE)

# set variable labels for use in RKWard
labels <- attr (data, "var.labels")
if (!is.null (labels)) {
        for (i in 1:length (labels)) {
                col <- make.names (attr (data, "names")[i] )
                if (!is.null (col)) {
                        rk.set.label (data[[col]], labels[i])
                }
        }
}

.GlobalEnv$my.stata.data <- data		# assign to globalenv()
## Print result
rk.header("Import Stata File", parameters=list("File", "import_export_plugins_testfile.dta",
	"Imported to", "my.stata.data"))
})
