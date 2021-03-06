\name{NEWS}
\title{News for Package 'rkwarddev'}
\encoding{UTF-8}
\section{Changes in rkwarddev version 0.06-5 (2014-10-12)}{
  \subsection{fixed}{
    \itemize{
      \item the \code{"show"} feature in \code{rk.plugin.skeleton()} was broken due to changes in the namespace defaults
      \item scanning plugin XML code for JS and help related content didn't work as expected in \code{rk.plugin.component()}
      \item \code{rk.rkh.scan()} now also recognises <optioncolumn> and <matrix> nodes
      \item a logical bug prevented \code{rk.plugin.component()} to run with default values for XML
    }
  }
  \subsection{added}{
    \itemize{
      \item new functions \code{rk.set.rkh.prompter()} and \code{rk.get.rkh.prompter()} to make it easier to generate help files
        (later...)
      \item \code{rk.rkh.scan()} (and automatically \code{rk.plugin.skeleton()} and \code{rk.plugin.component()}) are now capable of fetching
        text set with \code{rk.set.rkh.prompter()} and use it to generate help files
      \item all functions scanned by \code{rk.rkh.scan()} for setting nodes in .rkh files have gained two additional arguments,
        \code{"help"} and \code{"component"}, to register the text to be used via \code{rk.set.rkh.prompter()}
      \item new function \code{rk.XMLoption()} to allow setting and accessing IDs for single options as well
    }
  }
  \subsection{changed}{
    \itemize{
      \item updated the plugin skeleton example script; e.g., it now uses the new .rkh file generating features
    }
  }
}
\section{Changes in rkwarddev version 0.06-4 (2014-09-14)}{
  \subsection{added}{
    \itemize{
      \item new functions \code{rk.set.language()}, \code{rk.get.language()} and \code{i18n()} to
        facilitate static internationalisation of plugins; makes use of a new internal
        environment .rkdev.env
      \item new parameter \code{"lang"} in functions \code{rk.rkh.doc()}, \code{rk.XML.plugin()},
        \code{rk.XML.pluginmap()} and \code{rk.plugin.skeleton()} for internationalisation. if used, the
        attributes \code{"lang"} and "xml:lang" will be set in the <document> root of
        the generated files, respectively
      \item new parameter \code{"localized"} in \code{rk.XML.require()} for internationalisation
      \item the document id in \code{rk.XML.pluginmap()} can now be set manually
    }
  }
  \subsection{fixed}{
    \itemize{
      \item abbreviation of labels now limits valid characters to [0-9A-Za-z]
      \item in \code{rk.XML.pluginmap()}, \code{"components"} and \code{"hierarchy"} may be set to NULL if
        \code{"require"} is used accordingly
    }
  }
}
\section{Changes in rkwarddev version 0.06-3 (2013-12-21)}{
  \subsection{fixed}{
    \itemize{
      \item fixed outdated example code for \code{rk.plugin.component()}
    }
  }
  \subsection{added}{
    \itemize{
      \item new function \code{rk.uniqueIDs()} checks for duplicate IDs
      \item \code{rk.JS.array()} can now be told to quote values
    }
  }
  \subsection{changed}{
    \itemize{
      \item \code{rk.plugin.component()} and \code{rk.rkh.doc()} do now interpret the \code{"hints"}
        argument to prevent the generation of optional XML nodes.
      \item \code{rk.plugin.component()} now automatically calls \code{rk.uniqueIDs()} and stops if
        IDs are not unique
    }
  }
}
\section{Changes in rkwarddev version 0.06-2 (2013-04-04)}{
  \subsection{changed}{
    \itemize{
      \item the structure of <about> nodes will change in RKWard 0.6.1,
        <dependencies> will become a direct child of <document> or <component>, which explains
        several changes in this release. this is not really critical, because this
        information wasn't evaluated by RKWard until now anyway
      \item for consistency, from now on <component> is never an empty node
      \item \code{rk.XML.pluginmap()}, \code{rk.XML.plugin()} and \code{rk.plugin.skeleton()} will now
        move <dependencies> from <about> to a top level child node of plugin maps,
        with a warning
      \item from \code{rk.plugin.component()} and \code{rk.XML.plugin()}, the \code{"pluginmap"} argument
        was replaced by the more general \code{"include"}, which can now also process a
        vector of file names
      \item the object class rk.JS.var gained a new slot \code{"getter"} to set a default JS
        function to query variable values. it defaults to \code{"getValue"} to ensure
        compatibility with earlier releases. consequently, \code{rk.JS.vars()} and
        \code{rk.paste.JS()} have a new  \code{"getter"} argument to set or overwrite this value.
        another new argument, \code{"guess.getter"}, can be used to turn on automatic guessing
        which getter function might be most appropriate. this was also added to
        \code{rk.plugin.component()} and \code{rk.plugin.skeleton()}.
      \item updated the skeleton_dialog.R demo file and recreated the plugin code
      \item JavaScript functions like \code{rk.JS.scan()} and \code{id()} learned how to treat
        <optionset>, <optioncolumn> and <matrix>
      \item internally paste(..., sep=\code{""}) was replaced with paste0(...), in a way
        that ensures compatibility with R < 2.15
    }
  }
  \subsection{added}{
    \itemize{
      \item new function \code{rk.XML.switch()}
      \item new function \code{rk.XML.optiondisplay()}
      \item new function \code{rk.XML.optionset()}
      \item new function \code{rk.XML.matrix()}
      \item new function \code{rk.XML.dependencies()}
      \item new function \code{rk.XML.dependency_check()}
      \item new function \code{join()} to simplify "\code{.join()}" for JavaScript arrays
      \item added options \code{"dependencies"}, \code{"namespace"} and \code{"priority"} to
        \code{rk.XML.pluginmap()}
      \item added option \code{"dependencies"} to \code{rk.XML.component()}
      \item added \code{"map"} to \code{rk.XML.require()}
      \item the new class rk.JS.echo allows having objects in an \code{echo()} statement
        without quoting it
      \item new combined modifiers \code{"visible.not"}, \code{"visible.numeric"}, \code{"enabled.not"},
        \code{"enabled.numeric"}, \code{"state.not"} and \code{"state.numeric"} are now supported
      \item modifiers have been added for <optionset> and <matrix>, and <switch> can
        have any modifier
    }
  }
  \subsection{fixed}{
    \itemize{
      \item added some missing parameter in the docs for \code{rk.paste.JS.graph()}
      \item fixed a bug in the modifier checks; this unveiled a bug in how
        \code{rk.JS.scan()} dealt with <frame> nodes, which was also fixed
      \item fixed a duplicate entry in this ChangeLog for version 0.04-6
      \item \code{rk.plugin.skeleton()} now correctly works with more than one author
      \item pluginmap files are no longer included into plugin XML files automatically
    }
  }
}
\section{Changes in rkwarddev version 0.06-1 (2012-11-08)}{
  \subsection{changed}{
    \itemize{
      \item \code{rk.plugin.skeleton()}: \code{"tests"} will now ignore \code{"overwrite"} and not replace
        existing testsuite files
    }
  }
  \subsection{fixed}{
    \itemize{
      \item dots will now be removed from pluginmap IDs
      \item modifiers of \code{"external"} XML nodes will not be checked, since it can be
        all kinds of stuff
    }
  }
}
\section{Changes in rkwarddev version 0.05-8 (2012-09-30)}{
  \subsection{added}{
    \itemize{
      \item new function \code{rk.plotOptions()} and class \code{"rk.plot.opts"} to simplify code
        generation for plots; this also caused changes in the internal workflow,
        especially for \code{child.node()} and \code{rk.paste.JS()}
    }
  }
  \subsection{changed}{
    \itemize{
      \item \code{rk.paste.JS.graph()} also takes objects of class \code{"rk.plot.opts"}
      \item \code{rk.XML.embed()} now supresses the label if "button=FALSE"
    }
  }
}
\section{Changes in rkwarddev version 0.05-7 (2012-09-29)}{
  \subsection{added}{
    \itemize{
      \item new function \code{rk.paste.JS.graph()} to simplify JS code generation for plots
    }
  }
}
\section{Changes in rkwarddev version 0.05-6 (2012-05-10)}{
  \subsection{added}{
    \itemize{
      \item \code{rk.XML.wizard()} and \code{rk.XML.dialog()} can now set the \code{"recommended"}
        attribute
    }
  }
}
\section{Changes in rkwarddev version 0.05-5 (2012-04-19)}{
  \subsection{added}{
    \itemize{
      \item \code{rk.plugin.skeleton()} can now also generate initial ChangeLog files (but
        won't overwrite existing ones)
      \item added a LICENSE file to the sources
      \item sources were initially debianized by roxyPackage
    }
  }
  \subsection{changed}{
    \itemize{
      \item if files are being skipped by \code{rk.plugin.skeleton()}, the corresponding
        warning will now include the 'create' actions that these files belong to
    }
  }
  \subsection{fixed}{
    \itemize{
      \item \code{rk.paste.JS()} pastes \code{rk.comment()} objects correctly again
    }
  }
}
\section{Changes in rkwarddev version 0.05-4 (2012-04-06)}{
  \subsection{fixed}{
    \itemize{
      \item \code{rk.XML.frame()} didn't generate attributes due to a typo
    }
  }
}
\section{Changes in rkwarddev version 0.05-3 (2012-03-18)}{
  \itemize{
    \item fixed: \code{rk.XML.text()} now preserves XML tags in the text value
    \item internally, functions now call \code{XiMpLe::XMLNode()} and \code{XiMpLe::XMLTree()}
      constructors instead of \code{new()}, and \code{pasteXMLNode()} and \code{pasteXMLTree()} were
      globally renamed into \code{pasteXML()}
    \item internally, replaced object@node with slot(object, \code{"node"})
    \item internally, moved checks for valid child and parent nodes to an internal
      functions, \code{valid.child()} and \code{valid.parent()}
  }
}
\section{Changes in rkwarddev version 0.05-2 (2012-03-10)}{
  \itemize{
    \item added missing dependency to package methods
    \item fixed docs in \code{rk.XML.plugin()}, \code{rk.XML.saveobj()} and \code{rk.plugin.skeleton()}
    \item fixed bug in \code{rk.XML.snippets()}
    \item re-formatted the ChangeLog so roxyPackage can translate it into a NEWS.Rd
      file
  }
}
\section{Changes in rkwarddev version 0.05-1 (2012-01-04)}{
  \itemize{
    \item removed superfluous "level=1" arguments from automatic "\code{rk.header()}"s in
      \code{rk.JS.doc()}
    \item added wrapper function \code{rk.XML.checkbox()} for \code{rk.XML.cbox()}
    \item changed \code{rk.JS.saveobj()} to use ".GlobalEnv$" instead of "\code{assign()}" in the
      resulting code
    \item added option to toggle the addition of empty "else \{\}" statements in
      rk.JS.ite objects to \code{rk.paste.JS()}
  }
}
\section{Changes in rkwarddev version 0.05-0 (2011-12-14)}{
  \itemize{
    \item \code{"result.header"} now doesn't add quotes by itself in \code{rk.JS.doc()}, so you
      can have R objects pasted. previous scripts need to be adapted accordingly!
      the headers can also be deactivated by setting to FALSE or \code{""}
    \item fixed show method for objects of class rk.JS.var with more than one
      variable object
    \item added support for global variables to \code{rk.JS.doc()} and
      \code{rk.plugin.component()}, and therefore also \code{rk.plugin.skeleton()}
    \item \code{"variables"} and \code{"globals"} in \code{rk.JS.doc()} can now also be given as objects
      of class rk.JS.var
    \item worked on the vignette
  }
}
\section{Changes in rkwarddev version 0.04-13 (2011-12-12)}{
  \itemize{
    \item set default value of checked checkboxes to \code{"true"} in \code{rk.XML.cbox()}
    \item \code{rk.XML.connect()} now correctly supports 'governor="<ID>.<modifier>.not"'
  }
}
\section{Changes in rkwarddev version 0.04-12 (2011-12-11)}{
  \itemize{
    \item added function \code{tf()} for even quicker JavaScript code generation from
      checkboxes
    \item fixed issue with \code{"about"} not being an XML node in \code{rk.plugin.skeleton()}
  }
}
\section{Changes in rkwarddev version 0.04-11 (2011-12-10)}{
  \itemize{
    \item \code{ite()} now supports full recursion also for the \code{"thenjs"} option.
    \item fixed superfluous first newline in \code{rk.JS.vars()}
  }
}
\section{Changes in rkwarddev version 0.04-10 (2011-12-05)}{
  \itemize{
    \item when using \code{rk.comment()} for logic scripting, its contents will
      automatically be placed inside a <script> node now
  }
}
\section{Changes in rkwarddev version 0.04-9 (2011-12-03)}{
  \itemize{
    \item left over stuff from JS \code{printout()} function is now added to \code{doPrintout()}
  }
}
\section{Changes in rkwarddev version 0.04-8 (2011-11-10)}{
  \itemize{
    \item R 2.14 creates source archives which are incompatible with earlier
      versions. attempt to deal with this by adding empty R directory and NAMESPACE
      file
  }
}
\section{Changes in rkwarddev version 0.04-7 (2011-11-08)}{
  \itemize{
    \item added long description support to \code{rk.XML.about()}, used for the
      DESCRIPTION file
  }
}
\section{Changes in rkwarddev version 0.04-6 (2011-10-31)}{
  \itemize{
    \item added <frame> to the tags which are scanned by \code{rk.JS.scan()}, they're
      considered only if checkable
    \item improved output of rk.JS.var class objects by \code{rk.paste.JS()}
  }
}
\section{Changes in rkwarddev version 0.04-5 (2011-10-28)}{
  \itemize{
    \item set dependency of rkward to >= 0.5.6 to work around a glitch in rkward's
      package versioning. this can cause errors on real 0.5.6 installations
      because they lack functions introduced in 0.5.7 (to add & load a plugin
      automatically), but shouldn't really break anything
    \item added support to turn off modifier checks to \code{rk.XML.set()}
    \item added option \code{"load.silencer"} to \code{rk.JS.doc()}, to easily add a switch to
      turn off package load messages in output.
  }
}
\section{Changes in rkwarddev version 0.04-4 (2011-10-26)}{
  \itemize{
    \item fixed bug in check for valid modifiers (used to warn when mixed lists
      with/without modifiers were given)
    \item fixed bug in \code{rk.XML.convert()} (false output if provided with list without
      modifiers)
    \item added option \code{"check.modifiers"} to \code{rk.JS.vars()}
  }
}
\section{Changes in rkwarddev version 0.04-3 (2011-10-22)}{
  \itemize{
    \item added support for definint \code{doPrintout()} JS functions to \code{rk.JS.doc()},
      \code{rk.plugin.skeleton()} and \code{rk.plugin.component()}
    \item added function \code{rk.comment()} to add comments to the generated code. it's a
      <!-- comment --> node by default, but will be turned into // comment by
      \code{rk.paste.JS()} and <![CDATA[ comment ]]> for logic sections automatically
    \item added option \code{"gen.info"} to all file producing functions, to add a comment
      note that the file was generated and changes should be made to the script
      rather than the code directly
    \item fixed missing \code{"id.name"} option in \code{rk.XML.embed()}
    \item fixed automatic menu hierarchy generation for lists of legth 1 in
      \code{rk.XML.pluginmap()}
  }
}
\section{Changes in rkwarddev version 0.04-2 (2011-10-21)}{
  \itemize{
    \item removed the superfluous \code{"name"} option from \code{rk.plugin.skeleton()} and
      \code{rk.plugin.component()}; names are now always provided by \code{"about"}, either as an
      <about> node or just the name.
    \item result headers now start at level 1 by default in \code{rk.JS.doc()}
    \item added option \code{"suggest.required"} to \code{rk.plugin.skeleton()} to add package
      requirements as suggestions, not dependencies
    \item updated skeleton GUI dialog
  }
}
\section{Changes in rkwarddev version 0.04-1 (2011-10-20)}{
  \itemize{
    \item added \code{"about"} option to \code{rk.XML.plugin()} to overrule pluginmap defaults
    \item added \code{rk.plugin.component()}, i.e. modularized the component generation,
      to allow for more than one component in \code{rk.plugin.skeleton()}, which
      subsequently gained the new option \code{"components"}
    \item improved dependency support, \code{rk.plugin.skeleton()} writes dependencies
      from <about> to DESCRIPTION now
    \item fixed dependency definition in \code{rk.XML.about()}
    \item fixed \code{"verion"} typo in \code{rk.XML.about()}
    \item the dot \code{"."} is now also allowed in file names
  }
}
\section{Changes in rkwarddev version 0.04-0 (2011-10-19)}{
  \itemize{
    \item for accurcy and consistency with the docs, the \code{"properties"} option
      changed to \code{"modifiers"} in \code{rk.JS.vars()}
    \item added further property modifiers to the internal validation
    \item added class rk.JS.var, including show method
    \item added support for class rk.JS.var in \code{rk.paste.JS()} an \code{id()}
    \item \code{rk.JS.vars()} now returns a list of class rk.JS.var
    \item added support for all valid modifiers to \code{rk.XML.convert()} and
      \code{rk.XML.connect()}
  }
}
\section{Changes in rkwarddev version 0.03-7 (2011-10-18)}{
  \itemize{
    \item added \code{"checkable"} and \code{"checked"} options to \code{rk.XML.frame()}
    \item set \code{rk.paste.JS()} default level to 2
    \item fixed bug in \code{rk.JS.array()} (superfluous "=" in generated code)
  }
}
\section{Changes in rkwarddev version 0.03-6 (2011-10-13)}{
  \itemize{
    \item lifted rkward package dependecies to 0.5.7 (needed for
      \code{rk.load.pluginmaps()})
    \item \code{rk.XML.menu()} and \code{rk.plugin.skeleton()} can now recursively generate
      deeper menu structures if you provide it with a list
    \item fixed bug in autogeneration of IDs in \code{rk.XML.input()} and \code{rk.XML.saveobj()}
  }
}
\section{Changes in rkwarddev version 0.03-5 (2011-10-11)}{
  \itemize{
    \item \code{rk.XML.tabbook()} can now autogenerate IDs without a label
    \item fixed bug in autogeneration of IDs in \code{rk.XML.spinbox()}
    \item shortened syntax of \code{rk.XML.tabbook()} tabs are now simply a named list
  }
}
\section{Changes in rkwarddev version 0.03-4 (2011-10-10)}{
  \itemize{
    \item added functions \code{rk.XML.code()} and \code{rk.XML.help()}
    \item fixed bug in internal function \code{check.ID()} (produced false entry nodes
      under certain circumstances)
    \item fixed bug in \code{rk.XML.pluginmap()} for automatic component IDs
    \item fixed bug in \code{rk.plugin.skeleton()} for cases where XML file exists and is
      not overwritten, but JS/help files need to be generated
    \item cleaned up \code{rk.XML.pluginmap()} and \code{rk.XML.plugin()} hint code
    \item changed \code{"nodes"} option to \code{"..."} also in \code{rk.XML.menu()}
    \item added beginnings of a vignette (to be continued...)
  }
}
\section{Changes in rkwarddev version 0.03-3 (2011-10-09)}{
  \itemize{
    \item replaced most of the \code{"nodes"} and \code{"children"} options with \code{"..."} in
      functions \code{rk.rkh.related()}, \code{rk.rkh.settings()}, \code{rk.XML.col()}, \code{rk.XML.components()},
      \code{rk.XML.context()}, \code{rk.XML.dialog()}, \code{rk.XML.frame()}, \code{rk.XML.hierarchy()},
      \code{rk.XML.logic()}, \code{rk.XML.page()}, \code{rk.XML.row()}, \code{rk.XML.snippet()},
      \code{rk.XML.snippets()} and \code{rk.XML.wizard()}. therefore, you don't need to \code{list()} objects any
      more.
    \item any function which generates an ID now has an automation mechanism for
      it, which is also the default.
  }
}
\section{Changes in rkwarddev version 0.03-2 (2011-10-09)}{
  \itemize{
    \item fixed skeleton GUI pluginmap not being found
  }
}
\section{Changes in rkwarddev version 0.03-1 (2011-10-08)}{
  \itemize{
    \item added new shortcut function \code{qp()} -- "quote + plus" -- for \code{id()}
    \item added option to create arrays with \code{rk.JS.options()}
    \item enhanced class rk.JS.opt
    \item \code{rk.paste.JS()} now adds some comments to the generated code
    \item fixed wrong default value for \code{"required"} in \code{rk.XML.browser()}
    \item added demo script
    \item added skeleton GUI, was generated by the demo script
  }
}
\section{Changes in rkwarddev version 0.03-0 (2011-10-07)}{
  \itemize{
    \item redesigned options for \code{rk.plugin.skeleton()} again, to make them more
      intuitive and flexible at the same time. unfortunately, this breaks backwards
      compatibility again.
    \item \code{rk.plugin.skeleton()} and \code{rk.XML.pluginmap()} now only accept
      \code{rk.XML.about()} made objects for \code{"about"}
    \item \code{rk.plugin.skeleton()} uses internal function \code{XML2person()} to create nicer
      Authors@R entries in DESCRIPTION
    \item fixed bug in \code{id()} (now generates JS variable names, not XML IDs)
  }
}
\section{Changes in rkwarddev version 0.02-5 (2011-10-06)}{
  \itemize{
    \item added functions \code{rk.rkh.caption()}, \code{rk.rkh.link()}, \code{rk.rkh.related()},
      \code{rk.rkh.section()}, \code{rk.rkh.setting()}, \code{rk.rkh.settings()}, \code{rk.rkh.summary()},
      \code{rk.rkh.technical()}, \code{rk.rkh.title()} and \code{rk.rkh.usage()}
    \item \code{rk.rkh.doc()} now only accepts nodes of the above functions as input (and
      gained support for title and sections)
    \item \code{rk.rkh.scan()} now also looks for captions
    \item added full help page support to \code{rk.plugin.skeleton()}
    \item added support for properties to \code{rk.JS.vars()}
    \item added function \code{rk.JS.saveobj()} to generate JS code for saveobject nodes.
    \item added function \code{rk.JS.options()} to generate code for JS variables holding
      multiple options
    \item added class rk.JS.opt and a show method for it (use \code{rk.paste.JS()} on that)
    \item \code{id()} and \code{echo()} now also replace objects of classes rk.JS.opt and
      rk.JS.arr with their relevant ID
    \item linked "Introduction to Writing Plugins for RKWard" locally to the manual
      pages
  }
}
\section{Changes in rkwarddev version 0.02-4 (2011-10-03)}{
  \itemize{
    \item some experimental JavaScript generator tools added, might very well be
      changed soon again: - added functions \code{rk.JS.vars()}, \code{echo()}, \code{id()}, \code{ite()} and
      \code{rk.paste.JS()} to help generate JavaScript code - added classes rk.JS.ite,
      rk.JS.arr and show methods for them - function \code{rk.JS.array()} now returns
      an object of class rk.JS.arr (use \code{rk.paste.JS()} on that)
  }
}
\section{Changes in rkwarddev version 0.02-3 (2011-09-30)}{
  \itemize{
    \item added functions \code{rk.XML.attribute()}, \code{rk.XML.component()},
      \code{rk.XML.components()}, \code{rk.XML.context()}, \code{rk.XML.entry()}, \code{rk.XML.hierarchy()}, \code{rk.XML.menu()}
      and \code{rk.XML.require()}
    \item \code{rk.plugin.skeleton()} and \code{rk.XML.pluginmap()} now use the new functions,
      which makes them much more flexible
    \item added option \code{"menu"} to \code{rk.plugin.skeleton()}
    \item added options \code{"require"}, \code{"x11.context"}, \code{"import.context"} and \code{"hints"} to
      \code{rk.XML.pluginmap()}
    \item removed now superfluous option \code{"plugin.dir"} from \code{rk.XML.pluginmap()}
    \item tuned \code{rk.plugin.skeleton()} to only skip file writing if they exist
  }
}
\section{Changes in rkwarddev version 0.02-2 (2011-09-29)}{
  \itemize{
    \item added \code{"load"} and \code{"show"} options to \code{rk.plugin.skeleton()} to call
      \code{rk.load.pluginmaps()} and the plugin itself
    \item added function \code{rk.build.plugin()}
  }
}
\section{Changes in rkwarddev version 0.02-1 (2011-09-28)}{
  \itemize{
    \item added functions \code{rk.XML.insert()}, \code{rk.XML.include()}, \code{rk.XML.embed()},
      \code{rk.XML.preview()}, \code{rk.XML.snippet()}, and \code{rk.XML.snippets()}
    \item added support for snippets section to \code{rk.XML.plugin()} and
      \code{rk.plugin.skeleton()}
    \item included formula node into \code{rk.XML.vars()} wrapper
    \item \code{rk.XML.varslot()} now automatically sets "multi=TRUE" if \code{"min"}, \code{"max"} or
      \code{"any"} are set
  }
}
\section{Changes in rkwarddev version 0.02-0 (2011-09-27)}{
  \itemize{
    \item redesigned options for \code{rk.XML.plugin()} and \code{rk.plugin.skeleton()} for more
      consistency. unfortunately, this breaks backwards compatibility!
    \item added functions \code{rk.XML.varselector()}, \code{rk.XML.copy()}, \code{rk.XML.dialog()},
      \code{rk.XML.page()} and \code{rk.XML.wizard()}
    \item added type checks to \code{rk.XML.spinbox()}
    \item added \code{"id.name"} and \code{"label"} to various functions
    \item updated \code{rk.XML.formula()}
  }
}
\section{Changes in rkwarddev version 0.01-5 (2011-09-25)}{
  \itemize{
    \item added functions \code{rk.XML.formula()}, \code{rk.XML.convert()}, \code{rk.XML.connect()},
      \code{rk.XML.logic()}, \code{rk.XML.set()} and \code{rk.XML.external()}
    \item added possibility to add custom XML code to the logic section with
      \code{rk.XML.plugin()} and \code{rk.plugin.skeleton()}
    \item fixed id setting in \code{rk.XML.browser()}
    \item simplified \code{rk.plugin.skeleton()} and \code{rk.XML.pluginmap()} by making \code{"about"}
      entirely optional
  }
}
\section{Changes in rkwarddev version 0.01-4 (2011-09-22)}{
  \itemize{
    \item fixed wrong doc link and one wrong object name in \code{rk.plugin.skeleton()}
    \item fixed attribute typo in \code{rk.XML.vars()}
    \item fixed issue with auto-generated IDs (now using \code{"_"} instead of \code{"."})
    \item added wizard code options to \code{rk.XML.plugin()} and \code{rk.plugin.skeleton()}
    \item added \code{"edit"} and \code{"create"} options to \code{rk.plugin.skeleton()}
    \item added function \code{rk.XML.varslot()}
    \item added possibility to add custom XML nodes to the varslot in \code{rk.XML.vars()}
    \item added possibility to paste ready-to-use JavaScript code directly to the
      \code{preprocess()}, \code{calculate()} and \code{printout()} functions, respectively
  }
}
\section{Changes in rkwarddev version 0.01-3 (2011-09-16)}{
  \itemize{
    \item added \code{rk.XML.spinbox()} and missing options to \code{rk.XML.browser()} and
      \code{rk.XML.saveobj()}
    \item corrected browser default type in \code{rk.XML.browser()}
    \item added wizard option to \code{rk.plugin.skeleton()}
  }
}
\section{Changes in rkwarddev version 0.01-2 (2011-09-15)}{
  \itemize{
    \item reworked \code{rk.XML.about()} to use person class objects for authors, and need
      less info to produce usable output
  }
}
\section{Changes in rkwarddev version 0.01-1 (2011-09-05)}{
  \itemize{
    \item added \code{rk.JS.scan()}, \code{rk.JS.doc()}, \code{rk.JS.array()}, \code{rk.rkh.scan()} and
      \code{rk.rkh.doc()}
    \item added \code{rk.XML.browser()},  \code{rk.XML.input()},  \code{rk.XML.saveobj()},
      \code{rk.XML.stretch()} and  \code{rk.XML.text()}
    \item added \code{rk.testsuite.doc()}
    \item shortened package name from \code{"rkwardplugdev"} to \code{"rkwarddev"}
    \item merged code into RKWard's svn tree
  }
}
\section{Changes in rkwarddev version 0.01-0 (2011-08-30)}{
  \itemize{
    \item forked rk.* functions from XiMpLe package into this one
    \item added functions \code{rk.XML.cbox()}, \code{rk.XML.row()}, \code{rk.XML.col()},
      \code{rk.XML.frame()}, \code{rk.XML.radio()} and \code{rk.XML.vars()}
    \item rewrote the ID handling
    \item added docs
    \item initial release via reaktanz.de
  }
}
