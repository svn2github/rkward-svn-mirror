#' Create XML "snippets" node for RKWard plugins
#'
#' This function will create a snippets node for the document section, with optional child nodes "snippet".
#'
#' @param nodes A (list of) objects of class \code{XiMpLe.node}. They must all have the name "snippet".
#' @return A list of objects of class \code{XiMpLe.node}.
#' @export
#' @seealso
#'		\code{\link[rkwarddev:rk.XML.plugin]{rk.XML.plugin}}
#'		\code{\link[rkwarddev:rk.XML.snippet]{rk.XML.snippet}}
#' @examples
#' # define a formula section with varselector and varslots
#' test.formula <- rk.XML.vars("Variables", "Fixed", formula.dependent="Dependent")
#' # define the snippets section
#' test.snippet <- rk.XML.snippet(test.formula)
#' test.snippets <- rk.XML.snippets(test.snippet)
#' cat(pasteXMLNode(test.snippets))

rk.XML.snippets <- function(nodes=NULL){
	if(!is.null(nodes)){
		# check the node names and allow only valid ones
		sapply(child.list(nodes), function(this.node){
				stopifnot(inherits(this.node, "XiMpLe.node"))
				node.name <- this.node@name
				if(!identical(node.name, "snippet")){
					stop(simpleError(paste("Invalid XML nodes for snippets section: ", node.name, sep="")))
				} else {}
			})
	} else {
		nodes <- list()
	}

	node <- new("XiMpLe.node",
			name="snippets",
			children=child.list(nodes),
			value=""
		)

	return(node)
}
