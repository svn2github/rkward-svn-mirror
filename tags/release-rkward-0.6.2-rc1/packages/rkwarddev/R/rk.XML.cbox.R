# Copyright 2010-2014 Meik Michalke <meik.michalke@hhu.de>
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


#' Create XML node "checkbox" for RKWard plugins
#'
#' @param label Character string, a text label for this plugin element.
#' @param value Character string, the value to submit if the element is checked.
#' @param un.value Character string, an optional value for the unchecked option.
#' @param chk Logical, whether this element should be checked by default.
#' @param id.name Character string, a unique ID for this plugin element.
#'    If \code{"auto"}, an ID will be generated automatically from the label.
#' @param help Character string, will be used as the \code{text} value for a setting node in the .rkh file.
#'    If set to \code{FALSE}, \code{\link[rkwarddev:rk.rkh.scan]{rk.rkh.scan}} will ignore this node.
#'    Also needs \code{component} to be set accordingly!
#' @param component Character string, name of the component this node belongs to. Only needed if you
#'    want to use the scan features for automatic help file generation; needs \code{help} to be set
#'    accordingly, too!
#' @return An object of class \code{XiMpLe.node}.
#' @note There's also a simple wrapper function \code{rk.XML.checkbox}.
#' @export
#' @aliases rk.XML.checkbox
#' @seealso \href{help:rkwardplugins}{Introduction to Writing Plugins for RKWard}
#' @examples
#' test.checkboxes <- rk.XML.row(rk.XML.col(
#'   list(
#'     rk.XML.cbox(label="foo", value="foo1", chk=TRUE),
#'     rk.XML.cbox(label="bar", value="bar2"))))
#' cat(pasteXML(test.checkboxes))

rk.XML.cbox <- function(label, value="true", un.value=NULL, chk=FALSE, id.name="auto", help=NULL, component=rk.get.comp()){
  if(identical(id.name, "auto")){
    id <- auto.ids(label, prefix=ID.prefix("checkbox"))
  } else {
    id <- id.name
  }

  attr.list <- list(id=id, label=label, value=value)
  if(!is.null(un.value)){
    attr.list[["value_unchecked"]] <- un.value
  } else {}
  if(isTRUE(chk)){
    attr.list[["checked"]] <- "true"
  } else {}

  checkbox <- XMLNode("checkbox", attrs=attr.list)

  # check for .rkh content
  rk.set.rkh.prompter(component=component, id=id, help=help)
  
  return(checkbox)
}

## wrapper for name scheme consistency
#' @export
rk.XML.checkbox <- function(label, value="true", un.value=NULL, chk=FALSE, id.name="auto", help=NULL, component=rk.get.comp()){
  rk.XML.cbox(label=label, value=value, un.value=un.value, chk=chk, id.name=id.name, help=help, component=component)
}
