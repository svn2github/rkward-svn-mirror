# Copyright 2014 Meik Michalke <meik.michalke@hhu.de>
#
# This file is part of the R package rkwarddev.
#
# rkwarddev is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# rkwarddev is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with rkwarddev.  If not, see <http://www.gnu.org/licenses/>.


#' Create node "valueselector" for RKWard plugins
#'
#' @param label Character string, a text label for the value selection slot.
#'    Must be set if \code{id.name="auto"}.
#' @param options A named list with string values to choose from. The names of the list elements will become
#'    labels of the options, \code{val} defines the value to submit if the value is selected, and
#'    \code{chk=TRUE} should be set in the one option which is checked by default. Objects generated with
#'    \code{\link[rkwarddev:rk.XML.option]{rk.XML.option}} are accepted as well.
#' @param id.name Character vector, unique ID for this element.
#' @return An object of class \code{XiMpLe.node}.
#' @export
#' @seealso
#'    \code{\link[rkwarddev:rk.XML.valueslot]{rk.XML.valueslot}},
#'    \code{\link[rkwarddev:rk.XML.values]{rk.XML.values}},
#'    \code{\link[rkwarddev:rk.XML.option]{rk.XML.option}},
#'    and the \href{help:rkwardplugins}{Introduction to Writing Plugins for RKWard}
#' @examples
#' test.valueselector <- rk.XML.valueselector("Select some values")
#' cat(pasteXML(test.valueselector))

rk.XML.valueselector <- function(label=NULL, options=list(label=c(val=NULL, chk=FALSE)), id.name="auto"){
  if(identical(id.name, "auto")){
    ## if this ID generation get's changed, change it in rk.XML.vars(), too!
    attr.list <- list(id=auto.ids(label, prefix=ID.prefix("valueselector", length=3)))
  } else if(!is.null(id.name)){
    attr.list <- list(id=id.name)
  } else {}

  if(!is.null(label)){
    attr.list[["label"]] <- label
  } else {
    if(identical(id.name, "auto")){
      stop(simpleError("If id.name=\"auto\", then 'label' must have a value!"))
    } else {}
  }

  # convert list elements into a list of XiMpLe nodes (if they aren't already)
  vs.options <- rk.check.options(options, parent="valueselector")

  # check the node names and allow only valid ones
  valid.child("valueselector", children=vs.options)

  node <- XMLNode("valueselector",
    attrs=attr.list,
    .children=child.list(vs.options, empty=FALSE)
  )

  return(node)
}
