/***************************************************************************
                          rkmdiwindow  -  description
                             -------------------
    begin                : Tue Sep 26 2006
    copyright            : (C) 2006 by Thomas Friedrichsmeier
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

#ifndef RKMDIWINDOW_H
#define RKMDIWINDOW_H

#include <qwidget.h>

#include <kparts/part.h>

class RKWorkplace;

/** Base class for rkward document mdi windows */
class RKMDIWindow : public QWidget {
	Q_OBJECT
public:
	enum Type {
		DataEditorWindow=1,
		CommandEditorWindow=2,
		OutputWindow=4,
		HelpWindow=8,
		AnyType=DataEditorWindow | CommandEditorWindow | OutputWindow | HelpWindow
	};

	enum State {
		Attached=1,
		Detached=2,
		AnyState=Attached | Detached
	};
protected:
/** constructor
@param parent parent widget
@param type Type of window */
	RKMDIWindow (QWidget *parent, Type type);
	virtual ~RKMDIWindow ();
public:
/** @returns true, if the window's document was modified (and would need to be saved) */
	virtual bool isModified () = 0;
/** @returns A long / complete caption. Default implementation simply calls shortCaption () */
	virtual QString fullCaption ();
/** @returns A short caption (e.g. only the filename without the path). Default implementation simply calls QWidget::caption () */
	virtual QString shortCaption ();
/** @returns The corresponding KPart for this window */
	virtual KParts::Part *getPart () = 0;
/** This is used in RKWorkplace::saveWorkplace () to save the info about the workplace. Make sure to add corresponding code to RKWorkplace::restoreWorkplace (), so your window(s) get restored when loading a Workspace
@returns An internal descriptive string suitable for storage in R. */
	virtual QString getRDescription () = 0;
/** Reimplemented from QWidget::setCaption () to emit the signal captionChanged () when the caption is changed. */
	void setCaption (const QString &caption);
/** Is this window attached (or detached)?
@returns true if attached, false if detached */
	bool isAttached () { return (state == Attached); };
signals:
/** This signal is emitted, whenever the window caption was changed.
@param RKMDIWindow* a pointer to this window */
	void captionChanged (RKMDIWindow *);
protected:
friend class RKWorkplace;
/** type of this window */
	Type type;
private:
/** state of this window (attached / detached). This is set from the RKWorkplace */
	State state;
};

#endif
