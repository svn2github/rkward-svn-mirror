#' @export

# this simple class is for JavaScript generation,
# produced by ite()

setClass("rk.JS.ite",
	representation=representation(
		ifJS="character",
		thenJS="character",
		thenifJS="list",
		elseJS="character",
		elifJS="list"
	),
	prototype(
		ifJS=character(),
		thenJS=character(),
		thenifJS=list(),
		elseJS=character(),
		elifJS=list()
	)
)

setValidity("rk.JS.ite", function(object){
		if(length(object@thenifJS) > 1){
			stop(simpleError("Slot 'thenifJS' can only have one list element!"))
		} else {}
		if(length(object@thenifJS) == 1){
			if(!inherits(object@thenifJS[[1]], "rk.JS.ite")){
				stop(simpleError("Slot 'thenifJS' can only have one list element of class 'rk.JS.ite'!"))
			} else {}
		} else {}
		if(length(object@elifJS) > 1){
			stop(simpleError("Slot 'elifJS' can only have one list element!"))
		} else {}
		if(length(object@elifJS) == 1){
			if(!inherits(object@elifJS[[1]], "rk.JS.ite")){
				stop(simpleError("Slot 'elifJS' can only have one list element of class 'rk.JS.ite'!"))
			} else {}
		} else {}
	return(TRUE)
})
