/***************************************************************************
                          rkcommandeditorwindow  -  description
                             -------------------
    begin                : Mon Aug 30 2004
    copyright            : (C) 2004 by Thomas Friedrichsmeier
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
#include "rkcommandeditorwindow.h"

#include <kparts/partmanager.h>
#include <kparts/mainwindow.h>
#include <kparts/part.h>
#include <kparts/factory.h>

#include <ktexteditor/configinterface.h>
#include <ktexteditor/sessionconfiginterface.h>
#include <ktexteditor/viewcursorinterface.h>
#include <ktexteditor/printinterface.h>
#include <ktexteditor/encodinginterface.h>
#include <ktexteditor/editorchooser.h>
#include <ktexteditor/popupmenuinterface.h>

#include <qlayout.h>
#include <qpopupmenu.h>
#include <qapplication.h>
#include <qtabwidget.h>
#include <qfile.h>

#include <klocale.h>
#include <kmenubar.h>
#include <kmessagebox.h>
#include <kfiledialog.h>
#include <kaction.h>
#include <kstdaction.h>
#include <kaccel.h>
#include <klibloader.h>
#include <kiconloader.h>

#include "../misc/rkcommonfunctions.h"
#include "../core/robject.h"
#include "../rkglobals.h"
#include "../rkward.h"
#include "../khelpdlg.h"
#include "rkcommandeditorwindowpart.h"

#include "../debug.h"

#define GET_HELP_URL 1

RKCommandEditorWindow::RKCommandEditorWindow (QWidget *parent, bool use_r_highlighting) : RKMDIWindow (parent, RKMDIWindow::CommandEditorWindow) {
	RK_TRACE (COMMANDEDITOR);

	KLibFactory *factory = KLibLoader::self()->factory( "libkatepart" );
	if (factory) {
		// Create the part
		m_doc = (Kate::Document *) factory->create( this, "katepart", "KParts::ReadWritePart" );
		RK_ASSERT (m_doc);
		m_view = (Kate::View *) m_doc->widget();
	}

	// strip down the khtmlpart's GUI. remove some stuff we definitely don't need.
	RKCommonFunctions::removeContainers (m_doc, QStringList::split (',', "bookmarks,tools_spelling,tools_spelling_from_cursor,tools_spelling_selection,switch_to_cmd_line"), true);
	RKCommonFunctions::moveContainer (m_doc, "Menu", "tools", "edit", true);

	m_doc->insertChildClient (new RKCommandEditorWindowPart (m_view, this));

	QHBoxLayout *pLayout = new QHBoxLayout( this, 0, -1, "layout");
	pLayout->addWidget(m_view);

	setIcon (SmallIcon ("source"));

	connect (m_doc, SIGNAL (fileNameChanged ()), this, SLOT (updateCaption ()));
	connect (m_doc, SIGNAL (modifiedChanged ()), this, SLOT (updateCaption ()));		// of course most of the time this causes a redundant call to updateCaption. Not if a modification is undone, however.
	if (use_r_highlighting) setRHighlighting ();

	updateCaption ();	// initialize
}

RKCommandEditorWindow::~RKCommandEditorWindow () {
	RK_TRACE (COMMANDEDITOR);
	delete m_doc;
}

QString RKCommandEditorWindow::getRDescription () {
	RK_TRACE (COMMANDEDITOR);

	return (RObject::rQuote ("script:" + m_doc->url ().url ()));
}

void RKCommandEditorWindow::closeEvent (QCloseEvent *e) {
	if (isModified ()) {
		int status = KMessageBox::warningYesNo (this, i18n ("The document \"%1\" has been modified. Close it anyway?").arg (caption ()), i18n ("File not saved"));
	
		if (status != KMessageBox::Yes) {
			e->ignore ();
			return;
		}
	}

	QWidget::closeEvent (e);
}

void RKCommandEditorWindow::setRHighlighting () {
	// set syntax-highlighting for R
	int modes_count = highlightingInterface (m_doc)->hlModeCount ();
	bool found_mode = false;
	int i;
	for (i = 0; i < modes_count; ++i) {
		if (highlightingInterface (m_doc)->hlModeName (i).lower() == "r script") {
			found_mode = true;
			break;
		}
	}
	if (found_mode) {
		highlightingInterface (m_doc)->setHlMode (i);
	} else {
		RK_DO (qDebug ("No syntax highlighting definition found for r script."), COMMANDEDITOR, DL_WARNING);
	}
}

QString RKCommandEditorWindow::getSelection () {
	RK_TRACE (COMMANDEDITOR);
	return selectionInterface (m_doc)->selection ();
}

QString RKCommandEditorWindow::getLine () {
	RK_TRACE (COMMANDEDITOR);
	return m_view->currentTextLine ();
}

QString RKCommandEditorWindow::getText () {
	RK_TRACE (COMMANDEDITOR);
	return editInterface (m_doc)->text ();
}

void RKCommandEditorWindow::copy () {
	RK_TRACE (COMMANDEDITOR);

	m_view->copy ();
}

bool RKCommandEditorWindow::openURL (const KURL &url, bool use_r_highlighting, bool read_only){
	RK_TRACE (COMMANDEDITOR);
	if (m_doc->openURL (url)){
		if (use_r_highlighting) setRHighlighting ();
		m_doc->setReadWrite (!read_only);

		updateCaption ();

		return true;
	}
	return false;
}

bool RKCommandEditorWindow::isModified() {
	RK_TRACE (COMMANDEDITOR);
    return m_doc->isModified();
}

void RKCommandEditorWindow::insertText (const QString &text) {
	RK_TRACE (COMMANDEDITOR);
	m_doc->insertText (m_view->cursorLine  (), m_view->cursorColumn (), text);
	setFocus();
}

void RKCommandEditorWindow::setText (const QString &text) {
	RK_TRACE (COMMANDEDITOR);
	m_doc->setText (text);
}

void RKCommandEditorWindow::updateCaption () {
	RK_TRACE (COMMANDEDITOR);
	QString name = m_doc->url ().fileName ();
	if (name.isEmpty ()) name = m_doc->url ().prettyURL ();
	if (name.isEmpty ()) name = i18n ("Unnamed");
	if (isModified ()) name.append (i18n (" [modified]"));

	setCaption (name);
}

void RKCommandEditorWindow::showHelp () {
	RK_TRACE (COMMANDEDITOR);
	uint para=0; uint p=0;
	m_view->cursorPosition (&para, &p);

	QString line = m_view->currentTextLine() + " ";

	RKGlobals::helpDialog ()->getContextHelp (line, p);
}

#include "rkcommandeditorwindow.moc"
