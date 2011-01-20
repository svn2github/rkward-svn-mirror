## Instruction
rk.show.message ("<b>Instructions</b><br>Most examples presented in the article are concerned with interactive GUI elements, which can not be fully scripted in a 		meaningful way. For this reason, most demos will ask you to carry out certain user actions, such as pressing buttons, manually.<br>
	In each case you will be given the
	choice of taking ten (more) seconds to interact with the GUI, or to proceed to the next demo.")

ok.to.proceed <- function (instruction) {
	while (TRUE) {
		res <- rk.show.question (instruction, "Ok to proceed?", "Give me 10 seconds", "Proceed to the next demo", "")
		if (!isTRUE (res)) return ()
		Sys.sleep (10)
	}
}


## Figure 2
my.data <- data.frame (var=numeric (1), var1=factor (1), var2=character (1), var3=logical (1), stringsAsFactors=FALSE)
rk.sync.global ()

ok.to.proceed ("<b>Replication of Figure 2</b>: The object \"my.data\" has been created in the global environment.<br><br>
Click on the \"Workspace\" button in the left tool view to show object information in the workspace browser.
Click on the '+'-symbol next to the object to expand it.")


## Figure 5
library (datasets)
data (C02)
data (DNase)
data (ChickWeight)
rk.sync.global ()
rk.edit (CO2)
rk.edit (ChickWeight)
ok.to.proceed ("<b>Replication of Figure 5</b>: Example data sets 'CO2' and 'ChickWeight' (from package datasets) have been opened for editing.<br>
Use Windows->Detach from the menu to detach the editor showing the ChickWeight dataset. <b>Note</b>: The editors will not be populated with data, until the R interpreter becomes idle, i.e., in this case, until the demo script has finished.<br>
After clicking 'Proceed', the command 'fix(DNase)' will be called. You will need to close the DNase dataset,
manually, to proceed.")
fix (DNase)


## Figure 6
rk.call.plugin ("rkward::import_csv")
ok.to.proceed ("<b>Replication of Figure 6</b>: CSV data import dialog has been opened.<br>
<b>NOTE</b>: You will have to close the dialog, manually, to get rid of it.</br>
Click 'Proceed' when done interacting.")


## Figure 7
graphics.off ()
plot (rnorm (50))
data_rnorm <- rnorm (50)
boxplot (data_rnorm)
plot (ecdf (data_rnorm))
hist (data_rnorm)
stripchart (data_rnorm)
rk.first.plot ()
ok.to.proceed ("<b>Replication of Figure 7</b>: Five plots have been created, and the first has been activated.</br>
Click on the 'Go to plot' toolbar icon for a dropdown list of plots.")


## Figure 8
rk.call.plugin ("rkward::descriptive", constMad.real="1.4628", length.state="1", mad.state="0", mad_type.string="average", mean.state="1", median.state="1", prod.state="0", range.state="1", sd.state="1", sum.state="0", trim.real="0.00", x.available="DNase[[\"density\"]]\nDNase[[\"conc\"]]\nChickWeight[[\"weight\"]]\nChickWeight[[\"Time\"]]", submit.mode="submit")
ok.to.proceed ("<b>Replication of Figure 8</b>: The result of running the 'Descriptive Statistics' plugin should now be visible in the output window.")


## Figure 9
rk.call.plugin ("rkward::import_csv", quick.string="csv", name.objectname="experiment.data", file.selection=paste (getwd (), "experiment.txt", sep="/"))
ok.to.proceed ("<b>Replication of Figure 9</b>: CSV data import dialog.</br>
<b>Note</b>: You may need to adjust the path to the file 'experiment.txt', which we provided in the same directory
as the demo script.<br>
Click 'Submit' when done. <b>Note</b>: Subsequent demos require this data, so <b>do</b> click 'Submit'.")
