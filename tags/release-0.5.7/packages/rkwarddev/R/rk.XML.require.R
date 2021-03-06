#' Create XML "require" node for RKWard plugins
#'
#' This function will create a require node for .pluginmap files.
#' 
#' @param file Character string, file name of another .pluginmap file to be included.
#' @return A list of objects of class \code{XiMpLe.node}.
#' @export
#' @examples
#' test.require <- rk.XML.require("another.pluginmap")
#' cat(pasteXMLNode(test.require))

rk.XML.require <- function(file){
	if(length(file) > 1 | !is.character(file)){
		stop(simpleError("'file' must be a character string!"))
	} else {}

	node <- new("XiMpLe.node",
			name="require",
			attributes=list(file=file)
		)

	return(node)
}
