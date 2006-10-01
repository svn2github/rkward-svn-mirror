/***************************************************************************
                          robjectlist  -  description
                             -------------------
    begin                : Wed Aug 18 2004
    copyright            : (C) 2004, 2006 by Thomas Friedrichsmeier
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
#include "robjectlist.h"

#define AUTO_UPDATE_INTERVAL 10000
#define UPDATE_DELAY_INTERVAL 500

#define UPDATE_LIST_COMMAND 1
#define CHILD_GET_TYPE_COMMAND 2
#define LOAD_COMPLETE_COMMAND 3

#include <qtimer.h>
#include <qstringlist.h>

#include <klocale.h>

#include "rkvariable.h"
#include "rfunctionobject.h"
#include "renvironmentobject.h"

#include "../rbackend/rinterface.h"
#include "rkmodificationtracker.h"

#include "../rkglobals.h"

#include "../debug.h"

RObjectList::RObjectList () : RContainerObject (0, QString::null) {
	RK_TRACE (OBJECTS);
	update_timer = new QTimer (this);
	
	connect (update_timer, SIGNAL (timeout ()), this, SLOT (timeout ()));
	
	//update_timer->start (AUTO_UPDATE_INTERVAL, true);
	
	type = RObject::Workspace;
	
	update_chain = 0;
	toplevel_environments = 0;
	num_toplevel_environments = 0;
}


RObjectList::~RObjectList () {
	RK_TRACE (OBJECTS);
}

void RObjectList::rCommandDone (RCommand *command) {
	RK_TRACE (OBJECTS);

	bool changed = false;

	if (command->getFlags () == UPDATE_LIST_COMMAND) {
		// first check, whether all known children still exist:
		checkRemovedChildren (command->getStringVector (), command->stringVectorLength ());
		
		// next, update the existing and/or new children
		num_children_updating = command->stringVectorLength ();		// TODO: is this correct? Some children might have been removed!
		// empty workspace?
		if (!num_children_updating) {
			num_children_updating = 1;
			childUpdateComplete ();
			return;
		}
		REnvironmentObject **new_toplevel_envs = new REnvironmentObject*[command->stringVectorLength ()];
		int num_new_toplevel_envs = 0;
		for (int i = 0; i < command->stringVectorLength (); ++i) {
			QString cname = command->getStringVector ()[i];		// for easier typing
			/*if (cname == (".rk.meta")) {
				childUpdateComplete ();
				continue;
			}*/
			if (childmap.find (cname) != childmap.end ()) {
				childmap[cname]->updateFromR ();
			} else {
				createToplevelEnvironment (cname);
				changed = true;
			}

			RObject *object = childmap[cname];
			RK_ASSERT (object);
			RK_ASSERT (object->isType (Environment));
			new_toplevel_envs[num_new_toplevel_envs++] = static_cast<REnvironmentObject *> (object);
		}
		delete [] toplevel_environments;
		toplevel_environments = new_toplevel_envs;
		num_toplevel_environments = num_new_toplevel_envs;
	} else if (command->getFlags () == CHILD_GET_TYPE_COMMAND) {
		if (command->intVectorLength () != 1) {
			RK_ASSERT (false);
			qDebug (command->command ().latin1());
		}

		PendingObject *pobj = pending_objects[command];
		RObject *robj;
		// TODO: handle more special types!
		if (command->getIntVector ()[0] == 1) {
			robj = new RContainerObject (pobj->parent, pobj->name);
		} else if (command->getIntVector ()[0] == 2) {
			robj = new RFunctionObject (pobj->parent, pobj->name);
		} else {
			robj = new RKVariable (pobj->parent, pobj->name);
		}
		RK_ASSERT (robj);
		pobj->parent->addChild (robj, pobj->name);
		delete pobj;
		pending_objects.remove (command);
		RKGlobals::tracker ()->addObject (robj, 0);
	}
	
	// TODO: signal change
}

QString RObjectList::listChildrenCommand () {
	RK_TRACE (OBJECTS);

	return ("search ()");
}

void RObjectList::updateFromR () {
	RK_TRACE (OBJECTS);
	if (update_chain) {
		// gee, looks like another update is still on the way. lets schedule one for later:
		update_timer->start (UPDATE_DELAY_INTERVAL, true);
		RK_DO (qDebug ("another object-list update is already running (%d children still updating). Rescheduling a further update for later", num_children_updating), OBJECTS, DL_DEBUG);
		return;
	}

	emit (updateStarted ());
	update_chain = RKGlobals::rInterface ()->startChain (0);

	RCommand *command = new RCommand (listChildrenCommand (), RCommand::App | RCommand::Sync | RCommand::GetStringVector, QString::null, this, UPDATE_LIST_COMMAND);
	RKGlobals::rInterface ()->issueCommand (command, update_chain);
}

void RObjectList::createFromR (RContainerObject *parent, const QString &cname) {
	RK_TRACE (OBJECTS);
	PendingObject *obj = new PendingObject;
	obj->name = cname;
	obj->parent = parent;

	QString fullname = parent->makeChildName (cname);

	RCommand *command = new RCommand (".rk.get.type (" + fullname + ")", RCommand::App | RCommand::Sync | RCommand::GetIntVector, QString::null, this, CHILD_GET_TYPE_COMMAND);
	pending_objects.insert (command, obj);
	RKGlobals::rInterface ()->issueCommand (command, update_chain);
}

void RObjectList::createToplevelEnvironment (const QString &name) {
	RK_TRACE (OBJECTS);
	RK_ASSERT (childmap.find (name) == childmap.end ());

	REnvironmentObject *envobj = new REnvironmentObject (this, name);
	if (name == ".GlobalEnv") {
		envobj->type |= GlobalEnv;
	} else if (name.contains (':')) {
		envobj->namespace_name = name.section (':', 1);
	} else if (name == "Autoloads") {
		envobj->type |= GlobalEnv;		// this is wrong! but it's a temporary HACK to get things to work
	}

	addChild (envobj, name);
	RKGlobals::tracker ()->addObject (envobj, 0);
	envobj->updateFromR ();
}

void RObjectList::childUpdateComplete () {
	RK_TRACE (OBJECTS);
	RK_ASSERT (num_children_updating);
	if ((--num_children_updating) <= 0) {
		RK_TRACE (OBJECTS);

		RK_ASSERT (update_chain);
		RKGlobals::rInterface ()->closeChain (update_chain);
		update_chain = 0;

		RK_DO (qDebug ("object list update complete"), OBJECTS, DL_DEBUG);
		emit (updateComplete ());
	}
}

RObject *RObjectList::findObject (const QString &name, bool is_canonified) {
	RK_TRACE (OBJECTS);

	QString canonified = name;
	if (!is_canonified) {
		canonified = RObject::canonifyName (name);
	}

	// TODO: there could be objects with "::" in their names!
	if (canonified.contains ("::")) {
		QString env = canonified.section ("::", 0, 0);
		QString remainder = canonified.section ("::", 1);

		RObjectMap::iterator it = childmap.find (env);
		if (it == childmap.end ()) return 0;

		RObject *found = it.data ();
		return (found->findObject (remainder, true));
	}

	// no environment specified, do regular search:
	// TODO: there could be objects with "$" in their names!
	QString current_level = canonified.section (QChar ('$'), 0, 0);
	QString remainder = canonified.section (QChar ('$'), 1);

	for (int i = 0; i < num_toplevel_environments; ++i) {
		RObject *found = toplevel_environments[i]->findChild (current_level);
		if (found) {
			if (remainder.isEmpty ()) return (found);
			return (found->findObject (remainder, true));
		}
	}
	return 0;
}

void RObjectList::timeout () {
	RK_TRACE (OBJECTS);
	updateFromR ();
}

void RObjectList::renameChild (RObject *, const QString &) {
	RK_TRACE (OBJECTS);

	RK_ASSERT (false);
}

void RObjectList::removeChild (RObject *object, bool removed_in_workspace) {
	RK_TRACE (OBJECTS);

	if (removed_in_workspace) {
		RObjectMap::iterator it = childmap.find (object->getShortName ());
		RK_ASSERT (it.data () == object);
		childmap.remove (it);

		// remove from list of toplevel environments
		REnvironmentObject **new_toplevel_envs = new REnvironmentObject*[num_toplevel_environments];
		int num_new_toplevel_envs = 0;
		for (int i=0; i < num_toplevel_environments; ++i) {
			if (toplevel_environments[i] != object) new_toplevel_envs[num_new_toplevel_envs++] = toplevel_environments[i];
		}
		RK_ASSERT ((num_toplevel_environments - 1) == num_new_toplevel_envs); 
		delete [] toplevel_environments;
		toplevel_environments = new_toplevel_envs;
		num_toplevel_environments = num_new_toplevel_envs;

		delete object;
	} else {
		RK_ASSERT (false);
	}
}

#include "robjectlist.moc"
