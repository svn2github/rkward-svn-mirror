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

