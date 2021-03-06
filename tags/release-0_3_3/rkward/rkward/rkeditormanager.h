/***************************************************************************
                          rkeditormanager  -  description
                             -------------------
    begin                : Fri Aug 20 2004
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
#ifndef RKEDITORMANAGER_H
#define RKEDITORMANAGER_H

#include <qwidget.h>
#include <qmap.h>
#include <qvaluelist.h>

#include "rbackend/rcommandreceiver.h"

class RKEditor;
class RObject;
class RCommandChain;
class RCommand;
class RKEditorDataFrame;

/**
This class is used to manage open editor windows. For now, it will arrange opened editors in a tabbook. Later it will also be responsible for docking/undocking editors, etc. This class does only GUI-related stuff. It knows nothing about the types of editors and the data they hold.

@author Thomas Friedrichsmeier
*/
class RKEditorManager : public QObject, public RCommandReceiver {
Q_OBJECT
public:
	RKEditorManager();

	~RKEditorManager();

	RKEditor *editObject (RObject *object, bool initialize_to_empty=false);
/// tries to open the editors/objects that were last opened
	void restoreEditors ();
	
	void closeEditor (RKEditor *editor);

	void flushAll ();
	void closeAll ();
	
	bool canEditObject (RObject *object);

/// returns the currently active editor
	void setEditorName (RKEditor *editor, const QString &new_name);
public slots:
	void editorDestroyed (QObject* editor);
protected:
	void rCommandDone (RCommand *command);
private:
	RCommandChain *restore_chain;
	RKEditorDataFrame *newRKEditorDataFrame ();
	QValueList<RKEditor*> editors;
};

#endif
