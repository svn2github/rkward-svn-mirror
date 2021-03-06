\name{rk.XML.require}
\alias{rk.XML.require}
\title{Create XML "require" node for RKWard plugins}
\usage{
  rk.XML.require(file = NULL, map = NULL)
}
\arguments{
  \item{file}{Character string, file name of another
  .pluginmap file to be included. Should be preferred over
  \code{map} if that file is in the same package.}

  \item{map}{Character string, should be
  \code{"namespace::id"} of another .pluginmap to be
  included.  Can be used to address plugin maps which are
  not part of the same plugin package.}
}
\value{
  An object of class \code{XiMpLe.node}.
}
\description{
  This function will create a require node for .pluginmap
  files.
}
\details{
  Note that only one of the values can be set at a time.
  \code{file} should be preferred whenever possible.
}
\examples{
test.require <- rk.XML.require("another.pluginmap")
cat(pasteXML(test.require))
}
\seealso{
  \href{help:rkwardplugins}{Introduction to Writing Plugins
  for RKWard}
}

