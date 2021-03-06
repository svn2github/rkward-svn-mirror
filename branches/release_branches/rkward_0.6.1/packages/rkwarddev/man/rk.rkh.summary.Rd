\name{rk.rkh.summary}
\alias{rk.rkh.summary}
\title{Create XML "summary" node for RKWard help pages}
\usage{
  rk.rkh.summary(text = NULL)
}
\arguments{
  \item{text}{Character string, the text to be displayed.}
}
\value{
  An object of class \code{XiMpLe.node}.
}
\description{
  Create XML "summary" node for RKWard help pages
}
\examples{
plugin.summary <- rk.rkh.summary("This plugin folds space, using the spice package.")
cat(pasteXML(plugin.summary))
}
\seealso{
  \code{\link[rkwarddev:rk.rkh.doc]{rk.rkh.doc}} and the
  \href{help:rkwardplugins}{Introduction to Writing Plugins
  for RKWard}
}

