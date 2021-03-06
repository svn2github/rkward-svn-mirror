/***************************************************************************
                          rkcommandeditorwindow  -  description
                             -------------------
    begin                : Mon Aug 30 2004
    copyright            : (C) 2004, 2006, 2007, 2009 by Thomas Friedrichsmeier
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

#include <kxmlguifactory.h>

#include <ktexteditor/configinterface.h>
#include <ktexteditor/sessionconfiginterface.h>
#include <ktexteditor/editorchooser.h>
#include <ktexteditor/modificationinterface.h>

#include <qlayout.h>
#include <qapplication.h>
#include <qtabwidget.h>
#include <qfile.h>
#include <qtimer.h>
#include <qobject.h>
#include <QHBoxLayout>
#include <QCloseEvent>
#include <QFrame>
#include <QLabel>
#include <QKeyEvent>
#include <QEvent>
#include <QClipboard>

#include <klocale.h>
#include <kmenu.h>
#include <kmessagebox.h>
#include <kfiledialog.h>
#include <kaction.h>
#include <kstandardaction.h>
#include <klibloader.h>
#include <kactioncollection.h>
#include <kactionmenu.h>

#include "../misc/rkcommonfunctions.h"
#include "../misc/rkstandardicons.h"
#include "../misc/rkstandardactions.h"
#include "../core/robjectlist.h"
#include "../settings/rksettings.h"
#include "../settings/rksettingsmodulecommandeditor.h"
#include "../rkconsole.h"
#include "../rkglobals.h"
#include "../rkward.h"
#include "rkhelpsearchwindow.h"

#include "../debug.h"

RKCommandEditorWindowPart::RKCommandEditorWindowPart (QWidget *parent) : KParts::Part (parent) {
	RK_TRACE (COMMANDEDITOR);

	setComponentData (KGlobal::mainComponent ());
	setWidget (parent);
	setXMLFile ("rkcommandeditorwindowpart.rc");
}

RKCommandEditorWindowPart::~RKCommandEditorWindowPart () {
	RK_TRACE (COMMANDEDITOR);
}

#define GET_HELP_URL 1
#define NUM_BLOCK_RECORDS 6

RKCommandEditorWindow::RKCommandEditorWindow (QWidget *parent, bool use_r_highlighting) : RKMDIWindow (parent, RKMDIWindow::CommandEditorWindow) {
	RK_TRACE (COMMANDEDITOR);

	KTextEditor::Editor* editor = KTextEditor::editor("katepart");
	RK_ASSERT (editor);

	m_doc = editor->createDocument (this);
	RK_ASSERT (m_doc);
	// yes, we want to be notified, if the file has changed on disk.
	// why, oh why is this not the default?
	// this needs to be set *before* the view is created!
	KTextEditor::ModificationInterface* em_iface = qobject_cast<KTextEditor::ModificationInterface*> (m_doc);
	if (em_iface) em_iface->setModifiedOnDiskWarning (true);
	else RK_ASSERT (false);
	m_view = m_doc->createView (this);

	setFocusProxy (m_view);
	setFocusPolicy (Qt::StrongFocus);

	RKCommandEditorWindowPart* part = new RKCommandEditorWindowPart (m_view);
	part->insertChildClient (m_view);
	setPart (part);
	fixupPartGUI (false);
	initializeActions (part->actionCollection ());
	initializeActivationSignals ();

	QHBoxLayout *layout = new QHBoxLayout (this);
	layout->setContentsMargins (0, 0, 0, 0);
	layout->addWidget(m_view);

	connect (m_doc, SIGNAL (documentUrlChanged (KTextEditor::Document*)), this, SLOT (updateCaption (KTextEditor::Document*)));
	connect (m_doc, SIGNAL (modifiedChanged (KTextEditor::Document*)), this, SLOT (updateCaption (KTextEditor::Document*)));		// of course most of the time this causes a redundant call to updateCaption. Not if a modification is undone, however.
	connect (m_doc, SIGNAL (textChanged (KTextEditor::Document*)), this, SLOT (tryCompletionProxy (KTextEditor::Document*)));
	connect (m_view, SIGNAL (selectionChanged(KTextEditor::View*)), this, SLOT (selectionChanged(KTextEditor::View*)));
	// somehow the katepart loses the context menu each time it loses focus
	connect (m_view, SIGNAL (focusIn(KTextEditor::View*)), this, SLOT (focusIn(KTextEditor::View*)));
	completion_timer = new QTimer (this);
	completion_timer->setSingleShot (true);
	connect (completion_timer, SIGNAL (timeout ()), this, SLOT (tryCompletion()));

	completion_model = 0;
	cc_iface = 0;
	hinter = 0;
	if (use_r_highlighting) {
		setRHighlighting ();
		cc_iface = qobject_cast<KTextEditor::CodeCompletionInterface*> (m_view);
		if (cc_iface) {
			cc_iface->setAutomaticInvocationEnabled (true);
			completion_model = new RKCodeCompletionModel (this);
		} else {
			RK_ASSERT (false);
		}
		hinter = new RKFunctionArgHinter (this, m_view);
	}

	smart_iface = qobject_cast<KTextEditor::SmartInterface*> (m_doc);
	initBlocks ();
	RK_ASSERT (smart_iface);

	updateCaption ();	// initialize
	QTimer::singleShot (0, this, SLOT (setPopupMenu ()));
}

RKCommandEditorWindow::~RKCommandEditorWindow () {
	RK_TRACE (COMMANDEDITOR);
	delete hinter;
	delete m_doc;
}

void RKCommandEditorWindow::fixupPartGUI (bool reload) {
	RK_TRACE (COMMANDEDITOR);

	RKMDIWindow::fixupPartGUI (reload);

	// strip down the katepart's GUI. remove some stuff we definitely don't need.
	RKCommonFunctions::removeContainers (m_view, QString ("bookmarks,tools_spelling,tools_spelling_from_cursor,tools_spelling_selection,switch_to_cmd_line").split (','), true);
	RKCommonFunctions::moveContainer (m_view, "Menu", "tools", "edit", true);
}

void RKCommandEditorWindow::initializeActions (KActionCollection* ac) {
	RK_TRACE (COMMANDEDITOR);

	action_run_all = RKStandardActions::runAll (this, "run_all", this, SLOT (runAll()));
	action_run_selection = RKStandardActions::runSelection (this, "run_selection", this, SLOT (runSelection()));
	action_run_selection->setEnabled (false);
	action_run_line = RKStandardActions::runLine (this, "run_line", this, SLOT (runLine()));

	action_help_function = RKStandardActions::functionHelp (this, "function_reference", this, SLOT (showHelp()));

	actionmenu_run_block = new KActionMenu (i18n ("Run block"), this);
	actionmenu_run_block->setDelayed (false);	// KDE4: TODO does not work correctly in the tool bar.
	ac->addAction ("run_block", actionmenu_run_block);
	connect (actionmenu_run_block->menu(), SIGNAL (aboutToShow()), this, SLOT (clearUnusedBlocks()));
	actionmenu_mark_block = new KActionMenu (i18n ("Mark selection as block"), this);
	ac->addAction ("mark_block", actionmenu_mark_block);
	connect (actionmenu_mark_block->menu(), SIGNAL (aboutToShow()), this, SLOT (clearUnusedBlocks()));
	actionmenu_unmark_block = new KActionMenu (i18n ("Unmark block"), this);
	ac->addAction ("unmark_block", actionmenu_unmark_block);
	connect (actionmenu_unmark_block->menu(), SIGNAL (aboutToShow()), this, SLOT (clearUnusedBlocks()));

	action_setwd_to_script = ac->addAction ("setwd_to_script", this, SLOT (setWDToScript ()));
	action_setwd_to_script->setText (i18n ("CD to script directory"));
#if KDE_IS_VERSION(4,3,0)
	action_setwd_to_script->setHelpText (i18n ("Change the working directory to the directory of this script"));
#endif
	action_setwd_to_script->setIcon (RKStandardIcons::getIcon (RKStandardIcons::ActionCDToScript));

	KAction* action_configure = ac->addAction ("configure_commandeditor", this, SLOT (configure()));
	action_configure->setText (i18n ("Configure Script Editor"));
}

void RKCommandEditorWindow::initBlocks () {
	RK_TRACE (COMMANDEDITOR);
	RK_ASSERT (block_records.isEmpty ());

	KActionCollection* ac = getPart ()->actionCollection ();

	int i = 0;
	QColor colors[NUM_BLOCK_RECORDS];
	colors[i++] = QColor (255, 0, 0);
	colors[i++] = QColor (0, 255, 0);
	colors[i++] = QColor (0, 0, 255);
	colors[i++] = QColor (255, 255, 0);
	colors[i++] = QColor (255, 0, 255);
	colors[i++] = QColor (0, 255, 255);
	RK_ASSERT (i == NUM_BLOCK_RECORDS);

	// sorry for those idiotic shortcuts, but I just could not find any decent unused ones
	i = 0;
	QKeySequence shortcuts[NUM_BLOCK_RECORDS];
	shortcuts[i++] = QKeySequence (Qt::AltModifier | Qt::ShiftModifier | Qt::Key_F1);
	shortcuts[i++] = QKeySequence (Qt::AltModifier | Qt::ShiftModifier | Qt::Key_F2);
	shortcuts[i++] = QKeySequence (Qt::AltModifier | Qt::ShiftModifier | Qt::Key_F3);
	shortcuts[i++] = QKeySequence (Qt::AltModifier | Qt::ShiftModifier | Qt::Key_F4);
	shortcuts[i++] = QKeySequence (Qt::AltModifier | Qt::ShiftModifier | Qt::Key_F5);
	shortcuts[i++] = QKeySequence (Qt::AltModifier | Qt::ShiftModifier | Qt::Key_F6);
	RK_ASSERT (i == NUM_BLOCK_RECORDS);

	for (i = 0; i < NUM_BLOCK_RECORDS; ++i) {
		BlockRecord record;

		QColor shaded = colors[i];
		shaded.setAlpha (30);
		record.attribute = KTextEditor::Attribute::Ptr (new KTextEditor::Attribute ());
		record.attribute->clearProperty (KTextEditor::Attribute::BackgroundFillWhitespace);
		record.attribute->setBackground (shaded);

		QPixmap colorsquare (16, 16);
		colorsquare.fill (colors[i]);
		QIcon icon (colorsquare);

		record.mark = ac->addAction ("markblock" + QString::number (i), this, SLOT (markBlock()));
		record.mark->setIcon (icon);
		record.mark->setData (i);
		actionmenu_mark_block->addAction (record.mark);
		record.unmark = ac->addAction ("unmarkblock" + QString::number (i), this, SLOT (unmarkBlock()));
		record.unmark->setIcon (icon);
		record.unmark->setData (i);
		actionmenu_unmark_block->addAction (record.unmark);
		record.run = ac->addAction ("runblock" + QString::number (i), this, SLOT (runBlock()));
		record.run->setShortcut (shortcuts[i]);
		record.run->setIcon (icon);
		record.run->setData (i);
		actionmenu_run_block->addAction (record.run);

		block_records.append (record);
		removeBlock (i, true);	// initialize to empty
	}
	RK_ASSERT (block_records.size () == NUM_BLOCK_RECORDS);
}

void RKCommandEditorWindow::focusIn (KTextEditor::View* v) {
	RK_TRACE (COMMANDEDITOR);
	RK_ASSERT (v == m_view);

	setPopupMenu ();
}

void RKCommandEditorWindow::setPopupMenu () {
	RK_TRACE (COMMANDEDITOR);

	if (!getPart ()->factory ()) return;
	m_view->setContextMenu (static_cast<QMenu *> (getPart ()->factory ()->container ("ktexteditor_popup", getPart ())));
}

QString RKCommandEditorWindow::fullCaption () {
	RK_TRACE (COMMANDEDITOR);

	if (m_doc->url ().isEmpty ()) {
		return (shortCaption ());
	} else {
		QString cap = m_doc->url ().url ();
		if (isModified ()) cap.append (i18n (" [modified]"));
		return (cap);
	}
}

QString RKCommandEditorWindow::getDescription () {
	RK_TRACE (COMMANDEDITOR);

	return ("script:" + m_doc->url ().url ());
}

void RKCommandEditorWindow::closeEvent (QCloseEvent *e) {
	if (isModified ()) {
		int status = KMessageBox::warningYesNo (this, i18n ("The document \"%1\" has been modified. Close it anyway?", windowTitle ()), i18n ("File not saved"));
	
		if (status != KMessageBox::Yes) {
			e->ignore ();
			return;
		}
	}

	QWidget::closeEvent (e);
}

// KDE4 TODO: inline
void RKCommandEditorWindow::setRHighlighting () {
	RK_TRACE (COMMANDEDITOR);

	// set syntax-highlighting for R
	if (!m_doc->setHighlightingMode("R Script")) RK_DO (qDebug ("R syntax highlighting defintion not found!"), COMMANDEDITOR, DL_ERROR);
}

void RKCommandEditorWindow::copy () {
	RK_TRACE (COMMANDEDITOR);

	QApplication::clipboard()->setText (m_view->selectionText ());
}

void RKCommandEditorWindow::setReadOnly (bool ro) {
	RK_TRACE (COMMANDEDITOR);

	m_doc->setReadWrite (!ro);
}

bool RKCommandEditorWindow::openURL (const KUrl &url, bool use_r_highlighting, bool read_only){
	RK_TRACE (COMMANDEDITOR);
	if (m_doc->openUrl (url)){
		if (use_r_highlighting) setRHighlighting ();
		setReadOnly (read_only);

		updateCaption ();

		return true;
	}
	return false;
}

KUrl RKCommandEditorWindow::url () {
//	RK_TRACE (COMMANDEDITOR);
	return (m_doc->url ());
}

bool RKCommandEditorWindow::isModified() {
	RK_TRACE (COMMANDEDITOR);
	return m_doc->isModified();
}

void RKCommandEditorWindow::insertText (const QString &text) {
// KDE4: inline?
	RK_TRACE (COMMANDEDITOR);
	m_view->insertText (text);
	setFocus();
}

void RKCommandEditorWindow::setText (const QString &text) {
	RK_TRACE (COMMANDEDITOR);
	m_doc->setText (text);
}

void RKCommandEditorWindow::updateCaption (KTextEditor::Document*) {
	RK_TRACE (COMMANDEDITOR);
	QString name = url ().fileName ();
	if (name.isEmpty ()) name = url ().prettyUrl ();
	if (name.isEmpty ()) name = i18n ("Unnamed");
	if (isModified ()) name.append (i18n (" [modified]"));

	setCaption (name);

	// Well, this does not really belong, here, but needs to happen on pretty much the same occastions:
	action_setwd_to_script->setEnabled (!url ().isEmpty ());
}

void RKCommandEditorWindow::showHelp () {
	RK_TRACE (COMMANDEDITOR);

	KTextEditor::Cursor c = m_view->cursorPosition();
	QString line = m_doc->line(c.line ()) + ' ';

	RKHelpSearchWindow::mainHelpSearch ()->getContextHelp (line, c.column());
}

void RKCommandEditorWindow::tryCompletionProxy (KTextEditor::Document*) {
	if (RKSettingsModuleCommandEditor::completionEnabled ()) {
		if (cc_iface && cc_iface->isCompletionActive ()) {
			tryCompletion ();
		} else {
			completion_timer->start (RKSettingsModuleCommandEditor::completionTimeout ());
		}
	}
}

QString RKCommandEditorWindow::currentCompletionWord () const {
	RK_TRACE (COMMANDEDITOR);
// KDE4 TODO: This may no longer be needed, if the katepart gets fixed not to abort completions when the range
// contains dots or other special characters
	KTextEditor::Cursor c = m_view->cursorPosition();
	uint para=c.line(); uint cursor_pos=c.column();

	QString current_line = m_doc->line (para);
	if (current_line.lastIndexOf ("#", cursor_pos) >= 0) return QString ();	// do not hint while in comments

	return RKCommonFunctions::getCurrentSymbol (current_line, cursor_pos, false);
}

void RKCommandEditorWindow::tryCompletion () {
	// TODO: merge this with RKConsole::doTabCompletion () somehow
	RK_TRACE (COMMANDEDITOR);
	if ((!cc_iface) || (!completion_model)) {
		RK_ASSERT (false);
		return;
	}

	KTextEditor::Cursor c = m_view->cursorPosition();
	uint para=c.line(); uint cursor_pos=c.column();

	QString current_line = m_doc->line (para);
	int start;
	int end;
	RKCommonFunctions::getCurrentSymbolOffset (current_line, cursor_pos, false, &start, &end);

	KTextEditor::Range range = KTextEditor::Range (para, start, para, end);
	QString word = m_doc->text (range);
	if (current_line.lastIndexOf ("#", cursor_pos) >= 0) word.clear ();	// do not hint while in comments
	if (word.length () >= RKSettingsModuleCommandEditor::completionMinChars ()) {
		completion_model->updateCompletionList (word);
		if (completion_model->isEmpty ()) {
			cc_iface->abortCompletion ();
		} else {
			if (!cc_iface->isCompletionActive ()) {
				cc_iface->startCompletion (range, completion_model);
			}
		}
	} else {
		cc_iface->abortCompletion ();
	}
}

bool RKCommandEditorWindow::provideContext (unsigned int line_rev, QString *context, int *cursor_position) {
	RK_TRACE (COMMANDEDITOR);

	KTextEditor::Cursor c = m_view->cursorPosition();
	uint current_line_num=c.line(); uint cursor_pos=c.column();

	if (line_rev > current_line_num) return false;

	if (line_rev == 0) {
		*cursor_position = cursor_pos;
	} else {
		*cursor_position = -1;
	}
	*context = m_doc->line (current_line_num - line_rev);

	return true;
}

void RKCommandEditorWindow::setWDToScript () {
	RK_TRACE (COMMANDEDITOR);

	RK_ASSERT (!url ().isEmpty ());
	QString dir = url ().directory ();
#ifdef Q_OS_WIN
	// KURL::directory () returns a leading slash on windows as of KDElibs 4.3
	while (dir.startsWith ('/')) dir.remove (0, 1);
#endif
	RKConsole::pipeUserCommand (new RCommand ("setwd (\"" + dir + "\")", RCommand::User, i18n ("cd to current script directory")));
}

void RKCommandEditorWindow::runSelection() {
	RK_TRACE (COMMANDEDITOR);

	QString command = m_view->selectionText ();
	if (command.isEmpty ()) return;

	RKConsole::pipeUserCommand (new RCommand (command, RCommand::User, QString::null));
}

void RKCommandEditorWindow::runLine() {
	RK_TRACE (COMMANDEDITOR);

	KTextEditor::Cursor c = m_view->cursorPosition();
	QString command = m_doc->line (c.line());
	if (!command.isEmpty ()) RKConsole::pipeUserCommand (new RCommand (command, RCommand::User, QString::null));

	// advance to next line (NOTE: m_view->down () won't work on auto-wrapped lines)
	c.setLine(c.line() + 1);
	m_view->setCursorPosition (c);
}


void RKCommandEditorWindow::runAll () {
	RK_TRACE (COMMANDEDITOR);

	QString command = m_doc->text ();
	if (command.isEmpty ()) return;

	RKConsole::pipeUserCommand (command);
}

void RKCommandEditorWindow::runBlock () {
	RK_TRACE (COMMANDEDITOR);

	QAction* action = qobject_cast<QAction*>(sender ());
	if (!action) {
		RK_ASSERT (false);
		return;
	}

	clearUnusedBlocks ();	// this block might have been removed meanwhile
	int index = action->data ().toInt ();
	RK_ASSERT ((index >= 0) && (index < block_records.size ()));
	if (block_records[index].active) {
		QString command = m_doc->text (*(block_records[index].range));
		if (command.isEmpty ()) return;
	
		RKConsole::pipeUserCommand (new RCommand (command, RCommand::User, QString::null));
	}
}

void RKCommandEditorWindow::markBlock () {
	RK_TRACE (COMMANDEDITOR);

	QAction* action = qobject_cast<QAction*>(sender ());
	if (!action) {
		RK_ASSERT (false);
		return;
	}

	int index = action->data ().toInt ();
	RK_ASSERT ((index >= 0) && (index < block_records.size ()));
	if (m_view->selection ()) {
		addBlock (index, m_view->selectionRange ());
	} else {
		RK_ASSERT (false);
	}
}

void RKCommandEditorWindow::unmarkBlock () {
	RK_TRACE (COMMANDEDITOR);

	QAction* action = qobject_cast<QAction*>(sender ());
	if (!action) {
		RK_ASSERT (false);
		return;
	}

	int index = action->data ().toInt ();
	RK_ASSERT ((index >= 0) && (index < block_records.size ()));
	removeBlock (index);
}

void RKCommandEditorWindow::clearUnusedBlocks () {
	RK_TRACE (COMMANDEDITOR);

	for (int i = 0; i < block_records.size (); ++i) {
		if (block_records[i].active) {
// TODO: do we need to check whether the range was deleted? Does the katepart do such evil things?
			if (!block_records[i].range->isValid () || block_records[i].range->isEmpty ()) {
				removeBlock (i, true);
			}
		}
	}
}

void RKCommandEditorWindow::addBlock (int index, const KTextEditor::Range& range) {
	RK_TRACE (COMMANDEDITOR);
	RK_ASSERT ((index >= 0) && (index < block_records.size ()));

	clearUnusedBlocks ();
	removeBlock (index);

	KTextEditor::SmartRange* srange = smart_iface->newSmartRange (range);
	srange->setInsertBehavior (KTextEditor::SmartRange::ExpandRight);

	QString actiontext = i18n ("%1 (Active)", index + 1);
	block_records[index].range = srange;
	srange->setAttribute (block_records[index].attribute);
	block_records[index].active = true;
	block_records[index].mark->setText (actiontext);
	block_records[index].unmark->setText (actiontext);
	block_records[index].unmark->setEnabled (true);
	block_records[index].run->setText (actiontext);
	block_records[index].run->setEnabled (true);

	smart_iface->addHighlightToView (m_view, srange);
}

void RKCommandEditorWindow::removeBlock (int index, bool was_deleted) {
	RK_TRACE (COMMANDEDITOR);
	RK_ASSERT ((index >= 0) && (index < block_records.size ()));

	if (!was_deleted) {
		smart_iface->removeHighlightFromView (m_view, block_records[index].range);
		delete (block_records[index].range);
	}

	QString actiontext = i18n ("%1 (Unused)", index + 1);
	block_records[index].range = 0;
	block_records[index].active = false;
	block_records[index].mark->setText (actiontext);
	block_records[index].unmark->setText (actiontext);
	block_records[index].unmark->setEnabled (false);
	block_records[index].run->setText (actiontext);
	block_records[index].run->setEnabled (false);
}

void RKCommandEditorWindow::selectionChanged (KTextEditor::View* view) {
	RK_TRACE (COMMANDEDITOR);
	RK_ASSERT (view == m_view);

	if (view->selection ()) {
		action_run_selection->setEnabled (true);
		actionmenu_mark_block->setEnabled (true);
	} else {
		action_run_selection->setEnabled (false);
		actionmenu_mark_block->setEnabled (false);
	}
}

void RKCommandEditorWindow::configure () {
	RK_TRACE (COMMANDEDITOR);

	RKSettings::configureSettings (RKSettings::PageCommandEditor, this);
}

//////////////////////// RKFunctionArgHinter //////////////////////////////

#include "../core/rfunctionobject.h"

RKFunctionArgHinter::RKFunctionArgHinter (RKScriptContextProvider *provider, KTextEditor::View* view) {
	RK_TRACE (COMMANDEDITOR);

	RKFunctionArgHinter::provider = provider;
	RKFunctionArgHinter::view = view;

	const QObjectList children = view->children ();
	for (QObjectList::const_iterator it = children.constBegin(); it != children.constEnd (); ++it) {
		QObject *obj = *it;
		obj->installEventFilter (this);
	}

	arghints_popup = new QFrame (0, Qt::ToolTip);
	QVBoxLayout *layout = new QVBoxLayout (arghints_popup);
	layout->setContentsMargins (2, 2, 2, 2);
	arghints_popup->setFrameStyle (QFrame::Plain);
	arghints_popup->setFrameShape (QFrame::Box);
	arghints_popup->setLineWidth (1);
	arghints_popup_text = new QLabel (arghints_popup);
	layout->addWidget (arghints_popup_text);
	arghints_popup->hide ();
	active = false;

	connect (&updater, SIGNAL (timeout()), this, SLOT (updateArgHintWindow()));
}

RKFunctionArgHinter::~RKFunctionArgHinter () {
	RK_TRACE (COMMANDEDITOR);
}

void RKFunctionArgHinter::tryArgHint () {
	RK_TRACE (COMMANDEDITOR);

	// do this in the next event cycle to make sure any inserted characters have truly been inserted
	QTimer::singleShot (0, this, SLOT (tryArgHintNow ()));
}

void RKFunctionArgHinter::tryArgHintNow () {
	RK_TRACE (COMMANDEDITOR);

	int line_rev;
	int cursor_pos;
	QString current_context;
	QString current_line;

	// fetch the most immediate context line. More will be fetched later, if appropriate
	bool have_context = provider->provideContext (line_rev = 0, &current_line, &cursor_pos);
	RK_ASSERT (have_context);
	RK_ASSERT (cursor_pos >= 0);
	current_context = current_line;

	// find the corrresponding opening brace
	int matching_left_brace_pos;
	int brace_level = 1;
	int i = cursor_pos;

	// fix up seems to be needed
	if (current_context.isEmpty ()) {
		hideArgHint ();
		return;
	}
	if (i >= current_context.size ()) i = current_context.size () -1;
	if (i < 0) i = 0;

	while (true) {
		if (current_context.at (i) == QChar (')')) {
			brace_level++;
		} else if (current_context.at (i) == QChar ('(')) {
			brace_level--;
			if (!brace_level) break;
		}

		--i;
		if (i < 0) {
			bool have_context = provider->provideContext (++line_rev, &current_line, &cursor_pos);
			if ((!have_context) || (current_line.isEmpty ())) break;

			RK_ASSERT (cursor_pos < 0);
			current_context.prepend (current_line);
			i = current_line.length () - 1;
		}
	}

	if (!brace_level) matching_left_brace_pos = i;
	else {
		hideArgHint ();
		return;
	}

	// now find where the symbol to the left ends
	// there cannot be a line-break between the opening brace, and the symbol name (or can there?), so no need to fetch further context
	int potential_symbol_end = matching_left_brace_pos - 1;
	while ((potential_symbol_end >= 0) && current_context.at (potential_symbol_end).isSpace ()) {
		--potential_symbol_end;
	}
	if (potential_symbol_end < 0) {
		hideArgHint ();
		return;
	}

	// now identify the symbol and object (if any)
	QString effective_symbol = RKCommonFunctions::getCurrentSymbol (current_context, potential_symbol_end+1);
	if (effective_symbol.isEmpty ()) {
		hideArgHint ();
		return;
	}

	RObject *object = RObjectList::getObjectList ()->findObject (effective_symbol);
	if ((!object) || (!object->isType (RObject::Function))) {
		hideArgHint ();
		return;
	}

	// initialize and show popup
	arghints_popup_text->setText (effective_symbol + " (" + static_cast<RFunctionObject*> (object)->printArgs () + ')');
	arghints_popup->resize (arghints_popup_text->sizeHint () + QSize (2, 2));
	active = true;
	updater.start (50);
	updateArgHintWindow ();
}

void RKFunctionArgHinter::updateArgHintWindow () {
	RK_TRACE (COMMANDEDITOR);

	if (!active) return;

	arghints_popup->move (view->mapToGlobal (view->cursorPositionCoordinates () + QPoint (0, arghints_popup->height ())));
	if (view->hasFocus ()) arghints_popup->show ();
	else arghints_popup->hide ();
}

void RKFunctionArgHinter::hideArgHint () {
	RK_TRACE (COMMANDEDITOR);
	arghints_popup->hide ();
	active = false;
	updater.stop ();
}

bool RKFunctionArgHinter::eventFilter (QObject *, QEvent *e) {
	if (e->type () == QEvent::KeyPress || e->type () == QEvent::ShortcutOverride) {
		RK_TRACE (COMMANDEDITOR);	// avoid loads of empty traces, putting this here
		QKeyEvent *k = static_cast<QKeyEvent *> (e);

		if (k->key() == Qt::Key_Enter || k->key() == Qt::Key_Return || k->key () == Qt::Key_Up || k->key () == Qt::Key_Down || k->key () == Qt::Key_Left || k->key () == Qt::Key_Right || k->key () == Qt::Key_Home || k->key () == Qt::Key_Tab) {
			hideArgHint ();
		} else if (k->key () == Qt::Key_Backspace || k->key () == Qt::Key_Delete){
			tryArgHint ();
		} else {
			QString text = k->text ();
			if (text == "(") {
				tryArgHint ();
			} else if (text == ")") {
				tryArgHint ();
			}
		}
	}

	return false;
}

//////////////////////// RKCodeCompletionModel ////////////////////

RKCodeCompletionModel::RKCodeCompletionModel (RKCommandEditorWindow *parent) : KTextEditor::CodeCompletionModel (parent) {
	RK_TRACE (COMMANDEDITOR);

	setRowCount (0);
	command_editor = parent;
}

RKCodeCompletionModel::~RKCodeCompletionModel () {
	RK_TRACE (COMMANDEDITOR);
}

void RKCodeCompletionModel::updateCompletionList (const QString& symbol) {
	RK_TRACE (COMMANDEDITOR);

	if (current_symbol == symbol) return;	// already up to date

	RObject::RObjectSearchMap map;
	RObjectList::getObjectList ()->findObjectsMatching (symbol, &map);

	int count = map.size ();
	list.clear ();
	list_names.clear ();
	list.reserve (count);
	list_names.reserve (count);
	// this is silly, but we need an int indexable storage, so we copy the map to a list
	for (RObject::RObjectSearchMap::const_iterator it = map.constBegin (); it != map.constEnd (); ++it) {
		list.append (it.value ());
		// the second list is used to store the name that should be used for completion.
		// This may be object->getBaseName() or object->getFullName () depending on whether the object is
		// masked or not.
		list_names.append (it.key ());
	}

	setRowCount (count);
	current_symbol = symbol;

	reset ();

#warning deal with object removals while the completion model is active! Maybe cache all information?
}

void RKCodeCompletionModel::completionInvoked (KTextEditor::View*, const KTextEditor::Range&, InvocationType) {
	RK_TRACE (COMMANDEDITOR);

	// we totally ignore whichever range the katepart thinks we should offer a completion on.
	// it is often wrong, esp, when there are dots in the symbol
// KDE4 TODO: This may no longer be needed, if the katepart gets fixed not to abort completions when the range
// contains dots or other special characters
	updateCompletionList (command_editor->currentCompletionWord ());
}

void RKCodeCompletionModel::executeCompletionItem (KTextEditor::Document *document, const KTextEditor::Range &word, int row) const {
	RK_TRACE (COMMANDEDITOR);

	RK_ASSERT (list_names.size () > row);

	document->replaceText (word, list_names[row]);
}

QVariant RKCodeCompletionModel::data (const QModelIndex& index, int role) const {

	int col = index.column ();
	int row = index.row ();

	if (index.parent ().isValid ()) return QVariant ();
	if (row >= list.count ()) return QVariant ();

	RObject* object = list[row];
	RK_ASSERT (object);

	if ((role == Qt::DisplayRole) || (role==KTextEditor::CodeCompletionModel::CompletionRole)) {
		if (col == KTextEditor::CodeCompletionModel::Name) {
			return (object->getBaseName ());
		}
	} else if (role == Qt::DecorationRole) {
		if (col == KTextEditor::CodeCompletionModel::Icon) {
			return RKStandardIcons::iconForObject (object);
		}
	}

	return QVariant ();
}

#include "rkcommandeditorwindow.moc"
