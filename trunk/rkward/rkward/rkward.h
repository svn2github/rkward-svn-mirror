/***************************************************************************
                          rkward.h  -  description
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

#ifndef RKWARD_H
#define RKWARD_H
 

#ifdef HAVE_CONFIG_H
#include <config.h>
#endif

// include files for Qt

// include files for KDE 
#include <kapp.h>
#include <kmdimainfrm.h>
#include <kaccel.h>
#include <kaction.h>
#include <kurl.h>

// forward declaration of the RKward classes
class RKwardDoc;
class RKwardView;
class RSettings;
class RKMenu;
class QTimer;
class RKOutputWindow;
class RObjectBrowser;
class RKSettingsModule;
class RKSettings;
class RInterface;
class RKEditorManager;
class RKMenuList;
class RKDocManager;
class RKCommandEditorWindow;
class KHelpDlg;

/**
  * The base class for RKward application windows. It sets up the main
  * window and reads the config file as well as providing a menubar, toolbar
  * and statusbar. An instance of RKwardView creates your center view, which is connected
  * to the window's Doc object.
  * RKwardApp reimplements the methods that KMainWindow provides for main window handling and supports
  * full session management as well as using KActions.
  * @see KMainWindow
  * @see KApplication
  * @see KConfig
  *
  * @author Source Framework Automatically Generated by KDevelop, (c) The KDevelop Team.
  * @version KDevelop version 1.2 code generation
  */
  
  //KMdiMainFrm( 0, "KMDITest_MainWindow", KMdi::IDEAlMode )
class RKwardApp : public KMdiMainFrm, virtual public KParts::PartBase
{
  Q_OBJECT
  public:
    /** construtor of RKwardApp, calls all init functions to create the application.
     */
    RKwardApp(KURL *load_url=0, QWidget* parent=0, const char* name=0);
    ~RKwardApp();

	void startR ();
	
	void newOutput ();
	
	void fileOpenNoSave (const KURL &url);
	void fileOpenAskSave (const KURL &url);
	void openHTML(KURL url);
protected:
	void openWorkspace (const KURL &url);
    /** save general Options like all bar positions and status as well as the geometry and the recent file list to the configuration
     * file
     */ 	
    void saveOptions();
    /** read general Options again and initialize all variables like the recent file list
     */
    void readOptions();
    /** initializes the KActions of the application */
    void initActions();
    /** sets up the statusbar for the main window by initialzing a statuslabel.
     */
    void initStatusBar();
    /** queryClose is called by KTMainWindow on each closeEvent of a window. Against the
     * default implementation (only returns true), this calles saveModified() on the document object to ask if the document shall
     * be saved if Modified; on cancel the closeEvent is rejected.
     * @see KTMainWindow#queryClose
     * @see KTMainWindow#closeEvent
     */
    virtual bool queryClose();
    /** queryExit is called by KTMainWindow when the last window of the application is going to be closed during the closeEvent().
     * Against the default implementation that just returns true, this calls saveOptions() to save the settings of the last window's	
     * properties.
     * @see KTMainWindow#queryExit
     * @see KTMainWindow#closeEvent
     */
    virtual bool queryExit();
    /** saves the window properties for each open window during session end to the session config file, including saving the currently
     * opened file by a temporary filename provided by KApplication.
     * @see KTMainWindow#saveProperties
     */
    virtual void saveProperties(KConfig *_cfg);
    /** reads the session config file and restores the application's state including the last opened files and documents by reading the
     * temporary files saved by saveProperties()
     * @see KTMainWindow#readProperties
     */
    virtual void readProperties(KConfig *_cfg);

  public slots:
	/** creates a new (empty) data.frame */
	void slotNewDataFrame ();
    /** open a file and load it into the document*/
    void slotFileOpenWorkspace();
    /** opens a file from the recent files menu */
    void slotFileOpenRecentWorkspace(const KURL& url);
    /** save a document */
    void slotFileSaveWorkspace();
    /** save a document by a new filename*/
    void slotFileSaveWorkspaceAs();
	/** shows the dialog to install/load/unload packages */
	void slotFileLoadLibs ();
	/** close current editor */
	void slotCloseEditor ();
	/** close all editors */
	void slotCloseAllEditors ();
    /** print the actual file */
    void slotFilePrint();
    /** closes all open windows by calling close() on each memberList item until the list is empty, then quits the application.
     * If queryClose() returns false because the user canceled the saveModified() dialog, the closing breaks.
     */
    void slotFileQuit();
    /** put the marked text/object into the clipboard and remove
     *	it from the document
     */
    void slotEditCut();
    /** put the marked text/object into the clipboard
     */
    void slotEditCopy();
    /** paste the clipboard into the document
     */
    void slotEditPaste();
    /** paste the clipboard into the document, but not beyond table boundaries
     */
    void slotEditPasteToTable();
    /** paste the clipboard into the document, but not beyond selection boundaries
     */
    void slotEditPasteToSelection();
    /** toggles the toolbar
     */
    void slotViewToolBar();
    /** toggles the statusbar
     */
    void slotViewStatusBar();
    /** changes the statusbar contents for the standard label permanently, used to indicate current actions.
     * @param text the text that is displayed in the statusbar
     */
    void slotStatusMsg(const QString &text);

	/** shows/hides the RKWatch-window */
	void slotShowRKWatch ();
	
	/** shows/hides the RKWatch-window */
	void slotShowRKOutput ();

	/** shows/hides the RObjectBrowser-window */
	void slotShowRObjectBrowser ();
	
	/** called when a togglable window was closed. Updates the corresponding actions */
	void slotToggleWindowClosed ();
	
	/** configures RKward-settings */
	void slotConfigure ();

	/** Init-procedures to be done after the exec-loop was started */
	void doPostInit ();
	
	void slotEditorsChanged ();
	
	void slotNewCommandEditor();
	void slotOpenCommandEditor();
	void slotSaveCommandEditor();
	void slotSaveCommandEditorAs();
	void slotCloseCommandEditor();
	void slotOpenURL(const KURL &url);
	void slotChildWindowCloseRequest (KMdiChildView * window);
	void slotRunSelection();
	void slotInterruptCommand();
	void slotRunAll();
	void slotEditUndo();
	void slotEditRedo();
	void slotViewActivated (KMdiChildView *window);
	void slotOpenRecentCommandEditor(const KURL&);
	void slotFunctionReference();
  private:
    /** the configuration object of the application */
    KConfig *config;
    /** doc represents your actual document and is created only once. It keeps
     * information such as filename and does the serialization of your files.
     */
    RKwardDoc *doc;
    
    RKDocManager *m_docManager;

    // KAction pointers to enable/disable actions
    KAction* fileOpen;
    KRecentFilesAction* fileOpenRecent;
    KAction* fileSave;
    KAction* fileSaveAs;
    
    KAction* fileOpenWorkspace;
    KRecentFilesAction* fileOpenRecentWorkspace;
    KAction* fileSaveWorkspace;
    KAction* fileSaveWorkspaceAs;
    KAction* filePrint;
    KAction* fileQuit;
    KAction* file_load_libs;
	KAction* close_editor;
	KAction* close_all_editors;
	KAction* new_data_frame;
	KAction* new_command_editor;
	
	KAction* editUndo;
	KAction* editRedo;
	KAction* editCut;
    KAction* editCopy;
    KAction* editPaste;
    KAction* editPasteToSelection;
    KAction* editPasteToTable;
    KToggleAction* viewToolBar;
    KToggleAction* viewStatusBar;
	KToggleAction* showRKWatch;
	KToggleAction* showRKOutput;
	KToggleAction* showRObjectBrowser;
	
	KAction* runAll;
	KAction* runSelection;
	KAction* interruptCommand;
	KAction* configure;
	
	KAction* helpFunction;

	friend class RKSettingsModule;
	friend class RKSettingsModulePlugins;
	friend class RKSettings;
	
/** Does pasting (called from the respective slots) */
	void doPaste ();

/** Finds plugins and inserts them into the menu-structure */
	void initPlugins ();

/** recursively initialize the plugins in this directory */
	int initPluginDir (const QString & dirname, RKMenu *parent);

/** Used to receive a signal during startup AFTER the exec loop was entered */
	QTimer *startup_timer;
	
	RKOutputWindow *output;
	RObjectBrowser *object_browser;
	KHelpDlg *helpDlg;
	
	KURL *initial_url;
	
	RKMenuList *menu_list;
	
	friend class RInterface;
	void setRStatus (bool busy);
	
	bool getFilenameAndPath(const KURL &url,QString *fname);
	void saveAsProcedure(RKCommandEditorWindow *editor);
    void setEnabledActions(bool commandEditor);
signals:
    void childWindowCloseRequest(KMdiChildView * window);
};
 
#endif // RKWARD_H
