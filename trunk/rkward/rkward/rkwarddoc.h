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

// forward declaration of the RKward classes
class RKwardView;

/**	RKwardDoc provides a document object for a document-view model.
  *
  * The RKwardDoc class provides a document object that can be used in conjunction with the classes RKwardApp and RKwardView
  * to create a document-view model for standard KDE applications based on KApplication and KMainWindow. Thereby, the document object
  * is created by the RKwardApp instance and contains the document structure with the according methods for manipulation of the document
  * data by RKwardView objects. Also, RKwardDoc contains the methods for serialization of the document data from and to files.
  *
  * @author Source Framework Automatically Generated by KDevelop, (c) The KDevelop Team. 	
  * @version KDevelop version 1.2 code generation
  */
class RKwardDoc : public QObject
{
  Q_OBJECT
  public:
    /** Constructor for the fileclass of the application */
    RKwardDoc(QWidget *parent, const char *name=0);
    /** Destructor for the fileclass of the application */
    ~RKwardDoc();

    /** adds a view to the document which represents the document contents. Usually this is your main view. */
    void addView(RKwardView *view);
    /** removes a view from the list of currently connected views */
    void removeView(RKwardView *view);
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
    /** calls repaint() on all views connected to the document object and is called by the view by which the document has been changed.
     * As this view normally repaints itself, it is excluded from the paintEvent.
     */
    void slotUpdateAllViews(RKwardView *sender);
 	
  public:	
    /** the list of the views currently connected to the document */
    static QList<RKwardView> *pViewList;	

  private:
    /** the modified flag of the current document */
    bool modified;
    KURL doc_url;
};

#endif // RKWARDDOC_H
