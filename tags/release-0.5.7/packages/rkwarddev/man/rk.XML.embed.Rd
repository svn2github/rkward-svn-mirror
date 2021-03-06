\name{rk.XML.embed}
\alias{rk.XML.embed}
\title{Create XML node "embed" for RKWard plugins}
\usage{
  rk.XML.embed(component, button = FALSE, label =
  "Options")
}
\arguments{
  \item{component}{A character string, registered name
  (\code{id} in pluginmap file) of the component to be
  embedded.}

  \item{button}{Logical, whether the plugin should be
  embedded as a button and appear if it's pressed.}

  \item{label}{A character string, text label for the
  button (only used if \code{button=TRUE}).}
}
\value{
  A list of objects of class \code{XiMpLe.node}.
}
\description{
  Create XML node "embed" for RKWard plugins
}
\examples{
test.embed <- rk.XML.embed("someComponent")
cat(pasteXMLNode(test.embed))
}

