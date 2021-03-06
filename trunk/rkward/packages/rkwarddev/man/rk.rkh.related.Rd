% Generated by roxygen2 (4.0.2): do not edit by hand
\name{rk.rkh.related}
\alias{rk.rkh.related}
\title{Create XML "related" node for RKWard help pages}
\usage{
rk.rkh.related(..., text = NULL)
}
\arguments{
\item{...}{Objects of class \code{XiMpLe.node}. They must all have the name "link".}

\item{text}{Character string, the text to be displayed.}
}
\value{
An object of class \code{XiMpLe.node}.
}
\description{
Create XML "related" node for RKWard help pages
}
\examples{
package.link <- rk.rkh.link("Spice")
plugin.related <- rk.rkh.related(package.link)
cat(pasteXML(plugin.related))
}
\seealso{
\code{\link[rkwarddev:rk.rkh.doc]{rk.rkh.doc}}
   and the \href{help:rkwardplugins}{Introduction to Writing Plugins for RKWard}
}

