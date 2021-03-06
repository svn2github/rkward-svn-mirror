\name{rk.sessionInfo}
\alias{rk.sessionInfo}
\title{Print information on the RKWard session}
\usage{
  rk.sessionInfo()
}
\value{
  Returns the object created by \code{sessionInfo()},
  invisibly. Note that this includes only the information
  on the R portion of the session.
}
\description{
  Gathers and prints information on the setup of the
  current RKWard session. In general, you should always
  include this information when reporting a bug in RKWard.
}
\details{
  Typically, when reporting a bug, you should use
  \code{Help->Report Bug...} from the menu. Internally,
  this will call \code{rk.sessionInfo()}.
}
\examples{
rk.sessionInfo()
}
\author{
  Thomas Friedrichsmeier
  \email{rkward-devel@lists.sourceforge.net}
}
\seealso{
  \code{\link{sessionInfo}}
}
\keyword{misc}
\keyword{utilities}

