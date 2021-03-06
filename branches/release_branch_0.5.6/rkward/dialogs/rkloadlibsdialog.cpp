/***************************************************************************
                          rkloadlibsdialog  -  description
                             -------------------
    begin                : Mon Sep 6 2004
    copyright            : (C) 2004, 2006, 2007, 2008, 2009, 2010, 2011 by Thomas Friedrichsmeier
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
#include "rkloadlibsdialog.h"

#include <qwidget.h>
#include <qlayout.h>
#include <QTreeWidget>
#include <qlabel.h>
#include <qpushbutton.h>
#include <qcheckbox.h>
#include <qdir.h>
#include <qregexp.h>
#include <qtimer.h>
#include <qtextstream.h>
#include <QCloseEvent>

#include <klocale.h>
#include <kmessagebox.h>
#include <kvbox.h>
#include <kuser.h>
#include <kstandarddirs.h>

#include "../rkglobals.h"
#include "../rbackend/rinterface.h"
#include "../settings/rksettingsmodulegeneral.h"
#include "../settings/rksettings.h"
#include "../core/robjectlist.h"
#include "../misc/rkprogresscontrol.h"
#include "../misc/rkstandardicons.h"

#include "../debug.h"

#include <stdlib.h>


#define GET_CURRENT_LIBLOCS_COMMAND 1

RKLoadLibsDialog::RKLoadLibsDialog (QWidget *parent, RCommandChain *chain, bool modal) : KPageDialog (parent) {
	RK_TRACE (DIALOGS);
	RKLoadLibsDialog::chain = chain;
	installation_process = 0;

	setFaceType (KPageDialog::Tabbed);
	setModal (modal);
	setCaption (i18n ("Configure Packages"));
	setButtons (KDialog::Ok | KDialog::Apply | KDialog::Cancel | KDialog::User1);

	LoadUnloadWidget *luwidget = new LoadUnloadWidget (this);
	addPage (luwidget, i18n ("Local packages"));
	connect (this, SIGNAL (installedPackagesChanged ()), luwidget, SLOT (updateInstalledPackages ()));

	addPage (new UpdatePackagesWidget (this), i18n ("Update"));

	install_packages_widget = new InstallPackagesWidget (this);
	install_packages_pageitem = addPage (install_packages_widget, i18n ("Install"));

	setButtonText (KDialog::User1, i18n ("Configure Repositories"));

	connect (this, SIGNAL (currentPageChanged(KPageWidgetItem*,KPageWidgetItem*)), this, SLOT (slotPageChanged()));
	QTimer::singleShot (0, this, SLOT (slotPageChanged()));
	num_child_widgets = 3;
	accepted = false;

	RKGlobals::rInterface ()->issueCommand (".libPaths ()", RCommand::App | RCommand::GetStringVector, QString (), this, GET_CURRENT_LIBLOCS_COMMAND, chain);
}

RKLoadLibsDialog::~RKLoadLibsDialog () {
	RK_TRACE (DIALOGS);

	if (accepted) KPageDialog::accept ();
	else KPageDialog::reject ();
}

void RKLoadLibsDialog::slotPageChanged () {
	RK_TRACE (DIALOGS);

	if (!currentPage ()) return;
	// This, and most other focus operations in this file, is to make the keyboard search feature of the QTreeWidget's work (without having to click the lists, first)
	currentPage ()->widget ()->setFocus ();
}

//static
void RKLoadLibsDialog::showInstallPackagesModal (QWidget *parent, RCommandChain *chain, const QString &package_name) {
	RK_TRACE (DIALOGS);

	RKLoadLibsDialog *dialog = new RKLoadLibsDialog (parent, chain, true);
	dialog->auto_install_package = package_name;
	QTimer::singleShot (0, dialog, SLOT (automatedInstall ()));		// to get past the dialog->exec, below
	dialog->setCurrentPage (dialog->install_packages_pageitem);
	dialog->exec ();
	RK_TRACE (DIALOGS);
}

void RKLoadLibsDialog::automatedInstall () {
	RK_TRACE (DIALOGS);

	install_packages_widget->getListButtonClicked ();
	install_packages_widget->trySelectPackage (auto_install_package);
}

void RKLoadLibsDialog::tryDestruct () {
	RK_TRACE (DIALOGS);

	if (num_child_widgets <= 0) {
		deleteLater ();
	}
}

void RKLoadLibsDialog::childDeleted () {
	RK_TRACE (DIALOGS);
	--num_child_widgets;
	tryDestruct ();
}

void RKLoadLibsDialog::slotButtonClicked (int button) {
	RK_TRACE (DIALOGS);

	switch (button) {
	case KDialog::Ok:
		accepted = true;
		hide ();
		emit (okClicked ()); // will self-destruct via childDeleted ()
		break;
	case KDialog::Cancel:
		accepted = false;
		hide ();
		emit (cancelClicked ()); // will self-destruct via childDeleted ()
		break;
	case KDialog::Apply:
		emit (applyClicked ());
		break;
	case KDialog::User1:
		RKSettings::configureSettings (RKSettings::PageRPackages, this, chain);
		break;
	}
}

void RKLoadLibsDialog::closeEvent (QCloseEvent *e) {
	RK_TRACE (DIALOGS);
	e->accept ();

	// do as if cancel button was clicked:
	slotButtonClicked (KDialog::Cancel);
}

void RKLoadLibsDialog::rCommandDone (RCommand *command) {
	RK_TRACE (DIALOGS);
	if (command->getFlags () == GET_CURRENT_LIBLOCS_COMMAND) {
		RK_ASSERT (command->getDataType () == RData::StringVector);
		RK_ASSERT (command->getDataLength () > 0);
		QStringList current_library_locations;
		for (unsigned int i=0; i < command->getDataLength (); ++i) {
			current_library_locations.append (command->getStringVector ()[i]);
		}
		emit (libraryLocationsChanged (current_library_locations));
	} else {
		RK_ASSERT (false);
	}
}

bool RKLoadLibsDialog::installPackages (const QStringList &packages, const QString &to_libloc, bool install_dependencies, bool as_root) {
	RK_TRACE (DIALOGS);

	if (packages.isEmpty ()) return false;
	QString command_string = "install.packages (pkgs=c (\"" + packages.join ("\", \"") + "\")" + ", lib=\"" + to_libloc + "\"";
	QString downloaddir = QDir (RKSettingsModuleGeneral::filesPath ()).filePath ("package_archive");
	if (RKSettingsModuleRPackages::archivePackages ()) {
		QDir (RKSettingsModuleGeneral::filesPath ()).mkdir ("package_archive");
		command_string += ", destdir=\"" + downloaddir + "\"";
	}
	if (install_dependencies) command_string += ", dependencies=TRUE";
	command_string += ")\n";

// TODO: won't work with some versions of GCC (which ones exactly)?
//	QFile file (QDir (RKSettingsModuleGeneral::filesPath ()).filePath ("install_script.R"));
// WORKAROUND:
	QDir dir = RKSettingsModuleGeneral::filesPath ();
	QFile file (dir.filePath ("install_script.R"));
// WORKADOUND END
	if (file.open (QIODevice::WriteOnly)) {
		QTextStream stream (&file);
		stream << "options (repos=" + repos_string + ")\n" + command_string;
		if (as_root) {
#ifdef Q_WS_WIN
			RK_ASSERT (false);
#else
			KUser user;
			stream << QString ("system (\"chown ") + user.loginName() + ' ' + downloaddir + "/*\")\n";
#endif
		}
		stream << "q ()\n";
		file.close();
	} else {
		RK_ASSERT (false);
	}

	QString R_binary (getenv ("R_binary"));
	QString call;
	QStringList params;
#ifdef Q_WS_WIN
	RK_ASSERT (!as_root);
	call = R_binary;
#else
	if (as_root) {
		call = KStandardDirs::findExe ("kdesu");
		params << "-t" << "--" << R_binary;
	} else {
		call = R_binary;
	}
#endif
	params << "--no-save" << "--no-restore" << "--file=" + file.fileName ();

	installation_process = new QProcess ();
	installation_process->setProcessChannelMode (QProcess::SeparateChannels);

	connect (installation_process, SIGNAL (finished(int,QProcess::ExitStatus)), this, SLOT (processExited(int,QProcess::ExitStatus)));
	connect (installation_process, SIGNAL (readyReadStandardOutput()), this, SLOT (installationProcessOutput()));
	connect (installation_process, SIGNAL (readyReadStandardError()), this, SLOT (installationProcessError()));

	RKProgressControl *installation_progress = new RKProgressControl (this, i18n ("Please stand by while installing selected packages"), i18n ("Installing packages"), RKProgressControl::CancellableProgress);
	connect (this, SIGNAL (installationComplete()), installation_progress, SLOT (done()));
	connect (this, SIGNAL (installationOutput(const QString&)), installation_progress, SLOT (newOutput(const QString&)));
	connect (this, SIGNAL (installationError(const QString&)), installation_progress, SLOT (newError(const QString&)));

	installation_process->start (call, params, QIODevice::ReadWrite | QIODevice::Unbuffered);

	if (!installation_progress->doModal (true)) {
		installation_process->kill ();
		installation_process->waitForFinished (5000);
	}

	file.remove ();
	delete installation_process;
	installation_process = 0;

	emit (installedPackagesChanged ());
	return true;
}

void RKLoadLibsDialog::installationProcessOutput () {
	RK_TRACE (DIALOGS);
	RK_ASSERT (installation_process);

	emit (installationOutput (QString::fromLocal8Bit (installation_process->readAllStandardOutput())));
}

void RKLoadLibsDialog::installationProcessError () {
	RK_TRACE (DIALOGS);
	RK_ASSERT (installation_process);

	emit (installationError (QString::fromLocal8Bit (installation_process->readAllStandardError ())));
}

void RKLoadLibsDialog::processExited (int exitCode, QProcess::ExitStatus exitStatus) {
	RK_TRACE (DIALOGS);

	if (exitCode || (exitStatus != QProcess::NormalExit)) {
		installationError ("\n" + i18n ("Installation process died with exit code %1", exitCode));
	}

	emit (installationComplete ());
}

////////////////////// LoadUnloadWidget ////////////////////////////

#define GET_INSTALLED_PACKAGES 1
#define GET_LOADED_PACKAGES 2
#define LOAD_PACKAGE_COMMAND 3

LoadUnloadWidget::LoadUnloadWidget (RKLoadLibsDialog *dialog) : QWidget (0) {
	RK_TRACE (DIALOGS);
	LoadUnloadWidget::parent = dialog;
	
	QVBoxLayout *mvbox = new QVBoxLayout (this);
	mvbox->setContentsMargins (0, 0, 0, 0);
	
	QHBoxLayout *hbox = new QHBoxLayout ();
	mvbox->addLayout (hbox);
	hbox->setContentsMargins (0, 0, 0, 0);
	QVBoxLayout *instvbox = new QVBoxLayout ();
	hbox->addLayout (instvbox);
	instvbox->setContentsMargins (0, 0, 0, 0);
	QVBoxLayout *buttonvbox = new QVBoxLayout ();
	hbox->addLayout (buttonvbox);
	buttonvbox->setContentsMargins (0, 0, 0, 0);
	QVBoxLayout *loadedvbox = new QVBoxLayout ();
	hbox->addLayout (loadedvbox);
	loadedvbox->setContentsMargins (0, 0, 0, 0);
	
	QLabel *label = new QLabel (i18n ("Installed packages"), this);
	installed_view = new QTreeWidget (this);
	installed_view->setHeaderLabels (QStringList () << i18n ("Name") << i18n ("Title") << i18n ("Version") << i18n ("Location"));
	installed_view->setSelectionMode (QAbstractItemView::ExtendedSelection);
	instvbox->addWidget (label);
	instvbox->addWidget (installed_view);
	setFocusProxy (installed_view);

	load_button = new QPushButton (RKStandardIcons::getIcon (RKStandardIcons::ActionAddRight), i18n ("Load"), this);
	connect (load_button, SIGNAL (clicked ()), this, SLOT (loadButtonClicked ()));
	detach_button = new QPushButton (RKStandardIcons::getIcon (RKStandardIcons::ActionRemoveLeft), i18n ("Unload"), this);
	connect (detach_button, SIGNAL (clicked ()), this, SLOT (detachButtonClicked ()));
	buttonvbox->addStretch (1);
	buttonvbox->addWidget (load_button);
	buttonvbox->addWidget (detach_button);
	buttonvbox->addStretch (2);
	
	label = new QLabel (i18n ("Loaded packages"), this);
	loaded_view = new QTreeWidget (this);
	loaded_view->setHeaderLabel (i18n ("Name"));
	loaded_view->setSelectionMode (QAbstractItemView::ExtendedSelection);
	loadedvbox->addWidget (label);
	loadedvbox->addWidget (loaded_view);

	connect (loaded_view, SIGNAL (itemSelectionChanged()), this, SLOT (updateButtons()));
	connect (installed_view, SIGNAL (itemSelectionChanged()), this, SLOT (updateButtons()));

	connect (dialog, SIGNAL (okClicked ()), this, SLOT (ok ()));
	connect (dialog, SIGNAL (applyClicked ()), this, SLOT (apply ()));
	connect (dialog, SIGNAL (cancelClicked ()), this, SLOT (cancel ()));
	connect (this, SIGNAL (destroyed ()), dialog, SLOT (childDeleted ()));

	updateInstalledPackages ();
	updateButtons ();
}

LoadUnloadWidget::~LoadUnloadWidget () {
	RK_TRACE (DIALOGS);
}

void LoadUnloadWidget::rCommandDone (RCommand *command) {
	RK_TRACE (DIALOGS);
	if (command->failed ()) return;
	if (command->getFlags () == GET_INSTALLED_PACKAGES) {
		RK_ASSERT (command->getDataLength () == 4);

		RData *package = command->getStructureVector ()[0];
		RData *title = command->getStructureVector ()[1];
		RData *version = command->getStructureVector ()[2];
		RData *libpath = command->getStructureVector ()[3];

		unsigned int count = package->getDataLength ();
		RK_ASSERT (count == title->getDataLength ());
		RK_ASSERT (count == version->getDataLength ());
		RK_ASSERT (count == libpath->getDataLength ());
		for (unsigned int i=0; i < count; ++i) {
			QTreeWidgetItem* item = new QTreeWidgetItem (installed_view);
			item->setText (0, package->getStringVector ()[i]);
			item->setText (1, title->getStringVector ()[i]);
			item->setText (2, version->getStringVector ()[i]);
			item->setText (3, libpath->getStringVector ()[i]);
		}
		installed_view->resizeColumnToContents (0);
		installed_view->setSortingEnabled (true);
		installed_view->sortItems (0, Qt::AscendingOrder);
	} else if (command->getFlags () == GET_LOADED_PACKAGES) {
		RK_ASSERT (command->getDataType () == RData::StringVector);

		for (unsigned int i=0; i < command->getDataLength (); ++i) {
			QTreeWidgetItem* item = new QTreeWidgetItem (loaded_view);
			item->setText (0, command->getStringVector ()[i]);
			if (RKSettingsModuleRPackages::essentialPackages ().contains (command->getStringVector ()[i])) {
#if QT_VERSION >= 0x040400
				item->setFlags (Qt::NoItemFlags);
#else
				item->setFlags (0);
#endif
			}
		}
		loaded_view->resizeColumnToContents (0);
		loaded_view->setSortingEnabled (true);
		loaded_view->sortItems (0, Qt::AscendingOrder);
		updateCurrentList ();
	} else if (command->getFlags () == LOAD_PACKAGE_COMMAND) {
		emit (loadUnloadDone ());
	} else {
		RK_ASSERT (false);
	}
}

void LoadUnloadWidget::updateInstalledPackages () {
	RK_TRACE (DIALOGS);

	installed_view->clear ();
	loaded_view->clear ();

	RKGlobals::rInterface ()->issueCommand (".rk.get.installed.packages ()", RCommand::App | RCommand::Sync | RCommand::GetStructuredData, QString::null, this, GET_INSTALLED_PACKAGES, parent->chain);
	RKGlobals::rInterface ()->issueCommand (".packages ()", RCommand::App | RCommand::Sync | RCommand::GetStringVector, QString::null, this, GET_LOADED_PACKAGES, parent->chain);
}

void LoadUnloadWidget::loadButtonClicked () {
	RK_TRACE (DIALOGS);

	loaded_view->clearSelection ();
	QList<QTreeWidgetItem*> sel = installed_view->selectedItems ();
	for (int i = 0; i < sel.size (); ++i) {
		QString package_name = sel[i]->text (0);

		// is this package already loaded?
		QList<QTreeWidgetItem*> loaded = loaded_view->findItems (package_name, Qt::MatchExactly, 0);
		if (loaded.isEmpty ()) {
			QTreeWidgetItem* item = new QTreeWidgetItem (loaded_view);
			item->setText (0, package_name);
			item->setSelected (true);
		}
	}
}

void LoadUnloadWidget::detachButtonClicked () {
	RK_TRACE (DIALOGS);

	installed_view->clearSelection ();
	QList<QTreeWidgetItem*> sel = loaded_view->selectedItems ();
	for (int i = 0; i < sel.size (); ++i) {
		QString package_name = sel[i]->text (0);

		delete (sel[i]);	// remove from list of loaded packages

		// select corresponding package in list of available packages
		QList<QTreeWidgetItem*> installed = installed_view->findItems (package_name, Qt::MatchExactly, 0);
		if (!installed.isEmpty ()) {
			//RK_ASSERT (installed.count () == 1); // In fact, several versions of one package can be installed in several library locations
			installed[0]->setSelected (true);
		}
	}
}

void LoadUnloadWidget::updateButtons () {
	RK_TRACE (DIALOGS);

	detach_button->setEnabled (!loaded_view->selectedItems ().isEmpty ());
	load_button->setEnabled (!installed_view->selectedItems ().isEmpty ());
}

void LoadUnloadWidget::ok () {
	RK_TRACE (DIALOGS);
	doLoadUnload ();
	deleteLater ();
}

void LoadUnloadWidget::updateCurrentList () {
	RK_TRACE (DIALOGS);

	prev_packages.clear ();
	for (int i = 0; i < loaded_view->topLevelItemCount (); ++i) {
		prev_packages.append (loaded_view->topLevelItem (i)->text (0));
	}
}

void LoadUnloadWidget::doLoadUnload () {
	RK_TRACE (DIALOGS);

	RKProgressControl *control = new RKProgressControl (this, i18n ("There has been an error while trying to load / unload packages. See transcript below for details"), i18n ("Error while handling packages"), RKProgressControl::DetailedError);
	connect (this, SIGNAL (loadUnloadDone ()), control, SLOT (done ()));

	// load packages previously not loaded
	for (int i = 0; i < loaded_view->topLevelItemCount (); ++i) {
		QTreeWidgetItem* loaded = loaded_view->topLevelItem (i);
		if (!prev_packages.contains (loaded->text (0))) {
			RCommand *command = new RCommand ("library (\"" + loaded->text (0) + "\")", RCommand::App | RCommand::ObjectListUpdate);
			control->addRCommand (command);
			RKGlobals::rInterface ()->issueCommand (command, parent->chain);
		}
	}
	
	// detach packages previously attached
	QStringList packages_to_remove;
	for (QStringList::Iterator it = prev_packages.begin (); it != prev_packages.end (); ++it) {
		QList<QTreeWidgetItem*> loaded = loaded_view->findItems ((*it), Qt::MatchExactly, 0);
		if (loaded.isEmpty ()) {	// no longer in the list
			packages_to_remove.append ("package:" + *it);
		}
	}
	if (!packages_to_remove.isEmpty ()) {
		QStringList messages = RObjectList::getObjectList ()->detachPackages (packages_to_remove, parent->chain, control);
		if (!messages.isEmpty ()) KMessageBox::sorry (this, messages.join ("\n"));
	}

	// find out, when we're done
	RCommand *command = new RCommand (QString (), RCommand::EmptyCommand, QString (), this, LOAD_PACKAGE_COMMAND);
	RKGlobals::rInterface ()->issueCommand (command, parent->chain);

	control->doNonModal (true);
}

void LoadUnloadWidget::apply () {
	RK_TRACE (DIALOGS);

	doLoadUnload ();
	updateCurrentList ();
}

void LoadUnloadWidget::cancel () {
	RK_TRACE (DIALOGS);
	deleteLater ();
}

/////////////////////// UpdatePackagesWidget //////////////////////////

#define FIND_OLD_PACKAGES_COMMAND 1

UpdatePackagesWidget::UpdatePackagesWidget (RKLoadLibsDialog *dialog) : QWidget (0) {
	RK_TRACE (DIALOGS);
	UpdatePackagesWidget::parent = dialog;
	
	QVBoxLayout *mvbox = new QVBoxLayout (this);
	mvbox->setContentsMargins (0, 0, 0, 0);
	QLabel *label = new QLabel (i18n ("In order to find out, which of your installed packaged have an update available, click \"Fetch List\". This feature requires a working internet connection."), this);
	label->setWordWrap (true);
	mvbox->addWidget (label);
	
	QHBoxLayout *hbox = new QHBoxLayout ();
	mvbox->addLayout (hbox);
	hbox->setContentsMargins (0, 0, 0, 0);
	
	updateable_view = new QTreeWidget (this);
	updateable_view->setHeaderLabels (QStringList () << i18n ("Name") << i18n ("Location") << i18n ("Local Version") << i18n ("Online Version"));
	updateable_view->setSelectionMode (QAbstractItemView::ExtendedSelection);
	hbox->addWidget (updateable_view);
	setFocusProxy (updateable_view);
	
	QVBoxLayout *buttonvbox = new QVBoxLayout ();
	hbox->addLayout (buttonvbox);
	buttonvbox->setContentsMargins (0, 0, 0, 0);
	get_list_button = new QPushButton (i18n ("Fetch list"), this);
	connect (get_list_button, SIGNAL (clicked ()), this, SLOT (getListButtonClicked ()));
	update_selected_button = new QPushButton (i18n ("Update Selected"), this);
	connect (update_selected_button, SIGNAL (clicked ()), this, SLOT (updateSelectedButtonClicked ()));
	update_all_button = new QPushButton (i18n ("Update All"), this);
	connect (update_all_button, SIGNAL (clicked ()), this, SLOT (updateAllButtonClicked ()));
	install_params = new PackageInstallParamsWidget (this, false);
	connect (parent, SIGNAL (libraryLocationsChanged (const QStringList &)), install_params, SLOT (liblocsChanged (const QStringList &)));

	buttonvbox->addWidget (get_list_button);
	buttonvbox->addStretch (1);
	buttonvbox->addWidget (update_selected_button);
	buttonvbox->addWidget (update_all_button);
	buttonvbox->addStretch (1);
	buttonvbox->addWidget (install_params);
	buttonvbox->addStretch (1);
	
	update_selected_button->setEnabled (false);
	update_all_button->setEnabled (false);
	updateable_view->setEnabled (false);

	new QTreeWidgetItem (updateable_view, QStringList ("..."));	// i18n ("[Click \"Fetch list\" for updates]")

	connect (dialog, SIGNAL (okClicked ()), this, SLOT (ok ()));
	connect (dialog, SIGNAL (cancelClicked ()), this, SLOT (cancel ()));
	connect (this, SIGNAL (destroyed ()), dialog, SLOT (childDeleted ()));
}

UpdatePackagesWidget::~UpdatePackagesWidget () {
	RK_TRACE (DIALOGS);
}

void UpdatePackagesWidget::rCommandDone (RCommand *command) {
	RK_TRACE (DIALOGS);
	if (command->getFlags () == FIND_OLD_PACKAGES_COMMAND) {
		if (!command->failed ()) {
			updateable_view->clear ();

			RK_ASSERT (command->getDataLength () == 5);
			RData *package = command->getStructureVector ()[0];
			RData *libpath = command->getStructureVector ()[1];
			RData *installed = command->getStructureVector ()[2];
			RData *reposver = command->getStructureVector ()[3];
			RData *reposstring = command->getStructureVector ()[4];

			unsigned int count = package->getDataLength ();
			RK_ASSERT (count == libpath->getDataLength ());
			RK_ASSERT (count == installed->getDataLength ());
			RK_ASSERT (count == reposver->getDataLength ());
			for (unsigned int i=0; i < count; ++i) {
				QTreeWidgetItem* item = new QTreeWidgetItem (updateable_view);
				item->setText (0, package->getStringVector ()[i]);
				item->setText (1, libpath->getStringVector ()[i]);
				item->setText (2, installed->getStringVector ()[i]);
				item->setText (3, reposver->getStringVector ()[i]);
			}

			if (updateable_view->topLevelItemCount ()) {
				update_selected_button->setEnabled (true);
				update_all_button->setEnabled (true);
				updateable_view->setEnabled (true);
				updateable_view->setFocus ();
				updateable_view->setSortingEnabled (true);
				updateable_view->sortItems (0, Qt::AscendingOrder);
			} else {
				new QTreeWidgetItem (updateable_view, QStringList (i18n ("[No updates available]")));
			}
			updateable_view->resizeColumnToContents (0);

			RK_ASSERT (reposstring->getDataLength () == 1);
			// this is after the repository was chosen. Update the repository string.
			parent->repos_string = reposstring->getStringVector ()[0];
		} else {
			get_list_button->setEnabled (true);
		}
	} else {
		RK_ASSERT (false);
	}
}

void UpdatePackagesWidget::updatePackages (const QStringList &list) {
	RK_TRACE (DIALOGS);
	bool as_root = false;

	if (list.isEmpty ()) return;
	if (!install_params->checkWritable (&as_root)) return;

	parent->installPackages (list, install_params->libraryLocation (), install_params->installDependencies (), as_root);
}

void UpdatePackagesWidget::updateSelectedButtonClicked () {
	RK_TRACE (DIALOGS);
	QStringList list;
	QList<QTreeWidgetItem*> selected = updateable_view->selectedItems ();
	for (int i = 0; i < selected.count (); ++i) {
		list.append (selected[i]->text (0));
	}
	updatePackages (list);
}

void UpdatePackagesWidget::updateAllButtonClicked () {
	RK_TRACE (DIALOGS);
	QStringList list;
	for (int i = 0; i < updateable_view->topLevelItemCount (); ++i) {
		list.append (updateable_view->topLevelItem (i)->text (0));
	}
	updatePackages (list);
}

void UpdatePackagesWidget::getListButtonClicked () {
	RK_TRACE (DIALOGS);

	get_list_button->setEnabled (false);

	RCommand *command = new RCommand (".rk.get.old.packages ()", RCommand::App | RCommand::GetStructuredData, QString::null, this, FIND_OLD_PACKAGES_COMMAND);

	RKProgressControl *control = new RKProgressControl (this, i18n ("Please stand by while determining, which packages have an update available online."), i18n ("Fetching list"), RKProgressControl::CancellableProgress | RKProgressControl::AutoCancelCommands);
	control->addRCommand (command, true);
	RKGlobals::rInterface ()->issueCommand (command, parent->chain);
	control->doModal (true);
}

void UpdatePackagesWidget::ok () {
	RK_TRACE (DIALOGS);
	deleteLater ();
}

void UpdatePackagesWidget::cancel () {
	RK_TRACE (DIALOGS);
	deleteLater ();
}


/////////////////////// InstallPackagesWidget //////////////////////////

#define FIND_AVAILABLE_PACKAGES_COMMAND 1

InstallPackagesWidget::InstallPackagesWidget (RKLoadLibsDialog *dialog) : QWidget (0) {
	RK_TRACE (DIALOGS);
	InstallPackagesWidget::parent = dialog;
	
	QVBoxLayout *mvbox = new QVBoxLayout (this);
	mvbox->setContentsMargins (0, 0, 0, 0);
	QLabel *label = new QLabel (i18n ("Many packages are available on CRAN (Comprehensive R Archive Network), and other repositories (click \"Configure Repositories\" to add more sources). Click \"Fetch List\" to find out, which packages are available. This feature requires a working internet connection."), this);
	label->setWordWrap (true);
	mvbox->addWidget (label);
	QHBoxLayout *hbox = new QHBoxLayout ();
	mvbox->addLayout (hbox);
	hbox->setContentsMargins (0, 0, 0, 0);
	
	installable_view = new QTreeWidget (this);
	installable_view->setHeaderLabels (QStringList () << i18n ("Name") << i18n ("Version"));
	installable_view->setSelectionMode (QAbstractItemView::ExtendedSelection);
	hbox->addWidget (installable_view);
	setFocusProxy (installable_view);

	QVBoxLayout *buttonvbox = new QVBoxLayout ();
	hbox->addLayout (buttonvbox);
	buttonvbox->setContentsMargins (0, 0, 0, 0);
	get_list_button = new QPushButton (i18n ("Fetch list"), this);
	connect (get_list_button, SIGNAL (clicked ()), this, SLOT (getListButtonClicked ()));
	install_selected_button = new QPushButton (i18n ("Install Selected"), this);
	connect (install_selected_button, SIGNAL (clicked ()), this, SLOT (installSelectedButtonClicked ()));
	install_params = new PackageInstallParamsWidget (this, true);
	connect (parent, SIGNAL (libraryLocationsChanged (const QStringList &)), install_params, SLOT (liblocsChanged (const QStringList &)));

	buttonvbox->addWidget (get_list_button);
	buttonvbox->addStretch (1);
	buttonvbox->addWidget (install_selected_button);
	buttonvbox->addStretch (1);
	buttonvbox->addWidget (install_params);
	buttonvbox->addStretch (1);
	
	install_selected_button->setEnabled (false);
	installable_view->setEnabled (false);

	new QTreeWidgetItem (installable_view, QStringList ("..."));	// i18n ("[Click \"Fetch list\" to see available packages]")

	connect (dialog, SIGNAL (okClicked ()), this, SLOT (ok ()));
	connect (dialog, SIGNAL (cancelClicked ()), this, SLOT (cancel ()));
	connect (this, SIGNAL (destroyed ()), dialog, SLOT (childDeleted ()));
}

InstallPackagesWidget::~InstallPackagesWidget () {
	RK_TRACE (DIALOGS);
}

void InstallPackagesWidget::rCommandDone (RCommand *command) {
	RK_TRACE (DIALOGS);
	if (command->getFlags () == FIND_AVAILABLE_PACKAGES_COMMAND) {
		if (!command->failed ()) {
			installable_view->clear ();

			RK_ASSERT (command->getDataLength () == 3);

			RData *names = command->getStructureVector ()[0];
			RData *versions = command->getStructureVector ()[1];
			RData *repos = command->getStructureVector ()[2];

			unsigned int count = names->getDataLength ();
			RK_ASSERT (count == versions->getDataLength ());
			RK_ASSERT (repos->getDataLength () == 1);

			for (unsigned int i=0; i < count; ++i) {
				QTreeWidgetItem* item = new QTreeWidgetItem (installable_view);
				item->setText (0, names->getStringVector ()[i]);
				item->setText (1, versions->getStringVector ()[i]);
			}

			if (installable_view->topLevelItemCount ()) {
				install_selected_button->setEnabled (true);
				installable_view->setEnabled (true);
				installable_view->setFocus ();
				installable_view->setSortingEnabled (true);
				installable_view->sortItems (0, Qt::AscendingOrder);
			} else {
				new QTreeWidgetItem (installable_view, QStringList (i18n ("[No packages available]")));
			}
			installable_view->resizeColumnToContents (0);

			// this is after the repository was chosen. Update the repository string.
			parent->repos_string = repos->getStringVector ()[0];
		} else {
			get_list_button->setEnabled (true);
		}
	} else {
		RK_ASSERT (false);
	}
}

void InstallPackagesWidget::installPackages (const QStringList &list) {
	RK_TRACE (DIALOGS);
	bool as_root = false;

	if (list.isEmpty ()) return;
	if (!install_params->checkWritable (&as_root)) return;

	parent->installPackages (list, install_params->libraryLocation (), install_params->installDependencies (), as_root);
}

void InstallPackagesWidget::installSelectedButtonClicked () {
	RK_TRACE (DIALOGS);
	QStringList list;
	QList<QTreeWidgetItem*> selected = installable_view->selectedItems ();
	for (int i = 0; i < selected.count (); ++i) {
		list.append (selected[i]->text (0));
	}
	installPackages (list);
}

void InstallPackagesWidget::getListButtonClicked () {
	RK_TRACE (DIALOGS);

	get_list_button->setEnabled (false);

	RCommand *command = new RCommand (".rk.get.available.packages ()", RCommand::App | RCommand::GetStructuredData, QString::null, this, FIND_AVAILABLE_PACKAGES_COMMAND);
	RKProgressControl *control = new RKProgressControl (this, i18n ("Please stand by while downloading the list of available packages."), i18n ("Fetching list"), RKProgressControl::CancellableProgress | RKProgressControl::AutoCancelCommands);
	control->addRCommand (command, true);
	RKGlobals::rInterface ()->issueCommand (command, parent->chain);
	control->doModal (true);
}

void InstallPackagesWidget::trySelectPackage (const QString &package_name) {
	RK_TRACE (DIALOGS);

	QList<QTreeWidgetItem*> found = installable_view->findItems (package_name, Qt::MatchExactly, 0);
	if (found.isEmpty ()) {
		KMessageBox::sorry (0, i18n ("The package requested by the backend (\"%1\") was not found in the package repositories. Maybe the package name was mis-spelled. Or maybe you need to add additional repositories via the \"Configure Repositories\"-button.", package_name), i18n ("Package not available"));
	} else {
		RK_ASSERT (found.count () == 1);
		installable_view->setCurrentItem (found[0]);
		found[0]->setSelected (true);
		installable_view->scrollToItem (found[0]);
	}
}

void InstallPackagesWidget::ok () {
	RK_TRACE (DIALOGS);
	deleteLater ();
}

void InstallPackagesWidget::cancel () {
	RK_TRACE (DIALOGS);
	deleteLater ();
}

/////////////////////// PackageInstallParamsWidget //////////////////////////

#include <qcombobox.h>
#include <qfileinfo.h>

PackageInstallParamsWidget::PackageInstallParamsWidget (QWidget *parent, bool ask_depends) : QWidget (parent) {
	RK_TRACE (DIALOGS);

	QVBoxLayout *vbox = new QVBoxLayout (this);
	vbox->setContentsMargins (0, 0, 0, 0);
	vbox->addWidget (new QLabel (i18n ("Install packages to:"), this));
	libloc_selector = new QComboBox (this);
	vbox->addWidget (libloc_selector);

	if (ask_depends) {
		dependencies = new QCheckBox (i18n ("Include dependencies"), this);
		dependencies->setChecked (true);
		vbox->addStretch ();
		vbox->addWidget (dependencies);
	} else {
		dependencies = 0;
	}
}

PackageInstallParamsWidget::~PackageInstallParamsWidget () {
	RK_TRACE (DIALOGS);
}

bool PackageInstallParamsWidget::installDependencies () {
	RK_TRACE (DIALOGS);

	if (!dependencies) return false;
	return dependencies->isChecked ();
}

QString PackageInstallParamsWidget::libraryLocation () {
	RK_TRACE (DIALOGS);

	return (libloc_selector->currentText ());
}

bool PackageInstallParamsWidget::checkWritable (bool *as_root) {
	RK_TRACE (DIALOGS);
	RK_ASSERT (as_root);

	QFileInfo fi = QFileInfo (libraryLocation ());
	if (!fi.isWritable ()) {
		QString mcaption = i18n ("Selected library location not writable");
		QString message = i18n ("The directory you are trying to install to (%1) is not writable with your current user permissions. "
			"You can chose a different library location to install to (if none are wirtable, you will probably want to use the "
			"\"Configure Repositories\"-button to set up a writable directory to install package to).\n", libraryLocation ());
#ifdef Q_WS_WIN
		message.append (i18n ("If have access to an administrator account on this machine, you can use that to install the package(s), or "
			"you could change the permissions of '%1'. Sorry, automatic switching to Administrator is not yet supported in RKWard on Windows", libraryLocation ()));
		int res = KMessageBox::warningContinueCancel (this, message, mcaption, KGuiItem (i18n ("Attempt installation, anyway")));
		if (res == KMessageBox::Continue) return true;
#else
		message.append (i18n ("If you are the administrator of this machine, you can try to install the packages as root (you'll be prompted for the root password)."));
		int res = KMessageBox::warningContinueCancel (this, message, mcaption, KGuiItem (i18n ("Become root")));
		if (res == KMessageBox::Continue) {
			*as_root = true;
			return true;
		}
#endif
		return false;
	}

	*as_root = false;
	return true;
}

void PackageInstallParamsWidget::liblocsChanged (const QStringList &newlist) {
	RK_TRACE (DIALOGS);

	libloc_selector->clear ();
	libloc_selector->insertItems (0, newlist);
}

#include "rkloadlibsdialog.moc"
