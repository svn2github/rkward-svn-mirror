#' Create XML node "include" for RKWard plugins
#'
#' @param file A character string, the file name to be included.
#' @return A list of objects of class \code{XiMpLe.node}.
#' @export
#' @examples
#' test.include <- rk.XML.include("../some_file.xml")
#' cat(pasteXMLNode(test.include))

rk.XML.include <- function(file){
	node <- new("XiMpLe.node",
			name="include",
			attributes=list(file=as.character(file))
		)

	return(node)
}
