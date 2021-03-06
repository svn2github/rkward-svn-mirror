/***************************************************************************
                          xmlhelper.cpp  -  description
                             -------------------
    begin                : Fri May 6 2005
    copyright            : (C) 2005, 2007 by Thomas Friedrichsmeier
    email                : tfry@users.sourceforge.net
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#include "xmlhelper.h"

#include <klocale.h>

#include <qstringlist.h>
#include <qfile.h>
#include <qfileinfo.h>
#include <qdir.h>

#include "../debug.h"

//static
XMLHelper *XMLHelper::static_xml_helper=0;

XMLHelper::XMLHelper () {
	RK_TRACE (XML);

	highest_error = 0;
}

XMLHelper::~XMLHelper () {
	RK_TRACE (XML);
}

//static 
XMLHelper *XMLHelper::getStaticHelper () {
	RK_TRACE (XML);

	if (!static_xml_helper) {
		static_xml_helper = new XMLHelper ();
	}
	return static_xml_helper;
}

QDomElement XMLHelper::openXMLFile (const QString &filename, int debug_level, bool with_includes, bool with_snippets) {
	RK_TRACE (XML);

	int error_line, error_column;
	QString error_message;
	QDomDocument doc;

	XMLHelper::filename = filename;
	highest_error = 0;
	
	QFile f (filename);
	if (!f.open (QIODevice::ReadOnly)) displayError (0, i18n("Could not open file for reading"), debug_level, DL_ERROR);
	if (!doc.setContent(&f, false, &error_message, &error_line, &error_column)) {
		displayError (0, i18n ("Error parsing XML-file. Error-message was: '%1' in line '%2', column '%3'. Expect further errors to be reported below", error_message, error_line, error_column), debug_level, DL_ERROR);
	}
	f.close();

	QDomElement ret = doc.documentElement ();
	if (with_includes) {
		XMLChildList includes = nodeListToChildList (doc.elementsByTagName ("include"));
		for (XMLChildList::const_iterator it = includes.constBegin (); it != includes.constEnd (); ++it) {
			// resolve the file to include
			QDomElement el = *it;

			QString inc_filename = getStringAttribute (el, "file", QString::null, DL_ERROR);
			QDir base = QFileInfo (filename).absoluteDir ();
			inc_filename = base.filePath (inc_filename);

			// import
			QDomElement included = openXMLFile (inc_filename, debug_level, true, false);

			if (!included.isNull ()) {
				QDomElement copied = doc.importNode (included, true).toElement ();
	
				// insert everything within the document tag
				replaceWithChildren (&el, copied);
			}
		}
	}

	if (with_snippets) {
		return (resolveSnippets (ret));
	}

	return (ret);
}

void XMLHelper::replaceWithChildren (QDomNode *replaced, const QDomElement &replacement_parent) {
	RK_TRACE (XML);
	RK_ASSERT (replaced);

	QDomNode parent = replaced->parentNode ();
	XMLChildList replacement_children = getChildElements (replacement_parent, QString::null, DL_WARNING);
	for (XMLChildList::const_iterator it = replacement_children.constBegin (); it != replacement_children.constEnd (); ++it) {
		parent.insertBefore (*it, *replaced);
	}
	parent.removeChild (*replaced);
}

XMLChildList XMLHelper::nodeListToChildList (const QDomNodeList &from) {
	RK_TRACE (XML);

	int count = from.count ();
	XMLChildList ret;
	for (int i = 0; i < count; ++i) {
		ret.append (from.item (i).toElement ());
	}
	return ret;
}

QDomElement XMLHelper::resolveSnippets (QDomElement &from_doc) {
	RK_TRACE (XML);

	XMLChildList refs = nodeListToChildList (from_doc.elementsByTagName ("insert"));
	int ref_count = refs.count ();

	if (!ref_count) {	// nothing to resolve
		return (from_doc);
	}

	QDomElement snippets_section = getChildElement (from_doc, "snippets", DL_ERROR);
	XMLChildList snippets = getChildElements (snippets_section, "snippet", DL_ERROR);

	for (XMLChildList::const_iterator it = refs.constBegin (); it != refs.constEnd (); ++it) {
		QDomElement ref = *it;
		QString id = getStringAttribute (ref, "snippet", QString::null, DL_ERROR);
		displayError (&ref, "resolving snippet '" + id + "'", DL_DEBUG, DL_DEBUG);

		// resolve the reference
		QDomElement snippet;
		for (XMLChildList::const_iterator it = snippets.constBegin(); it != snippets.constEnd (); ++it) {
			if (getStringAttribute (*it, "id", QString::null, DL_ERROR) == id) {
				snippet = *it;
				break;
			}
		}
		if (snippet.isNull ()) {
			displayError (&ref, "no such snippet '" + id + "'", DL_ERROR, DL_ERROR);
		}

		// now insert it.
		replaceWithChildren (&ref, snippet.cloneNode (true).toElement ());
	}

	return from_doc;
}

XMLChildList XMLHelper::getChildElements (const QDomElement &parent, const QString &name, int debug_level) {
	RK_TRACE (XML);

	XMLChildList list;

	if (!parent.isNull()) {
		QDomNode n = parent.firstChild ();
		while (!n.isNull ()) {
			QDomElement e = n.toElement ();
			if (!e.isNull ()) {
				if ((name.isEmpty ()) || (e.tagName () == name)) {
					list.append (e);
				}
			}
			n = n.nextSibling ();
		}
	} else {
		displayError (&parent, i18n ("Trying to retrieve children of invalid element"), debug_level);
	}

	return (list);
}

QDomElement XMLHelper::getChildElement (const QDomElement &parent, const QString &name, int debug_level) {
	RK_TRACE (XML);

	XMLChildList list = getChildElements (parent, name, debug_level);
	if (list.count () != 1) {
		displayError (&parent, i18n ("Expected exactly one element '%1' but found %2", name, list.count ()), debug_level);
		QDomElement dummy;
		return dummy;
	}

	return list.first ();
}

QDomElement XMLHelper::findElementWithAttribute (const QDomElement &parent, const QString &attribute_name, const QString &attribute_value, bool recursive, int debug_level) {
	RK_TRACE (XML);

	XMLChildList list = getChildElements (parent, QString (), debug_level);
	for (XMLChildList::const_iterator it = list.constBegin (); it != list.constEnd (); ++it) {
		if ((*it).hasAttribute (attribute_name)) {
			if (attribute_value.isNull () || ((*it).attribute (attribute_name) == attribute_value)) {
				return (*it);
			}
		}
		if (recursive) {
			QDomElement found = findElementWithAttribute (*it, attribute_name, attribute_value, true, debug_level);
			if (!found.isNull ()) return found;
		}
	}

	QDomElement dummy;
	return dummy;
}

XMLChildList XMLHelper::findElementsWithAttribute (const QDomElement &parent, const QString &attribute_name, const QString &attribute_value, bool recursive, int debug_level) {
	RK_TRACE (XML);

	XMLChildList ret;
	XMLChildList list = getChildElements (parent, QString (), debug_level);
	for (XMLChildList::const_iterator it = list.constBegin (); it != list.constEnd (); ++it) {
		if ((*it).hasAttribute (attribute_name)) {
			if (attribute_value.isNull () || ((*it).attribute (attribute_name) == attribute_value)) {
				ret.append (*it);
			}
		}
		if (recursive) {
			XMLChildList subret = findElementsWithAttribute (*it, attribute_name, attribute_value, true, debug_level);
			for (XMLChildList::const_iterator it = subret.constBegin (); it != subret.constEnd (); ++it) {
				ret.append (*it);
			}
		}
	}

	return ret;
}


QString XMLHelper::getStringAttribute (const QDomElement &element, const QString &name, const QString &def, int debug_level) {
	RK_TRACE (XML);

	if (!element.hasAttribute (name)) {
		displayError (&element, i18n ("'%1'-attribute not given. Assuming '%2'", name, def), debug_level);
		return (def);
	}

	return (element.attribute (name));
}

int XMLHelper::getMultiChoiceAttribute (const QDomElement &element, const QString &name, const QString &values, int def, int debug_level) {
	RK_TRACE (XML);

	QStringList value_list = values.split (';');

	QString plain_value = getStringAttribute (element, name, value_list[def], debug_level);
	
	int index;
	if ((index = value_list.indexOf (plain_value)) >= 0) {
		return (index);
	} else {
		displayError (&element, i18n ("Illegal attribute value. Allowed values are one of '%1', only.", values), debug_level, DL_ERROR);
		return def;
	}
}

int XMLHelper::getIntAttribute (const QDomElement &element, const QString &name, int def, int debug_level) {
	RK_TRACE (XML);

	QString res = getStringAttribute (element, name, QString::number (def), debug_level);

	bool valid_number;;
	int ret = res.toInt (&valid_number);

	if (!valid_number) {
		displayError (&element, i18n ("Illegal attribute value. Only integer numbers are allowed."), debug_level, DL_ERROR);
		return def;
	}

	return ret;
}

double XMLHelper::getDoubleAttribute (const QDomElement &element, const QString &name, double def, int debug_level) {
	RK_TRACE (XML);

	QString res = getStringAttribute (element, name, QString::number (def), debug_level);

	bool valid_number;;
	double ret = res.toDouble (&valid_number);

	if (!valid_number) {
		displayError (&element, i18n ("Illegal attribute value. Only real numbers are allowed."), debug_level, DL_ERROR);
		return def;
	}

	return ret;
}

bool XMLHelper::getBoolAttribute (const QDomElement &element, const QString &name, bool def, int debug_level) {
	RK_TRACE (XML);

	QString defstring, res;
	if (def) defstring = "true";
	else defstring = "false";

	res = getStringAttribute (element, name, defstring, debug_level);
	if (res == "true") return true;
	if (res == "false") return false;

	displayError (&element, i18n ("Illegal attribute value. Allowed values are '%1' or '%2', only.", QString ("true"), QString ("false")), debug_level, DL_ERROR);
	return def;
}

void XMLHelper::displayError (const QDomNode *in_node, const QString &message, int debug_level, int message_level) {
	RK_TRACE (XML);

	if (message_level < debug_level) message_level = debug_level;
	if (highest_error < debug_level) highest_error = debug_level;

	if ((RK_Debug_Flags & XML) && (message_level >= RK_Debug_Level)) {
		QString backtrace = i18n ("XML-parsing '%1' ", filename);
		// create a "backtrace"
		QStringList list;

		if (in_node) {
			QDomNode node_copy = *in_node;
			while (!((node_copy.isNull ()) || (node_copy.isDocument ()))) {
				list.prepend (node_copy.nodeName ());
				node_copy = node_copy.parentNode ();
			}
		}

		backtrace += list.join ("->");

		RK_DO (qDebug ("%s: %s", backtrace.toLatin1 ().data (), message.toLatin1 ().data ()), XML, message_level);
	}
}

