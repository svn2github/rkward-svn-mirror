#' Create XML node "optioncolumn" for RKWard plugins
#' 
#' These nodes are valid only inside \code{<optionset>} nodes.
#'
#' @note The \code{<optionset>} node was introduced with RKWard 0.6.1, please set the dependencies
#'		of your component/plugin accordingly.
#'
#' @param label Either logical or a character string. If given, the optioncolumn will be displayed in the \code{<optiondisplay>} in a column by that label.
#'		If set to \code{TRUE} and you provide a XiMpLe node object to \code{connect}, the label will be extracted from that node.
#' @param external Logical, set to \code{TRUE} if the optioncolumn is controlled from outside the optionset.
#' @param connect Either a character string (the \code{id} of the property to connect this optioncolumn to), or an object of
#'		class XiMpLe.node (whose \code{id} will be extracted and used). For external \code{<optioncolumn>}s, the corresponding value will
#'		be set to the externally set value. For regular (non-external) \code{<optioncolumn>}s, the corresponding row of the \code{<optioncolumn>} property, will be set
#'		when the property changes inside the content-area.
#' @param modifier Character string, the modifier of the property to connect to, will be appended to the \code{id} of \code{connect}.
#' @param default Character string, only for external columns: The value to assume for this column, if no value is known for an entry. Rarely useful.
#' @param id.name Character string, a unique ID for this plugin element.
#'		If \code{"auto"}, an ID will be generated automatically from the \code{connect} object.
#' @return An object of class \code{XiMpLe.node}.
#' @export
#' @seealso
#'		\code{\link[rkwarddev:rk.XML.optionset]{rk.XML.optionset}},
#'		\code{\link[rkwarddev:rk.XML.optiondisplay]{rk.XML.optiondisplay}},
#'		and the \href{help:rkwardplugins}{Introduction to Writing Plugins for RKWard}
#' @examples
#' myInput <- rk.XML.input(label="Given name(s)", size="small")
#' myOptCol <- rk.XML.optioncolumn(myInput, modifier="text")
rk.XML.optioncolumn <- function(connect, modifier=NULL, label=TRUE, external=FALSE, default=NULL, id.name="auto"){

	connect.id <- check.ID(connect)
	if(is.XiMpLe.node(connect) && !is.null(modifier)){
		# validate modifier
		if(modif.validity(connect, modifier=modifier)){
			connect.id <- paste(connect.id, modifier, sep=".")
		} else {}
	} else {}

	if(identical(id.name, "auto")){
		attr.list <- list(
			id=auto.ids(connect.id, prefix=ID.prefix("ocolumn"), chars=10),
			connect=as.character(connect.id))
	} else if(!is.null(id.name)){
		attr.list <- list(id=id.name, connect=as.character(connect.id))
	} else {
		stop(simpleError("'id.name' must have a value!"))
	}

	if(is.logical(label)){
		if(isTRUE(label)){
			if(is.XiMpLe.node(connect)){
				attr.list[["label"]] <- XMLAttrs(connect)[["label"]]
			} else {}
		} else {
		}
	} else if(is.character(label)){
		attr.list[["label"]] <- label
	} else {}

	if(isTRUE(external)){
		attr.list[["external"]] <- "true"
	} else {}

	if(!is.null(default)){
		attr.list[["default"]] <- default
	} else {}

	node <- XMLNode("optioncolumn",
		attrs=attr.list)

	return(node)
}
