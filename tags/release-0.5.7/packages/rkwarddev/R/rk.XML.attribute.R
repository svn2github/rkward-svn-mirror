#' Create XML "attribute" node for RKWard plugins
#'
#' This function will create a attribute node for component sections in .pluginmap files.
#' Only meaningful for import plugins.
#'
#' @param id Either a character string (the \code{id} of the property whose attribute should be set),
#'		or an object of class \code{XiMpLe.node} (whose \code{id} will be extracted and used).
#' @param value Character string, new value for the attribute.
#' @param label Character string, label associated with the attribute.
#' @return A list of objects of class \code{XiMpLe.node}.
#' @export
#' @seealso
#'		\code{\link[rkwarddev:rk.XML.components]{rk.XML.components}}
#' @examples
#' # define a formula section with varselector and varslots
#' test.checkbox <- rk.XML.cbox(label="foo", value="foo1", chk=TRUE)
#' # re-set the attribute
#' test.attribute <- rk.XML.attribute(test.checkbox, value="bar2", label="bar")
#' cat(pasteXMLNode(test.attribute))

rk.XML.attribute <- function(id, value=NULL, label=NULL){
	# let's see if we need to extract IDs first
	attr.list <- list(id=check.ID(id))

	if(all(is.null(value), is.null(label))){
		stop(simpleError("You must at least specity either one of 'value' or 'label'!"))
	} else {}
	
	if(!is.null(value)){
		attr.list[["value"]] <- value
	} else {}
	if(!is.null(label)){
		attr.list[["label"]] <- label
	} else {}

	node <- new("XiMpLe.node",
			name="attribute",
			attributes=attr.list
		)

	return(node)
}
