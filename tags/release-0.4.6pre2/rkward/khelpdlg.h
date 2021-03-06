/***************************************************************************
                          khelpdlg  -  description
                             -------------------
    begin                : Fri Feb 25 2005
    copyright            : (C) 2005, 2006 by Thomas Friedrichsmeier
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

#ifndef KHELPDLG_H
#define KHELPDLG_H

#include <qwidget.h>

#include "rbackend/rcommandreceiver.h"

//#include "helpdlg.h"

class QComboBox;
class QCheckBox;
class QPushButton;
class QListView;
class QListViewItem;

class RCommandChain;

/** Provides a UI interface for help-search.

@author Pierre Ecochard */
class KHelpDlg : public QWidget, public RCommandReceiver {
	Q_OBJECT
public:
	KHelpDlg (QWidget* parent = 0, const char* name = 0);
	~KHelpDlg ();
	void rCommandDone (RCommand *command);

/** small convenience function to get context help for RKCommandEditorWindow and RKConsole.
@param context_line The current line
@param cursor_pos cursor position in the current line
Will figure out the word under the cursor, and provide help on that (if there is such a word, and such help exists) */
	void getContextHelp (const QString &context_line, int cursor_pos);
	void getFunctionHelp (const QString &function_name);
public slots:
	void slotFindButtonClicked();
	void slotResultsListDblClicked( QListViewItem *item, const QPoint &, int );
private:
	QComboBox* field;
	QComboBox* fieldsList;
	QComboBox* packagesList;
	QCheckBox* caseSensitiveCheckBox;
	QCheckBox* fuzzyCheckBox;
	QPushButton* findButton;
	QListView* resultsList;
};

#endif

