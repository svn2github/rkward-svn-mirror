\name{rk.XML.set}
\alias{rk.XML.set}
\title{Create XML node "set" for RKWard plugins}
\usage{
  rk.XML.set(id, set = NULL, to, check.modifiers = TRUE)
}
\arguments{
  \item{id}{Either a character string (the \code{id} of the
  property whose value should be set), or an object of
  class \code{XiMpLe.node} (whose \code{id} will be
  extracted and used).}

  \item{set}{Character string, a valid modifier.}

  \item{to}{Character string or logical, the value the
  property should be set to.}

  \item{check.modifiers}{Logical, if \code{TRUE} the given
  modifiers will be checked for validity. Should only be
  turned off if you know what you're doing.}
}
\value{
  An object of class \code{XiMpLe.node}.
}
\description{
  Create XML node "set" for RKWard plugins
}
\examples{
test.set <- rk.XML.set(id="input_foo", set="required", to=TRUE)
cat(pasteXML(test.set))
}
\seealso{
  \code{\link[rkwarddev:rk.XML.convert]{rk.XML.convert}},
  \code{\link[rkwarddev:rk.XML.connect]{rk.XML.connect}},
  \code{\link[rkwarddev:rk.XML.external]{rk.XML.external}},
  \code{\link[rkwarddev:rk.XML.logic]{rk.XML.logic}}, and
  the \href{help:rkwardplugins}{Introduction to Writing
  Plugins for RKWard}
}

