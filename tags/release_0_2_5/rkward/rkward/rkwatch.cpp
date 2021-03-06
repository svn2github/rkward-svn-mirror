/***************************************************************************
                          rkwatch.cpp  -  description
                             -------------------
    begin                : Sun Nov 3 2002
    copyright            : (C) 2002 by Thomas Friedrichsmeier
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

#include "rkwatch.h"

#include "rbackend/rinterface.h"
#include "rkcommandeditor.h"
#include "rkglobals.h"
#include "rkeditormanager.h"

#include <qtextedit.h>
#include <qpushbutton.h>
#include <qfont.h>
#include <qlayout.h>
#include <qsplitter.h>

#include <klocale.h>

RKwatch::RKwatch(RInterface *parent) : RKToggleWidget () {
	QGridLayout *grid = new QGridLayout (this, 1, 1, 11, 6);

	QSplitter *splitter = new QSplitter (QSplitter::Vertical, this);
	grid->addWidget (splitter, 0, 0);

	watch = new QTextEdit (splitter);
	watch->setTextFormat (PlainText);
	watch->setReadOnly (true);

	QWidget *layout_widget = new QWidget (splitter);
	QHBoxLayout *bottom_hbox = new QHBoxLayout (layout_widget, 0, 6);

	commands = new RKCommandEditor (layout_widget);
	bottom_hbox->addWidget (commands);
	
	// add run & reset buttons
	QVBoxLayout *button_vbox = new QVBoxLayout (0, 0, 6);
	bottom_hbox->addLayout (button_vbox);
	
	submit = new QPushButton(i18n ("&Run"), layout_widget);
	connect (submit, SIGNAL (clicked ()), this, SLOT (submitCommand ()));
	button_vbox->addWidget (submit);

	clear_commands = new QPushButton (i18n ("Reset"), layout_widget);
	connect (clear_commands, SIGNAL (clicked ()), this, SLOT (clearCommand ()));
	button_vbox->addWidget (clear_commands);

    resize (QSize (600, 511).expandedTo (minimumSizeHint ()));
	setCaption (i18n ("R-Interface Watch"));
	
	// set a fixed width font
    QFont font ("Courier");
	watch->setCurrentFont (font);
	watch->setWordWrap (QTextEdit::NoWrap);
	
	r_inter = parent;
}

RKwatch::~RKwatch(){
	delete commands;
}

void RKwatch::addInput (RCommand *command) {
// TODO: make colors/styles configurable
	if (command->type () & RCommand::User) {
		watch->setColor (Qt::red);
	} else if (command->type () & RCommand::Sync) {
		watch->setColor (Qt::gray);
	} else if (command->type () & RCommand::Plugin) {
		watch->setColor (Qt::blue);
	}

	watch->append ("---------------------------\n");
	watch->append ("Issuing command:\n");
	watch->setItalic (true);

	watch->append (command->command ());

	watch->setItalic (false);
}

void RKwatch::addOutput (RCommand *command) {
	watch->append ("---------------------------\n");
	watch->append ("Got reply:");
    watch->setBold (true);

	watch->append (command->output ());
	watch->append (command->error ());

	watch->setBold (false);	
	watch->setColor (Qt::black);
}

void RKwatch::clearCommand () {
	commands->setText ("");
	commands->setFocus ();
}

void RKwatch::submitCommand () {
	RKGlobals::editorManager ()->syncAllToR (0);
	r_inter->issueCommand (new RCommand (commands->text (), RCommand::User));
	clearCommand ();
}

void RKwatch::enableSubmit () {
	submit->setEnabled (true);
}

void RKwatch::disableSubmit () {
	submit->setEnabled (false);
}
