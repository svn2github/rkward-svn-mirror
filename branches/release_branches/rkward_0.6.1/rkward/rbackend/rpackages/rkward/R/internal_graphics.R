## Internal functions manipulating graphics should be stored here.
## These functions are _not_ supposed to be called by the end user.

# overriding x11 to get informed, when a new x11 window is opened
#' @export
"rk.screen.device" <- function (..., is.being.duplicated = FALSE, is.preview.device = FALSE) {
	.rk.do.call ("startOpenX11", as.character (dev.cur ()));

	old_dev <- dev.cur ()

	args <- list (...)
	if (!exists (".rk.default.device")) {
		if (base::.Platform$OS.type == "unix") {
			device <- grDevices::x11
		} else {
			device <- grDevices::windows
			if (is.null (args[["width"]])) args[["width"]] <- options ("rk.screendevice.width")[[1]]
			if (!is.numeric (args[["width"]])) args[["width"]] <- 7
			if (is.null (args[["height"]])) args[["height"]] <- options ("rk.screendevice.height")[[1]]
			if (!is.numeric (args[["height"]])) args[["height"]] <- 7
		}
	} else {
		device <- .rk.default.device
		if (is.character (.rk.default.device)) {
			device <- get (.rk.default.device)
		}
	}
	x <- do.call (device, args)

	.rk.do.call ("endOpenX11", as.character (dev.cur ()));

	if (getOption ("rk.enable.graphics.history"))
		rk.record.plot$onAddDevice (old_dev, dev.cur (), is.being.duplicated, is.preview.device)

	invisible (x)
}

#' @export
"x11" <- rk.screen.device

#' @export
"X11" <- x11

if (base::.Platform$OS.type == "windows") {
	  "windows" = rk.screen.device
	  "win.graph" = rk.screen.device
}

# set from rkward the application:
# options(device="rk.screen.device")
#' @include internal.R
assign(".rk.preview.devices", list (), envir=.rk.variables)

#' @export
".rk.startPreviewDevice" <- function (x) {
	a <- .rk.variables$.rk.preview.devices[[x]]
	if (is.null (a)) {
		devnum <- dev.cur ()
		x11 (is.preview.device = TRUE)
		if (devnum != dev.cur ()) {
			.rk.variables$.rk.preview.devices[[x]] <- list (devnum=dev.cur(), par=par (no.readonly=TRUE))
		} else {
			return (0L)	# no device could be opened
		}
	} else {
		dev.set (a$devnum)
		par (a$par)
	}
	as.integer (dev.cur ())
}

#' @export
".rk.killPreviewDevice" <- function (x) {
	a <- .rk.variables$.rk.preview.devices[[x]]
	if (!is.null (a)) {
		if (a$devnum %in% dev.list ()) {
			dev.off (a$devnum)
		}
		.rk.variables$.rk.preview.devices[[x]] <- NULL
	}
}

".rk.discard.preview.device.num" <- function (devnum) {
	for (dev in names (.rk.variables$.rk.preview.devices)) {
		if (.rk.variables$.rk.preview.devices[[dev]]$devnum == devnum) {
			.rk.variables$.rk.preview.devices[[dev]] <- NULL
			return (invisible (TRUE))
		}
	}
	invisible (FALSE)
}

".rk.list.preview.device.numbers" <- function () {
	unlist (sapply (.rk.variables$.rk.preview.devices, function (x) x$devnum))
}

.rk.variables$.rk.printer.devices <- list ()

# see .rk.fix.assignmetns () in internal.R
#' @export
".rk.fix.assignments.graphics" <- function ()
{
	rk.replace.function ("plot.new", as.environment ("package:graphics"),
		function () {
			rk.record.plot$.plot.new.hook ()
			eval (body (.rk.backups$plot.new))
		})

	rk.replace.function ("dev.off", as.environment ("package:grDevices"),
		function (which = dev.cur ()) {
			if (getOption ("rk.enable.graphics.history"))
				rk.record.plot$onDelDevice (devId = which)
			
			# see http://thread.gmane.org/gmane.comp.statistics.rkward.devel/802
			.rk.do.call ("killDevice", as.character (which))
			
			ret <- eval (body (.rk.backups$dev.off))

			printfile <- .rk.variables$.rk.printer.devices[[as.character (which)]]
			if (!is.null (printfile)) {
				.rk.do.plain.call ("printPreview", printfile, FALSE)
				.rk.variables$.rk.printer.devices[[as.character (which)]] <- NULL
			}

			rkward:::.rk.discard.preview.device.num(which)

			return (ret)
		})

	rk.replace.function ("dev.set", as.environment ("package:grDevices"),
		function () {
			ret <- eval (body (.rk.backups$dev.set))
			
			if (getOption ("rk.enable.graphics.history") && rk.record.plot$.is.device.managed (which))
				rk.record.plot$.set.trellis.last.object (which)
			
			ret
		})

	## set a hook defining "print.function" for lattice:
	setHook (packageEvent ("lattice", "onLoad"),
		function (...)
			lattice::lattice.options (print.function = function (x, ...)
			{
				if (dev.cur() == 1) rk.screen.device ()
				## TODO: use "trellis" instead of "lattice" to accomodate ggplot2 plots?
				plot_hist_enabled <- getOption ("rk.enable.graphics.history")
				if (plot_hist_enabled) {
					rk.record.plot$record (nextplot.pkg = "lattice")
					on.exit (options (rk.enable.graphics.history=TRUE))
					options (rk.enable.graphics.history=FALSE)	# avoid duplicate trigger inside plot(), below
				}
				plot (x, ...)
				if (plot_hist_enabled) {
					options (rk.enable.graphics.history=TRUE)
					rk.record.plot$.save.tlo.in.hP ()
				}
				invisible ()
			})
	)

	if (compareVersion (as.character (getRversion ()), "2.14.0") < 0) {
		setHook (packageEvent ("grid", "attach"),
			function (...)
				rk.replace.function ("grid.newpage", as.environment ("package:grid"),
					function () {
						## TODO: add specific support for ggplots?
						rk.record.plot$.plot.new.hook ()
						ret <- eval (body (.rk.backups$grid.newpage))
					})
		)
	} else {
		setHook ("before.grid.newpage",
			function (...)
			{
				rk.record.plot$.plot.new.hook ()
			},
			action = "append"
		)
	}

	## persp does not call plot.new (), so set a hook. Fortunately, the hook is placed after drawing the plot.
	setHook ("persp",
		function (...)
		{
			rk.record.plot$.plot.new.hook ()
		},
		action = "append"
	)
}

