\name{rk.XML.matrix}
\alias{rk.XML.matrix}
\title{Create XML "matrix" node for RKWard plugins}
\usage{
  rk.XML.matrix(label, mode = "real", rows = 2,
    columns = 2, min = NULL, max = NULL,
    allow_missings = FALSE,
    allow_user_resize_columns = TRUE,
    allow_user_resize_rows = TRUE, fixed_width = FALSE,
    fixed_height = FALSE, horiz_headers = NULL,
    vert_headers = NULL, id.name = "auto")
}
\arguments{
  \item{label}{Character string, a label for the matrix.}

  \item{mode}{Character string, one of "integer", "real" or
  "string". The type of data that will be accepted in the
  table (required)}

  \item{rows}{Number of rows in the matrix. Has no effect
  if \code{allow_user_resize_rows=TRUE}.}

  \item{columns}{Number of columns in the matrix. Has no
  effect if \code{allow_user_resize_columns=TRUE}.}

  \item{min}{Minimum acceptable value (if \code{type} is
  "integer" or "real"). Defaults to the smallest
  representable value.}

  \item{max}{Maximum acceptable value (if \code{type} is
  "integer" or "real"). Defaults to the largest
  representable value.}

  \item{allow_missings}{Logical, whether missing (empty)
  values are allowed in the matrix (if \code{type} is
  "string").}

  \item{allow_user_resize_columns}{Logical, if \code{TRUE},
  the user can add columns by typing on the rightmost
  (inactive) cells.}

  \item{allow_user_resize_rows}{Logical, if \code{TRUE},
  the user can add rows by typing on the bottommost
  (inactive) cells.}

  \item{fixed_width}{Logical, force the GUI element to stay
  at its initial width. Do not use in combindation with
  matrices, where the number of columns may change in any
  way.  Useful, esp. when creating a vector input element
  (rows="1").}

  \item{fixed_height}{Logical, force the GUI element to
  stay at its initial height. Do not use in combindation
  with matrices, where the number of rows may change in any
  way.  Useful, esp. when creating a vector input element
  (columns="1").}

  \item{horiz_headers}{Character vector to use for the
  horiztonal header. Defaults to column number.}

  \item{vert_headers}{Character vector to use for the
  vertical header. Defaults to row number.}

  \item{id.name}{Character string, a unique ID for this
  plugin element.  If \code{"auto"}, an ID will be
  generated automatically from the label.}
}
\value{
  An object of class \code{XiMpLe.node}.
}
\description{
  Create XML "matrix" node for RKWard plugins
}
\note{
  The \code{<matrix>} node was introduced with RKWard
  0.6.1, please set the dependencies of your
  component/plugin accordingly.
}
\examples{
test.matrix <- rk.XML.matrix("A matrix")
}
\seealso{
  and the \href{help:rkwardplugins}{Introduction to Writing
  Plugins for RKWard}
}

