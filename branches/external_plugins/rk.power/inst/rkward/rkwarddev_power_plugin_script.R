# the plugin code was generated by this script
# you should not change the plugin code directly, but this script
# note: this script only creates objects in your workspace,
# *EXCEPT* for the last call, see below.

require(rkwarddev)
rkwarddev.required("0.06-5")

local({
# set the output directory to overwrite the actual plugin
output.dir <- tempdir()
overwrite <- TRUE
# if you set guess.getters to TRUE, the resulting code will need RKWard >= 0.6.0
guess.getter <- FALSE

about.info <- rk.XML.about(
  name="rk.power",
  author=c(
    person(given="Meik", family="Michalke",
      email="meik.michalke@hhu.de", role=c("aut","cre")),
    person(given="Thomas", family="Friedrichsmeier", role=c("ctb"))),
  about=list(desc="RKWard GUI to perform power analysis and sample size estimation.",
    version="0.01-3", url="http://rkward.sf.net")
  )
dependencies.info <- rk.XML.dependencies(
  dependencies=list(rkward.min=ifelse(isTRUE(guess.getter), "0.6.0", "0.5.6"),
  package=list(c(name="pwr")))
)

rk.set.comp("Power analysis")

pwr.parameter.rad <- rk.XML.radio(label="Parameter to determine", options=list(
    "Power of test"=c(val="Power", chk=TRUE),
    "Sample size"=c(val="Sample size"),
    "Effect size"=c(val="Effect size"),
    "Significance level"=c(val="Significance level"),
    pwr.parameter.opt.dfu <- rk.XML.option ("Parameter count", val="Parameter count", id.name="auto")
  ), id.name="rad_pwr_param",
  help="Parameter to estimate, given the others.")

pwr.stat.drop <- rk.XML.dropdown(label="Select a method", options=list(
    "t-Tests of means"=c(val="pwr.t.test", chk=TRUE),
    "Correlation test"=c(val="pwr.r.test"),
    "ANOVA (balanced one-way)"=c(val="pwr.anova.test"),
    "General linear model"=c(val="pwr.f2.test"),
    "Chi-squared test"=c(val="pwr.chisq.test"),
    "Proportion tests"=c(val="pwr.p.test"),
    "Mean of a normal distribution (known variance)"=c(val="pwr.norm.test")
  ), help="Specify the statistical method to perform power estimation for", id.name="drp_pwr_stat")

pwr.hypothesis.drop <- rk.XML.dropdown("Using test hypothesis",
  options=list(
    "Two-sided"=c(val="two.sided", chk=TRUE),
    "First is greater"=c(val="greater"),
    "Second is greater"=c(val="less")
  ), help="Specify the hypothesis to use. Note that for the one-sided hypothesis \"first is greater\",
           a positive effect size is expected. For \"second is greater\", a negative effect size is expected.",
  id.name="drp_pwr_hypothesis")
pwr.txt.hypothesis.neg <- rk.XML.text("Hypothesis probably expects a negative effect size!", id.name="pwr_txt_hypothesis_neg", type="warning")
pwr.txt.hypothesis.pos <- rk.XML.text("Hypothesis probably expects a positive effect size!", id.name="pwr_txt_hypothesis_pos", type="warning")

pwr.effect.etasq.rad <- rk.XML.radio(label="Provided effect size", options=list(
    "Cohen's f"=c(val="f", chk=TRUE),
    "Eta squared"=c(val="e2")
  ), help="Only shown where applicable. Allows you to select, whether to specify the effect size as Cohen's f, or as Eta squared.",
  id.name="rad_effct_eta")

pwr.type.drop <- rk.XML.dropdown("Samples",
  options=list(
    "Two samples (equal sizes)"=c(val="two.sample", chk=TRUE),
    "Two samples (different sizes)"=c(val="two.sample.diff"), # pwr.t2n.test
    "Single sample (test against constant)"=c(val="one.sample"),
    "Paired samples"=c(val="paired")
  ), help="Only enabled where applicable. Specify the nature of samples used in the test. For samples of different sizes, only one sample size can be estimated.",
  id.name="drp_pwr_type")

pwr.proptype.drop <- rk.XML.dropdown("Samples",
  options=list(
    "Two samples (equal sizes)"=c(val="two.sample.same", chk=TRUE), # pwr.2p.test
    "Two samples (different sizes)"=c(val="two.sample.diff"), # pwr.2p2n.test
    "One sample"=c(val="one.sample") # pwr.p.test
  ), help=FALSE, # In the help file, same as t.test dropdown
  id.name="drp_pwr_proptype")

pwr.input.power <- rk.XML.spinbox(label="Power", min=0, max=1, initial=0.8, help="Targetted power of test (1 minus Type II error probability)")
pwr.input.df <- rk.XML.spinbox(label="Degrees of freedom", id.name="pwr_spin_df", min=1, real=FALSE, initial=30,
                               help="Only shown for chi-square statistics: Targetted degrees of freedom. As a reminder, this is (rows &minus; 1)&times;(columns &minus; 1) for a test of independence,
                               and (cells &minus; 1) for a test of goodness of fit.")
pwr.input.dfu <- rk.XML.spinbox(label="Degrees of freedom for numerator", id.name="pwr_spin_dfu", min=1, real=FALSE, initial=30,
                               help="Only shown for general linear model: Targetted numerator degrees of freedom. As a reminder, this is the number of parameters to estimate, or number of groups/samples minus 1.")
pwr.input.dfv <- rk.XML.spinbox(label="Degrees of freedom for denominator", id.name="pwr_spin_dfv", min=1, real=FALSE, initial=30,
                               help="Only shown for general linear model: Available denominator degrees of freedom / degrees of freedom of the error term.
                               As a reminder, this is the total number of observations minus numerator degrees of freedom minus 1, or total number of observations minus number of groups/samples.")
pwr.txt.dfu <- rk.XML.text("df<sub>num</sub>: k &minus; 1", id.name="pwr_txt_dfu")
pwr.txt.dfv <- rk.XML.text("df<sub>den</sub>: N &minus; k", id.name="pwr_txt_dfv")

pwr.input.sample <- rk.XML.spinbox(label="Sample size", id.name="pwr_spin_sample0", min=1, real=FALSE, initial=30, ,
                               help="Sample size. Note that depending on the selected method, this can mean observations per sample, per group, or in total. Make sure to read the note shown below the control.")
pwr.input.sample.n1 <- rk.XML.spinbox(label="First sample size", id.name="pwr_spin_sample1", min=1, real=FALSE, initial=30, help=FALSE)
pwr.input.sample.n2 <- rk.XML.spinbox(label="Second sample size", id.name="pwr_spin_sample2", min=1, real=FALSE, initial=30, help=FALSE)
pwr.txt.sample.default <- rk.XML.text("Number of observations", id.name="pwr_txt_smpl")
pwr.txt.sample.ps <- rk.XML.text("Number of observations <b>per sample</b>", id.name="pwr_txt_smpl_ps")
pwr.txt.sample.pg <- rk.XML.text("Number of observations <b>per group</b>", id.name="pwr_txt_smpl_pg")
pwr.txt.sample.tt <- rk.XML.text("Number of observations <b>in total</b>", id.name="pwr_txt_smpl_tt")
pwr.txt.sample.pairs <- rk.XML.text("Number of <b>pairs</b>", id.name="pwr_txt_smpl_pairs")

pwr.input.groups <- rk.XML.spinbox(label="Number of groups", min=1, real=FALSE, initial=2, help="Number of groups. For ANOVA, only.")

pwr.input.effect <- rk.XML.spinbox(label="Effect size", min=-1, max=1, initial=0.3,
   help="Minimum detectable effect size. Note that effect size specifications differ between the available methods. Be sure to read the note shown below the control.\n\n
   As a reminder, for mapping between cohen's f and Eta&sup2; use f&sup2; = Eta&sup2; / (1 &minus; Eta&sup2;)")
# effect sizes: d, r, f, f2, w, h
pwr.txt.effect.d <- rk.XML.text("Measure for selected method is <b>Cohen's d</b>", id.name="pwr_txt_efct_d")
pwr.txt.effect.r <- rk.XML.text("Measure for selected method is <b>Pearson's r</b>", id.name="pwr_txt_efct_r")
pwr.txt.effect.f <- rk.XML.text("Measure for selected method is <b>Cohen's f</b>", id.name="pwr_txt_efct_f")
pwr.txt.effect.e2 <- rk.XML.text("Measure for selected method is <b>Eta<sup>2</sup></b>", id.name="pwr_txt_efct_e2")
# f <- sqrt(etasq / (1 - etasq))
pwr.txt.effect.f2 <- rk.XML.text("Measure for selected method is <b>Cohen's f<sup>2</sup></b>", id.name="pwr_txt_efct_f2")
pwr.txt.effect.w <- rk.XML.text("Measure for selected method is <b>Cohen's w</b>", id.name="pwr_txt_efct_w")
pwr.txt.effect.h <- rk.XML.text("Measure for selected method is <b>Cohen's h</b>", id.name="pwr_txt_efct_h")
pwr.input.signif <- rk.XML.spinbox(label="Significance level", min=0, max=1, initial=0.05, help="Targetted level of significance")


save.results.pwr <- rk.XML.saveobj("Save results to workspace", initial="pwr.result",
  component="Power analysis", help=FALSE)

tab.pwr.data <- rk.XML.row(
    rk.XML.col(
      rk.XML.frame(
        pwr.stat.drop,
        pwr.input.groups,
        pwr.type.drop,
        pwr.proptype.drop,
        pwr.hypothesis.drop,
        pwr.txt.hypothesis.neg,
        pwr.txt.hypothesis.pos,
        pwr.effect.etasq.rad,
        label="Statistical Method"
      ),
      rk.XML.stretch()
    ),
    rk.XML.col(
      rk.XML.frame(
        pwr.parameter.rad,
        rk.XML.stretch(),
        label="Target measure"
      )
    ),
    rk.XML.col(
      rk.XML.frame(
        pwr.frame.power <- rk.XML.frame(pwr.input.power),
        pwr.frame.df <- rk.XML.frame(
          pwr.input.df,
          pwr.input.dfu,
          pwr.txt.dfu,
          pwr.input.dfv,
          pwr.txt.dfv
        ),
        pwr.frame.sample <- rk.XML.frame(
          pwr.input.sample,
          pwr.input.sample.n1,
          pwr.input.sample.n2,
          pwr.txt.sample.default,
          pwr.txt.sample.ps,
          pwr.txt.sample.pg,
          pwr.txt.sample.tt,
          pwr.txt.sample.pairs
        ),
        pwr.frame.effect <- rk.XML.frame(
          pwr.input.effect,
          pwr.txt.effect.d,
          pwr.txt.effect.r,
          pwr.txt.effect.f,
          pwr.txt.effect.e2,
          pwr.txt.effect.f2,
          pwr.txt.effect.w,
          pwr.txt.effect.h
        ),
        pwr.frame.signif <- rk.XML.frame(pwr.input.signif),
        rk.XML.stretch(),
        save.results.pwr,
        label="Known measures"
      )
    )
  )

pwr.full.dialog <- rk.XML.dialog(
  tab.pwr.data,
  label="Power analysis")

## logic section
  lgc.sect.pwr <- rk.XML.logic(
    pwr.gov.want.power <- rk.XML.convert(sources=list(string=pwr.parameter.rad), mode=c(equals="Power"), id.name="pwr_lgc_power"),
    pwr.gov.want.sample <- rk.XML.convert(sources=list(string=pwr.parameter.rad), mode=c(equals="Sample size"), id.name="pwr_lgc_sample"),
    pwr.gov.want.effect <- rk.XML.convert(sources=list(string=pwr.parameter.rad), mode=c(equals="Effect size"), id.name="pwr_lgc_effect"),
    pwr.gov.want.signif <- rk.XML.convert(sources=list(string=pwr.parameter.rad), mode=c(equals="Significance level"), id.name="pwr_lgc_signif"),
    pwr.gov.want.df.u <- rk.XML.convert(sources=list(string=pwr.parameter.rad), mode=c(equals="Parameter count"), id.name="pwr_lgc_df_u"),
    rk.XML.connect(governor=pwr.gov.want.power, client=pwr.frame.power, set="enabled", not=TRUE),
    rk.XML.connect(governor=pwr.gov.want.effect, client=pwr.frame.effect, set="enabled", not=TRUE),
    rk.XML.connect(governor=pwr.gov.want.signif, client=pwr.frame.signif, set="enabled", not=TRUE),
    
    pwr.gov.meth.ttest <- rk.XML.convert(sources=list(string=pwr.stat.drop), mode=c(equals="pwr.t.test"), id.name="pwr_lgc_ttest"),
    pwr.gov.meth.rtest <- rk.XML.convert(sources=list(string=pwr.stat.drop), mode=c(equals="pwr.r.test"), id.name="pwr_lgc_rtest"),
    pwr.gov.meth.anova <- rk.XML.convert(sources=list(string=pwr.stat.drop), mode=c(equals="pwr.anova.test"), id.name="pwr_lgc_anova"),
    pwr.gov.meth.f2test <- rk.XML.convert(sources=list(string=pwr.stat.drop), mode=c(equals="pwr.f2.test"), id.name="pwr_lgc_f2test"),
    pwr.gov.meth.chisq <- rk.XML.convert(sources=list(string=pwr.stat.drop), mode=c(equals="pwr.chisq.test"), id.name="pwr_lgc_chisq"),
    pwr.gov.meth.proptest <- rk.XML.convert(sources=list(string=pwr.stat.drop), mode=c(equals="pwr.p.test"), id.name="pwr_lgc_proptest"),
    pwr.gov.meth.norm <- rk.XML.convert(sources=list(string=pwr.stat.drop), mode=c(equals="pwr.norm.test"), id.name="pwr_lgc_norm"),
    pwr.gov.meth.proptest.same <- rk.XML.convert(sources=list(string=pwr.proptype.drop), mode=c(equals="two.sample.same"), id.name="pwr_lgc_sample_2p_same"),
    pwr.gov.meth.proptest.diff <- rk.XML.convert(sources=list(string=pwr.proptype.drop), mode=c(equals="two.sample.diff"), id.name="pwr_lgc_sample_2p_diff"),
    pwr.gov.meth.ttest.typesame <- rk.XML.convert(sources=list(string=pwr.type.drop), mode=c(equals="two.sample"), id.name="pwr_lgc_sample_t_same"),
    pwr.gov.meth.ttest.2diff <- rk.XML.convert(sources=list(string=pwr.type.drop), mode=c(equals="two.sample.diff"), id.name="pwr_lgc_sample_t_diff"),
    pwr.gov.meth.ttest.pairs <- rk.XML.convert(sources=list(string=pwr.type.drop), mode=c(equals="paired"), id.name="pwr_lgc_sample_t_pairs"),
    pwr.gov.meth.ttest.single <- rk.XML.convert(sources=list(string=pwr.type.drop), mode=c(equals="one.sample"), id.name="pwr_lgc_sample_t_onesample"),
    pwr.gov.meth.2ptest <- rk.XML.convert(sources=list(pwr.gov.meth.proptest.same, pwr.gov.meth.proptest), mode=c(and=""), id.name="pwr_lgc_2p"),
    pwr.gov.meth.2p2ntest <- rk.XML.convert(sources=list(pwr.gov.meth.proptest.diff, pwr.gov.meth.proptest), mode=c(and=""), id.name="pwr_lgc_2p2n"),
    pwr.gov.meth.ttest.same <- rk.XML.convert(sources=list(pwr.gov.meth.ttest.typesame, pwr.gov.meth.ttest), mode=c(and=""), id.name="pwr_lgc_tsame"),
    pwr.gov.meth.ttest.diff <- rk.XML.convert(sources=list(pwr.gov.meth.ttest.2diff, pwr.gov.meth.ttest), mode=c(and=""), id.name="pwr_lgc_tdiff"),
    pwr.gov.meth.ttest.paired <- rk.XML.convert(sources=list(pwr.gov.meth.ttest.pairs, pwr.gov.meth.ttest), mode=c(and=""), id.name="pwr_lgc_tpaired"),
    pwr.gov.meth.ttest.onesample <- rk.XML.convert(sources=list(pwr.gov.meth.ttest.single, pwr.gov.meth.ttest), mode=c(and=""),
    id.name="pwr_lgc_tunpaired"),
 
    rk.XML.connect(governor=pwr.gov.meth.proptest, client=pwr.type.drop, set="visible", not=TRUE),
    rk.XML.connect(governor=pwr.gov.meth.ttest, client=pwr.type.drop, set="enabled"),
    rk.XML.connect(governor=pwr.gov.meth.proptest, client=pwr.proptype.drop, set="visible"),
    rk.XML.connect(governor=pwr.gov.meth.proptest, client=pwr.proptype.drop, set="enabled"),
    rk.XML.connect(governor=pwr.gov.meth.f2test, client=pwr.parameter.opt.dfu, set="enabled"),
    rk.XML.connect(governor=pwr.gov.meth.f2test, client=pwr.frame.sample, set="visible", not=TRUE),
    pwr.gov.meth.df <- rk.XML.convert(sources=list(pwr.gov.meth.f2test, pwr.gov.meth.chisq), mode=c(or=""), id.name="pwr_lgc_show_df"),
    rk.XML.connect(governor=pwr.gov.meth.df, client=pwr.frame.df, set="visible"),
    rk.XML.connect(governor=pwr.gov.meth.chisq, client=pwr.input.df, set="visible"),
    rk.XML.connect(governor=pwr.gov.meth.f2test, client=pwr.input.dfu, set="visible"),
    rk.XML.connect(governor=pwr.gov.meth.f2test, client=pwr.txt.dfu, set="visible"),
    rk.XML.connect(governor=pwr.gov.meth.f2test, client=pwr.input.dfv, set="visible"),
    rk.XML.connect(governor=pwr.gov.meth.f2test, client=pwr.txt.dfv, set="visible"),

    pwr.gov.efct.d <- rk.XML.convert(sources=list(pwr.gov.meth.ttest, pwr.gov.meth.norm), mode=c(or=""), id.name="pwr_lgc_efct_d"),
    rk.XML.connect(governor=pwr.gov.efct.d, client=pwr.txt.effect.d, set="visible"),
    rk.XML.connect(governor=pwr.gov.meth.rtest, client=pwr.txt.effect.r, set="visible"),
    pwr.gov.efct.f <- rk.XML.convert(sources=list(string=pwr.effect.etasq.rad), mode=c(equals="f"), id.name="pwr_lgc_efct_f"),
    pwr.gov.efct.show.f <- rk.XML.convert(sources=list(pwr.gov.meth.anova, pwr.gov.efct.f), mode=c(and=""), id.name="pwr_lgc_efct_show_f"),
    pwr.gov.efct.show.e2 <- rk.XML.convert(sources=list(pwr.gov.meth.anova, not=pwr.gov.efct.f), mode=c(and=""), id.name="pwr_lgc_efct_show_e2"),
    rk.XML.connect(governor=pwr.gov.efct.show.f, client=pwr.txt.effect.f, set="visible"),
    rk.XML.connect(governor=pwr.gov.efct.show.e2, client=pwr.txt.effect.e2, set="visible"),
    rk.XML.connect(governor=pwr.gov.meth.f2test, client=pwr.txt.effect.f2, set="visible"),
    rk.XML.connect(governor=pwr.gov.meth.chisq, client=pwr.txt.effect.w, set="visible"),
    rk.XML.connect(governor=pwr.gov.meth.proptest, client=pwr.txt.effect.h, set="visible"),
    rk.XML.connect(governor=pwr.gov.meth.anova, client=pwr.effect.etasq.rad, set="visible"),
    rk.XML.connect(governor=pwr.gov.want.effect, client=pwr.effect.etasq.rad, set="enabled", not=TRUE),

    rk.XML.connect(governor=pwr.gov.meth.anova, client=pwr.input.groups, set="enabled"),

    # text for sample size
    pwr.gov.smpl.ps <- rk.XML.convert(sources=list(pwr.gov.meth.ttest.same, pwr.gov.meth.ttest.onesample, pwr.gov.meth.2ptest), mode=c(or=""), id.name="pwr_lgc_smpl_ps"),
    pwr.gov.smpl.nondefault <- rk.XML.convert(sources=list(
      pwr.gov.meth.ttest,
      pwr.gov.meth.2ptest,
      pwr.gov.meth.2p2ntest,
      pwr.gov.meth.ttest.diff,
      pwr.gov.meth.anova,
      pwr.gov.meth.chisq), mode=c(or=""), id.name="pwr_lgc_smpl_nondefault"),
    rk.XML.connect(governor=pwr.gov.smpl.ps, client=pwr.txt.sample.ps, set="visible"),
    rk.XML.connect(governor=pwr.gov.meth.anova, client=pwr.txt.sample.pg, set="visible"),
    rk.XML.connect(governor=pwr.gov.meth.chisq, client=pwr.txt.sample.tt, set="visible"),
    rk.XML.connect(governor=pwr.gov.meth.ttest.paired, client=pwr.txt.sample.pairs, set="visible"),
    rk.XML.connect(governor=pwr.gov.smpl.nondefault, client=pwr.txt.sample.default, set="visible", not=TRUE),
    pwr.gov.smpl.diff <- rk.XML.convert(sources=list(pwr.gov.meth.ttest.diff, pwr.gov.meth.2p2ntest), mode=c(or=""), id.name="pwr_lgc_smpl_diff"),
    rk.XML.connect(governor=pwr.gov.smpl.diff, client=pwr.input.sample.n1, set="visible"),
    rk.XML.connect(governor=pwr.gov.smpl.diff, client=pwr.input.sample.n2, set="visible"),
    rk.XML.connect(governor=pwr.gov.smpl.diff, client=pwr.input.sample, set="visible", not=TRUE),

    # switch between sample estimations
    pwr.gov.smpl.switch <- rk.XML.convert(sources=list(pwr.gov.want.sample, pwr.gov.smpl.diff), mode=c(and=""), id.name="pwr_lgc_smpl_switch"),
    pwr.gov.enable.sample.frame <- rk.XML.convert(sources=list(not=pwr.gov.want.sample, pwr.gov.smpl.switch), mode=c(or=""), id.name="pwr_lgc_enable_sample_frame"),
    rk.XML.connect(governor=pwr.gov.enable.sample.frame, client=pwr.frame.sample, set="enabled"),
    rk.XML.connect(governor=pwr.gov.want.sample, client=pwr.input.sample.n2, not=TRUE, set="enabled"),
    
    # df
    rk.XML.connect(governor=pwr.gov.want.df.u, client=pwr.input.dfu, not=TRUE, set="enabled"),
    rk.XML.connect(governor=pwr.gov.want.sample, client=pwr.input.dfv, not=TRUE, set="enabled"),
    rk.XML.connect(governor=pwr.gov.want.df.u, client=pwr.txt.dfu, not=TRUE, set="enabled"),
    rk.XML.connect(governor=pwr.gov.want.sample, client=pwr.txt.dfv, not=TRUE, set="enabled"),
    
    # disable alterative setting
    pwr.gov.meth.noalternative <- rk.XML.convert(sources=list(not=pwr.gov.meth.anova, not=pwr.gov.meth.f2test, not=pwr.gov.meth.chisq), mode=c(and=""), id.name="pwr_lgc_noalternative"),
    rk.XML.connect(governor=pwr.gov.meth.noalternative, client=pwr.hypothesis.drop, set="enabled"),
    # check if a warning regarding negative effect size is in order
    pwr.gov.meth.alt.less <- rk.XML.convert(sources=list(string=pwr.hypothesis.drop), mode=c(equals="less"), id.name="pwr_lgc_alt_less"),
    pwr.gov.meth.alt.greater <- rk.XML.convert(sources=list(string=pwr.hypothesis.drop), mode=c(equals="greater"), id.name="pwr_lgc_alt_greater"),
    pwr.gov.meth.effect.positive <- rk.XML.convert(sources=list(real=pwr.input.effect), mode=c(min=0), id.name="pwr_lgc_pos_effect"),
    pwr.gov.meth.effect.negative <- rk.XML.convert(sources=list(real=pwr.input.effect), mode=c(max=0), id.name="pwr_lgc_neg_effect"),
    pwr.gov.meth.alt.warning.neg <- rk.XML.convert(sources=list(pwr.gov.meth.alt.less, pwr.gov.meth.noalternative, pwr.gov.meth.effect.positive), mode=c(and=""), id.name="pwr_lgc_alt_warn_neg"),
    pwr.gov.meth.alt.warning.pos <- rk.XML.convert(sources=list(pwr.gov.meth.alt.greater, pwr.gov.meth.noalternative, pwr.gov.meth.effect.negative), mode=c(and=""), id.name="pwr_lgc_alt_warn_pos"),
    rk.XML.connect(governor=pwr.gov.meth.alt.warning.neg, client=pwr.txt.hypothesis.neg, set="visible"),
    rk.XML.connect(governor=pwr.gov.meth.alt.warning.pos, client=pwr.txt.hypothesis.pos, set="visible")
  )


 
## JavaScript
pwr.js.calc <- rk.paste.JS(
  echo("\tpwr.result <- try(\n\t\t"),
  #########
  ## t-test
  ite(id(pwr.stat.drop, " == \"pwr.t.test\""),
    rk.paste.JS(
      # two samples with different sizes or not?
      ite(id(pwr.type.drop, " == \"two.sample.diff\""),
        rk.paste.JS(# yes
          echo("pwr.t2n.test("),
          ite(id(pwr.parameter.rad, " != \"Sample size\""),
            echo("\n\t\t\tn1=", pwr.input.sample.n1, ",\n\t\t\tn2=", pwr.input.sample.n2),
            echo("\n\t\t\tn1=", pwr.input.sample.n1, ",")
          )
        ),
        rk.paste.JS(#no
          echo("pwr.t.test("),
          ite(id(pwr.parameter.rad, " != \"Sample size\""),
            echo("\n\t\t\tn=", pwr.input.sample)
          )
        )
      ),
      ite(id(pwr.parameter.rad, " != \"Effect size\""),
        rk.paste.JS(
          ite(id(pwr.parameter.rad, " != \"Sample size\""), echo(",")),
          echo("\n\t\t\td=", pwr.input.effect)
        )
      )
    )
  ),
  ###############
  ## correlations
  ite(id(pwr.stat.drop, " == \"pwr.r.test\""),
    rk.paste.JS(
      echo("pwr.r.test("),
      ite(id(pwr.parameter.rad, " != \"Sample size\""),
        echo("\n\t\t\tn=", pwr.input.sample)
      ),
      ite(id(pwr.parameter.rad, " != \"Effect size\""),
        rk.paste.JS(
          ite(id(pwr.parameter.rad, " != \"Sample size\""), echo(",")),
          echo("\n\t\t\tr=", pwr.input.effect)
        )
      )
    )
  ),
  ########
  ## ANOVA
  ite(id(pwr.stat.drop, " == \"pwr.anova.test\""),
    rk.paste.JS(
      echo("pwr.anova.test("),
      echo("\n\t\t\tk=", pwr.input.groups),
      ite(id(pwr.parameter.rad, " != \"Sample size\""),
        echo(",\n\t\t\tn=", pwr.input.sample)
      ),
      ite(id(pwr.parameter.rad, " != \"Effect size\""),
        ite(id(pwr.effect.etasq.rad, " == \"f\""),
          echo(",\n\t\t\tf=", pwr.input.effect),
          echo(",\n\t\t\tf=sqrt(", pwr.input.effect,"/(1-", pwr.input.effect,")) # calculate f from eta squared")
        )
      )
    )
  ),
  ######
  ## GLM
  ite(id(pwr.stat.drop, " == \"pwr.f2.test\""),
    rk.paste.JS(
      echo("pwr.f2.test("),
      ite(id(pwr.parameter.rad, " != \"Parameter count\""),
        rk.paste.JS(
          echo("\n\t\t\tu=", pwr.input.dfu)
        )
      ),
      ite(id(pwr.parameter.rad, " != \"Sample size\""),
        rk.paste.JS(
          ite(id(pwr.parameter.rad, " != \"Parameter count\""),
            echo (",")
          ),
          echo("\n\t\t\tv=", pwr.input.dfv)
        )
      ),
      ite(id(pwr.parameter.rad, " != \"Effect size\""),
        rk.paste.JS(
          echo(",\n\t\t\tf2=", pwr.input.effect)
        )
      )
    )
  ),
  ##############
  ## Chi squared
  ite(id(pwr.stat.drop, " == \"pwr.chisq.test\""),
    rk.paste.JS(
      echo("pwr.chisq.test("),
      ite(id(pwr.parameter.rad, " != \"Effect size\""),
        echo("\n\t\t\tw=", pwr.input.effect)
      ),
      ite(id(pwr.parameter.rad, " != \"Sample size\""),
        rk.paste.JS(
          ite(id(pwr.parameter.rad, " != \"Effect size\""), echo(",")),
          echo("\n\t\t\tN=", pwr.input.sample)
        )
      ),
      echo(",\n\t\t\tdf=", pwr.input.df)
    )
  ),
  ##############
  ## proportions
  ite(id(pwr.stat.drop, " == \"pwr.p.test\""),
    rk.paste.JS(
      ite(id(pwr.proptype.drop, " == \"two.sample.same\""), echo("pwr.2p.test(")),
      ite(id(pwr.proptype.drop, " == \"two.sample.diff\""), echo("pwr.2p2n.test(")),
      ite(id(pwr.proptype.drop, " == \"one.sample\""), echo("pwr.p.test(")),
      ite(id(pwr.parameter.rad, " != \"Effect size\""),
        echo("\n\t\t\th=", pwr.input.effect)
      ),
      ite(id(pwr.parameter.rad, " != \"Sample size\""),
        rk.paste.JS(
          ite(id(pwr.parameter.rad, " != \"Effect size\""), echo(",")),
          ite(id(pwr.proptype.drop, " != \"two.sample.diff\""),
            echo("\n\t\t\tn=", pwr.input.sample),
            echo("\n\t\t\tn1=", pwr.input.sample.n1, ",\n\t\t\tn2=", pwr.input.sample.n2)
          )
        ),
        ite(id(pwr.proptype.drop, " == \"two.sample.diff\""),
          echo(",\n\t\t\tn1=", pwr.input.sample.n1),
        )
      )
    )
  ),
  ######################
  ## normal distribution
  ite(id(pwr.stat.drop, " == \"pwr.norm.test\""),
    rk.paste.JS(
      echo("pwr.norm.test("),
      ite(id(pwr.parameter.rad, " != \"Effect size\""),
        echo("\n\t\t\td=", pwr.input.effect)
      ),
      ite(id(pwr.parameter.rad, " != \"Sample size\""),
        rk.paste.JS(
          ite(id(pwr.parameter.rad, " != \"Effect size\""), echo(",")),
          echo("\n\t\t\tn=", pwr.input.sample)
        )
      )
    )
  ),
  ite(id(pwr.parameter.rad, " != \"Significance level\""),
    ite(id(pwr.input.signif, " != 0.05"), echo("\n\t\t\tsig.level=", pwr.input.signif, ",")),
    echo(",\n\t\t\tsig.level=NULL")
  ),
  ite(id(pwr.parameter.rad, " != \"Power\""),
    echo(",\n\t\t\tpower=", pwr.input.power)
  ),
  ite(id(pwr.stat.drop, " == \"pwr.t.test\" & ", pwr.type.drop, " != \"two.sample.diff\" & ", pwr.type.drop, " != \"two.sample\""),
    echo(",\n\t\t\ttype=\"", pwr.type.drop, "\"")
  ),
  ite(id(pwr.stat.drop, " != \"pwr.anova.test\" & ", pwr.stat.drop, " != \"pwr.f2.test\" & ", pwr.stat.drop, " != \"pwr.chisq.test\""),
    ite(id(pwr.hypothesis.drop, " != \"two.sided\""),
      echo(",\n\t\t\talternative=\"", pwr.hypothesis.drop, "\"")
    )
  ),
  echo("\n\t\t)\n\t)\n\n")
)

pwr.js.print <- rk.paste.JS(
  rk.JS.vars(list(pwr.stat.drop, pwr.parameter.rad)),
  echo(
    "\t# Catch errors due to unsuitable data\n",
    "\tif(class(pwr.result) == \"try-error\"){\n",
    "\t\trk.print(\"Power anaylsis not possible with the data you provided\")\n",
    "\t\treturn()\n\t}\n\n",
    "\t# Prepare printout\n",
    "\tnote <- pwr.result[[\"note\"]]\n",
    "\tparameters <- list(\"Target measure\"=\"", pwr.parameter.rad, "\")\n",
    "\tif(!is.null(pwr.result[[\"alternative\"]])){\n\t\tparameters[[\"alternative\"]] <- pwr.result[[\"alternative\"]]\n\t}\n\n",
    "\trk.header(pwr.result[[\"method\"]], parameters=parameters)\n",
    "\tpwr.result[c(\"method\", \"note\", \"alternative\")] <- NULL\n",
    "\tpwr.result <- as.data.frame(unlist(pwr.result))\n",
    "\tcolnames(pwr.result) <- \"Parameters\"\n\n",
    "\trk.results(pwr.result)\n",
    "\tif(!is.null(note)){\n\t\trk.print(paste(\"<strong>Note:</strong> \", note))\n\t}\n\n"
  ),
  ite(id(pwr.stat.drop, " == \"pwr.t.test\" | ", pwr.stat.drop, " == \"pwr.norm.test\""),
    echo("\trk.print(\"Interpretation of effect size <strong>d</strong> (according to Cohen):\")\n",
      "\trk.results(data.frame(small=0.2, medium=0.5, large=0.8))\n")
  ),
  ite(id(pwr.stat.drop, " == \"pwr.r.test\""),
    echo("\trk.print(\"Interpretation of effect size <strong>r</strong> (according to Cohen):\")\n",
      "\trk.results(data.frame(small=0.1, medium=0.3, large=0.5))\n")
  ),
  ite(id(pwr.stat.drop, " == \"pwr.f2.test\""),
    echo("\trk.print(\"Interpretation of effect size <strong>f<sup>2</sup></strong> (according to Cohen):\")\n",
      "\trk.results(data.frame(small=0.02, medium=0.15, large=0.35))\n")
  ),
  ite(id(pwr.stat.drop, " == \"pwr.anova.test\""),
    echo("\trk.print(\"Interpretation of effect size <strong>f</strong> (according to Cohen):\")\n",
      "\trk.results(data.frame(small=0.1, medium=0.25, large=0.4))\n")
  ),
  ite(id(pwr.stat.drop, " == \"pwr.chisq.test\""),
    echo("\trk.print(\"Interpretation of effect size <strong>w</strong> (according to Cohen):\")\n",
      "\trk.results(data.frame(small=0.1, medium=0.3, large=0.5))\n")
  ),
  ite(id(pwr.stat.drop, " == \"pwr.p.test\""),
    echo("\trk.print(\"Interpretation of effect size <strong>h</strong> (according to Cohen):\")\n",
      "\trk.results(data.frame(small=0.2, medium=0.5, large=0.8))\n")
  )
)

############
## help file

pwr.rkh.summary <- rk.rkh.summary("Perform power anaylsis for a variety of statistcal methods.")

pwr.rkh.usage <- rk.rkh.usage("Given three of the parameters 'power of test', 
  'sample size', 'effect size', and 'significance level', this plugin will 
  estimate the fourth, i.e. for example the test power of a t.test at a given 
  sample size, effect size, and level of significance. On the left hand, specify the 
  statistical method, on the right hand side, enter the values of the given 
  parameters. In the control in the middle, select which of the parameters to estimate.\n\n
  Note that in some cases it will not be possible to estimate a (finite) parameter at the given
  specifications. In general, this means that you have to increase sample size(s) or effect size,
  or decrease effect power or parameter count.")

pwr.rkh.related <- rk.rkh.related(rk.rkh.link ("pwr", text="Description of the R package \"pwr\", used to perform the power calculations."))

#############
## if you run the following function call, files will be written to tempdir!
#############
# this is where it get's serious, that is, here all of the above is put together into one plugin

pwr.plugin.dir <<- rk.plugin.skeleton(
  about.info,
  path=output.dir,
  guess.getter=guess.getter,
  xml=list(
      dialog=pwr.full.dialog,
      logic=lgc.sect.pwr
    ),
  js=list(results.header=FALSE,
    require="pwr",
    calculate=pwr.js.calc,
    printout=pwr.js.print),
  rkh=list(
    summary=pwr.rkh.summary,
    usage=pwr.rkh.usage,
    related=pwr.rkh.related
  ),
  pluginmap=list(name="Power analysis", hierarchy=list("analysis")),
  dependencies=dependencies.info,
  create=c("pmap", "xml", "js", "desc", "rkh"),
  overwrite=overwrite,
  tests=FALSE,
# edit=TRUE,
  load=TRUE,
# show=TRUE,
  hints=FALSE)
})
