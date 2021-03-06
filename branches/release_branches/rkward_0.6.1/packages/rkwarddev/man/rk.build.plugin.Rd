\name{rk.build.plugin}
\alias{rk.build.plugin}
\title{Build an RKWard plugin package}
\usage{
  rk.build.plugin(plugin, check = FALSE, install = FALSE,
    R.libs = NULL)
}
\arguments{
  \item{plugin}{A character string, path to the plugin
  package root directory (hint: it's the directory with the
  DESCRIPTION file in it).}

  \item{check}{Logical, whether the package should be
  checked for errors. Always do this before you publish a
  package!}

  \item{install}{Logical, whether the built package should
  also be installed locally.}

  \item{R.libs}{A character string, path to local R
  packages, used by \code{install} to figure out where to
  install to.}
}
\description{
  Build an RKWard plugin package
}
\examples{
\dontrun{
plugin.dir <- rk.plugin.skeleton("MyPlugin", dialog=full.dialog, wizard=full.wizard)
rk.build.plugin(plugin.dir, R.libs="~/R", check=TRUE)
}
}
\seealso{
  \href{help:rkwardplugins}{Introduction to Writing Plugins
  for RKWard}
}

