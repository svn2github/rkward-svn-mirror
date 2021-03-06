/***************************************************************************
                          rfunctionobject  -  description
                             -------------------
    begin                : Wed Apr 26 2006
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
#ifndef RFUNCTION_H
#define RFUNCTION_H

#include "robject.h"

#include <qpair.h>
#include <qvaluelist.h>

class RCommand;

/**
Internal representation of function objects in the R workspace

@author Thomas Friedrichsmeier
*/

class RFunctionObject : public RObject {
public:
	RFunctionObject (RContainerObject *parent, const QString &name);
	~RFunctionObject ();

	void updateFromR ();
protected:
	void rCommandDone (RCommand *command);

	typedef QPair<QString, QString> FunctionArg;
	typedef QValueList<FunctionArg *> FunctionArguments;
	FunctionArguments function_args;
};

#endif
