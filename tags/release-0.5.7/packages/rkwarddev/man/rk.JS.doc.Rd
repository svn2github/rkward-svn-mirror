\name{rk.JS.doc}
\alias{rk.JS.doc}
\title{Create JavaScript outline from RKWard plugin XML}
\usage{
  rk.JS.doc(require = c(), variables = NULL, results.header
  = NULL, preprocess = NULL, calculate = NULL, printout =
  NULL, indent.by = "\t")
}
\arguments{
  \item{require}{A character vector with names of R
  packages that the dialog depends on.}

  \item{variables}{A character string to be included to
  read in all needed variables from the dialog. Refer to
  \code{\link{rk.JS.scan}} for a function to create this
  from an existing plugin XML file.}

  \item{results.header}{A character string to headline the
  printed results.}

  \item{preprocess}{A character string to be included in
  the \code{preprocess()} function. This string will be
  pasted as-is, after \code{require} has been evaluated.}

  \item{calculate}{A character string to be included in the
  \code{calculate()} function. This string will be pasted
  as-is, after \code{variables} has been evaluated.}

  \item{printout}{A character string to be included in the
  \code{printout()} function. This string will be pasted
  as-is, after \code{results.header} has been evaluated.}

  \item{indent.by}{A character string defining how
  indentation should be done.}
}
\value{
  A character string.
}
\description{
  Create JavaScript outline from RKWard plugin XML
}
\note{
  The JavaScript
}
\seealso{
  \code{\link[rkwarddev:rk.paste.JS]{rk.paste.JS}},
  \code{\link[rkwarddev:rk.JS.vars]{rk.JS.vars}},
  \code{\link[rkwarddev:rk.JS.array]{rk.JS.array}},
  \code{\link[rkwarddev:ite]{ite}},
  \code{\link[rkwarddev:echo]{echo}},
  \code{\link[rkwarddev:id]{id}}
}

