\name{join}
\alias{join}
\title{Generate JavaScript to join an array object}
\usage{
  join(var, by = "\", \"")
}
\arguments{
  \item{var}{Either a character string (the name of the
  variable to combine to a vector or list), or an object of
  class \code{XiMpLe.node} (whose ID will be extracted and
  used). Also accepts objects of class \code{rk.JS.arr}.}

  \item{by}{Character string by which the values ought to
  be joined.}
}
\value{
  An object of class \code{rk.JS.echo}.
}
\description{
  This function pastes an object of class \code{rk.JS.arr}
  similar to
  \code{\link[rkwarddev:rk.paste.JS]{rk.paste.JS}}, but was
  specifically written for elements like \code{<optionset>}
  or \code{<matrix>}, whose values must be queried by
  \code{getList()} rather than \code{getValue()}. This
  means, the resulting variable is already an array an
  merely needs to be joined in as R code output (e.g., an
  \code{<optioncolumn>}).
}
\seealso{
  \code{\link[rkwarddev:rk.paste.JS]{rk.paste.JS}},
  \code{\link[rkwarddev:rk.JS.options]{rk.JS.options}},
  \code{\link[rkwarddev:rk.JS.vars]{rk.JS.vars}},
  \code{\link[rkwarddev:echo]{echo}},
  \code{\link[rkwarddev:id]{id}}, and the
  \href{help:rkwardplugins}{Introduction to Writing Plugins
  for RKWard}
}

