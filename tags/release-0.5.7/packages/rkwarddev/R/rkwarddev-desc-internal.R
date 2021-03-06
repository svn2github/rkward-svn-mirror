# package description files
# this internal object can be used by the package roxyPackage to
# automatically create/update DESCRIPTION and CITATION files
pckg.dscrptn <- data.frame(
		Package="rkwarddev",
		Type="Package",
		Title="A collection of tools for RKWard plugin development",
		Author="m.eik michalke <meik.michalke@hhu.de>",
		AuthorsR="c(person(given=\"Meik\", family=\"Michalke\", email=\"meik.michalke@hhu.de\",
			role=c(\"aut\", \"cre\")))",
		Maintainer="m.eik michalke <meik.michalke@hhu.de>",
## TODO:
## need this for rk.load.pluginmaps()
## 		Depends="R (>= 2.9.0),XiMpLe,rkward (>= 0.5.7)",
		Depends="R (>= 2.9.0),XiMpLe,rkward (>= 0.5.6)",
		Enhances="rkward",
		Description="Provides functions to create plugin skeletons and XML structures for RKWard.",
		License="GPL (>= 3)",
		Encoding="UTF-8",
		LazyLoad="yes",
		URL="http://rkward.sourceforge.net",
		stringsAsFactors=FALSE)
