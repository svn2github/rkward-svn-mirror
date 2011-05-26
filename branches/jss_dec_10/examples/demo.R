## Instruction
rk.show.message ("<b>Instructions</b><br>Most examples presented in the article are concerned with interactive GUI elements, which cannot be fully scripted in a 		meaningful way. For this reason, most demos will ask you to carry out certain user actions, such as pressing buttons, manually.<br><br>
	In each case you will be given the
	choice of taking ten (more) seconds to interact with the GUI, or to proceed to the next demo. <br><br><b>Note</b>: To be able to interact with the plugin windows, you must click on \"Give me 10 seconds\".")

ok.to.proceed <- function (instruction) {
	while (TRUE) {
		res <- rk.show.question (instruction, "Ok to proceed?", "Give me 10 seconds to try", "Proceed to the next demo", "Quit demo.")
		if (is.null (res)) stop ("Demo interrupted")
		if (!isTRUE (res)) return ()
		Sys.sleep (10)
	}
}


## Figure 2
my.data <- data.frame (var=numeric (1), var1=factor (1), var2=character (1), var3=logical (1), stringsAsFactors=FALSE)
rk.sync.global ()

f <- function () {
      print ("Interactive console with syntax highlighting")
   }
   f ()
setClass ("demoClass", representation=list (slotA="numeric", slotB="character", slotC="list"), contains="data.frame")
s4.demo.object <- new ("demoClass")
s4.demo.object@slotC <- list (a=1, b=2)

ok.to.proceed ("<b>Replication of Figure 2</b>:<br>The object \"my.data\" has been created in the global environment.<br><br>
Click on the \"Workspace\" button in the left tool view to show object information in the workspace browser.
Click on the '+'-symbol next to the object to expand it.")


ok.to.proceed ("<b>Replication of Figure 2</b>:<br>The object \"my.data\" has been created in the global environment.<br><br>
Click on the \"Workspace\" button in the left tool view to show object information in the workspace browser.
Click on the '+'-symbol next to the object to expand it.")

## Figure 5
library (datasets)
data (CO2)
data (DNase)
data (ChickWeight)
rk.sync.global ()
rk.edit (CO2)
rk.edit (ChickWeight)
ok.to.proceed ("<b>Replication of Figure 5</b>:<br>Example data sets 'CO2' and 'ChickWeight' (from package datasets) have been opened for editing.<br>
Use Windows->Detach from the menu to detach the editor showing the ChickWeight dataset.<br><br><b>Note</b>: The editors will <b>not</b> be populated with data, until the R interpreter becomes idle, i.e., in this case, until the demo script has finished.<br><br>
After clicking 'Proceed', the command 'fix(DNase)' will be called. You will need to close the DNase dataset,
manually, to proceed.")


## Figure 6
rk.call.plugin ("rkward::import_csv")
ok.to.proceed ("<b>Replication of Figure 6</b>:<br>CSV data import dialog has been opened.<br>
<b>Note</b>: You will have to close the dialog, manually, to get rid of it.</br>
Click 'Proceed' when done interacting.")


## Figure 7
graphics.off ()
rk.clear.plot.history ()
plot (rnorm (50))
data_rnorm <- rnorm (50)
boxplot (data_rnorm)
plot (ecdf (data_rnorm))
hist (data_rnorm)
stripchart (data_rnorm)
rk.first.plot ()
ok.to.proceed ("<b>Replication of Figure 7</b>:<br>Five plots have been created, and the first has been activated.</br>
Click on the 'Go to plot' toolbar icon for a drop-down list of plots.")


## Figure 8
rk.call.plugin ("rkward::descriptive", constMad.real="1.4628", length.state="1", mad.state="0", mad_type.string="average", mean.state="1", median.state="1", prod.state="0", range.state="1", sd.state="1", sum.state="0", trim.real="0.00", x.available="DNase[[\"density\"]]\nDNase[[\"conc\"]]\nChickWeight[[\"weight\"]]\nChickWeight[[\"Time\"]]", submit.mode="submit")
ok.to.proceed ("<b>Replication of Figure 8</b>:<br>The result of running the 'Descriptive Statistics' plugin should now be visible in the output window. If it is not visible, use Windows->Show Output from the menu.")


## Figure 9
rk.call.plugin ("rkward::import_csv", quick.string="csv", name.objectname="experiment.data", file.selection=paste (getwd (), "experiment.txt", sep="/"))
ok.to.proceed ("<b>Replication of Figure 9</b>:<br>CSV data import dialog.</br><br><br>
<b>Note</b>: You may need to adjust the path to the file 'experiment.txt', which we provided in the same directory
as the demo script.<br><br>
Click 'Submit' when done. Subsequent demos require this data, so <b>do</b> click 'Submit' before proceeding.")


## Figure 10
rk.call.plugin ("rkward::t_test_two_vars", confint.state="1", conflevel.real="0.95", hypothesis.string="less", paired.state="1", x.available="experiment.data[[\"before\"]]", y.available="experiment.data[[\"after\"]]", submit.mode="manual")
ok.to.proceed ("<b>Replication of Figure 10</b>:<br>Dialog for t-test on imported data.</br><br><br>
<b>Note</b>: The results (Figure 10B) will appear in the output window after clicking 'Submit'.")


## Figure 11
rk.call.plugin ("rkward::box_plot", mean.state="", names_custom.text="T1;T2", names_exp.text="names (x)", names_mode.string="custom", notch.state="FALSE", orientation.string="FALSE", outline.state="TRUE", plotoptions.add_grid.state="0", plotoptions.asp.real="0.00", plotoptions.main.text="", plotoptions.pointcolor.color.string="", plotoptions.pointtype.string="", plotoptions.sub.text="", plotoptions.xaxt.state="", plotoptions.xlab.text="", plotoptions.xlog.state="", plotoptions.xmaxvalue.text="", plotoptions.xminvalue.text="", plotoptions.yaxt.state="", plotoptions.ylab.text="", plotoptions.ylog.state="", plotoptions.ymaxvalue.text="", plotoptions.yminvalue.text="", sd.state="", x.available="experiment.data[[\"before\"]]\nexperiment.data[[\"after\"]]", submit.mode="manual")
ok.to.proceed ("<b>Replication of Figure 11</b>:<br>Dialog for boxplot of imported data.</br><br><br>
<b>Note</b>: To follow the text of the article, you can check the 'Preview'-box, here, but this is not required for this demo. Click 'Close' when done.")


## Figure 12
data_list <- experiment.data
names (data_list) <- c ("T1", "T2")
boxplot (data_list, notch = FALSE, outline = TRUE, horizontal = FALSE)
ok.to.proceed ("<b>Replication of Figure 12</b>:<br>Box plot of imported data.</br><br><br>
Select Device->Export... to bring up the dialog shown in Figure 12 (not accessible programmatically).")


## Section 5.2
rk.show.message ("<b>Code listing in Section 5.2</b>.<br>The following demo runs the code listing in section 5.2
of the article.<br><br>First, we run the example that <b>is</b> subject to object modification detection.
On typical systems, this will take several seconds to complete.")
i <- 1
rk.sync.global ()	# Needed to trigger object modification detection without returning to the toplevel command prompt
for (i in 1:100000) i+i
rk.show.message ("<b>Code listing in Section 5.2</b>.<br>Next, we run the example that <b>is not</b> subject to object modification detection, but performs equivalent computations. This should finish nearly instantaneously.")
f <- function () {
	i <- 1
	for (i in 1:100000) i+i
}
f ()


## Done
rk.show.message ("<b>Finished</b>.<br>This concludes the demo.<br><br>
<b>Note</b> that the example plugin shown in section 6 cannot be wrapped into this demo script in a meaningful
way. For instructions on replicating this example, see the \'README.txt\' file which we provided in the same directory
as this demo script.")
