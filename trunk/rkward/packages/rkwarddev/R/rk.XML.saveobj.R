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


#' Create XML node "saveobject" for RKWard plugins
#'
#' @param label Character string, a text label for this plugin element.
#' @param chk Logical, if \code{TRUE} and \code{checkable=TRUE} the option is checkable and active by default.
#' @param checkable Logical, if \code{TRUE} the option can be switched on and off.
#' @param initial Character string, the default name for the object should be saved to.
#'    If \code{"auto"} and a label was provided, an name will be generated automatically from the label.
#' @param required Logical, whether an entry is mandatory or not.
#' @param id.name Character string, a unique ID for this plugin element.
#'    If \code{"auto"} and a label was provided, an ID will be generated automatically from the label.
#' @param help Character string or list of character values and XiMpLe nodes, will be used as the \code{text} value for a setting node in the .rkh file.
#'    If set to \code{FALSE}, \code{\link[rkwarddev:rk.rkh.scan]{rk.rkh.scan}} will ignore this node.
#'    Also needs \code{component} to be set accordingly!
#' @param component Character string, name of the component this node belongs to. Only needed if you
#'    want to use the scan features for automatic help file generation; needs \code{help} to be set
#'    accordingly, too!
#' @return An object of class \code{XiMpLe.node}.
#' @export
#' @seealso \href{help:rkwardplugins}{Introduction to Writing Plugins for RKWard}
#' @examples
#' test.saveobj <- rk.XML.saveobj("Save the results")
#' cat(pasteXML(test.saveobj))

rk.XML.saveobj <- function(label, chk=FALSE, checkable=TRUE, initial="auto", required=FALSE, id.name="auto",
  help=NULL, component=rk.get.comp()){
  attr.list <- list(label=label)

  if(isTRUE(checkable)){
    attr.list[["checkable"]] <- "true"
    if(isTRUE(chk)){
      attr.list[["checked"]] <- "true"
    } else {}
  } else {
    attr.list[["checkable"]] <- "false"
  }

  if(identical(initial, "auto")){
    attr.list[["initial"]] <- auto.ids(label, suffix=".obj")
  } else if(!is.null(id.name)){
    attr.list[["initial"]] <- initial
  } else {}
  if(isTRUE(required)){
    attr.list[["required"]] <- "true"
  } else {}


  if(identical(id.name, "auto")){
    attr.list[["id"]] <- auto.ids(label, prefix=ID.prefix("saveobject"))
  } else if(!is.null(id.name)){
    attr.list[["id"]] <- id.name
  } else {}

  node <- XMLNode("saveobject", attrs=attr.list)

  # check for .rkh content
  rk.set.rkh.prompter(component=component, id=attr.list[["id"]], help=help)

  return(node)
}
