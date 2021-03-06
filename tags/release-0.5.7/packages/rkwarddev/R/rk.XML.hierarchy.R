#' Create XML hierarchy section for RKWard plugins
#'
#' This function will create a hierarchy section for .pluginmap files,
#' with mandatory child nodes "menu".
#'
#' @param nodes A (list of) objects of class \code{XiMpLe.node}, must all be "menu".
#' @return A list of objects of class \code{XiMpLe.node}.
#' @export
#' @seealso
#'		\code{\link[rkwarddev:rk.XML.menu]{rk.XML.menu}},
#'		\code{\link[rkwarddev:rk.XML.entry]{rk.XML.entry}},
#'		\code{\link[rkwarddev:rk.XML.component]{rk.XML.component}},
#'		\code{\link[rkwarddev:rk.XML.components]{rk.XML.components}}
#' @examples
#' test.component <- rk.XML.component("My GUI dialog", "plugins/MyGUIdialog.xml")
#' test.entry <- rk.XML.entry(test.component)
#' test.menu <- rk.XML.menu("Analysis", nodes=test.entry, id.name="analysis")
#' test.hierarchy <- rk.XML.hierarchy(test.menu)
#' cat(pasteXMLNode(test.hierarchy))

rk.XML.hierarchy <- function(nodes){
	# check the node names and allow only valid ones
	node.names <- sapply(child.list(nodes), function(this.node){
			this.node@name
		})

	invalid.sets <- !node.names %in% c("menu")
	if(any(invalid.sets)){
		stop(simpleError(paste("Invalid XML nodes for hierarchy section: ",
			paste(node.names[invalid.sets], collapse=", "), sep="")))
	} else {}

	node <- new("XiMpLe.node",
			name="hierarchy",
			children=child.list(nodes)
		)

	return(node)
}
