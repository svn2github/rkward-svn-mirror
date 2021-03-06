\name{rk.XML.external}
\alias{rk.XML.external}
\title{Create XML node "external" for RKWard plugins}
\usage{
  rk.XML.external(id, default = NULL)
}
\arguments{
  \item{id}{Character string, the ID of the new property.}

  \item{default}{Character string, initial value of the
  property if not connected.}
}
\value{
  An object of class \code{XiMpLe.node}.
}
\description{
  Create XML node "external" for RKWard plugins
}
\examples{
test.external <- rk.XML.external(id="ext_property", default="none")
cat(pasteXML(test.external))
}
\seealso{
  \code{\link[rkwarddev:rk.XML.convert]{rk.XML.convert}},
  \code{\link[rkwarddev:rk.XML.connect]{rk.XML.connect}},
  \code{\link[rkwarddev:rk.XML.logic]{rk.XML.logic}},
  \code{\link[rkwarddev:rk.XML.set]{rk.XML.set}}, and the
  \href{help:rkwardplugins}{Introduction to Writing Plugins
  for RKWard}
}

