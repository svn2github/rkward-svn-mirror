local({
## Prepare
## Compute
## Print result
# parameters:
loc <- 0.0; scale <- 3.0;
# mean and variances of the distribution of sample averages:
avg.exp <- loc;
avg.var <- ((pi^2/3)*scale^2)/10;
# generate the entire data:
data <- matrix(rlogis(n=10000, location=loc, scale=scale), nrow=10);
# get the sample averages:
avg <- colMeans(data);
# generate random normal samples:
normX <- seq(from=min(avg), to=max(avg), length=1000);
normY <- dnorm (normX, mean = avg.exp, sd = sqrt(avg.var));
dist.hist <- hist(avg, plot=FALSE, breaks=seq (floor (min (avg, na.rm=TRUE))-0.5, ceiling (max (avg, na.rm=TRUE))+0.5), right=FALSE);
# calculate the ylims appropriately:
ylim <- c(0,max(c(dist.hist$density, normY)));
rk.graph.on ()
try ({
	plot(dist.hist, ylim=ylim, freq=FALSE, labels=TRUE, lty="solid", density=-1, xlab="Sample Averages", main="Logistic")
	lines (x=normX, y=normY, type="l", col="red")
})
rk.graph.off ()
})
.rk.rerun.plugin.link(plugin="rkward::plot_logistic_clt", settings="drawnorm.state=1\nfunction.string=hist\nhistogram_opt.addtoplot.state=\nhistogram_opt.barlabels.state=1\nhistogram_opt.density.real=-1.00\nhistogram_opt.doborder.state=1\nhistogram_opt.freq.state=0\nhistogram_opt.histbordercol.color.string=\nhistogram_opt.histbreaksFunction.string=int\nhistogram_opt.histlinetype.string=solid\nhistogram_opt.include_lowest.state=1\nhistogram_opt.rightclosed.state=\nhistogram_opt.usefillcol.state=\nloc.real=0.0\nnAvg.real=10.00\nnDist.real=1000.00\nnormlinecol.color.string=red\nnormpointtype.string=l\nplotoptions.add_grid.state=0\nplotoptions.asp.real=0.00\nplotoptions.main.text=\nplotoptions.pointcolor.color.string=\nplotoptions.pointtype.string=\nplotoptions.sub.text=\nplotoptions.xaxt.state=\nplotoptions.xlab.text=\nplotoptions.xlog.state=\nplotoptions.xmaxvalue.text=\nplotoptions.xminvalue.text=\nplotoptions.yaxt.state=\nplotoptions.ylab.text=\nplotoptions.ylog.state=\nplotoptions.ymaxvalue.text=\nplotoptions.yminvalue.text=\nscale.real=3.0\nscalenorm.state=0", label="Run again")
.rk.make.hr()
