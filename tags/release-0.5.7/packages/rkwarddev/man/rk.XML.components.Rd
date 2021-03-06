\name{rk.XML.components}
\alias{rk.XML.components}
\title{Create XML "components" node for RKWard plugins}
\usage{
  rk.XML.components(nodes)
}
\arguments{
  \item{nodes}{A (list of) objects of class
  \code{XiMpLe.node}. They must all have the name
  "component".}
}
\value{
  A list of objects of class \code{XiMpLe.node}.
}
\description{
  This function will create a components node for a
  .pluginmap file, with mandatory child nodes "component".
}
\examples{
test.component <- rk.XML.component("My GUI dialog", "plugins/MyGUIdialog.xml")
test.components <- rk.XML.components(test.component)
cat(pasteXMLNode(test.components))
}
\seealso{
  \code{\link[rkwarddev:rk.XML.pluginmap]{rk.XML.pluginmap}},
  \code{\link[rkwarddev:rk.XML.component]{rk.XML.component}}
}

