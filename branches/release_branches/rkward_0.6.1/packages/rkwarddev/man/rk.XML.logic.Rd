\name{rk.XML.logic}
\alias{rk.XML.logic}
\title{Create XML logic section for RKWard plugins}
\usage{
  rk.XML.logic(...)
}
\arguments{
  \item{...}{Objects of class \code{XiMpLe.node}.}
}
\value{
  An object of class \code{XiMpLe.node}.
}
\description{
  This function will create a logic section with "convert",
  "connect", "include", "insert", "external" and "set"
  nodes. You can also include JavaScript code to use the
  locig scripting features of RKWard, if you place it in a
  comment with
  \code{\link[rkwarddev:rk.comment]{rk.comment}}: Its
  contents will automatically be placed inside a
  \code{<script><![CDATA[ ]]></script>} node.
}
\examples{
# define an input field and two checkboxes
test.input <- rk.XML.input("Type some text")
test.cbox1 <- rk.XML.cbox(label="Want to type?", value="true")
test.cbox2 <- rk.XML.cbox(label="Are you shure?", value="true")
# now create some logic so that the input field is only enabled when both boxes are checked
test.convert <- rk.XML.convert(c(state=test.cbox1,state=test.cbox2), mode=c(and=""))
test.connect <- rk.XML.connect(governor=test.convert, client=test.input, set="enabled")
test.logic <- rk.XML.logic(test.convert, test.connect)
cat(pasteXML(test.logic))

# with only one checkbox, you can directly query if it's checked
test.connect2 <- rk.XML.connect(governor=test.cbox1, client=test.input, set="enabled")
test.logic2 <- rk.XML.logic(test.connect2)
cat(pasteXML(test.logic2))
}
\seealso{
  \code{\link[rkwarddev:rk.XML.convert]{rk.XML.convert}},
  \code{\link[rkwarddev:rk.XML.connect]{rk.XML.connect}},
  \code{\link[rkwarddev:rk.XML.external]{rk.XML.external}},
  \code{\link[rkwarddev:rk.XML.set]{rk.XML.set}},
  \code{\link[rkwarddev:rk.XML.switch]{rk.XML.switch}}, and
  the \href{help:rkwardplugins}{Introduction to Writing
  Plugins for RKWard}
}

