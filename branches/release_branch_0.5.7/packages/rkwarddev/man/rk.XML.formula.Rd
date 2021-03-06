\name{rk.XML.formula}
\alias{rk.XML.formula}
\title{Create XML node "formula" for RKWard plugins}
\usage{
  rk.XML.formula(fixed, dependent, id.name = "auto")
}
\arguments{
  \item{fixed}{The \code{id} of the varslot holding the
  selected fixed factors.}

  \item{dependent}{The \code{id} of the varslot holding the
  selected dependent variable.}

  \item{id.name}{Character string, a unique ID for this
  plugin element. If \code{"auto"}, an ID will be generated
  automatically from the \code{fixed} and \code{dependent}
  value.}
}
\value{
  An object of class \code{XiMpLe.node}.
}
\description{
  If \code{fixed} or \code{dependent} are objects of class
  \code{XiMpLe.node}, their \code{id} will be extracted and
  used.
}
\examples{
test.varselector <- rk.XML.varselector("Select some vars")
test.varslot1 <- rk.XML.varslot("Fixed factors", source=test.varselector)
test.varslot2 <- rk.XML.varslot("Dependent variables", source=test.varselector)
test.formula <- rk.XML.formula(fixed=test.varslot1, dependent=test.varslot2)
cat(pasteXMLNode(test.formula))
}
\seealso{
  \code{\link[rkwarddev:rk.XML.varselector]{rk.XML.varselector}},
  \code{\link[rkwarddev:rk.XML.varslot]{rk.XML.varslot}},
  \code{\link[rkwarddev:rk.XML.vars]{rk.XML.vars}} (a
  wrapper, including formula)
}

