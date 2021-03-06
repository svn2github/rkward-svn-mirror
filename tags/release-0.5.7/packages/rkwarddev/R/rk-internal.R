# internal functions for the rk.* functions

## function auto.ids()
auto.ids <- function(identifiers, prefix=NULL, suffix=NULL, chars=8){
	identifiers <- gsub("[[:space:]]*[^[:alnum:]]*", "", identifiers)
	id.names <- ifelse(nchar(identifiers) > 8, abbreviate(identifiers, minlength=chars), identifiers)
	# check for uniqueness
	if(any(duplicated(id.names))){
		warning("IDs are not unique, please check!")
	} else {}
	ids <- paste(prefix, id.names, suffix, sep="")
	return(ids)
} ## end function auto.ids()

## function child.list()
# convenience function to let single children be provided without list()
child.list <- function(children){
	if(inherits(children, "XiMpLe.node")){
		children <- list(children)
	} else {}
	return(children)
} ## end function child.list()

## function trim()
# cuts off space at start and end of a character string
trim <- function(char){
	char <- gsub("^[[:space:]]*", "", char)
	char <- gsub("[[:space:]]*$", "", char)
	return(char)
} ## end function trim()

## function indent()
# will create tabs to format the output
indent <- function(level, by="\t"){
	paste(rep(by, level-1), collapse="")
} ## end function indent()

## function get.single.tags()
get.single.tags <- function(XML.obj, drop=NULL){
	# determine if we need to read a file or process an XiMpLe object
	if(inherits(XML.obj, "XiMpLe.doc")){
		single.tags <- trim(unlist(strsplit(pasteXMLTree(XML.obj, shine=1, indent.by=""), split="\n")))
	} else if(inherits(XML.obj, "XiMpLe.node")){
		single.tags <- trim(unlist(strsplit(pasteXMLNode(XML.obj, shine=1, indent.by=""), split="\n")))
	} else {
		xml.raw <- paste(readLines(XML.obj), collapse=" ")
		single.tags <- XiMpLe:::XML.single.tags(xml.raw, drop=drop)
	}
	names(single.tags) <- NULL

	return(single.tags)
} ## end function get.single.tags()


## function get.IDs()
# scans XML tags for defined IDs, returns a matrix with columns "id" and "abbrev"
# 'single.tags' can also contain XiMpLe.node objects
get.IDs <- function(single.tags, relevant.tags, add.abbrev=FALSE){

	# filter for relevant tags
	cleaned.tags <- list()
	for(this.tag in child.list(single.tags)){
		if(inherits(this.tag, "XiMpLe.node")){
			this.tag.name <- this.tag@name
			if(this.tag.name %in% relevant.tags & "id" %in% names(this.tag@attributes)){
				cleaned.tags[length(cleaned.tags)+1] <- this.tag
			} else {}
		} else {
			this.tag.name <- tolower(XiMpLe:::XML.tagName(this.tag))
			# we're only interested in entries with an ID
			if(this.tag.name %in% relevant.tags & grepl("[[:space:]]+id=", this.tag)){
				cleaned.tags[length(cleaned.tags)+1] <- this.tag
			} else {}
		}
	}

	ids <- t(sapply(cleaned.tags, function(this.tag){
				if(inherits(this.tag, "XiMpLe.node")){
					this.tag.name <- this.tag@name
					this.tag.id <- this.tag@attributes["id"]
				} else {
					this.tag.name <- XiMpLe:::XML.tagName(this.tag)
					this.tag.id <- XiMpLe:::parseXMLAttr(this.tag)[["id"]]
				}

				if(isTRUE(add.abbrev)){
					this.tag.id.abbrev <- paste(ID.prefix(this.tag.name), this.tag.id, sep="")
				} else {
					this.tag.id.abbrev <- this.tag.id
				}
			return(c(id=this.tag.id, abbrev=this.tag.id.abbrev))
		}
	))
	rownames(ids) <- NULL

	# do a check if all IDs are really unique
	if("id" %in% names(ids)){
		multiple.id <- duplicated(ids[,"id"])
		if(any(multiple.id)){
			warning(paste("IDs are not unique:\n  ", paste(ids[multiple.id,"id"], collapse=", "), "\n  Expect errors!", sep=""))
		} else {}
	}

	return(ids)
} ## end function get.IDs()

## function camelCode()
# changes the first letter of each string
# (except for the first one) to upper case
camelCode <- function(words){

	words <- as.vector(unlist(sapply(words, function(cur.word){
			unlist(strsplit(cur.word, split="[._]"))
		})))

	new.words <- sapply(words[-1], function(cur.word){
		word.vector <- unlist(strsplit(cur.word, split=""))
		word.vector[1] <- toupper(word.vector[1])
		word.new <- paste(word.vector, collapse="")
		return(word.new)
	})

	results <- paste(words[1], paste(new.words, collapse=""), sep="")

	return(results)
} ## end function camelCode()

## function get.JS.vars()
#   <tag id="my.id" ...>
# in XML will become
#   var my.id = getValue("my.id");
get.JS.vars <- function(JS.var, XML.var=NULL, JS.prefix="", indent.by="", names.only=FALSE, properties=NULL, default=FALSE){
	# check for XiMpLe nodes
	JS.var <- check.ID(JS.var)
	if(!is.null(XML.var)){
		# check validity of properties value
		if(!is.null(properties)){
			if(identical(properties, "all")){
					if(inherits(XML.var, "XiMpLe.node")){
						tag.name <- XML.var@name
					} else {
						tag.name <- XML.var
					}
				if(tag.name %in% names(all.valid.props)){
					properties <- all.valid.props[[tag.name]]
				} else {
					properties <- NULL
				}
			} else {
				properties <- sapply(child.list(properties), function(this.prop){
					prop.validity(XML.var, property=this.prop, warn.only=TRUE, bool=FALSE)
				})
				properties <- properties[!"" %in% properties]
			}
		} else {}
		XML.var <- check.ID(XML.var)
	} else {}

	results <- c()
	if(is.null(properties) | isTRUE(default)){
		if(isTRUE(names.only)){
			results <- camelCode(c(JS.prefix, JS.var))
		} else {
			results <- paste(indent.by, "var ", camelCode(c(JS.prefix, JS.var)), " = getValue(\"", XML.var, "\");\n", sep="")
		}
	} else {}
	if(!is.null(properties)){
		if(isTRUE(names.only)){
			results <- c(results,
				sapply(properties, function(this.prop){camelCode(c(JS.prefix, JS.var, this.prop))})
			)
		} else {
			results <- c(results,
				sapply(properties, function(this.prop){
					paste(indent.by, "var ", camelCode(c(JS.prefix, JS.var, this.prop)), " = getValue(\"", XML.var, ".", this.prop, "\");\n", sep="")
				})
			)
		}
	}

	return(results)
} ## end function get.JS.vars()

## function ID.prefix()
ID.prefix <- function(initial, abbr=TRUE, length=3, dot=FALSE){
	if(isTRUE(abbr)){
		prfx <- abbreviate(initial, minlength=length, strict=TRUE)
	} else {
		# currently empty, but can later be used to define fixed abbreviations
		prfx <- NULL
	}
	if(isTRUE(dot)){
		prfx <- paste(prfx, ".", sep="")
	} else {
		prfx <- paste(prfx, "_", sep="")
	}
	return(prfx)
} ## end function ID.prefix()

## function node.soup()
# pastes the nodes as XML, only alphanumeric characters, e.g. to generate auto-IDs
node.soup <- function(nodes){
	if(inherits(nodes, "XiMpLe.node")){
		the.soup <- gsub("[^[:alnum:]]", "", pasteXMLNode(nodes, shine=0))
	} else {
		stop(simpleError("Nodes must be of class XiMpLe.node!"))
	}
	return(the.soup)
}
## end function node.soup()

## function get.by.role()
# filters a vector with person objects by roles
get.by.role <- function(persons, role="aut"){
	role.filter <- function(x){is.null(r <- x$role) | role %in% r}
	filtered.persons <- Filter(role.filter, persons)
	return(filtered.persons)
} ## end function get.by.role()

## function check.ID()
check.ID <- function(node){
	if(is.list(node)){
		return(sapply(node, check.ID))
	} else {}

	if(inherits(node, "XiMpLe.node")){
		node.ID <- node@attributes[["id"]]
	} else if(is.character(node)){
		node.ID <- node
	} else {
		stop(simpleError("Can't find an ID!"))
	}

	if(is.null(node.ID)){
		warning("ID is NULL!")
	} else {}

	return(node.ID)
} ## end function check.ID()

## list with valid properties
all.valid.props <- list(
	all=c("visible", "enabled", "required"),
	text=c("text"),
	varselector=c("selected", "root"),
	varslot=c("available", "selected", "source"),
	radio=c("string", "number"),
	dropdown=c("string", "number"),
	# option=c(),
	checkbox=c("state"),
	frame=c("checked"),
	input=c("text"),
	browser=c("selection"),
	saveobject=c("selection", "parent", "objectname", "active"),
	spinbox=c("int", "real"),
	formula=c("model", "table", "labels", "fixed_factors", "dependent"),
	embed=c("code"),
	preview=c("state")
) ## end list with valid properties

## function prop.validity()
# checks if a property is valid for an XML node, if source is XiMpLe.node
# if bool=FALSE, returns the property or ""
prop.validity <- function(source, property, ignore.empty=TRUE, warn.only=TRUE, bool=TRUE){
	if(identical(property, "") & isTRUE(ignore.empty)){
		if(isTRUE(bool)){
			return(TRUE)
		} else {
			return(property)
		}
	} else {}

	if(inherits(source, "XiMpLe.node")){
		tag.name <- source@name
	} else {
		if(isTRUE(bool)){
			return(TRUE)
		} else {
			return(property)
		}
	}

	if(tag.name %in% names(all.valid.props)){
		valid.props <- c(all.valid.props[["all"]], all.valid.props[[tag.name]])
	} else {
		valid.props <- c(all.valid.props[["all"]])
	}

	invalid.prop <- !property %in% valid.props
	if(any(invalid.prop)){
		if(isTRUE(warn.only)){
			warning(paste("Some property you provided is invalid for '",tag.name,"' and was ignored: ",
				paste(property[invalid.prop], collapse=", "), sep=""), call.=FALSE)
			if(isTRUE(bool)){
				return(FALSE)
			} else {
				return("")
			}
		} else {
			stop(simpleError(paste("Some property you provided is invalid for '",tag.name,"' and was ignored: ",
				paste(property[invalid.prop], collapse=", "), sep="")))
		}
	} else {
		if(isTRUE(bool)){
			return(TRUE)
		} else {
			return(property)
		}
	}
} ## end function prop.validity()

## function check.type()
check.type <- function(value, type, var.name, warn.only=TRUE){
	if(inherits(value, type)){
		return(invisible(NULL))
	} else {
		msg.text <- paste(sQuote(var.name), " should be of type ", type, "!", sep="")
		if(isTRUE(warn.only)){
			warning(msg.text)
		} else {
			stop(simpleError(msg.text))
		}
	}
} ## end function check.type()

## function clean.name()
clean.name <- function(name, message=TRUE){
	name.orig <- name
	name <- gsub("[[:space:]]*[^[:alnum:]_]*", "", name)
	if(!identical(name.orig, name)){
		if(isTRUE(message)){
			message(paste("For filenames ", sQuote(name.orig), " was renamed to ", sQuote(name), ".", sep=""))
		} else {}
	} else {}
	return(name)
} ## end function clean.name()

## function paste.JS.ite()
paste.JS.ite <- function(object, level=1, indent.by="\t", recurse=FALSE){
	stopifnot(inherits(object, "rk.JS.ite"))
	# check indentation
	main.indent <- indent(level, by=indent.by)
	scnd.indent <- indent(level+1, by=indent.by)

	# if this is not a single "if" but an "else if", do not indent
	if(isTRUE(recurse)){
		ifJS <- paste("if(", object@ifJS, ") {\n", sep="")
	} else {
		ifJS <- paste(main.indent, "if(", object@ifJS, ") {\n", sep="")
	}
	thenJS <- paste(scnd.indent, object@thenJS, "\n", main.indent, "}", sep="")
	if(nchar(object@elseJS) > 0) {
		elseJS <- paste(" else {\n", scnd.indent, object@elseJS, "\n", main.indent, "}", sep="")
	} else {
		# if there is another rk.JS.ite object, call with recursion
		if(length(object@elifJS) == 1){
			if(inherits(object@elifJS[[1]], "rk.JS.ite")){
				elseJS <- paste(" else ", paste.JS.ite(object@elifJS[[1]], level=level, indent.by=indent.by, recurse=TRUE), sep="")
			} else {
				elseJS <- " else {}"
			}
		} else {
			# close for sure with an empty "else"
			elseJS <- " else {}"
		}
	}
	result <- paste(ifJS, thenJS, elseJS, collapse="", sep="")

	return(result)
} ## end function paste.JS.ite()

## function paste.JS.array()
paste.JS.array <- function(object, level=2, indent.by="\t", funct=NULL){
	stopifnot(inherits(object, "rk.JS.arr"))
	# check indentation
	main.indent <- indent(level, by=indent.by)
	scnd.indent <- indent(level+1, by=indent.by)

	arr.name  <- object@arr.name
	opt.name  <- object@opt.name
	variables <- object@variables
	option    <- object@option
	if(is.null(funct)){
		funct <- object@funct
	} else {}

	JS.array <- paste(
		main.indent, "var ", arr.name, " = new Array();\n",
		main.indent, arr.name, ".push(",
		paste(variables, collapse=", "), ");\n",
		main.indent, arr.name, " = ", arr.name, ".filter(String);\n",
		main.indent, "if(", arr.name, ".length > 0) {\n",
		scnd.indent, "var ", opt.name, " = \", ", option,"=",
		funct, "(\" + ", arr.name, ".join(\", \") + \")\";\n",
		main.indent, "} else {\n",
		scnd.indent, "var ", opt.name, " = \"\";\n",
		main.indent, "}\n",
		sep="")

	return(JS.array)
} ## end function paste.JS.array()
