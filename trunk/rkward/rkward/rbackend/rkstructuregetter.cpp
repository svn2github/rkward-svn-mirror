/***************************************************************************
                          rkstructuregetter  -  description
                             -------------------
    begin                : Wed Apr 11 2007
    copyright            : (C) 2007 by Thomas Friedrichsmeier
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

#include "rkstructuregetter.h"

RKStructureGetter::RKStructureGetter (bool keep_evalled_promises) {
	RK_TRACE (RBACKEND);

	RKStructureGetter::keep_evalled_promises = keep_evalled_promises;

	class_fun = Rf_findFun (Rf_install ("class"),  R_BaseEnv);;
	PROTECT (class_fun);
	RK_ASSERT (!Rf_isNull (class_fun));

	meta_attrib = Rf_install (".rk.meta");
	PROTECT (meta_attrib);
	RK_ASSERT (!Rf_isNull (meta_attrib));

	get_meta_fun = Rf_findFun (Rf_install (".rk.get.meta"),  R_GlobalEnv);;
	PROTECT (get_meta_fun);
	RK_ASSERT (!Rf_isNull (get_meta_fun));

// Why do we need all these? Because the is.xxx functions may do an internal dispatch, that we do not want to miss, but don't easily get by e.g. calling Rf_isFunction() directly.
	is_matrix_fun = Rf_install ("is.matrix");
	PROTECT (is_matrix_fun);
	RK_ASSERT (!Rf_isNull (is_matrix_fun));

	is_array_fun = Rf_install ("is.array");
	PROTECT (is_array_fun);
	RK_ASSERT (!Rf_isNull (is_array_fun));

	is_list_fun = Rf_install ("is.list");
	PROTECT (is_list_fun);
	RK_ASSERT (!Rf_isNull (is_list_fun));

	is_function_fun = Rf_install ("is.function");
	PROTECT (is_function_fun);
	RK_ASSERT (!Rf_isNull (is_function_fun));

	is_environment_fun = Rf_install ("is.environment");
	PROTECT (is_environment_fun);
	RK_ASSERT (!Rf_isNull (is_environment_fun));

	is_factor_fun = Rf_install ("is.factor");
	PROTECT (is_factor_fun);
	RK_ASSERT (!Rf_isNull (is_factor_fun));

	is_numeric_fun = Rf_install ("is.numeric");
	PROTECT (is_numeric_fun);
	RK_ASSERT (!Rf_isNull (is_numeric_fun));

	is_character_fun = Rf_install ("is.character");
	PROTECT (is_character_fun);
	RK_ASSERT (!Rf_isNull (is_character_fun));

	is_logical_fun = Rf_install ("is.logical");
	PROTECT (is_logical_fun);
	RK_ASSERT (!Rf_isNull (is_logical_fun));

	names_fun = Rf_findFun (Rf_install ("names"), R_BaseEnv);
	PROTECT (names_fun);
	RK_ASSERT (!Rf_isNull (names_fun));

	/* TODO:
	formals-handling
	*/
}

RKStructureGetter::~RKStructureGetter () {
	RK_TRACE (RBACKEND);

	UNPROTECT (13); /* all the pre-resolved functions */
}

SEXP RKStructureGetter::callSimpleFun (SEXP fun, SEXP arg) {
	SEXP call = allocVector (LANGSXP, 2);
	PROTECT (call);
	SETCAR (call, fun);
	SETCAR (CDR (call), arg);

	SEXP ret = eval (call, R_GlobalEnv);

	UNPROTECT (1); /* call */
	return ret;
}

bool RKStructureGetter::callSimpleBool (SEXP fun, SEXP arg) {
	SEXP res = callSimpleFun (fun, arg);
	RK_ASSERT (TYPEOF (res) == LGLSXP);
	return ((bool) VECTOR_ELT (res, 0));
}

RData *RKStructureGetter::getStructure (SEXP toplevel, SEXP name, SEXP namespacename) {
	RK_TRACE (RBACKEND);

	envir_depth = 0;

	unsigned int count;
	QString *name_dummy = SEXPToStringList (name, &count);
	RK_ASSERT (count == 1);
	QString name_string = name_dummy[0];
	delete [] name_dummy;

	// resolve namespace, if needed
	if (Rf_isNull (namespacename)) {
		with_namespace = false;
	} else {
		with_namespace = true;

		SEXP as_ns_fun = Rf_findFun (Rf_install ("asNamespace"),  R_BaseEnv);;
		PROTECT (as_ns_fun);
		RK_ASSERT (!Rf_isNull (as_ns_fun));

		SEXP call = allocVector (LANGSXP, 2);
		PROTECT (call);
		SETCAR (call, as_ns_fun);
		SETCAR (CDR (call), namespacename);
		int error;
		namespace_envir = R_tryEval (call, R_GlobalEnv, &error);
		UNPROTECT (2);	/* as_ns_fun, call */

		if (error) namespace_envir = R_NilValue;

		PROTECT (namespace_envir);
	}

	RData *ret = new RData;
	// TODO: wrap inside a toplevel exec
	getStructureWorker (toplevel, name_string, false, ret);

	if (with_namespace) {
		UNPROTECT (1);	/* namespace_envir */
	}

qDebug ("finished");
	return ret;
}

SEXP RKStructureGetter::resolvePromise (SEXP from) {
	RK_TRACE (RBACKEND);

	SEXP ret = from;
qDebug ("resolving type: %d", TYPEOF (from));
	if (TYPEOF (from) == PROMSXP) {
		if (PRVALUE(from) == R_UnboundValue) {
qDebug ("resolving: is an unresolved promise");
			PROTECT (from);
			SET_PRSEEN(from, 1);
qDebug ("resolve1");
			ret = eval(PRCODE(from), PRENV(from));
qDebug ("resolve2");
			SET_PRSEEN(from, 0);
qDebug ("resolve3");
			if (keep_evalled_promises) {
				SET_PRVALUE(from, ret);
				SET_PRENV(from, R_NilValue);
			}
qDebug ("resolve4");
			UNPROTECT (1);
		}
	} else if (TYPEOF (from) == SYMSXP) {
qDebug ("resolving: is a symbol");
// TODO! (and do we actually need this?)
		return R_NilValue;
	}

	return ret;
}

// TODO: split out some of the large blocks into helper functions, to make this easier to read
void RKStructureGetter::getStructureWorker (SEXP val, const QString &name, bool misplaced, RData *storage) {
	RK_TRACE (RBACKEND);

	bool is_function = false;
	bool is_container = false;
	bool is_environment = false;
	unsigned int type = 0;
	unsigned int count;
	SEXP call;

	qDebug ("fetching '%s': %p", name.latin1(), val);

	PROTECT (val);
	// manually resolve any promises
	SEXP value = resolvePromise (val);
	UNPROTECT (1);		/* val */
	PROTECT (value);

qDebug ("resolved");

	// first field: get name
	RData *namedata = new RData;
	namedata->datatype = RData::StringVector;
	namedata->length = 1;
	QString *name_dummy = new QString[1];
	name_dummy[0] = name;
	namedata->data = name_dummy;

	// get classes
	SEXP classes_s = callSimpleFun (class_fun, value);
	PROTECT (classes_s);
	QString *classes = SEXPToStringList (classes_s, &count);
	unsigned int num_classes = count;
	UNPROTECT (1);	/* classes_s */

	// store classes
	RData *classdata = new RData;
	classdata->datatype = RData::StringVector;
	classdata->data = classes;
	classdata->length = num_classes;

	// basic classification
	for (unsigned int i = 0; i < num_classes; ++i) {
		if (classes[i] == "data.frame") type |= RObject::DataFrame;
	}

	if (callSimpleBool (is_matrix_fun, value)) type |= RObject::Matrix;
	if (callSimpleBool (is_array_fun, value)) type |= RObject::Array;
	if (callSimpleBool (is_list_fun, value)) type |= RObject::List;

	if (type != 0) {
		is_container = true;
	} else {
		if (callSimpleBool (is_function_fun, value)) {
			is_function = true;
			type |= RObject::Function;
		} else if (callSimpleBool (is_environment_fun, value)) {
			is_container = true;
			is_environment = true;
			type |= RObject::Environment;
		} else {
			type |= RObject::Variable;
			if (callSimpleBool (is_factor_fun, value)) type |= RObject::Factor;
			else if (callSimpleBool (is_numeric_fun, value)) type |= RObject::Numeric;
			else if (callSimpleBool (is_character_fun, value)) type |= RObject::Character;
			else if (callSimpleBool (is_logical_fun, value)) type |= RObject::Logical;
		}
	}
	if (misplaced) type |= RObject::Misplaced;

	// get meta data, if any
	RData *metadata = new RData;
	metadata->datatype = RData::StringVector;
	if (!Rf_isNull (Rf_getAttrib (value, meta_attrib))) {
		type |= RObject::HasMetaObject;

		SEXP meta_s = callSimpleFun (get_meta_fun, value);
		PROTECT (meta_s);
		metadata->data = SEXPToStringList (classes_s, &count);
		metadata->length = count;
		UNPROTECT (1);	/* meta_s */
	} else {
		metadata->length = 1;
		QString *meta_dummy = new QString[1];
		meta_dummy[0] = "";
		metadata->data = meta_dummy;
	}

	// store type
	RData *typedata = new RData;
	typedata->datatype = RData::IntVector;
	typedata->length = 1;
	int *type_dummy = new int[1];
	type_dummy[0] = type;
	typedata->data = type_dummy;

	// get dims
	int *dims;
	unsigned int num_dims;
	SEXP dims_s = Rf_getAttrib (value, R_DimSymbol);
	if (!Rf_isNull (dims_s)) {
		dims = SEXPToIntArray (dims_s, &num_dims);
	} else {
		num_dims = 1;
		dims = new int[1];
		dims[0] = Rf_length (dims_s);
	}

	// store dims
	RData *dimdata = new RData;
	dimdata->datatype = RData::IntVector;
	dimdata->length = num_dims;
	dimdata->data = dims;

	// store everything we have so far
	if (is_container) {
		storage->length = 6;
	} else if (is_function) {
		storage->length = 7;
	} else {
		storage->length = 5;
	}
	storage->datatype = RData::StructureVector;
	RData **res = new RData*[storage->length];
	storage->data = res;
	res[0] = namedata;
	res[1] = typedata;
	res[2] = classdata;
	res[3] = metadata;
	res[4] = dimdata;

	// now add the extra info for containers and functions
	if (is_container) {
		bool do_env = (is_environment && (++envir_depth < 2));
		bool do_cont = is_container && (!is_environment);

		RData *childdata = new RData;
		childdata->datatype = RData::StructureVector;
		childdata->length = 0;
		childdata->data = 0;
		res[5] = childdata;

		// fetch list of child names
		unsigned int childcount;
		SEXP childnames_s;
		if (do_env) {
			childnames_s = R_lsInternal (value, (Rboolean) 1);
		} else if (do_cont) {
			childnames_s = callSimpleFun (names_fun, value);
		} else {
			childnames_s = R_NilValue; // dummy
		}
		PROTECT (childnames_s);
		QString *childnames = SEXPToStringList (childnames_s, &childcount);
QString dummy;
for (unsigned int i = 0; i < childcount; ++i) {
	dummy.append (childnames[i] + "\t");
}
qDebug ("%s", dummy.latin1());

		childdata->length = childcount;
		RData **children = new RData*[childcount];
		childdata->data = children;
		childdata->length = childcount;
		for (unsigned int i = 0; i < childcount; ++i) {		// in case there is an error while fetching one of the children, let's pre-initialize everything.
			children[i] = new RData;
			children[i]->data = 0;
			children[i]->length = 0;
			children[i]->datatype = RData::NoData;
		}

		if (do_env) {
			qDebug ("recurse into environment %s", name.latin1());
			for (unsigned int i = 0; i < childcount; ++i) {
				SEXP current_childname = install(CHAR(STRING_ELT(childnames_s, i)));
				PROTECT (current_childname);
				SEXP child = Rf_findVar (current_childname, value);
				PROTECT (child);

				bool child_misplaced = false;
				if (with_namespace) {
					/* before R 2.4.0, operator "::" would only work on true namespaces, not on package names (operator "::" work, if there is a namespace, and that namespace has the symbol in it)
					TODO remove once we depend on R >= 2.4.0 */
#					ifndef R_2_5
					if (Rf_isNull (namespace_envir)) {
						child_misplaced = true;
					} else {
						SEXP dummy = Rf_findVar (current_childname, namespace_envir);
						if (Rf_isNull (dummy)) child_misplaced = true;
					}
					/* for R 2.4.0 or greater: operator "::" works if package has no namespace at all, or has a namespace with the symbol in it */
#					else
					if (!Rf_isNull (namespace_envir)) {
						SEXP dummy = Rf_findVar (current_childname, namespace_envir);
						if (Rf_isNull (dummy)) child_misplaced = true;
					}
#					endif
				}

qDebug ("element %d of %d from environment %s", i, childcount, name.latin1());
				getStructureWorker (child, childnames[i], child_misplaced, children[i]);
				UNPROTECT (2); /* childname, child */
			}
		} else if (do_cont) {
			qDebug ("recurse into list %s", name.latin1());
			if (Rf_isList (value)) {		// old style list
				for (unsigned int i = 0; i < childcount; ++i) {
					SEXP child = CAR (value);
					getStructureWorker (child, childnames[i], false, children[i]);
					CDR (value);
				}
			} else {				// new style list
				for (unsigned int i = 0; i < childcount; ++i) {
					SEXP child = VECTOR_ELT(value, i);
					getStructureWorker (child, childnames[i], false, children[i]);
				}
			}
		}
		UNPROTECT (1);   /* childnames_s */
qDebug ("leaving container %s", name.latin1());
	} else if (is_function) {
qDebug ("fun");
		RData *funargsdata = new RData;
		funargsdata->datatype = RData::StringVector;
		funargsdata->length = 0;
		funargsdata->data = 0;
		res[5] = funargsdata;

		RData *funargvaluesdata = new RData;
		funargvaluesdata->datatype = RData::StringVector;
		funargvaluesdata->length = 0;
		funargvaluesdata->data = 0;
		res[6] = funargvaluesdata;

		if (TYPEOF (value) == CLOSXP) {		// if it is not, it does not have any formals
			SEXP formals_s = FORMALS (value);
			PROTECT (formals_s);
qDebug ("%d args", Rf_length (formals_s));
qDebug ("fun1");
			SEXP names_s = getAttrib (formals_s, R_NamesSymbol);
			PROTECT (names_s);
qDebug ("fun2");
			funargsdata->data = SEXPToStringList (names_s, &(funargsdata->length));
qDebug ("fun3");
			// TODO: get and store argument values
	
			// convert argument values to character representation
/*			unsigned int length = Rf_length (formals_s);
			SEXP argvalues_char_s = Rf_allocVector (STRSXP, Rf_length (formals_s));
			PROTECT (arg_values_char_s);
			for (unsigned int i = 0; i < length; ++i) {
				if (TYPEOF (VECTOR_ELT (formals_s, i)) == STRSXP) {
					SET_VECTOR_ELT (formals_s, 
				}
			} */
QString *dummy1;
			funargvaluesdata->data = dummy1 = SEXPToStringList (formals_s, &(funargvaluesdata->length));
qDebug ("fun4");
QString dummy;
for (unsigned int i = 0; i < funargvaluesdata->length; ++i) {
	dummy.append (dummy1[i] + "\t");
}
qDebug ("%s", dummy.latin1());
			UNPROTECT (2); /* names_s, formals_s */
		} else {
qDebug ("not a closure");
		}
	}

qDebug ("object done %s", name.latin1());
	UNPROTECT (1); /* value */
}

