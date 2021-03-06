## internal functions, not exported

## function child.list()
# convenience function to let single children be provided without list()
child.list <- function(children){
	if(inherits(children, "XiMpLe.node")){
		children <- list(children)
	} else {
		# if already a list, check if it's a list in a list and get it out
		if(inherits(children, "list") & length(children) == 1){
			if(inherits(children[[1]], "list")){
				children <- children[[1]]
			} else {}
		} else {}
	}
	return(children)
} ## end function child.list()


## function split.chars()
# used to split a character string into parts at each occurrence of the start and end of a regex pattern
split.chars <- function(txt, pattern, perl=FALSE){
	found.pattern <- gregexpr(pattern, text=txt, perl=perl)
	found.pattern.start <- found.pattern[[1]]
	found.pattern.end <- found.pattern.start + attr(found.pattern[[1]], "match.length") - 1
	# returned -1 if pattern wasn't found
	if(found.pattern.start[1] == -1){
		return(txt)
	} else {
		txt.length <- nchar(txt)
		num.found.patterns <- length(found.pattern.start)
		result <- unlist(sapply(0:num.found.patterns, function(pat.idx){
				# 0: chars before first match
				if(pat.idx == 0){
					if(found.pattern.start[1] > 1){
						return(substr(txt, 1, found.pattern.start[1] - 1))
					} else {}
				} else {
					result.match <- substr(txt, found.pattern.start[pat.idx], found.pattern.end[pat.idx])
					# check if there's stuff between two matches
					aft.match <- found.pattern.end[pat.idx] + 1
						if(pat.idx < num.found.patterns){
							nxt.match <- found.pattern.start[pat.idx + 1]
						} else {
							nxt.match <- txt.length + 1
						}
					if(aft.match < nxt.match){
						result.aft.match <- trim(substr(txt, aft.match, nxt.match - 1))
						# remove empty space
						if(!identical("", result.aft.match)){
							result.match <- c(result.match, result.aft.match)
						} else {}
					} else {}
					return(result.match)
				}
			}))
		return(result)
	}
} ## end function split.chars()


## function XML.single.tags()
# Splits one character string or vector with an XML tree into a vector with its single tags.
# - tree: The XML tree, must be character.
# - drop: A character vector with the possible contens \code{c("comments","declarations","cdata","value")}
XML.single.tags <- function(tree, drop=NULL){
	if(!is.character(tree)){
		stop(simpleError("'tree' must be character!"))
	} else {}
	if(length(tree) > 1) {
		# force tree into one string
		tree <- paste(tree, collapse="")
	} else {}
	# remove space at beginning (and end)
	tree <- trim(tree)

	## the main splitting process
	# CDATA or comments can contain stuff which might ruin the outcome. we'll deal with those parts first.
	tree <- split.chars(txt=tree, pattern="<!\\[CDATA\\[((?s).*?)\\]\\]>|/\\*[[:space:]]*<!\\[CDATA\\[[[:space:]]*\\*/((?s).*?)/\\*[[:space:]]*\\]\\]>[[:space:]]*\\*/|<!--((?s).*?)-->", perl=TRUE)
	# now do the splitting
	single.tags <- as.character(unlist(sapply(tree, function(this.tree){
				# exclude the already cut our comments an CDATA entries
				if(XML.comment(this.tree) | XML.cdata(this.tree) | XML.commcdata(this.tree)){
					return(this.tree)
				} else {
					these.tags <- split.chars(txt=this.tree, "<((?s).*?)>", perl=TRUE)
					# remove probably troublesome content like newlines
					these.tags[!XML.value(these.tags)] <- gsub("[[:space:]]+", " ", these.tags[!XML.value(these.tags)])
					return(these.tags)
				}
			})))
	colnames(single.tags) <- NULL
	if("comments" %in% drop){
		single.tags <- single.tags[!XML.comment(single.tags)]
	} else {}
	if("declarations" %in% drop){
		single.tags <- single.tags[!XML.declaration(single.tags)]
	} else {}
	if("doctype" %in% drop){
		single.tags <- single.tags[!XML.doctype(single.tags)]
	} else {}
	if("cdata" %in% drop){
		single.tags <- single.tags[!XML.cdata(single.tags)]
	} else {}
	return(single.tags)
} ## end function XML.single.tags()


## function setMinIndent()
# takes a string, determines the minimum number of grouped \t strings,
# and adjusts it globally to the given level
setMinIndent <- function(tag, level=1, indent.by="\t", shine=0){
	if(shine > 0){
		tag <- gsub("\n([^\t])", "\n\t\\1", tag, perl=TRUE)
	} else {}
	currentMinIndent <- min(nchar(unlist(strsplit(tag, "[^\t]+"))))
	indentDiff <- currentMinIndent - level
	# if currentMinIndent is greater than level, reduce indentation
	if(indentDiff > 0){
		tag <- gsub(paste("(^|\n)(\t){", indentDiff, "}", sep=""), "\\1", tag, perl=TRUE)
	} else if(indentDiff < 0){
		tag <- gsub("(^|\n)(\t)", paste("\\1", indent(level + 1, by=indent.by), sep=""), tag, perl=TRUE)
	} else {}

	return(tag)
} ## end function setMinIndent()


## function indent()
# will create tabs to format the output
indent <- function(level, by="\t"){
	paste(rep(by, level-1), collapse="")
} ## end function indent()


## function xml.tidy()
# replace special character < and > from attributes or text values
# with harmless entities
xml.tidy <- function(text){
	if(is.character(text)){
		tidy.text <- gsub("<", "&lt;", gsub(">", "&gt;", gsub("&([#[:alnum:]]{7}[^;]|[[:space:]]|[^;]*$)", "&amp;\\1", text, perl=TRUE)))
	} else {
		return(text)
	}
	return(tidy.text)
} ## function xml.tidy()


## function lookupAttrName()
# takes the original input element names and returns
# the according XML attribute name
lookupAttrName <- function(tag, attr, rename){
	if(is.null(tag)){
		attr.name <- attr
	} else {
		attr.name <- rename[[tag]][[attr]]
	}
	return(attr.name)
} ## end function lookupAttrName()

## function pasteXMLAttr()
# pastes all attributes in a nicely readable way
pasteXMLAttr <- function(attr=NULL, tag=NULL, level=1, rename=NULL, shine=2, indent.by="\t", tidy=FALSE){
	if(is.null(attr)){
		return("")
	} else {}

	if(isTRUE(tidy)){
		attr <- sapply(attr, xml.tidy)
	} else {}

	new.indent <- ifelse(shine > 1, indent(level+1, by=indent.by), "")
	new.attr   <- ifelse(shine > 1, "\n", " ")

	# only use formatting if more than one attribute
	if(length(attr) > 1){
		full.attr <- c()
		for (this.attr in names(attr)){
			# skip empty elements
			if(is.null(attr[[this.attr]])){next}
			if(nchar(attr[[this.attr]]) > 0){
				if(!is.null(rename)){
					# look up attribute name to paste
					attr.name <- lookupAttrName(tag, this.attr, rename=rename)
				} else {
					attr.name <- this.attr
				}
				full.attr <- trim(paste(full.attr, new.attr, new.indent, attr.name, "=\"", attr[[this.attr]], "\"", sep=""))
			} else {}
		}
	} else {
		if(!is.null(rename)){
			# look up attribute name to paste
			attr.name <- lookupAttrName(tag, names(attr), rename=rename)
		} else {
			attr.name <- names(attr)
		}
		# look up attribute name to paste
		full.attr <- paste(attr.name, "=\"", attr[[1]], "\"", sep="")
	}
	return(full.attr)
} ## end function pasteXMLAttr()

## function parseXMLAttr()
# takes a whole XML tag and returns a named list with its attributes
parseXMLAttr <- function(tag){
	if(XML.doctype(tag)){
		stripped.tag <- gsub("<!((?i)DOCTYPE)[[:space:]]+([^[:space:]]+)[[:space:]]*([^\"[:space:]]*)[[:space:]]*.*>",
			"doctype=\"\\2\", id=\"\\3\"", tag)
		stripped.tag2 <- eval(parse(text=paste("c(",gsub("[^\"]*[\"]?([^\"]*)[\"]?[^\"]*", "\"\\1\",", tag),"NULL)")))
		is.dtd <- grepl("\\.dtd", stripped.tag2)
		doct.decl <- ifelse(sum(!is.dtd) > 0, paste(stripped.tag2[!is.dtd][1], sep=""), paste("", sep=""))
		doct.ref <- ifelse(sum(is.dtd) > 0, paste(stripped.tag2[is.dtd][1], sep=""), paste("", sep=""))
		parsed.list <- eval(parse(text=paste("list(", stripped.tag, ", decl=\"", doct.decl,"\"", ", refer=\"", doct.ref,"\")", sep="")))
	} else if(XML.endTag(tag) | XML.comment(tag) |XML.cdata(tag)){
		# end tags, comments and CDATA don't have attributes
		parsed.list <- ""
	} else {
		# first strip of start and end characters
		stripped.tag <- gsub("<([?[:space:]]*)[^[:space:]]+[[:space:]]*(.*)", "\\2", tag, perl=TRUE)
		stripped.tag <- gsub("[/?]*>$", "", stripped.tag, perl=TRUE)
		# fill in commas, so we can evaluate this as elements of a named list
		separated.tag <- gsub("=[[:space:]]*\"([^\"]*)\"[[:space:]]+([^[:space:]=]+)", "=\"\\1\", \\2", stripped.tag, perl=TRUE)
		# to be on the safe side, escape all list names, in case there's unexpected special characters in them
		separated.tag <- gsub("( ,)?([^[:space:],\"]*)=\"", "\\1\"\\2\"=\"", separated.tag, perl=TRUE)
		parsed.list <- eval(parse(text=paste("list(", separated.tag, ")")))
	}
	if(XML.declaration(tag)){
		valid.attr <- c("version", "encoding", "standalone")
		parsed.list <- parsed.list[tolower(names(parsed.list)) %in% valid.attr]
		for (miss.attr in valid.attr[!valid.attr %in% tolower(names(parsed.list))]){
			parsed.list[[miss.attr]] <- ""
		}
	} else {}

	return(parsed.list)
} ## end function parseXMLAttr()

## function trim()
# cuts off space at start and end of a character string
trim <- function(char){
	char <- gsub("^[[:space:]]*", "", char)
	char <- gsub("[[:space:]]*$", "", char)
	return(char)
} ## end function trim()

## function XML.emptyTag()
# checks if a tag is a pair of start/end tags or an empty tag;
# returns either TRUE/FALSE, or the tag name if it is an empty tag and get=TRUE
XML.emptyTag <- function(tag, get=FALSE){
	empty.tags <- sapply(tag, function(this.tag){
			empty <- grepl("/>$", this.tag)
			if(isTRUE(get)){
				result <- ifelse(isTRUE(empty), XML.tagName(this.tag), "")
			} else {
				result <- empty
			}
			return(result)
		})
	names(empty.tags) <- NULL
	return(empty.tags)
} ## end function XML.emptyTag()

## function XML.endTag()
# checks if a tag an end tag;
# returns either TRUE/FALSE, or the tag name if it is an end tag and get=TRUE
XML.endTag <- function(tag, get=FALSE){
	end.tags <- sapply(tag, function(this.tag){
			end <- grepl("^</", this.tag)
			if(isTRUE(get)){
				result <- ifelse(isTRUE(end), XML.tagName(this.tag), "")
			} else {
				result <- end
			}
			return(result)
		})
	names(end.tags) <- NULL
	return(end.tags)
} ## end function XML.endTag()

## function XML.comment()
# checks if a tag is a comment, returns TRUE or FALSE, or the comment (TRUE & get=TRUE)
XML.comment <- function(tag, get=FALSE, trim=TRUE){
	comment.tags <- sapply(tag, function(this.tag){
			comment <- grepl("<!--((?s).*)-->", this.tag, perl=TRUE)
			if(isTRUE(get)){
				result <- ifelse(isTRUE(comment), gsub("<!--((?s).*)-->", "\\1", this.tag, perl=TRUE), "")
				if(isTRUE(trim)){result <- trim(result)} else {}
			} else {
				result <- comment
			}
			return(result)
		})
	names(comment.tags) <- NULL
	return(comment.tags)
} ## end function XML.comment()

## function XML.cdata()
# checks if a tag is a CDATA declaration, returns TRUE or FALSE, or the data (TRUE & get=TRUE)
XML.cdata <- function(tag, get=FALSE, trim=TRUE){
	cdata.tags <- sapply(tag, function(this.tag){
			cdata <- grepl("<!\\[CDATA\\[((?s).*)\\]\\]>", this.tag, perl=TRUE)
			if(isTRUE(get)){
				result <- ifelse(isTRUE(cdata), gsub("<!\\[CDATA\\[((?s).*)\\]\\]>", "\\1", this.tag, perl=TRUE), "")
				if(isTRUE(trim)){result <- trim(result)} else {}
			} else {
				result <- cdata
			}
			return(result)
		})
	names(cdata.tags) <- NULL
	return(cdata.tags)
} ## end function XML.cdata()

## function XML.commcdata()
# checks if a tag is a /* CDATA */ declaration, returns TRUE or FALSE, or the data (TRUE & get=TRUE)
XML.commcdata <- function(tag, get=FALSE, trim=TRUE){
	commcdata.tags <- sapply(tag, function(this.tag){
			commcdata <- grepl("/\\*[[:space:]]*<!\\[CDATA\\[[[:space:]]*\\*/((?s).*?)/\\*[[:space:]]*\\]\\]>[[:space:]]*\\*/", this.tag, perl=TRUE)
			if(isTRUE(get)){
				result <- ifelse(isTRUE(commcdata), gsub("/\\*[[:space:]]*<!\\[CDATA\\[[[:space:]]*\\*/((?s).*?)/\\*[[:space:]]*\\]\\]>[[:space:]]*\\*/", "\\1", this.tag, perl=TRUE), "")
				if(isTRUE(trim)){result <- trim(result)} else {}
			} else {
				result <- commcdata
			}
			return(result)
		})
	names(commcdata.tags) <- NULL
	return(commcdata.tags)
} ## end function XML.commcdata()

## function XML.value()
# checks if 'tag' is actually not a tag but value/content/data. returns TRUE or FALSE, or the value (TRUE & get=TRUE)
XML.value <- function(tag, get=FALSE, trim=TRUE){
	all.values <- sapply(tag, function(this.tag){
			value <- grepl("^[[:space:]]*[^<]", this.tag)
			if(isTRUE(get)){
				result <- ifelse(isTRUE(value), this.tag, "")
				if(isTRUE(trim)){result <- trim(result)} else {}
			} else {
				result <- value
			}
			return(result)
		})
	names(all.values) <- NULL
	return(all.values)
} ## end function XML.value()

## function XML.declaration()
# checks for a declaration, like <?xml bar?>
XML.declaration <- function(tag, get=FALSE){
	decl.tags <- sapply(tag, function(this.tag){
			declaration <- grepl("<\\?((?i)xml).*\\?>", this.tag, perl=TRUE)
			if(isTRUE(get)){
				result <- ifelse(isTRUE(declaration), XML.tagName(this.tag), "")
			} else {
				result <- declaration
			}
			return(result)
		})
	names(decl.tags) <- NULL
	return(decl.tags)
} ## end function XML.declaration()

## function XML.doctype()
# checks for a doctype declaration, like <!DOCTYPE foo>
XML.doctype <- function(tag, get=FALSE){
	decl.tags <- sapply(tag, function(this.tag){
			declaration <- grepl("<!((?i)DOCTYPE).*>", this.tag, perl=TRUE)
			if(isTRUE(get)){
				result <- ifelse(isTRUE(declaration), XML.tagName(this.tag), "")
			} else {
				result <- declaration
			}
			return(result)
		})
	names(decl.tags) <- NULL
	return(decl.tags)
} ## end function XML.doctype()

## function XML.def()
XML.def <- function(tag, get=FALSE){
	decl.tags <- sapply(tag, function(this.tag){
			declaration <- grepl("<[!?]+[^-]*>", this.tag)
			if(isTRUE(get)){
				result <- ifelse(isTRUE(declaration), XML.tagName(this.tag), "")
			} else {
				result <- declaration
			}
			return(result)
		})
	names(decl.tags) <- NULL
	return(decl.tags)
} ## end function XML.def()

## function XML.tagName()
XML.tagName <- function(tag){
	tag.names <- sapply(tag, function(this.tag){
			tagName <- gsub("<([[:space:]!?/]*)([^[:space:]>]+).*", "\\2", this.tag, perl=TRUE)
			return(tagName)
		})
	names(tag.names) <- NULL
	return(tag.names)
} ## end function XML.tagName()

## function parseXMLTag()
parseXMLTag <- function(tag){
	tag.name <- XML.tagName(tag)
	tag.attr <- parseXMLAttr(tag)
	if(!is.null(tag.attr)){
		parsed.tag <- list()
		parsed.tag[[tag.name]] <- list(attr=tag.attr)
	} else {
		parsed.tag <- list()
		parsed.tag[[tag.name]] <- list()
	}
	return(parsed.tag)
} ## end function parseXMLTag()

## function XML.nodes()
XML.nodes <- function(single.tags, end.here=NA, start=1){
	# try to iterate through the single tags
	children <- list()
	tag.no <- start
	## uncomment to debug:
	# cat(start,"\n")
	while (tag.no < length(single.tags)){
		## uncomment to debug:
		# time.spent <- system.time({
		this.tag <- single.tags[tag.no]
		nxt.child <- length(children) + 1
		child.name <- XML.tagName(this.tag)
		child.end.tag <- paste("</[[:space:]]*", end.here,"[[:space:]>]+.*", sep="")
		if(isTRUE(grepl(child.end.tag, this.tag))){
		## uncomment to debug:
		# cat(this.tag, ": break (",tag.no,")\n")
			break
		} else {}
		# we must test for commented CDATA first, because XML.value() would be TRUE, too
		if(XML.commcdata(this.tag)){
			children[nxt.child] <- new("XiMpLe.node",
				name="*![CDATA[",
				value=XML.commcdata(this.tag, get=TRUE))
			names(children)[nxt.child] <- "*![CDATA["
			tag.no <- tag.no + 1
			next
		} else {}
		if(XML.value(this.tag)){
			children[nxt.child] <- new("XiMpLe.node",
				name="",
				value=XML.value(this.tag, get=TRUE))
			names(children)[nxt.child] <- "!value!"
			tag.no <- tag.no + 1
			next
		} else {
			child.attr <- parseXMLAttr(this.tag)
		}
		if(XML.declaration(this.tag)){
			children[nxt.child] <- new("XiMpLe.node",
				name=child.name,
				attributes=child.attr)
			names(children)[nxt.child] <- child.name
			tag.no <- tag.no + 1
			next
		} else {}
		if(XML.comment(this.tag)){
			children[nxt.child] <- new("XiMpLe.node",
				name="!--",
				value=XML.comment(this.tag, get=TRUE))
			names(children)[nxt.child] <- "!--"
			tag.no <- tag.no + 1
			next
		} else {}
		if(XML.cdata(this.tag)){
			children[nxt.child] <- new("XiMpLe.node",
				name="![CDATA[",
				value=XML.cdata(this.tag, get=TRUE))
			names(children)[nxt.child] <- "![CDATA["
			tag.no <- tag.no + 1
			next
		} else {}
		if(XML.endTag(this.tag)){
			break
		} else {}
		if(!XML.emptyTag(this.tag)){
		## uncomment to debug:
		# cat(child.name, ":", tag.no, "-", child.end.tag,"\n")
			rec.nodes <- XML.nodes(single.tags, end.here=child.name, start=tag.no + 1)
			children[nxt.child] <- new("XiMpLe.node",
				name=child.name,
				attributes=child.attr,
				children=rec.nodes$children,
				# this value will force the node to remain non-empty if it had no children,
				# it would be turned into an empty tag otherwise
				value="")
			names(children)[nxt.child] <- child.name
			tag.no <- rec.nodes$tag.no + 1
			next
		} else {
			children[nxt.child] <- new("XiMpLe.node",
				name=child.name,
				attributes=child.attr)
			names(children)[nxt.child] <- child.name
			tag.no <- tag.no + 1
			next
		}
		# force garbage collection
		gc()
		## uncomment to debug:
		# })
		# cat("system.time:", time.spent, "\n")
	}
	return(list(children=children, tag.no=tag.no))
} ## end function XML.nodes()
