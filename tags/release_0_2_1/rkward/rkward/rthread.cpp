/***************************************************************************
                          rthread  -  description
                             -------------------
    begin                : Mon Aug 2 2004
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
#include "rthread.h"

#include "rembed.h"
#include "rinterface.h"

#include <qapplication.h>

RThread::RThread(RInterface *parent) : QThread() {
	inter = parent;
	top_chain = new RCommand::CommandChain;
	top_chain->closed = true;
	top_chain->parent = 0;
	current_chain = top_chain;
}

RThread::~RThread() {
}

void RThread::issueCommand (RCommand::RCommand *command, RCommand::CommandChain *chain) {
	mutex.lock ();
	if (!chain) chain = top_chain;
	
	RCommand::ChainOrCommand *coc = new RCommand::ChainOrCommand;
	coc->command = command;
	coc->chain = 0;
	chain->commands.append (coc);
	mutex.unlock ();
}

RCommand::CommandChain *RThread::startChain (RCommand::CommandChain *parent) {
	mutex.lock ();
	if (!parent) parent = top_chain;

	RCommand::ChainOrCommand *coc = new RCommand::ChainOrCommand;
	coc->command = 0;
	coc->chain = new RCommand::CommandChain;
	coc->chain->closed = false;
	coc->chain->parent = parent;
	parent->commands.append (coc);
	
	mutex.unlock ();
	return coc->chain;
}

RCommand::CommandChain *RThread::closeChain (RCommand::CommandChain *chain) {
	if (!chain) return 0;

	mutex.lock ();
	chain->closed = true;
	RCommand::CommandChain *ret = chain->parent;
	
	// lets see, whether we can do some cleanup
	while (current_chain->commands.isEmpty () && current_chain->closed && current_chain->parent) {
		RCommand::CommandChain *temp = current_chain;
		current_chain = current_chain->parent;
		delete temp;
	}
	
	mutex.unlock ();
	return ret;
}

void RThread::run () {
	embeddedR = new REmbed ();
	if (embeddedR->initialize ()) {
		qApp->postEvent (inter, new QCustomEvent (RERROR_SINKING_EVENT));
	}
	qApp->postEvent (inter, new QCustomEvent (RSTARTED_EVENT));

	while (1) {
		mutex.lock ();
		
		if (current_chain->commands.isEmpty () && (!current_chain->closed)) {
			qApp->postEvent (inter, new QCustomEvent (RBUSY_EVENT));
		}
	
		// while commands are in queue, don't wait
		while (!current_chain->commands.isEmpty ()) {
			RCommand::ChainOrCommand *coc = current_chain->commands.first ();
			current_chain->commands.removeFirst ();
			if (coc->command) {
				RCommand *command = coc->command;
				
				mutex.unlock ();
				
				// this statement is the time-consuming one. Thankfully, we do not need a mutex at this point
				doCommand (command);
				
				mutex.lock ();
				
				delete coc;
			} else {
				current_chain = coc->chain;
				delete coc;
			}
			
			// reached end of chain and chain is closed? walk up
			while (current_chain->commands.isEmpty () && current_chain->closed && current_chain->parent) {
				RCommand::CommandChain *temp = current_chain;
				current_chain = current_chain->parent;
				delete temp;
			}
		}
		
		// if no commands are in queue, sleep for a while
		if (current_chain->closed) {
			qApp->postEvent (inter, new QCustomEvent (RIDLE_EVENT));
		}
		
		mutex.unlock ();
		msleep (10);
	}
}

void RThread::doCommand (RCommand *command) {
	// notify GUI-thread that a new command is being tried
	QCustomEvent *event = new QCustomEvent (RCOMMAND_IN_EVENT);
	event->setData (command);
	qApp->postEvent (inter, event);
	
	embeddedR->runCommand (command);
	qDebug ("ran command %d", command->id ());

	// notify GUI-thread that command was finished
	event = new QCustomEvent (RCOMMAND_OUT_EVENT);
	event->setData (command);
	qApp->postEvent (inter, event);
}
