\name{rk.show.message}
\alias{rk.show.message}
\alias{rk.show.question}
\alias{rk.select.list}

\title{Message boxes and selection list using native KDE GUI}

\description{
  Multi-purpose pop-up message boxes and selection list using native KDE GUI elements. The message boxes can be used either to show some information or ask some question. The selection list can be used to get a vector of selected items.
}

\usage{
rk.show.message (message, caption = "Information", wait = TRUE)

rk.show.question (message, caption = "Question", 
                   button.yes = "yes", button.no = "no", button.cancel = "cancel")

rk.select.list (list, preselect = NULL, multiple = FALSE, title = NULL)
}

\arguments{
  \item{message}{a string for the content of the message box.}
  \item{caption}{a string for title of the message box.}
  \item{button.yes}{a string for the text label of the \bold{Yes} button. Can be an empty string (\code{""}), in which case the button is not displayed at all.}
  \item{button.no}{a string used for the text label of the \bold{No} button, similar to \code{button.yes}.}
  \item{button.canel}{a string used for the text label of the \bold{Cancel} button, similar to \code{button.yes}.}
  \item{wait}{a logical (not NA) indicating whether the R interpreter should wait for the user's action, or run it asynchronously.}
  \item{list}{a vector, coerced into a character vector.}
  \item{preselct}{a vector, coerced into a character vector, items to be preselected.}
  \item{multiple}{a logical (not NA), when \code{TRUE} multiple selection selection is allowed.}
  \item{title}{a string, for the window title of the displayed list}
}

\details{
  For \code{rk.show.question}, the R interpreter always waits for the user's choice.
  
  \code{rk.select.list} replaces \code{utils::select.list} for the running session acting as a drop-in replacement for \code{tk_select.list}. Use \code{.rk.backups$select.list} for the original \code{utils::select.list} function (see Examples).
}

\value{
  \code{rk.show.message} always returns \code{TRUE}, invisibly.
  
  \code{rk.show.question} returns \code{TRUE} for \bold{Yes}, \code{FALSE} for \bold{No}, and \code{NULL} for \bold{Cancel} actions.
  
  \code{rk.select.list} returns the value of \code{\link{select.list}}.
}

\author{Thomas Friedrichsmeier \email{rkward-devel@lists.sourceforge.net}}

\seealso{
  \code{\link{system}}, \code{\link{select.list}}
}
\examples{
require (rkward)

## Message boxes
if (rk.show.question ("Question:\nDo you want to know about RKWard?", 
    button.yes = "Yes, I do!", button.no = "No, I don't care!", button.cancel = "")) {
  rk.show.message ("Message:\nRKWard is a KDE GUI for R.", "RKWard Info")
} else {
  rk.show.message ("You must be joking!", "RKWard Info", wait = FALSE) ## Run asynchronously
}

## Selection lists:
rk.select.list (LETTERS, preselect = c("A", "E", "I", "O", "U"), 
  multiple = TRUE, title = "vowels")
.rk.backups$select.list (LETTERS, preselect = c("A", "E", "I", "O", "U"), 
  multiple = TRUE, title = "vowels")
}

\keyword{utilities}
