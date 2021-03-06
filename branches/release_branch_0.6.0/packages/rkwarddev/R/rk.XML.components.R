#' Create XML "components" node for RKWard plugins
#'
#' This function will create a components node for a .pluginmap file, with mandatory child nodes "component".
#'
#' @param ... Objects of class \code{XiMpLe.node}. They must all have the name "component".
#' @return A list of objects of class \code{XiMpLe.node}.
#' @export
#' @seealso
#'		\code{\link[rkwarddev:rk.XML.pluginmap]{rk.XML.pluginmap}},
#'		\code{\link[rkwarddev:rk.XML.component]{rk.XML.component}},
#'		and the \href{help:rkwardplugins}{Introduction to Writing Plugins for RKWard}
#' @examples
#' test.component <- rk.XML.component("My GUI dialog", "plugins/MyGUIdialog.xml")
#' test.components <- rk.XML.components(test.component)
#' cat(pasteXML(test.components))

rk.XML.components <- function(...){
	nodes <- list(...)

	# check the node names and allow only valid ones
	valid.child("components", children=nodes)

	node <- XMLNode("components", .children=child.list(nodes, empty=FALSE))

	return(node)
}
