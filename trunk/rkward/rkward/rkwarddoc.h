/***************************************************************************
                          rkwarddoc.h  -  description
                             -------------------
    begin                : Tue Oct 29 20:06:08 CET 2002
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

#ifndef RKWARDDOC_H
#define RKWARDDOC_H

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif 

// include files for QT
#include <qobject.h>
#include <qstring.h>
#include <qlist.h>

// include files for KDE
#include <kurl.h>

#include "twintable.h"
class RKwardApp;
class TwinTableMember;
class TwinTable;
class RInterface;
class RCommand;

/**	This class represents the currently active document, i.e. the
	currently opened table. As of this version, there only ever is
	one single table/document, but this will be changed some day.
	Note that this code is based on a framework provided by KDevelop,
	and there's still lots of stuff in here, that will need to be
	removed/renamed, or is not implemented, yet.
  * @author Source Framework Automatically Generated by KDevelop, (c) The KDevelop Team. 	
  * @version KDevelop version 1.2 code generation
  */
class RKwardDoc : public TwinTable
{
  Q_OBJECT
  public:
    /** Constructor for the fileclass of the application */
    RKwardDoc(RKwardApp *parent, const char *name=0);
    /** Destructor for the fileclass of the application */
    ~RKwardDoc();

    /** sets the modified flag for the document after a modifying action on the view connected to the document.*/
    void setModified(bool _m=true){ modified=_m; };
    /** returns if the document is modified or not. Use this to determine if your document needs saving by the user on closing.*/
    bool isModified(){ return modified; };
    /** "save modified" - asks the user for saving if the document is modified */
    bool saveModified();	
    /** deletes the document's contents */
    void deleteContents();
    /** initializes the document generally */
    bool newDocument();
    /** closes the acutal document */
    void closeDocument();
    /** loads the document by filename and format and emits the updateViews() signal */
    bool openDocument(const KURL& url, const char *format=0);
    /** saves the document under filename and format.*/	
    bool saveDocument(const KURL& url, const char *format=0);
    /** returns the KURL of the document */
    const KURL& URL() const;
    /** sets the URL of the document */
	void setURL(const KURL& url);

  public slots:
/** processes output received by R. Uses the output_is-var, to determine, how
	to interpret this output */
	void processROutput (RCommand *command); 	
  public:	
	/** will take care of all necessary operations to sync up to R */
	void syncToR ();
	/** will take care of all necessary operations to sync up from R */
	void syncFromR ();

  private:
    /** the modified flag of the current document */
    bool modified;
    KURL doc_url;

	RKwardApp *app;
	QString tablename;
	QString command_separator;

	/** These are used, to keep track of what a running RCommand means */
	int should_load_id;
	int should_pull_id;

	/** pushes a whole (modified) twintable to R */
	void pushTable (TwinTable *ttable, QString name);
	/** pulls a whole table from R */
	void pullTable ();
};

#endif // RKWARDDOC_H
