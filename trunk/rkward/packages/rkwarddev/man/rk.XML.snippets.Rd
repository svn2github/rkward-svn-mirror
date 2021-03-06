% Generated by roxygen2 (4.0.2): do not edit by hand
\name{rk.XML.snippets}
\alias{rk.XML.snippets}
\title{Create XML "snippets" node for RKWard plugins}
\usage{
rk.XML.snippets(...)
}
\arguments{
\item{...}{Objects of class \code{XiMpLe.node}. They must all have the name "snippet".}
}
\value{
An object of class \code{XiMpLe.node}.
}
\description{
This function will create a snippets node for the document section,
      with optional child nodes "snippet".
}
\examples{
# define a formula section with varselector and varslots
test.formula <- rk.XML.vars("Variables", "Fixed", formula.dependent="Dependent")
# define the snippets section
test.snippet <- rk.XML.snippet(test.formula)
test.snippets <- rk.XML.snippets(test.snippet)
cat(pasteXML(test.snippets))
}
\seealso{
\code{\link[rkwarddev:rk.XML.plugin]{rk.XML.plugin}}
   \code{\link[rkwarddev:rk.XML.snippet]{rk.XML.snippet}},
   and the \href{help:rkwardplugins}{Introduction to Writing Plugins for RKWard}
}

