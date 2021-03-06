\name{node}
\alias{node}
\alias{node<-}
\alias{node<-,XiMpLe.doc-method}
\alias{node,XiMpLe.doc-method}
\title{Extract/manipulate a node or parts of it from an XML tree}
\arguments{
  \item{obj}{An object of class \code{XiMpLe.doc}}

  \item{node}{A list of node names (or their numeric
  values), where each element is the child of its previous
  element. duplicate matches will be returned as a list.}

  \item{what}{A character string, must be a valid slot name
  of class \code{XiMpLe.node}, like \code{"attributes"} or
  \code{"value"}. If not \code{NULL}, only that part of a
  node will be returned. There's also two special
  properties for this option: \code{what="@path"} will not
  return the node or it's contents, but a character string
  with the "path" to it in the object;
  \code{what="obj@path"} is the same but won't have
  \code{obj} substituted with the object's name.}

  \item{cond.attr}{A named character string, to further
  filter the returned results. If not \code{NULL}, only
  nodes with fully matching attributes will be considered.}

  \item{cond.value}{A character string, similar to
  \code{cond.attr}, but is matched against the value
  between a pair of tags.}

  \item{element}{A character string naming one list element
  of the node slot. If \code{NULL}, all elements will be
  returned.}
}
\description{
  This method can be used to get parts of a parsed XML tree
  object, or to fill it with new values.
}
\examples{
\dontrun{
node(my.xml.tree, node=list("html","body"), what="attributes")
node(my.xml.tree, node=list("html","head","title"), what="value") <- "foobar"
}
}

