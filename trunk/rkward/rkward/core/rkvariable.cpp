/***************************************************************************
                          rkvariable  -  description
                             -------------------
    begin                : Thu Aug 12 2004
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
#include "rkvariable.h"

#include "rcontainerobject.h"
#include "robjectlist.h"

#include "../rbackend/rinterface.h"
#include "../rkglobals.h"
#include "rkmodificationtracker.h"

#define UPDATE_DIM_COMMAND 1

#include "../debug.h"

RKVariable::RKVariable (RContainerObject *parent, const QString &name) : RObject (parent, name) {
	RK_TRACE (OBJECTS);
// TODO: better check, wether it really is one
	RObject::type = Variable;
	var_type = Unknown;
}

RKVariable::~RKVariable () {
	RK_TRACE (OBJECTS);
}

QString RKVariable::getVarTypeString () {
	RK_TRACE (OBJECTS);
	return RObject::typeToText (var_type);
}

void RKVariable::setVarType (RObject::VarType new_type, bool sync) {
	RK_TRACE (OBJECTS);
	var_type = new_type;
	setMetaProperty ("type", QString ().setNum ((int) new_type), sync);
}


QString RKVariable::getTable () {
	RK_TRACE (OBJECTS);
	return parent->getFullName ();
}

void RKVariable::updateFromR () {
	RK_TRACE (OBJECTS);
	
	getMetaData (RKGlobals::rObjectList()->getUpdateCommandChain ());

	RCommand *command = new RCommand ("length (" + getFullName () + ")", RCommand::App | RCommand::Sync | RCommand::GetIntVector, "", this, UPDATE_DIM_COMMAND);
	RKGlobals::rInterface ()->issueCommand (command, RKGlobals::rObjectList()->getUpdateCommandChain ());
}

void RKVariable::rCommandDone (RCommand *command) {
	RK_TRACE (OBJECTS);

	RObject::rCommandDone (command);
	
	if (command->getFlags () == UPDATE_DIM_COMMAND) {
		if (command->intVectorLength () == 1) {
			length = command->getIntVector ()[0];
		} else {
			length = 1;
		}
		
		QString dummy = getMetaProperty ("type");
		int new_var_type = dummy.toInt ();
		var_type = (RObject::VarType) new_var_type;
		if (new_var_type != var_type) RKGlobals::tracker ()->objectMetaChanged (this, 0);

		parent->childUpdateComplete ();
	}
}

////////////////////// BEGIN: data-handling //////////////////////////////
#define ALLOC_STEP 100

#define DELETE_STRING_DATA(row) if (myData ()->cell_string_data && (myData ()->cell_string_data[row] != empty_char) && (myData ()->cell_string_data[row] != unknown_char)) { delete myData ()->cell_string_data[row]; } myData ()->cell_string_data[row] = 0;

// virtual
void RKVariable::allocateEditData () {
	RK_TRACE (OBJECTS);

	// this assert should stay even when more than one editor is allowed per object. After all, the edit-data should only ever be allocated once!
	RK_ASSERT (!myData ());
	
	data = new RKVarEditData;
	myData ()->cell_double_data = 0;
	myData ()->cell_string_data = 0;
	myData ()->allocated_length = 0;
	myData ()->immediate_sync = true;
	myData ()->changes = 0;
	
	extendToLength (getLength ());
}

// virtual
void RKVariable::initializeEditData (bool) {
	RK_TRACE (OBJECTS);

	// TODO
}

// virtual
void RKVariable::discardEditData () {
	RK_TRACE (OBJECTS);

	RK_ASSERT (myData ());

	delete [] myData ()->cell_double_data;
	for (int i = 0; i < myData ()->allocated_length; ++i) {
		DELETE_STRING_DATA (i);
	}
	delete [] myData ()->cell_string_data;

	RK_ASSERT (!(myData ()->changes));
	delete myData ();
}

void RKVariable::setSyncing (bool immediate) {
	RK_TRACE (OBJECTS);
	RK_ASSERT (myData ());
	
	myData ()->immediate_sync = immediate;
	if (!immediate) {
		if (!myData ()->changes) {
			myData ()->changes = new ChangeSet;
			myData ()->changes->from_index = -1;
			myData ()->changes->to_index = -1;
		}
	} else {
		delete myData ()->changes;
		myData ()->changes = 0;
	}
}

void RKVariable::syncDataToR () {
	RK_TRACE (OBJECTS);
	if (!(myData ()->changes)) return;
	
	// TODO
	writeData (myData ()->changes->from_index, myData ()->changes->to_index);
	myData ()->changes->from_index = -1;
	myData ()->changes->to_index = -1;
}

void RKVariable::writeData (int from_row, int to_row) {
	if (from_row == -1) return;

	// TODO: try to sync in correct storage mode
	if (from_row == to_row) {
		RKGlobals::rInterface ()->issueCommand (getFullName () + "[" + QString::number (from_row+1) + "] <- " + rQuote (getText (from_row)), RCommand::App | RCommand::Sync);
	} else {
		QString data_string = "c (";
		for (int row = from_row; row <= to_row; ++row) {
			// TODO: use getCharacter and direct setting of vectors.
			data_string.append (rQuote (getText (row)));
			if (row != to_row) {
				data_string.append (", ");
			}
		}
		data_string.append (")");
		RKGlobals::rInterface ()->issueCommand (getFullName () + "[" + QString::number (from_row + 1) + ":" + QString::number (to_row + 1) + "] <- " + data_string, RCommand::App | RCommand::Sync);
	}
}

void RKVariable::cellChanged (int row) {
	RK_TRACE (OBJECTS);
	if (myData ()->immediate_sync) {
		writeData (row, row);
	} else {
		RK_ASSERT (myData ()->changes);
		if ((myData ()->changes->from_index > row) || (myData ()->changes->from_index == -1)) myData ()->changes->from_index = row;
		if (myData ()->changes->to_index < row) myData ()->changes->to_index = row;
	}
}

void RKVariable::cellsChanged (int from_row, int to_row) {
	RK_TRACE (OBJECTS);
	if (myData ()->immediate_sync) {
		writeData (from_row, to_row);
	} else {
		RK_ASSERT (myData ()->changes);
		if ((myData ()->changes->from_index > from_row) || (myData ()->changes->from_index == -1)) myData ()->changes->from_index = from_row;
		if (myData ()->changes->to_index < to_row) myData ()->changes->to_index = to_row;
	}
}

void RKVariable::extendToLength (int length) {
	RK_TRACE (OBJECTS);

	if (length <= myData ()->allocated_length) return;
	
	int target = length + ALLOC_STEP - (length % ALLOC_STEP);
	
	char **new_string_data = new char*[target];
	double *new_double_data = new double[target];
	
	if (myData ()->cell_string_data) {		// not starting from 0
		qmemmove (myData ()->cell_string_data, new_string_data, myData ()->allocated_length * sizeof (char*));
		qmemmove (myData ()->cell_double_data, new_double_data, myData ()->allocated_length * sizeof (double*));
	
		delete [] (myData ()->cell_string_data);
		delete [] (myData ()->cell_double_data);
	}
	for (int i=myData ()->allocated_length; i < target; ++i) {
		myData ()->cell_string_data[i] = empty_char;
	}

	myData ()->cell_string_data = new_string_data;
	myData ()->cell_double_data = new_double_data;

	myData ()->allocated_length = target;
	RKVariable::length = length;
}

void RKVariable::downSize () {
	RK_TRACE (OBJECTS);

	// TODO: downsizing to values other than 0
	if (length <= 0) {
		delete [] myData ()->cell_double_data;
		myData ()->cell_double_data = 0;
		for (int i = 0; i < myData ()->allocated_length; ++i) {
			DELETE_STRING_DATA (i);
		}
		delete [] myData ()->cell_string_data;
		myData ()->cell_string_data = 0;
	}
}

/** See Storage enum. Returns how the row is actually saved in the R-backend. */
RKVariable::RStorage RKVariable::rStorage () {
	//TODO: implement correctly!
	return StorageString;
}

QString RKVariable::getText (int row) {
	if (row >= getLength ()) {
		RK_ASSERT (false);
		return unknown_char;
	}
	if (getVarType () == String) {
		return QString::fromLocal8Bit (myData ()->cell_string_data[row]);
	} else {
		if (myData ()->cell_string_data[row] != 0) {
			return QString::fromLocal8Bit (myData ()->cell_string_data[row]);
		} else {
			return QString::number (myData ()->cell_double_data[row]);
		}
	}
}

void RKVariable::setText (int row, const QString &text) {
	RK_ASSERT (row < length);

	// delete previous string data, unless it's a special value
	DELETE_STRING_DATA (row);

	if (getVarType () == String) {
		if (text.isEmpty ()) myData ()->cell_string_data[row] = empty_char;
		else myData ()->cell_string_data[row] = qstrdup (text.local8Bit ());
	} else {
		bool ok;
		myData ()->cell_double_data[row] = text.toDouble (&ok);
		if (!ok) {
			if (text.isEmpty ()) myData ()->cell_string_data[row] = empty_char;
			else myData ()->cell_string_data[row] = qstrdup (text.local8Bit ());
		}
	}
	cellChanged (row);
}

/** get the text in pretty form, e.g. rounding numbers to a certain number of digits, replacing numeric values with value labels if available, etc. Formatting is done according to the meta-information stored in the RObject and global user preferences */
QString RKVariable::getFormatted (int row) {
	// TODO: implement!
	// for now just return the text
	return getText (row);
}

/** get a copy of the numeric values of rows starting from from_index, going to to_index. Do not use this before making sure that the rStorage () is really
numeric! */
double *RKVariable::getNumeric (int from_row, int to_row) {
	if (to_row >= length) {
		RK_ASSERT (false);
		return 0;
	}
	RK_ASSERT (from_row <= to_row);

	// TODO: no, this is not good. Return a _copy_!
	// we simply return the whole array starting at the given offset for now. Change this, if the storage mechanism gets changed!
	return &(myData ()->cell_double_data[from_row]);
}

void RKVariable::setNumeric (int from_row, int to_row, double *data) {
	RK_ASSERT (to_row < length);
	
	for (int row=from_row; row <= to_row; ++row) {
		DELETE_STRING_DATA (row);
	}
	
	if (getVarType () == String) {
		RK_ASSERT (false);		// asserting false to catch cases of this use for now. it's not really a problem, though
		int i = 0;
		for (int row=from_row; row <= to_row; ++row) {
			myData ()->cell_string_data[row] = qstrdup (QString::number (data[i++]));
		}
	} else {
		int i = 0;
		for (int row=from_row; row <= to_row; ++row) {
			myData ()->cell_double_data[row] = data[i++];
		}
	}
	cellsChanged (from_row, to_row);
}

/** like getNumeric, but returns values as an array of char*s */
char **RKVariable::getCharacter (int from_row, int to_row) {
	if (to_row >= length) {
		RK_ASSERT (false);
		return 0;
	}
	RK_ASSERT (from_row <= to_row);

	char **ret = new char*[(to_row - from_row) + 1];
	
	int i = 0;
	for (int row = from_row; row <= to_row; ++row) {
		if (myData ()->cell_string_data[row]) {
			ret[i] = myData ()->cell_string_data[row];
		} else {
			ret[i] = qstrdup (getText (row).local8Bit ());;
		}
		i++;
	}

	return ret;
}

/** like setNumeric, but sets chars. If internalStorage () is numeric, attempts to convert the given strings to numbers. I.e. the function behaves essentially like setText (), but operates on a range of cells. */
void RKVariable::setCharacter (int from_row, int to_row, char **data) {
	RK_ASSERT (to_row < length);
	
	if (getVarType () == String) {
		int i=0;
		for (int row=from_row; row <= to_row; ++row) {
			DELETE_STRING_DATA (row);
			myData ()->cell_string_data[row] = data[i++];
		}
	} else {
		int i=0;
		for (int row=from_row; row <= to_row; ++row) {
			// TODO: converting to QString and then back to local8Bit () is inefficient!
			// note: old string pointers are deleted inside setText ();
			setText (row, data[i++]);
		}
	}
	cellsChanged (from_row, to_row);
}

void RKVariable::setUnknown (int from_row, int to_row) {
	RK_ASSERT (to_row < length);

	if ((from_row < 0)) from_row = 0;
	if ((to_row < 0)) to_row = myData ()->allocated_length - 1;
		
	for (int row=from_row; row <= to_row; ++row) {
		DELETE_STRING_DATA (row);
		myData ()->cell_string_data[row] = unknown_char;
	}
}

RKVariable::Status RKVariable::cellStatus (int row) {
	if (myData ()->cell_string_data[row] == empty_char) {
		return ValueUnused;
	} else if (myData ()->cell_string_data[row] == unknown_char) {
		return ValueUnknown;
	} else if ((getVarType () == Number) && (myData ()->cell_string_data[row] != 0)) {
		return ValueInvalid;
	} else if (getVarType () != String) {
		return ValueInvalid;
	}
	return ValueValid;
}

/** entirely remove the given row (i.e. the cell). Will also take care of updating the state (are there any invalid cells left?), and syncing with the backend */
void RKVariable::removeRow (int row) {
	removeRows (row, row);
}

/** see removeRow (), but removes a range of rows (i.e. cells). Since data only needs to be copied once, this is more efficient than several single calls to removeRow () */
void RKVariable::removeRows (int from_row, int to_row) {
	for (int row = from_row; row <= to_row; ++row) {
		DELETE_STRING_DATA (row);
	}

	if (to_row < (myData ()->allocated_length - 1)) {	// not the last rows
		qmemmove (&(myData ()->cell_string_data[to_row+1]), &(myData ()->cell_string_data[from_row]), (myData ()->allocated_length - to_row - 1) * sizeof (char*));
		qmemmove (&(myData ()->cell_double_data[to_row+1]), &(myData ()->cell_double_data[from_row]), (myData ()->allocated_length - to_row - 1) * sizeof (double*));
	}

	for (int row = (myData ()->allocated_length - 1 - (to_row - from_row)); row < myData ()->allocated_length; ++row) {
		myData ()->cell_string_data[myData ()->allocated_length - 1] = empty_char;
		myData ()->cell_double_data[myData ()->allocated_length - 1] = 0;
	}

	length -= (to_row - from_row) + 1;	
	downSize ();
}

void RKVariable::insertRow (int row) {
	insertRows (row, 1);
}

void RKVariable::insertRows (int row, int count) {
	extendToLength (row + count + 1);
	
	qmemmove (&(myData ()->cell_string_data[row]), &(myData ()->cell_string_data[row+count]), (myData ()->allocated_length - row - count) * sizeof (char*));
	qmemmove (&(myData ()->cell_double_data[row]), &(myData ()->cell_double_data[row+count]), (myData ()->allocated_length - row - count) * sizeof (double));
	
	for (int i=row+count; i >= row; --i) {
		myData ()->cell_string_data[i] = empty_char;
		myData ()->cell_double_data[i] = 0;
	}
}

/////////////////// END: data-handling ///////////////////////////
