\name{rk.XML.entry}
\alias{rk.XML.entry}
\title{Create XML "entry" node for RKWard plugins}
\usage{
  rk.XML.entry(component, index = -1)
}
\arguments{
  \item{component}{An ID.}

  \item{index}{Integer number to influence the level of
  menu placement.}
}
\value{
  A list of objects of class \code{XiMpLe.node}.
}
\description{
  This function will create a entry node for menu sections
  in .pluginmap files.
}
\examples{
test.component <- rk.XML.component("My GUI dialog", "plugins/MyGUIdialog.xml")
test.entry <- rk.XML.entry(test.component)
cat(pasteXMLNode(test.entry))
}
\seealso{
  \code{\link[rkwarddev:rk.XML.menu]{rk.XML.menu}},
  \code{\link[rkwarddev:rk.XML.hierarchy]{rk.XML.hierarchy}},
  \code{\link[rkwarddev:rk.XML.component]{rk.XML.component}},
  \code{\link[rkwarddev:rk.XML.components]{rk.XML.components}}
}

