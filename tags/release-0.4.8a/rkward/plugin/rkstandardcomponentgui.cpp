/***************************************************************************
                          rkstandardcomponentgui  -  description
                             -------------------
    begin                : Sun Mar 19 2006
    copyright            : (C) 2006, 2007 by Thomas Friedrichsmeier
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

#include "rkstandardcomponentgui.h"

#include <klocale.h>
#include <kaction.h>
#include <kurl.h>

#include <qtimer.h>
#include <qlayout.h>
#include <qvbox.h>
#include <qhbox.h>
#include <qpushbutton.h>
#include <qlabel.h>

#include "rkcomponentmap.h"
#include "../windows/rkworkplace.h"
#include "../windows/rkcommandeditorwindow.h"
#include "../rbackend/rinterface.h"
#include "../rkward.h"
#include "../settings/rksettingsmoduleplugins.h"
#include "../rkglobals.h"
#include "../debug.h"

/////////////////////////////////////// RKStandardComponentGUI ////////////////////////////////////////////////

RKStandardComponentGUI::RKStandardComponentGUI (RKStandardComponent *component, RKComponentPropertyCode *code_property, bool enslaved) {
	RK_TRACE (PLUGIN);

	toggle_code_button = 0;

	RKStandardComponentGUI::component = component;
	RKStandardComponentGUI::code_property = code_property;
	connect (code_property, SIGNAL (valueChanged (RKComponentPropertyBase *)), this, SLOT (codeChanged (RKComponentPropertyBase *)));
	connect (RKWardMainWindow::getMain(), SIGNAL (aboutToQuitRKWard()), this, SLOT (cancel()));

	RKStandardComponentGUI::enslaved = enslaved;

	// code update timer
	code_update_timer = new QTimer (this);
	connect (code_update_timer, SIGNAL (timeout ()), this, SLOT (updateCodeNow ()));

	if (!enslaved) {
		KActionCollection *action_collection = new KActionCollection (this);
		KStdAction::copy (this, SLOT (copyCode ()), action_collection);
	}
}

RKStandardComponentGUI::~RKStandardComponentGUI () {
	RK_TRACE (PLUGIN);
}

void RKStandardComponentGUI::createDialog (bool switchable) {
	RK_TRACE (PLUGIN);

	QVBoxLayout *main_vbox = new QVBoxLayout (this);
	QWidget *upper_widget = new QWidget (this);
	
	QHBoxLayout *hbox = new QHBoxLayout (upper_widget, RKGlobals::marginHint (), RKGlobals::spacingHint ());
	QVBoxLayout *vbox = new QVBoxLayout (hbox, RKGlobals::spacingHint ());

	// build standard elements
	main_widget = new QVBox (upper_widget);
	hbox->addWidget (main_widget);

	// lines
	QFrame *line;
	line = new QFrame (upper_widget);
	line->setFrameShape (QFrame::VLine);
	line->setFrameShadow (QFrame::Plain);	
	hbox->addWidget (line);

	// buttons
	vbox = new QVBoxLayout (hbox, RKGlobals::spacingHint ());
	ok_button = new QPushButton (i18n ("Submit"), upper_widget);
	connect (ok_button, SIGNAL (clicked ()), this, SLOT (ok ()));
	vbox->addWidget (ok_button);
	if (enslaved) ok_button->hide ();
	
	cancel_button = new QPushButton (i18n ("Close"), upper_widget);
	connect (cancel_button, SIGNAL (clicked ()), this, SLOT (cancel ()));
	vbox->addWidget (cancel_button);
	vbox->addStretch (1);
	
	help_button = new QPushButton (i18n ("Help"), upper_widget);
	help_button->setEnabled (component->haveHelp ());
	connect (help_button, SIGNAL (clicked ()), this, SLOT (help ()));
	vbox->addWidget (help_button);
	
	if (switchable && (!enslaved)) {
		switch_button = new QPushButton (i18n ("Use Wizard"), upper_widget);
		connect (switch_button, SIGNAL (clicked ()), this, SLOT (switchInterface ()));
		vbox->addWidget (switch_button);
	}
	vbox->addStretch (2);
	
	toggle_code_button = new QPushButton (i18n ("Code"), upper_widget);
	toggle_code_button->setToggleButton (true);
	connect (toggle_code_button, SIGNAL (clicked ()), this, SLOT (toggleCode ()));
	vbox->addWidget (toggle_code_button);
	if (enslaved) toggle_code_button->hide ();
	
	// code display
	code_display = new RKCommandEditorWindow (this, true);
	code_display->setMinimumHeight (RKSettingsModulePlugins::defaultCodeHeight ());
	code_display->hide ();

	main_vbox->addWidget (upper_widget);
	main_vbox->addWidget (code_display);

	if (!enslaved && RKSettingsModulePlugins::showCodeByDefault ()) {
		toggle_code_button->setOn (true);	// will trigger showing the code along with the dialog
	}
}

void RKStandardComponentGUI::show () {
	RK_TRACE (PLUGIN);

	QWidget::show ();

	if (toggle_code_button) {	// this is a dialog, not  wizard
		QTimer::singleShot (0, this, SLOT (toggleCode ()));
	}
}


void RKStandardComponentGUI::ok () {
	RK_TRACE (PLUGIN);

	RK_ASSERT (code_property->isValid ());

	QString command = "local({\n";
	command.append (code_property->preprocess ());
	command.append (code_property->calculate ());
	command.append (code_property->printout ());
	command.append ("})\n");
	RKGlobals::rInterface ()->issueCommand (new RCommand (command, RCommand::Plugin | RCommand::DirectToOutput | RCommand::ObjectListUpdate));
}

void RKStandardComponentGUI::cancel () {
	RK_TRACE (PLUGIN);

	hide ();
	if (!enslaved) {
		component->deleteLater ();
	}
}

void RKStandardComponentGUI::toggleCode () {
	RK_TRACE (PLUGIN);
	RK_ASSERT (toggle_code_button);

	int new_height = height ();

	if (toggle_code_button->isOn()) {
		new_height += RKSettingsModulePlugins::defaultCodeHeight ();
		code_display->show ();
	} else {
		new_height -= code_display->height ();
		code_display->hide ();
	}

	if (isVisible ()) {
		layout ()->activate ();
		resize (width (), new_height);
	}

	updateCode ();
}

void RKStandardComponentGUI::copyCode () {
	RK_TRACE (PLUGIN);

	code_display->copy ();
}

void RKStandardComponentGUI::help () {
	RK_TRACE (PLUGIN);

	QString id = RKComponentMap::getComponentId (component->getHandle ());

	QString path = QStringList::split ("::", id).join ("/");
	RKWorkplace::mainWorkplace ()->openHelpWindow (KURL ("rkward://component/" + path));
}

void RKStandardComponentGUI::closeEvent (QCloseEvent *e) {
	RK_TRACE (PLUGIN);

	e->accept ();
	cancel ();
}

void RKStandardComponentGUI::enableSubmit (bool enable) {
	RK_TRACE (PLUGIN);

	ok_button->setEnabled (enable);
}

void RKStandardComponentGUI::codeChanged (RKComponentPropertyBase *) {
	RK_TRACE (PLUGIN);

	updateCode ();
}

void RKStandardComponentGUI::updateCode () {
	RK_TRACE (PLUGIN);

	if (!code_display->isShown ()) return;
	code_update_timer->start (0, true);
}

void RKStandardComponentGUI::updateCodeNow () {
	RK_TRACE (PLUGIN);

	code_display->setReadOnly (false);	// sigh. The kate part does not allow setting text programatically, when it is read only
	if (!code_property->isValid ()) {
		code_display->setText (i18n ("Processing. Please wait"));
		RK_DO (qDebug ("code not ready to be displayed: pre %d, cal %d, pri %d", !code_property->preprocess ().isNull (), !code_property->calculate ().isNull (), !code_property->printout ().isNull ()), PLUGIN, DL_DEBUG);
	} else {
		code_display->setText ("local({\n" + code_property->preprocess () + code_property->calculate () + code_property->printout () + "})\n");
	}
	code_display->setReadOnly (true);
}

///////////////////////////////// RKStandardComponentWizard /////////////////////////////////

RKStandardComponentWizard::RKStandardComponentWizard (RKStandardComponent *component, RKComponentPropertyCode *code_property, bool enslaved) : RKStandardComponentGUI (component, code_property, enslaved) {
	RK_TRACE (PLUGIN);

	submit_enabled = false;
	is_switchable = false;
}

RKStandardComponentWizard::~RKStandardComponentWizard () {
	RK_TRACE (PLUGIN);
}

void RKStandardComponentWizard::updateCode () {
	RK_TRACE (PLUGIN);

	updateState ();
}

void RKStandardComponentWizard::createWizard (bool switchable) {
	RK_TRACE (PLUGIN);

	is_switchable = switchable;
	// create main layout and stack
	QGridLayout *main_grid = new QGridLayout (this, 3, 4, RKGlobals::marginHint (), RKGlobals::spacingHint ());
	main_widget = stack = new RKStandardComponentStack (this);
	main_grid->addMultiCellWidget (stack, 0, 0, 0, 3);

	// build standard elements
	// lines
	QFrame *line;
	line = new QFrame (main_widget);
	line->setFrameShape (QFrame::HLine);
	line->setFrameShadow (QFrame::Plain);
	main_grid->addMultiCellWidget (line, 1, 1, 0, 3);

	// buttons
	cancel_button = new QPushButton (i18n ("Cancel"), this);
	main_grid->addWidget (cancel_button, 2, 0, Qt::AlignLeft);
	if (enslaved) cancel_button->hide ();
	help_button = new QPushButton ("Help", this);
	main_grid->addWidget (help_button, 2, 1, Qt::AlignLeft);
	prev_button = new QPushButton (QString::null, this);
	prev_button->setEnabled (false);
	main_grid->addWidget (prev_button, 2, 2, Qt::AlignRight);
	next_button = new QPushButton (QString::null, this);
	main_grid->addWidget (next_button, 2, 3, Qt::AlignRight);
	connect (next_button, SIGNAL (clicked ()), this, SLOT (next ()));
	connect (prev_button, SIGNAL (clicked ()), this, SLOT (prev ()));
	connect (cancel_button, SIGNAL (clicked ()), this, SLOT (cancel ()));
	connect (help_button, SIGNAL (clicked ()), this, SLOT (help ()));
}

void RKStandardComponentWizard::addLastPage () {
	RK_TRACE (PLUGIN);

	if (!enslaved) {
		// build the last page
		RKComponent *last_page = stack->addPage (component);
		QVBoxLayout *vbox = new QVBoxLayout (last_page, RKGlobals::spacingHint ());
		QLabel *label = new QLabel (i18n ("Below you can see the command(s) corresponding to the settings you made. Click 'Submit' to run the command(s)."), last_page);
		label->setAlignment (Qt::AlignAuto | Qt::AlignVCenter | Qt::ExpandTabs | Qt::WordBreak);
		code_display = new RKCommandEditorWindow (last_page, true);
		vbox->addWidget (label);
		vbox->addWidget (code_display);
	}

	stack->goToFirstPage ();
	updateState ();
}

void RKStandardComponentWizard::next () {
	RK_TRACE (PLUGIN);

	RK_ASSERT (stack->currentPageSatisfied ());

	if (stack->havePage (true)) {
		stack->movePage (true);
		updateState ();
	} else {
		if (enslaved) cancel ();
		else ok ();
	}
}

void RKStandardComponentWizard::prev () {
	RK_TRACE (PLUGIN);

	if (enslaved) {
		if (stack->havePage (false)) {
			stack->movePage (false);
			updateState ();
		} else {
			cancel ();
		}
	} else {
		if (stack->havePage (false)) {
			stack->movePage (false);
			updateState ();
		} else if (is_switchable) {
			switchInterface ();
		} else {
			RK_ASSERT (false);
		}
	}
}

void RKStandardComponentWizard::updateState () {
	RK_TRACE (PLUGIN);

	if (enslaved) {
		if (stack->havePage (true)) {		// not on last page
			next_button->setText (i18n ("Next >"));
			next_button->setEnabled (stack->currentPageSatisfied ());
		} else {			// on last page
			// do code update when on last page
			next_button->setText (i18n ("Done"));
			next_button->setEnabled (stack->currentPageSatisfied ());
		}

		prev_button->setEnabled (true);
		if (stack->havePage (false)) {		// not on first page
			prev_button->setText (i18n ("< Back"));
		} else {
			prev_button->setText (i18n ("Close"));
		}
		return;
	}

	if (stack->havePage (true)) {		// not on last page
		next_button->setText (i18n ("Next >"));
		next_button->setEnabled (stack->currentPageSatisfied ());
	} else {			// on last page
		// do code update when on last page
		if (!stack->havePage (true)) code_update_timer->start (0, true);
		next_button->setText (i18n ("Submit"));
		next_button->setEnabled (submit_enabled);
	}

	if (stack->havePage (false) || (!is_switchable)) {		// not on first page
		prev_button->setText (i18n ("< Back"));
		prev_button->setEnabled (stack->havePage (false));
	} else {
		prev_button->setText (i18n ("Use Dialog"));
		prev_button->setEnabled (true);
	}
}

void RKStandardComponentWizard::enableSubmit (bool enable) {
	RK_TRACE (PLUGIN);

	submit_enabled = enable;
}



//////////////////////////////// RKStandardComponentStack ////////////////////////////////////

RKStandardComponentStack::RKStandardComponentStack (QWidget *parent) : QWidgetStack (parent) {
	RK_TRACE (PLUGIN);

	num_pages = current_page = 0;
	current_def = 0;
}

RKStandardComponentStack::~RKStandardComponentStack () {
	RK_TRACE (PLUGIN);

	for (Pages::const_iterator it = pages.constBegin (); it != pages.constEnd (); ++it) {
		delete (*it);
	}
}

bool RKStandardComponentStack::havePage (bool next) {
	RK_TRACE (PLUGIN);

	if (next) {
		return (nextVisiblePage () <= (num_pages-1));
	} else {
		return (previousVisiblePage () >= 0);
	}
}

void RKStandardComponentStack::movePage (bool next) {
	RK_TRACE (PLUGIN);

	int id;
	if (next) {
		id = nextVisiblePage ();
	} else {
		id = previousVisiblePage ();
	}

	if (id < 0) {
		RK_ASSERT (false);
		return;
	}

	current_page = id;
	current_def = pages[id];
	raiseWidget (current_def->page);
}

bool RKStandardComponentStack::currentPageSatisfied () {
	RK_TRACE (PLUGIN);
	if (!current_def) {
		RK_ASSERT (false);
		return false;
	}

	for (PageComponents::const_iterator it = current_def->page_components.constBegin (); it != current_def->page_components.constEnd (); ++it) {
		if (!((*it)->isSatisfied ())) {
			return false;
		}
	}

	return true;
}

void RKStandardComponentStack::goToFirstPage () {
	RK_TRACE (PLUGIN);

	current_page = 0;
	current_def = pages.first ();
	raiseWidget (current_def->page);
}

RKComponent *RKStandardComponentStack::addPage (RKComponent *parent) {
	RK_TRACE (PLUGIN);

	PageDef *def = new PageDef;
	def->page = new RKComponent (parent, this);
	addWidget (def->page);
	pages.append (def);

	current_def = def;
	num_pages++;
	current_page++;

	return def->page;
}

void RKStandardComponentStack::addComponentToCurrentPage (RKComponent *component) {
	RK_TRACE (PLUGIN);
	if (!current_def) {
		RK_ASSERT (false);
		return;
	}

	current_def->page_components.append (component);
}

int RKStandardComponentStack::previousVisiblePage () {
	RK_TRACE (PLUGIN);

	int prev_page = current_page - 1;
	while (prev_page >= 0) {
		if (pages[prev_page]->page->visibilityProperty ()->boolValue ()) return prev_page;
		--prev_page;
	}

	return prev_page;
}

int RKStandardComponentStack::nextVisiblePage () {
	RK_TRACE (PLUGIN);

	int next_page = current_page + 1;
	while (next_page <= (num_pages-1)) {
		if (pages[next_page]->page->visibilityProperty ()->boolValue ()) return next_page;
		++next_page;
	}

	return next_page;
}

#include "rkstandardcomponentgui.moc"
