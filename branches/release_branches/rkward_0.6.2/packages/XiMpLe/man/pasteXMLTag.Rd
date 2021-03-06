\name{pasteXMLTag}
\alias{pasteXMLTag}
\title{Write an XML tag}
\usage{
pasteXMLTag(tag, attr = NULL, child = NULL, empty = TRUE, level = 1,
  allow.empty = FALSE, rename = NULL, shine = 2, indent.by = "\\t",
  tidy = TRUE)
}
\arguments{
  \item{tag}{Character string, name of the XML tag.}

  \item{attr}{A list of attributes for the tag.}

  \item{child}{If \code{empty=FALSE}, a character string to
  be pasted as a child node between start and end tag.}

  \item{empty}{Logical, <true /> or <false></false>}

  \item{level}{Indentation level.}

  \item{allow.empty}{Logical, if \code{FALSE}, tags without
  attributes will not be returned.}

  \item{rename}{An optional named list if the attributes in
  XML need to be renamed from their list names in
  \code{attr}.  This list must in turn have a list element
  named after \code{tag}, containing named character
  elements, where the names represent the element names in
  \code{attr} and their values the names the XML attribute
  should get.}

  \item{shine}{Integer, controlling if the output should be
  formatted for better readability. Possible values:
  \describe{ \item{0}{No formatting.} \item{1}{Nodes will
  be indented.} \item{2}{Nodes will be indented and each
  attribute gets a new line.} }}

  \item{indent.by}{A charachter string defining how
  indentation should be done. Defaults to tab.}

  \item{tidy}{Logical, if \code{TRUE} the special
  characters "<", ">" and "&" will be replaced with the
  entities "&lt;", "&gt;" and "&amp;" in attribute values.
  For comment or CDATA tags, if the text includes newline
  characters they will also be indented.}
}
\value{
A character string.
}
\description{
Creates a whole XML tag with attributes and, if it is a
pair of start and end tags, also one object as child. This
can be used recursively to create whole XML tree structures
with this one function.
}
\note{
However, you will probably not want to use this function at
all, as it is much more comfortable to create XML nodes or
even nested trees with
\code{\link[XiMpLe:XMLNode]{XMLNode}} and
\code{\link[XiMpLe:XMLTree]{XMLTree}}, and then feed the
result to \code{\link[XiMpLe:pasteXML]{pasteXML}}.
}
\examples{
sample.XML.tag <- pasteXMLTag("a",
  attr=list(href="http://example.com", target="_blank"),
  child="klick here!",
  empty=FALSE)
}
\seealso{
\code{\link[XiMpLe:XMLNode]{XMLNode}},
\code{\link[XiMpLe:XMLTree]{XMLTree}},
\code{\link[XiMpLe:pasteXML]{pasteXML}}
}

