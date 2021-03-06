\name{rk.sync}
\alias{rk.sync}
\alias{rk.sync.global}

\title{Sync R object(s)}

\usage{
rk.sync(x)
rk.sync.global()
}

\arguments{
\item{x}{any R object to sync}
}

\details{
RKWard keeps an internal representation of objects in the R workspace. For objects in the \code{.GlobalEnv}, this representation is updated after each top-level statement. For the rare cases where this is not enough, \code{rk.sync} can be used to update the representation of a single object, \code{x}, while \code{rk.sync.global} scans the \code{.GlobalEnv} for new and removed objects, and updates as appropriate.

These functions are rarely needed outside automated testing. However, rk.sync() can be useful, if an object outside the \code{.GlobalEnv} has changed, since this will not be detected automatically. Also, by default RKWard does not recurse into environments when updating its representation of objects. rk.sync() can be used, here, to inspect the objects inside environments (see examples).
}

\value{
\code{NULL}, invisibly.
}

\author{Thomas Friedrichsmeier \email{rkward-devel@lists.sourceforge.net}}

\section{Warning}{
A typical user should not need to use these.
}

\seealso{
\url{rkward://page/rkward_workspace_browser} 
}

\examples{
rk.sync (rkward::rk.record.plot)
}

\keyword{utilities}
\keyword{misc}
