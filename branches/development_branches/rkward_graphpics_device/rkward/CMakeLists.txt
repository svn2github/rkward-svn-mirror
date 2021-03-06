IF(NOT ${PROJECT_NAME} STREQUAL "rkward")
	MESSAGE (FATAL_ERROR "Build triggered from wrong subdirectory. Please point cmake to the parent of this directory, instead.")
ENDIF(NOT ${PROJECT_NAME} STREQUAL "rkward")

INCLUDE(SetVersionNumber.cmake)

IF(Q_WS_MAC)
	SET(RKWARD_FRONTEND_LOCATION ${BIN_INSTALL_DIR}/rkward.frontend.app/Contents/MacOS)
	SET(CPACK_BUNDLE_ICON rkward.icns)
	SET(CPACK_BUNDLE_NAME RKWard)
	SET(CPACK_BUNDLE_STARTUP_COMMAND rkward)
	SET(KDE_START_DBUS "launchctl load -w /opt/rkward/Library/LaunchAgents/org.freedesktop.dbus-session.plist")
#	SET(CPACK_BUNDLE_PLIST ${CMAKE_SOURCE_DIR}/rkward/Info.plist)
ELSE(Q_WS_MAC)
	SET(RKWARD_FRONTEND_LOCATION ${LIBEXEC_INSTALL_DIR})
ENDIF(Q_WS_MAC)

ADD_SUBDIRECTORY( dataeditor )
ADD_SUBDIRECTORY( settings )
ADD_SUBDIRECTORY( plugin )
ADD_SUBDIRECTORY( agents )
ADD_SUBDIRECTORY( rbackend )
ADD_SUBDIRECTORY( dialogs )
ADD_SUBDIRECTORY( scriptbackends )
ADD_SUBDIRECTORY( misc )
ADD_SUBDIRECTORY( core )
ADD_SUBDIRECTORY( icons )
IF(WIN32)
	ADD_SUBDIRECTORY( qwinhost )
	LIST(APPEND RKWARD_ADDLIBS qwinhost)
ELSE(WIN32)
	LIST(APPEND RKWARD_ADDLIBS ${X11_X11_LIB})
ENDIF(WIN32)
ADD_SUBDIRECTORY( windows )
ADD_SUBDIRECTORY( syntax )

INCLUDE_DIRECTORIES( ${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_BINARY_DIR} ${KDE4_INCLUDE_DIR} ${QT_INCLUDES} ${X11_X11_INCLUDE_PATH} )

SET(RKWard_Sources
	rkward.cpp
	main.cpp
	rkglobals.cpp
	robjectviewer.cpp
	rkconsole.cpp
	rkwardapplication.cpp
)

# auto-gen sources
#QT4_AUTOMOC(${RKWard_Sources})	# not needed here, as KDE4_ADD_EXECUTABLE mocs the sources in this dir.

# somehow the needed libdirs for R do not get passed down automatically
GET_DIRECTORY_PROPERTY(R_SHAREDLIBDIR DIRECTORY rbackend LINK_DIRECTORIES)
LINK_DIRECTORIES(${R_SHAREDLIBDIR})

KDE4_ADD_EXECUTABLE(rkward.frontend ${RKWard_Sources})
SET_TARGET_PROPERTIES(rkward.frontend PROPERTIES
        MACOSX_BUNDLE_BUNDLE_NAME "RKWard")

# wrapper script
GET_DIRECTORY_PROPERTY(R_EXECUTABLE DIRECTORY rbackend DEFINITION R_EXECUTABLE)
IF(WIN32)
	SET(RKWARD_WRAPPER_TEMPLATE rkward.bat.in)
	SET(RKWARD_WRAPPER_SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/rkward.bat)
# For now use wrapper binary on Windows, only, and only as an alternative to rkward.bat.
# Will become standard startup mechanism on all platforms, in a later release
	ADD_SUBDIRECTORY( wrapper )
ELSE(WIN32)
	SET(RKWARD_WRAPPER_TEMPLATE rkward.sh.in)
	SET(RKWARD_WRAPPER_SCRIPT ${CMAKE_CURRENT_BINARY_DIR}/rkward)
ENDIF(WIN32)
CONFIGURE_FILE(
	${RKWARD_WRAPPER_TEMPLATE}
	${RKWARD_WRAPPER_SCRIPT}
	@ONLY)
ADD_DEPENDENCIES(rkward.frontend ${RKWARD_WRAPPER_SCRIPT})

IF(Q_WS_MAC)
	SET(RKWARD_INFOPLIST_TEMPLATE Info.plist.in)
	SET(RKWARD_INFOPLIST_FILE ${CMAKE_SOURCE_DIR}/rkward/Info.plist)
	CONFIGURE_FILE(
		${RKWARD_INFOPLIST_TEMPLATE}
		${RKWARD_INFOPLIST_FILE}
		@ONLY)
ENDIF(Q_WS_MAC)

TARGET_LINK_LIBRARIES(rkward.frontend ${KDE4_KDECORE_LIBS} windows ${RKWARD_ADDLIBS} agents dialogs plugin settings dataeditor core scriptbackends rbackend misc ktexteditor ${KDE4_KHTML_LIBS} ${KDE4_KFILE_LIBS} ${KDE4_KDEUI_LIBS} ${KDE4_KROSSCORE_LIBS} ${QT_QTSCRIPT_LIBRARY} ${QT_QTNETWORK_LIBRARY})

########### install files ###############

INSTALL(DIRECTORY plugins/ pages DESTINATION ${DATA_INSTALL_DIR}/rkward
	PATTERN .svn EXCLUDE)

INSTALL(FILES resource.ver rkwardui.rc rkconsolepart.rc DESTINATION ${DATA_INSTALL_DIR}/rkward )

IF(Q_WS_MAC)
	INSTALL(TARGETS rkward.frontend DESTINATION ${BIN_INSTALL_DIR})
	INSTALL(PROGRAMS ${RKWARD_WRAPPER_SCRIPT} DESTINATION ${BUNDLE_INSTALL_DIR}/${CPACK_BUNDLE_NAME}.app/Contents/MacOS)
	INSTALL(FILES ${CMAKE_SOURCE_DIR}/rkward/icons/app-icon/rkward.icns DESTINATION ${BUNDLE_INSTALL_DIR}/${CPACK_BUNDLE_NAME}.app/Contents/Resources)
	INSTALL(FILES ${RKWARD_INFOPLIST_FILE} DESTINATION ${BUNDLE_INSTALL_DIR}/${CPACK_BUNDLE_NAME}.app/Contents)
ELSE(Q_WS_MAC)
	INSTALL(TARGETS rkward.frontend DESTINATION ${LIBEXEC_INSTALL_DIR})
	INSTALL(PROGRAMS ${RKWARD_WRAPPER_SCRIPT} DESTINATION ${BIN_INSTALL_DIR})
ENDIF(Q_WS_MAC)

INSTALL(FILES rkward.desktop DESTINATION ${XDG_APPS_INSTALL_DIR})
