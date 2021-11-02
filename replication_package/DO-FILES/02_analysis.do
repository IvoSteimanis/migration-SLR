*** Data analysis for "Why do people persist in sea-level rise threatened coastal regions? Empirical evidence on risk aversion and place attachment"

*--------------------------------------------------
* Description
*--------------------------------------------------
* (1) Main Manuscript
* (2) Supplemental Materials
*--------------------------------------------------



* Load dataset
use "$datapath\data_analysis.dta"


*-----------------------------------
* (1) MAIN MANUSCRIPT: FIGURES & TABLES
*-----------------------------------
* set globals for variables
global damages land_lost pca_rebuild_intensity
global socio_economic female age married edu log_income_hh log_asset_sum people_hh
global preferences z_risk2 z_identity z_dependence


*-------------------------------------------------------------------
* Description of affectedness
*-------------------------------------------------------------------
sum number_extremes, detail
tab t_extremes

gen dmg_exceed_income = 0 if rebuild_costs < income_hh
replace dmg_exceed_income = 1 if rebuild_costs > income_hh




*-----------------------------------------------------------------------------
* Fig. 2. Distribution of preferences and migration aspirations across groups
*-----------------------------------------------------------------------------
ttest place_identity_norm = place_dependence_norm
estpost tabstat place_identity place_dependence, statistics(count mean sd min max) columns(statistics)
estpost tabstat risk_aversion_norm place_identity_norm place_dependence_norm , statistics(count mean sd min max) columns(statistics)

*Panel a: distribution risk
twoway kdensity risk_aversion_norm if t_extremes == 0, lwidth(thick) lcolor(538b%60) || kdensity risk_aversion_norm if t_extremes == 1, lwidth(thick) color(538y%60) || kdensity risk_aversion_norm if  t_extremes == 2, lwidth(thick) color(538r%60) yla(, nogrid)  title("{bf:a  } Risk aversion", size(10pt)) legend(pos(6) size(8pt) row(1) order(1 2 3) stack label(1 "None") label(2 "1 or 2") label(3 "3 and more")) xsize(3.465) ysize(3) xtitle("Higher values imply stronger risk aversion", size(8pt)) ytitle("Density", size(8pt))
gr save  "$output\fig2_a.gph", replace

ksmirnov risk_aversion_norm if t_extremes != 2, by(t_extremes)
ksmirnov risk_aversion_norm if t_extremes != 1, by(t_extremes)

*Panel b: distribution place identity
twoway kdensity place_identity_norm if t_extremes == 0, lwidth(thick) lcolor(538b%60) || kdensity place_identity_norm if t_extremes == 1, lwidth(thick) color(538y%60) || kdensity place_identity_norm if  t_extremes == 2, lwidth(thick) color(538r%60) yla(, nogrid) title("{bf:b  } Place identity", size(10pt)) legend(pos(6) size(8pt) row(1) order(1 2 3) stack label(1 "None") label(2 "1 or 2") label(3 "3 and more")) xsize(3.465) ysize(2) xtitle("Higher values imply stronger place identity", size(8pt)) ytitle("Density", size(8pt))
gr save  "$output\fig2_b.gph", replace

ksmirnov place_identity_norm if t_extremes != 2, by(t_extremes)
ksmirnov place_identity_norm if t_extremes != 1, by(t_extremes)

*Panel c: distribution place dependence
twoway kdensity place_dependence_norm if t_extremes == 0, lwidth(thick) lcolor(538b%60) || kdensity place_dependence_norm if t_extremes == 1, lwidth(thick) color(538y%60) || kdensity place_dependence_norm if  t_extremes == 2, lwidth(thick) color(538r%60) yla(, nogrid) title("{bf:c  } Place dependence", size(10pt)) legend(pos(6) size(8pt) row(1) order(1 2 3) stack label(1 "None") label(2 "1 or 2") label(3 "3 and more")) xsize(3.465) ysize(2) xtitle("Higher values imply stronger place dependence", size(8pt)) ytitle("Density", size(8pt))
gr save  "$output\fig2_c.gph", replace

ksmirnov place_dependence_norm if t_extremes != 2, by(t_extremes)
ksmirnov place_dependence_norm if t_extremes != 1, by(t_extremes)


*Panel d: Aspired destinations by extremes
* Ability to aspire and reasons for moving to the named country
bysort country_id: tab migrate_abroad
tab costliness_destinations
bysort country_id: sum ma_reason_relig ma_reason_econ ma_reason_rel ma_reason_prox ma_reason_lifesat if costliness_destination==3
bysort country_id: tab ma_reason_rel if costliness_destination==3
bysort country_id: sum ma_reason_relig ma_reason_econ ma_reason_rel ma_reason_prox ma_reason_lifesat if costliness_destination==2
sum ma_reason_relig ma_reason_econ ma_reason_rel ma_reason_prox ma_reason_lifesat if costliness_destination==2
bysort country_id: sum ma_reason_relig ma_reason_econ ma_reason_rel ma_reason_prox ma_reason_lifesat if costliness_destination==1
sum ma_reason_relig ma_reason_econ ma_reason_rel ma_reason_prox ma_reason_lifesat if costliness_destination==1


mylabels 0(20)100, myscale(@) local(pctlabel) suffix("%") 
catplot costliness_destinations,  over(t_extremes) asyvar stack percent(t_extremes)  yla(`pctlabel', nogrid) blabel(bar, format(%9.0f) size(8pt) pos(center))   l1title("")  b1title("") legend(rows(2) ring(1) pos(6) size(8pt)) title("{bf:d } Migration aspirations", size(10pt))
gr save  "$output\fig2_d.gph", replace

tab aspired_destination1  t_extremes if t_extremes!=1, chi2 exact
tab aspired_destination1 t_extremes if t_extremes!=2, chi2 exact

tab aspired_destination4 t_extremes if t_extremes!=1, chi2 exact
tab aspired_destination4 t_extremes if t_extremes!=2, chi2 exact

gr combine "$output\fig2_a.gph" "$output\fig2_b.gph" "$output\fig2_c.gph" "$output\fig2_d.gph", rows(2) xsize(3.465) ysize(3) 
gr save "$output\figure2_preferences_distribution.gph", replace
gr export "$output\01_main\figure2_preferences_distribution.tif", replace width(3465)
gr export "$output\01_main\figure2_preferences_distribution.svg", replace 




*----------------------------------------------------------------
* Fig. 3.	Preferences and aspirations associate with reported hazards
*----------------------------------------------------------------
** PANEL A
*Risk
reg z_risk2 extreme2 extreme3 i.location, vce(robust)
est store risk1
outreg2 using "$output\02_supplemental\tableS5_preferences", drop(i.location)  adjr2 addstat() dec(2) word  replace
reg z_dependence extreme2 extreme3 $socio_economic $damages i.location, vce(robust)
est store risk2
testparm $socio_economic
local F1 = r(p)
testparm $damages
local F2 = r(p)
outreg2 using "$output\02_supplemental\tableS5_preferences", drop(i.location)  adjr2 addstat("Socio-economics", `F1', "Damages", `F2') adec(2) dec(2) word  append

*Place identity
reg z_identity  extreme2 extreme3  i.location, vce(robust)
est store ident1
outreg2 using "$output\02_supplemental\tableS5_preferences", drop(i.location)  adjr2 addstat() dec(2) word  append
reg z_identity  extreme2 extreme3  $socio_economic $damages i.location , vce(robust)
est store ident2
testparm $socio_economic
local F1 = r(p)
testparm $damages
local F2 = r(p)
outreg2 using "$output\02_supplemental\tableS5_preferences", drop(i.location)  adjr2 addstat("Socio-economics", `F1', "Damages", `F2') adec(2) dec(2) word  append

*Place dependence
reg z_dependence extreme2 extreme3  i.location , vce(robust)
est store depend1
outreg2 using "$output\02_supplemental\tableS5_preferences", drop(i.location)  adjr2 addstat() dec(2) word  append
reg z_dependence extreme2 extreme3  $socio_economic $damages i.location, vce(robust)
est store depend2
testparm $socio_economic
local F1 = r(p)
testparm $damages
local F2 = r(p)
outreg2 using "$output\02_supplemental\tableS5_preferences", drop(i.location)  adjr2 addstat("Socio-economics", `F1', "Damages", `F2') adec(2) dec(2) word  append

*plot point estimates and CIs
coefplot (risk2, keep(extreme2) mcolor(538y)  mlabcolor(538y) levels(95 90) ciopts(lwidth(0.5 1.2) lcolor(538y*.8 538y*.2 ) recast(rcap))) (risk2, keep(extreme3)),  bylabel(Risk aversion (z-score)) || (ident2, keep(extreme2)) (ident2, keep(extreme3)), bylabel(Place identity (z-score))  || (depend2, keep(extreme2)) (depend2, keep(extreme3)), bylabel(Place dependence (z-score)) ||,  byopts(compact cols(1)) subtitle(, size(8pt) margin(small) justification(left)  bmargin(top)) coeflabels(extreme2 = "1 or 2"  extreme3 = "3 or more") xline(0, lpattern(dash) lcolor(gs3))  xtitle("Effect size in SD / pp relative to no hazards", size(6pt)) msymbol(d)    xla(-0.2(0.2)0.6, nogrid) grid(none) levels(95 90) ciopts(lwidth(0.5 1.2) lcolor(*.8 *.2) recast(rcap)) mlabel(string(@b, "%5.2f")) mlabsize(8pt) msize(4pt)  mlabposition(3)  mlabgap(0.5) xsize(2.5) ysize(2) 
gr save "$output\figure3_EE_preferences_A.gph", replace



** PANEL B
* Migration aspirations
mlogit costliness_destinations extreme2 extreme3 $socio_economic  $damages i.location, vce(robust) base(0)
outreg2 using "$output\02_supplemental\tableS6_mlogit_aspirations", drop(i.location)  addstat("Pseudo-squared", e(r2_p)) adec(2) dec(2) word  replace
margins, dydx(extreme2 extreme3)
margins, dydx(extreme2 extreme3) predict(pr outcome(0)) post
est store stay

mlogit costliness_destinations extreme2 extreme3 $socio_economic  $damages i.location, vce(robust) base(0)
margins, dydx(extreme2 extreme3) predict(pr outcome(1)) post
est store low
mlogit costliness_destinations extreme2 extreme3 $socio_economic  $damages i.location, vce(robust) base(0)
margins, dydx(extreme2 extreme3) predict(pr outcome(2)) post
est store medium
mlogit costliness_destinations extreme2 extreme3 $socio_economic  $damages i.location, vce(robust) base(0)
margins, dydx(extreme2 extreme3) predict(pr outcome(3)) post
est store high

*plot point estimates and CIs
coefplot (stay, keep(extreme2) mcolor(538y)  mlabcolor(538y) levels(95 90) ciopts(lwidth(0.5 1.2) lcolor(538y*.8 538y*.2 ) recast(rcap))) (stay, keep(extreme3)),  bylabel(No aspirations) || (low, keep(extreme2)) (low, keep(extreme3)),  bylabel(Low-income) || (medium, keep(extreme2)) (medium, keep(extreme3)),  bylabel(Medium-income ) ||(high, keep(extreme2)) (high, keep(extreme3)),  bylabel(High-income) ||,  byopts(compact cols(1)) subtitle(, size(8pt) margin(small) justification(left)  bmargin(top)) coeflabels(extreme2 = "1 or 2"  extreme3 = "3 or more") xline(0, lpattern(dash) lcolor(gs3)) xtitle("Effect size in SD / pp relative to no hazards", size(6pt)) msymbol(d)    xla(-0.2(0.2)0.6, nogrid) grid(none) levels(95 90) ciopts(lwidth(0.5 1.2) lcolor(*.8 *.2) recast(rcap)) mlabel(string(@b, "%5.2f")) mlabsize(8pt) msize(4pt)  mlabposition(3)  mlabgap(0.5) xsize(2.5) ysize(2) 
gr save  "$output\figure3_EE_aspirations_B.gph", replace

grc1leg  "$output\figure3_EE_preferences_A.gph" "$output\figure3_EE_aspirations_B.gph"
gr save "$output\figure3_EE_preferences.gph", replace
gr export "$output\01_main\figure3_extreme_events_effects_new.tif", replace width(5400)
gr export "$output\01_main\figure3_extreme_events_effects_new.svg", replace


* country specific migration aspirations (no village fixed effects possible)
mlogit costliness_destinations extreme2 extreme3 $socio_economic  $damages if country_id==2, vce(robust) base(0)
margins, dydx(extreme2 extreme3)
probit aspired_destination4 extreme2 extreme3 $socio_economic  $damages if country_id==3, vce(robust)
margins, dydx(extreme2 extreme3)




*----------------------------------------------------------------
* Fig. 4.	Effect of hazards through preferences on aspirations
*----------------------------------------------------------------
*PANEL A

probit migrate_abroad  $preferences $socio_economic $damages  i.country_id if t_extremes==0, vce(robust)
local R2 = e(r2_p)
margins, dydx(*) post
est store ma1
outreg2 using "$output\02_supplemental\tableS16_aspirations", drop()  addstat("Pseudo R-squared", `R2') adec(2) dec(2) word  replace 
probit migrate_abroad $preferences $socio_economic $damages  i.country_id if t_extremes==1, vce(robust)
local R2 = e(r2_p)
margins, dydx(*) post
est store ma2
outreg2 using "$output\02_supplemental\tableS16_aspirations", drop()  addstat("Pseudo R-squared", `R2') adec(2) dec(2) word  append 
probit migrate_abroad $preferences $socio_economic $damages  i.country_id if t_extremes==2, vce(robust)
local R2 = e(r2_p)
margins, dydx(*) post
est store ma3
outreg2 using "$output\02_supplemental\tableS16_aspirations", drop()  addstat("Pseudo R-squared", `R2') adec(2) dec(2) word  append 

coefplot (ma2, mcolor(538y)  mlabcolor(538y) levels(95 90) ciopts(lwidth(0.5 1.2) lcolor(538y*.8 538y*.2 ) recast(rcap))) (ma3,), nokey  keep(z_risk2 z_identity z_dependence)  coeflabels(z_risk2 = "Risk aversion" z_identity = "Place Identity" z_dependence = "Place Dependence") xline(0, lpattern(dash) lcolor(gs3)) title("{bf:a } Aspiring to move abroad", size(10pt)) xtitle("Effect size in percentage points", size(8pt)) msymbol(d)  xla(-0.2(0.1)0.2, nogrid) grid(none) levels(95 90) ciopts(lwidth(0.5 1.2)  msize(4pt)  lcolor(*.8 *.2) recast(rcap))  mlabel(string(@b, "%5.2f")) mlabsize(10pt)  mlabposition(12) mlabgap(0.3) xsize(3.465) ysize(2)
gr save "$output\figure4_a.gph", replace


*PANEL B
probit aspired_destination4  $preferences $socio_economic $damages  i.country_id if t_extremes==0, vce(robust)
local R2 = e(r2_p)
margins, dydx(*) post
est store mhigh1
outreg2 using "$output\02_supplemental\tableS16_aspirations", drop()  addstat("Pseudo R-squared", `R2') adec(2) dec(2) word  append 
probit aspired_destination4 $preferences $socio_economic $damages  i.country_id if t_extremes==1, vce(robust)
local R2 = e(r2_p)
margins, dydx(*) post
est store mhigh2
outreg2 using "$output\02_supplemental\tableS16_aspirations", drop()  addstat("Pseudo R-squared", `R2') adec(2) dec(2) word  append 
probit aspired_destination4 $preferences $socio_economic $damages  i.country_id if t_extremes==2, vce(robust)
local R2 = e(r2_p)
margins, dydx(*) post
est store mhigh3
outreg2 using "$output\02_supplemental\tableS16_aspirations", drop()  addstat("Pseudo R-squared", `R2') adec(2) dec(2) word  append 

coefplot (mhigh2, mcolor(538y)  mlabcolor(538y) levels(95 90) ciopts(lwidth(0.5 1.2) lcolor(538y*.8 538y*.2 ) recast(rcap))) (mhigh3,  lcolor(538r)), keep(z_risk2 z_identity z_dependence)  coeflabels(z_risk2 = "Risk aversion" z_identity = "Place Identity" z_dependence = "Place Dependence") xline(0, lpattern(dash) lcolor(gs3)) title("{bf:b } Aspiring a high-income destination", size(10pt)) xtitle("Effect size in percentage points", size(8pt)) msymbol(d)  xla(-0.2(0.1)0.2, nogrid) grid(none) levels(95 90) ciopts(lwidth(0.5 1.2) lcolor(*.8 *.2 ) recast(rcap)) mlabel(string(@b, "%5.2f")) mlabsize(10pt) msize(4pt)  mlabposition(12) mlabgap(0.3) legend(order(3 "1 or 2 (n=203)" 6 "3+ (n=238)") pos(6) ring(0) rows(1) size(10pt) bmargin(small)) xsize(3.465) ysize(2)
gr save "$output\figure4_b.gph", replace


*Combine both panels to one graph
gr combine "$output\figure4_a.gph" "$output\figure4_b.gph", scale(1.1) rows(2) xsize(3.465) ysize(4)
gr save "$output\figure4_aspirations.gph", replace
gr export "$output\01_main\figure4_aspirations.tif", replace width(3465)
gr export "$output\01_main\figure4_aspirations.svg", replace





*------------------------------
* (2) SUPPLEMENTARY MATERIALS
*------------------------------
*** SECTION S1	Summary statistics, descriptive results, affectedness, and balancing across groups

* Table S1.	Summary statistics
tab likelihood_next3y, gen(likely_)
global overview survey_risk risk place_identity place_dependence aspired_destination1 aspired_destination2 aspired_destination3 aspired_destination4 likely_1 likely_2 likely_3 /// outcomes
		number_extremes rebuild_frequency rebuild_days rebuild_costs cc_relocate land_lost pc_livelihood pc_relocate fp_slr  /// past experience & perceptions
			female age edu people_hh married asset_sum income_hh   /// socio

estpost tabstat $overview, statistics(count mean sd min max) columns(statistics)
esttab . using "$output\02_supplemental\Table1.rtf", cells("count(fmt(0)) mean(fmt(%9.2fc)) sd(fmt(%9.2fc)) min(fmt(0)) max(fmt(0))")  not nostar unstack nomtitle nonumber nonote label replace


* Table S2.	Affectedness across self-reported hazards
global affectedness rebuild_frequency rebuild_days rebuild_costs cc_relocate land_lost pc_livelihood pc_relocate fp_slr
iebaltab $affectedness, grpvar(t_extremes) stdev ftest fmissok rowvarlabels format(%9.2f) tblnonote save("$output\02_supplemental\tableS2_affectedness.xlsx") replace


* Table S3.	Balancing across self-reported hazards
global balance female age edu people_hh married income_hh asset_sum 
iebaltab $balance, grpvar(t_extremes) stdev ftest fmissok rowvarlabels format(%9.2f) tblnonote save("$output\02_supplemental\tableS3_extremes.xlsx") replace

 
* Table S4.	Determinants of number of self-reported hazards
reg number_extremes female age married edu log_income_hh log_asset_sum people_hh, vce(robust)
outreg2 using "$output\02_supplemental\tableS1d_determinants_extremes", drop(i.location)  adjr2  dec(2) word replace




*** SECTION S2	Impact- and risk appraisal of SLR hazards and adaptation strategies

* Figure S1.	Perceived climate impacts and recommended adaptation actions
*PANEL A
bysort country_id: sum pp_slr fp_slr, detail
ttest pp_slr = fp_slr
ranksum fp_slr, by(country_id)
*Panel a: Past and future perception of SLR Impacts
vioplot pp_slr fp_slr, over(country_id)  median(msymbol(D) mcolor(white)) title("{bf:a  } Past and future perception of SLR impacts") ytitle("score", size(medium)) yla(1(1)5, nogrid) xsize(3.465) ysize(2)
gr save "$output\figS1_a.gph", replace


* Panel B
lab def adapt1_lab 0 "Don't know" 1 "Adaptation in-situ" 2 "Out-migration" 3 "In-situ & migration", replace
lab val adapt1 adapt1_lab
mylabels 0(20)100, myscale(@) local(pctlabel) suffix("%") 
catplot adapt1,  over(country_id) asyvar stack percent(country_id)  yla(`pctlabel', nogrid)  var1opts(sort(1) descending) blabel(bar, format(%9.0f) size(medium) pos(center))   l1title("")  b1title("") legend(rows(2) ring(1) pos(6)) title("{bf:b } Recommended adaptation measures") xsize(3.465) ysize(2)
gr save  "$output\figS1_b.gph", replace
tab adapt1
tab1 sealevel1 sealevel2 sealevel3 sealevel4 sealevel5


gr combine "$output\figS1_a.gph" "$output\figS1_b.gph", rows(2) scale(1.2) xsize(3.465) ysize(4) graphregion(margin(zero)) 
gr save "$output\figS1_SLR_appraisal_adaptation.gph", replace
gr export "$output\02_supplemental\figS1_SLR_appraisal_adaptation.tif", replace width(3465)
gr export "$output\02_supplemental\figS1_SLR_appraisal_adaptation.svg", replace 




*** SECTION S3	Additional analysis and robustness checks

* Figure S2.	Predicted migration likelihood in the next three years
ologit likelihood_next3y extreme2 extreme3 $socio_economic  $damages i.location, vce(robust)
margins, dydx(extreme2 extreme3) predict(pr outcome(1)) post
est store unlikely
ologit likelihood_next3y extreme2 extreme3 $socio_economic  $damages i.location,  vce(robust)
margins, dydx(extreme2 extreme3) predict(pr outcome(2)) post
est store neither
ologit likelihood_next3y extreme2 extreme3 $socio_economic  $damages i.location,  vce(robust)
margins, dydx(extreme2 extreme3) predict(pr outcome(3)) post
est store likely

coefplot (unlikely, keep(extreme2) mcolor(538y)  mlabcolor(538y) levels(95 90) ciopts(lwidth(0.5 1.2) lcolor(538y*.8 538y*.2 ) recast(rcap))) (unlikely, keep(extreme3)),  bylabel(Very unlikely) || (neither, keep(extreme2)) (neither, keep(extreme3)),  bylabel(Neither likely nor unlikely) || (likely, keep(extreme2)) (likely, keep(extreme3)),  bylabel(Very-likely) ||,  byopts(compact cols(1)) subtitle(, size(8pt) margin(small) justification(left)  bmargin(top)) coeflabels(extreme2 = "1 or 2"  extreme3 = "3 or more") xline(0, lpattern(dash) lcolor(gs3)) xtitle("Effect size in SD / pp relative to no hazards", size(6pt)) msymbol(d)    xla(-0.2(0.2)0.6, nogrid) grid(none) levels(95 90) ciopts(lwidth(0.5 1.2) lcolor(*.8 *.2) recast(rcap)) mlabel(string(@b, "%5.2f")) mlabsize(8pt) msize(4pt)  mlabposition(3)  mlabgap(0.5) xsize(2.5) ysize(2) 
gr save  "$output\figureS2_migration_likelihood_extremes.gph", replace
gr export "$output\02_supplemental\figureS2_migration_likelihood_extremes.tif", replace width(3460)


* Table S5.	Full regression output for preferences (Figure 3, panel a)
* already saved in main manuscript part of the do-file


* Table S6.	Multinomial logit with no aspiration as the reference group (Figure 3, panel b)
* already saved in main manuscript part of the do-file


* Table S7.	Additional regressions: Risk preferences
*without controlling for imbalances across groups and damages
reg z_risk2 extreme2 extreme3 i.location, vce(robust)
outreg2 using "$output\02_supplemental\tableS7_additional_risk", drop(i.location)  adjr2  dec(2) word replace
* controlling for socio-economics
reg z_risk2 extreme2 extreme3 $socio_economic $damages i.location, vce(robust)
outreg2 using "$output\02_supplemental\tableS7_additional_risk", drop(i.location) adjr2 dec(2) word  append
*Controlling for interviewer FE
reg z_risk2 extreme2 extreme3 $socio_economic $damages i.location i.assistant, vce(robust)
outreg2 using "$output\02_supplemental\tableS7_additional_risk", drop(i.location i.assistant) adjr2 dec(2) word  append
*Bangladesh only
reg survey_risk extreme2 extreme3 $socio_economic $damages i.location i.assistant if country_id==2, vce(robust)
outreg2 using "$output\02_supplemental\tableS7_additional_risk", drop(i.location i.assistant) adjr2 dec(2) word  append
*Vietnam only
reg risk extreme2 extreme3 $socio_economic $damages i.location i.assistant if country_id==3, vce(robust)
outreg2 using "$output\02_supplemental\tableS7_additional_risk", drop(i.location i.assistant) adjr2 dec(2) word  append


* Table S8.	Additional regressions: Place identity (z-score)
*without controlling for imbalances across groups and damages
reg z_identity extreme2 extreme3 i.location, vce(robust)
outreg2 using "$output\02_supplemental\tableS8_additional_identity", drop(i.location)  adjr2  dec(2) word replace
* as plotted in main paper
reg z_identity extreme2 extreme3 $socio_economic $damages i.location, vce(robust)
outreg2 using "$output\02_supplemental\tableS8_additional_identity", drop(i.location)  adjr2  dec(2) word append
* including interviewer FE
reg z_identity extreme2 extreme3 $socio_economic $damages i.location i.assistant, vce(robust)
outreg2 using "$output\02_supplemental\tableS8_additional_identity", drop(i.location i.assistant)  adjr2 dec(2) word append
*Bangladesh only
reg z_identity extreme2 extreme3 $socio_economic $damages i.location if country_id==2, vce(robust)
outreg2 using "$output\02_supplemental\tableS8_additional_identity", drop(i.location i.assistant)  adjr2 dec(2) word append
*Vietnam only
reg z_identity extreme2 extreme3 $socio_economic $damages i.location if country_id==3, vce(robust)
outreg2 using "$output\02_supplemental\tableS8_additional_identity", drop(i.location i.assistant)  adjr2 dec(2) word append


* Table S9.	Additional regressions: Place dependence (z-score)
*without controlling for imbalances across groups and damages
reg z_dependence extreme2 extreme3 i.location, vce(robust)
outreg2 using "$output\02_supplemental\tableS9_additional_dependence", drop(i.location)  adjr2  dec(2) word replace
* as plotted in main paper
reg z_dependence extreme2 extreme3 $socio_economic $damages i.location, vce(robust)
outreg2 using "$output\02_supplemental\tableS9_additional_dependence", drop(i.location)  adjr2  dec(2) word append
* including interviewer FE
reg z_dependence extreme2 extreme3 $socio_economic $damages i.location i.assistant, vce(robust)
outreg2 using "$output\02_supplemental\tableS9_additional_dependence", drop(i.location i.assistant)  adjr2  dec(2) word append
*Bangladesh only
reg z_dependence extreme2 extreme3 $socio_economic $damages i.location if country_id==2, vce(robust)
outreg2 using "$output\02_supplemental\tableS9_additional_dependence", drop(i.location i.assistant)  adjr2  dec(2) word append
*Vietnam only
reg z_dependence extreme2 extreme3 $socio_economic $damages i.location if country_id==3, vce(robust)
outreg2 using "$output\02_supplemental\tableS9_additional_dependence", drop(i.location i.assistant)  adjr2  dec(2) word append


* Table S10.	 SURE models place attachment
* accounting for the interdependence between place identity and place dependence is to allow for some correlation in the unobserved components of both outcomes. We do so by estimating both equations using the SURE regression method.
sureg (z_identity extreme2 extreme3 $socio_economic $damages i.location) (z_dependence extreme2 extreme3 $socio_economic $damages i.location)
outreg2 using "$output\02_supplemental\tableS10_SURE_attachment", drop(i.location)  adjr2  dec(2) word append


* Table S11.	Tobit models: Accounting for censoring of measures
*Risk
tobit risk_aversion_norm extreme2 extreme3 $socio_economic $damages  i.location i.assistant, vce(robust) ll(0) ul(1)
local R = e(r2_p)
outreg2 using "$output\02_supplemental\tableS11_accounting_censoring", drop(i.location i.assistant) addstat("Pseudo R-Squared", `R') adec(2) dec(2) word replace
*Identity
tobit place_identity_norm extreme2 extreme3 $socio_economic $damages  i.location, vce(robust) ll(0) ul(1)
local R = e(r2_p)
outreg2 using "$output\02_supplemental\tableS11_accounting_censoring", drop(i.location i.assistant) addstat("Pseudo R-Squared", `R') adec(2) dec(2) word append
*Dependence
tobit place_dependence_norm extreme2 extreme3 $socio_economic $damages  i.location, vce(robust) ll(0) ul(1)
local R = e(r2_p)
outreg2 using "$output\02_supplemental\tableS11_accounting_censoring", drop(i.location i.assistant) addstat("Pseudo R-Squared", `R') adec(2) dec(2) word append


* Table S12.	Accounting for count structure of measures
*Bangladesh: Staircase method -> use poisson or negative binomial regrresion to account for count data structure
poisson survey_risk extreme2 extreme3 $damages $socio_economic i.location i.assistant, vce(robust)
estat gof // not the best fit for poisson regression
local R = e(r2_p)
outreg2 using "$output\02_supplemental\tableS12_count_data_models", drop(i.location i.assistant) addstat("Pseudo R-Squared", `R') adec(2) dec(2) word  replace

nbreg survey_risk extreme2 extreme3 $damages $socio_economic i.location i.assistant, vce(robust)
local R = e(r2_p)
outreg2 using "$output\02_supplemental\tableS12_count_data_models", drop(i.location i.assistant) addstat("Pseudo R-Squared", `R') adec(2) dec(2) word  append

*Additonal given the bimodal distribution we use a probit regression
gen risk_bd = 0 if survey_risk <17
replace risk_bd = 1 if survey_risk >=17
replace risk_bd = . if country_id!=2

probit risk_bd extreme2 extreme3 $damages $socio_economic i.location i.assistant, vce(robust) 
local R = e(r2_p)
margins, dydx(*) post
outreg2 using "$output\02_supplemental\tableS12_count_data_models", drop(i.location i.assistant) addstat("Pseudo R-Squared", `R') adec(2) dec(2) word  append

*Vietnam: investment decision only took 11 different values --> poisson or negative binomial regression
poisson risk extreme2 extreme3 $damages $socio_economic i.location i.assistant, vce(robust)
estat gof // not the best fit for poisson regression
local R = e(r2_p)
outreg2 using "$output\02_supplemental\tableS12_count_data_models", drop(i.location i.assistant) addstat("Pseudo R-Squared", `R') adec(2) dec(2) word  append

nbreg risk extreme2 extreme3 $damages $socio_economic i.location i.assistant, vce(robust)
local R = e(r2_p)
outreg2 using "$output\02_supplemental\tableS12_count_data_models", drop(i.location i.assistant) addstat("Pseudo R-Squared", `R') adec(2) dec(2) word  append

*Place identity
poisson place_identity_norm extreme2 extreme3 $damages $socio_economic i.location, vce(robust) 
estat gof
local R = e(r2_p)
outreg2 using "$output\02_supplemental\tableS12_count_data_models", drop(i.location i.assistant) addstat("Pseudo R-Squared", `R') adec(2) dec(2) word

*Place dependence
poisson place_dependence_norm extreme2 extreme3 $damages $socio_economic i.location, vce(robust) 
estat gof
local R = e(r2_p)
outreg2 using "$output\02_supplemental\tableS12_count_data_models", drop(i.location i.assistant) addstat("Pseudo R-Squared", `R') adec(2) dec(2) word  append


* Table S13.	Binary specification of self-reported hazards variable (yes / no)
* Risk
reg z_risk2 exp_extreme number_extremes $socio_economic $damages i.location, vce(robust)
outreg2 using "$output\02_supplemental\tableS13_binary_extremes", drop(i.location) adjr2 dec(2) word replace
* Identity
reg z_identity exp_extreme number_extremes  $socio_economic $damages i.location, vce(robust)
outreg2 using "$output\02_supplemental\tableS13_binary_extremes", drop(i.location) adjr2 dec(2) word  append
* Dependence
reg z_dependence exp_extreme number_extremes  $socio_economic $damages i.location, vce(robust)
outreg2 using "$output\02_supplemental\tableS13_binary_extremes", drop(i.location) adjr2 dec(2) word append
* Aspirations
probit migrate_abroad  exp_extreme number_extremes  $socio_economic  $damages i.location, vce(robust)
local R = e(r2_p)
margins, dydx(*) post
outreg2 using "$output\02_supplemental\tableS13_binary_extremes", drop(i.location i.assistant) addstat("Pseudo R-Squared", `R') adec(2) dec(2) word append


* Table S14.	Preferences robustness check with aggregate measure of hazards
* Risk
reg z_risk2 mean_extremes $socio_economic $damages i.country_id, cluster(location) vce(bootstrap, reps(500))
outreg2 using "$output\02_supplemental\tableS14_mean_extremes", drop(i.location)  adjr2  dec(2) word replace
* Identity
reg z_identity mean_extremes $socio_economic $damages i.country_id, cluster(location) vce(bootstrap, reps(500))
outreg2 using "$output\02_supplemental\tableS14_mean_extremes", drop(i.location)  adjr2  dec(2) word append
* Dependence
reg z_dependence mean_extremes $socio_economic $damages i.country_id, cluster(location) vce(bootstrap, reps(500))
outreg2 using "$output\02_supplemental\tableS14_mean_extremes", drop(i.location)  adjr2  dec(2) word append
* throughout all specifications with aggregate information the results on risk are robust, while the findings for place attachment are not


* Table S15.	Excluding all migrants in our sample
* Risk
reg z_risk2 extreme2 extreme3 $socio_economic $damages i.location if village_same==1, vce(robust)
outreg2 using "$output\02_supplemental\tableS15_without_migrants", drop(i.location)  adjr2  dec(2) word replace
* Identity
reg z_identity extreme2 extreme3 $socio_economic $damages i.location if village_same==1, vce(robust)
outreg2 using "$output\02_supplemental\tableS15_without_migrants", drop(i.location) adjr2 dec(2) word  append
* Dependence
reg z_dependence extreme2 extreme3 $socio_economic $damages i.location if village_same==1, vce(robust)
outreg2 using "$output\02_supplemental\tableS15_without_migrants", drop(i.location i.assistant) adjr2 dec(2) word  append
* Aspirations
probit migrate_abroad extreme2 extreme3 $socio_economic  $damages i.location  if village_same==1, vce(robust)
local R = e(r2_p)
margins, dydx(*) post
outreg2 using "$output\02_supplemental\tableS15_without_migrants", drop(i.location i.assistant) addstat("Pseudo R-Squared", `R') adec(2) dec(2) word  append


* Table S16.	Determinants of migration aspirations across groups
* already saved in main manuscript part of the do-file


** Table S17.	Heterogeneous effects for migration aspirations depending on preferences
*risk
twoway (scatter migrate_abroad z_risk2, msym(oh) jitter(3)) (lfit migrate_abroad z_risk2 if t_extremes==0) (lfit migrate_abroad z_risk2 if t_extremes==1)  (lfit migrate_abroad z_risk2 if t_extremes==2), legend(order(2 "none" 3 "1 or 2" 4 "3 and more"))
reg migrate_abroad t_extremes##c.z_risk2 z_identity z_dependence $socio_economic $damages  i.country_id, vce(robust)
testparm i.t_extremes##c.z_risk2
*overall the interaction with risk preferences is significant
local F1 = r(p)
outreg2 using "$output\02_supplemental\tableS17_interaction_model", drop()  addstat("Adjusted R-squared", e(r2_a), "Joint F-test interaction", `F1') adec(2) dec(2) word  replace
margins t_extremes, dydx(z_risk2)
quietly margins t_extremes, at(z_risk2=(-1.45(0.5)1))
marginsplot, recast(line) noci addplot(scatter migrate_abroad z_risk2, jitter(3) msym(oh))
margins rb2.t_extremes, dydx(z_risk2)
margins, dydx(t_extremes) at(z_risk2=(-1.45(0.5)1)) vsquish
marginsplot, recast(line) recastci(rarea) yline(0)

*place identity
twoway (scatter migrate_abroad place_identity_norm, msym(oh) jitter(3)) (lfit migrate_abroad place_identity_norm if t_extremes==0) (lfit migrate_abroad place_identity_norm if t_extremes==1)  (lfit migrate_abroad place_identity_norm if t_extremes==2), legend(order(2 "none" 3 "1 or 2" 4 "3 and more")) 
reg migrate_abroad t_extremes##c.z_identity z_risk2 z_dependence $socio_economic $damages  i.country_id, vce(robust)
testparm i.t_extremes##c.z_identity
*overall the interaction with place identity is significant
local F1 = r(p)
outreg2 using "$output\02_supplemental\tableS17_interaction_model", drop()  addstat("Adjusted R-squared", e(r2_a), "Joint F-test interaction", `F1') adec(2) dec(2) word  append
margins t_extremes, dydx(z_identity)
quietly margins t_extremes, at(z_identity=(0(.1)1))
marginsplot, recast(line) noci addplot(scatter migrate_abroad z_identity, jitter(3) msym(oh))
margins rb2.t_extremes, dydx(z_identity)
margins, dydx(t_extremes) at(z_identity=(0(.1)1)) vsquish
marginsplot, recast(line) recastci(rarea) yline(0)

*place dependence
twoway (scatter migrate_abroad place_dependence_norm, msym(oh) jitter(3)) (lfit migrate_abroad place_dependence_norm if t_extremes==0) (lfit migrate_abroad place_dependence_norm if t_extremes==1)  (lfit migrate_abroad place_dependence_norm if t_extremes==2), legend(order(2 "none" 3 "1 or 2" 4 "3 and more")) 
reg migrate_abroad t_extremes##c.z_dependence z_risk2 z_identity $socio_economic $damages  i.country_id, vce(robust)
testparm i.t_extremes##c.z_dependence
*overall the interaction with place dependence is insignificant
local F1 = r(p)
outreg2 using "$output\02_supplemental\tableS17_interaction_model", drop()  addstat("Adjusted R-squared", e(r2_a), "Joint F-test interaction", `F1') adec(2) dec(2) word  append
margins t_extremes, dydx(z_dependence)
quietly margins t_extremes, at(z_dependence=(-3(.5)1.5))
marginsplot, recast(line) noci addplot(scatter migrate_abroad z_dependence, jitter(3) msym(oh))
margins rb2.t_extremes, dydx(z_dependence)
margins, dydx(t_extremes) at(z_dependence=(-3(.5)1.5)) vsquish
marginsplot, recast(line) recastci(rarea) yline(0)

// HIGH INCOME DESTINATION
*risk
twoway (scatter aspired_destination4 z_risk2, msym(oh) jitter(3)) (lfit aspired_destination4 z_risk2 if t_extremes==0) (lfit aspired_destination4 z_risk2 if t_extremes==1)  (lfit aspired_destination4 z_risk2 if t_extremes==2), legend(order(2 "none" 3 "1 or 2" 4 "3 and more"))
reg aspired_destination4 t_extremes##c.z_risk2 z_identity z_dependence $socio_economic $damages  i.country_id, vce(robust)
testparm t_extremes#c.z_risk2 
*overall the interaction with risk preferences is not-significant
local F1 = r(p)
outreg2 using "$output\02_supplemental\tableS17_interaction_model", drop()  addstat("Adjusted R-squared", e(r2_a), "Joint F-test interaction", `F1') adec(2) dec(2) word  append
margins t_extremes, dydx(z_risk2)
quietly margins t_extremes, at(z_risk2=(-1(.5)1))
marginsplot, recast(line) noci addplot(scatter migrate_abroad z_risk2, jitter(3) msym(oh))
margins rb2.t_extremes, dydx(z_risk2)
margins, dydx(t_extremes) at(z_risk2=(-1(.5)1)) vsquish
marginsplot, recast(line) recastci(rarea) yline(0)

*place identity
twoway (scatter aspired_destination4 place_identity_norm, msym(oh) jitter(3)) (lfit aspired_destination4 place_identity_norm if t_extremes==0) (lfit aspired_destination4 place_identity_norm if t_extremes==1)  (lfit aspired_destination4 place_identity_norm if t_extremes==2), legend(order(2 "none" 3 "1 or 2" 4 "3 and more")) 
reg aspired_destination4 t_extremes##c.z_identity z_risk2 z_dependence $socio_economic $damages  i.country_id, vce(robust)
testparm t_extremes#c.z_identity 
*overall the interaction with place identity is significant
local F1 = r(p)
outreg2 using "$output\02_supplemental\tableS17_interaction_model", drop()  addstat("Adjusted R-squared", e(r2_a), "Joint F-test interaction", `F1') adec(2) dec(2) word  append
margins t_extremes, dydx(z_identity)
quietly margins t_extremes, at(z_identity=(-4.5(.5)1))
marginsplot, recast(line) noci addplot(scatter migrate_abroad z_identity, jitter(3) msym(oh))
margins rb2.t_extremes, dydx(z_identity)
margins, dydx(t_extremes) at(z_identity=(-4.5(.5)1)) vsquish
marginsplot, recast(line) recastci(rarea) yline(0)

*place dependence
twoway (scatter aspired_destination4 place_dependence_norm, msym(oh) jitter(3)) (lfit aspired_destination4 place_dependence_norm if t_extremes==0) (lfit aspired_destination4 place_dependence_norm if t_extremes==1)  (lfit migrate_abroad place_dependence_norm if t_extremes==2), legend(order(2 "none" 3 "1 or 2" 4 "3 and more")) 
reg aspired_destination4 t_extremes##c.z_dependence z_risk2 z_identity $socio_economic $damages  i.country_id, vce(robust)
testparm t_extremes#c.z_dependence 
*overall the interaction with place dependence is insignificant
local F1 = r(p)
outreg2 using "$output\02_supplemental\tableS17_interaction_model", drop()  addstat("Adjusted R-squared", e(r2_a), "Joint F-test interaction", `F1') adec(2) dec(2) word  append
margins t_extremes, dydx(z_dependence)
quietly margins t_extremes, at(z_dependence=(-3.5(.5)1.5))
marginsplot, recast(line) noci addplot(scatter migrate_abroad z_dependence, jitter(3) msym(oh))
margins rb2.t_extremes, dydx(z_dependence)
margins, dydx(t_extremes) at(z_dependence=(-3.5(.5)1.5)) vsquish
marginsplot, recast(line) recastci(rarea) yline(0)


* Figure S3.	Predicted relationship between climate hazards and distance to urban center
qui summ urban_distance
gen norm_urban_distance = (urban_distance - r(min)) / (r(max) - r(min))
*median split
egen median_dist_urban = median(urban_distance)
gen d_urban = 0 if urban_distance < median_dist_urban
replace d_urban = 1 if urban_distance >= median_dist_urban
* >= 10km
gen d_urban10 = 0 if urban_distance < 10
replace d_urban10 = 1 if urban_distance >= 10

ttest mean_extremes, by(d_urban)
ttest mean_extremes, by(d_urban10)
reg mean_extremes urban_distance

reg mean_extremes c.urban_distance##c.urban_distance
quietly margins, at(urban_distance=(0(10)80))
marginsplot, recast(line) recastci(rarea) addplot(scatter mean_extremes urban_distance, jitter(3) msym(oh))
gr save "$output\FigureS3_hazard_urban_distance.gph", replace
gr export "$output\02_supplemental\FigureS3_hazard_urban_distance.tif", replace width(3465)


* Table S18.	Heterogeneous effects for migration aspirations depending on distance to urban centers
*median split
reg aspired_destination1 i.t_extremes##i.d_urban $socio_economic $damages i.country_id, vce(robust)
testparm i.t_extremes##i.d_urban
local F1 = r(p)
outreg2 using "$output\02_supplemental\tableS18_heterogeneous_aspirations_by_distance_urban", drop()  addstat("Adjusted R-squared", e(r2_a), "Joint F-test interaction",`F1') adec(2) dec(2) word replace 
reg aspired_destination2 i.t_extremes##i.d_urban  $socio_economic $damages i.country_id, vce(robust)
testparm i.t_extremes##i.d_urban
local F1 = r(p)
outreg2 using "$output\02_supplemental\tableS18_heterogeneous_aspirations_by_distance_urban", drop()  addstat("Adjusted R-squared", e(r2_a), "Joint F-test interaction",`F1') adec(2) dec(2) word append 
reg aspired_destination3 i.t_extremes##i.d_urban  $socio_economic $damages i.country_id, vce(robust)
testparm i.t_extremes##i.d_urban
local F1 = r(p)
outreg2 using "$output\02_supplemental\tableS18_heterogeneous_aspirations_by_distance_urban", drop()  addstat("Adjusted R-squared", e(r2_a), "Joint F-test interaction",`F1') adec(2) dec(2) word append 
reg aspired_destination4 i.t_extremes##i.d_urban  $socio_economic $damages i.country_id, vce(robust)
testparm i.t_extremes##i.d_urban
local F1 = r(p)
outreg2 using "$output\02_supplemental\tableS18_heterogeneous_aspirations_by_distance_urban", drop()  addstat("Adjusted R-squared", e(r2_a), "Joint F-test interaction",`F1') adec(2) dec(2) word append 

*robustness check with distance to urban <10km
reg aspired_destination1 i.t_extremes##i.d_urban10 $socio_economic $damages i.country_id, vce(robust)
testparm i.t_extremes##i.d_urban10
local F1 = r(p)
outreg2 using "$output\02_supplemental\tableS18_heterogeneous_aspirations_by_distance_urban", drop()  addstat("Adjusted R-squared", e(r2_a), "Joint F-test interaction",`F1') adec(2) dec(2) word append 
reg aspired_destination2 i.t_extremes##i.d_urban10  $socio_economic $damages i.country_id, vce(robust)
testparm i.t_extremes##i.d_urban10
local F1 = r(p)
outreg2 using "$output\02_supplemental\tableS18_heterogeneous_aspirations_by_distance_urban", drop()  addstat("Adjusted R-squared", e(r2_a), "Joint F-test interaction",`F1') adec(2) dec(2) word append 
reg aspired_destination3 i.t_extremes##i.d_urban10  $socio_economic $damages i.country_id, vce(robust)
testparm i.t_extremes##i.d_urban10
local F1 = r(p)
outreg2 using "$output\02_supplemental\tableS18_heterogeneous_aspirations_by_distance_urban", drop()  addstat("Adjusted R-squared", e(r2_a), "Joint F-test interaction",`F1') adec(2) dec(2) word append 
reg aspired_destination4 i.t_extremes##i.d_urban10  $socio_economic $damages i.country_id, vce(robust)
testparm i.t_extremes##i.d_urban10
local F1 = r(p)
outreg2 using "$output\02_supplemental\tableS18_heterogeneous_aspirations_by_distance_urban", drop()  addstat("Adjusted R-squared", e(r2_a), "Joint F-test interaction",`F1') adec(2) dec(2) word append 

*continous normalized distance to urban centers
reg aspired_destination1 i.t_extremes##c.norm_urban_distance $socio_economic $damages i.country_id, vce(robust)
testparm i.t_extremes##i.norm_urban_distance
local F1 = r(p)
outreg2 using "$output\02_supplemental\tableS18_heterogeneous_aspirations_by_distance_urban", drop()  addstat("Adjusted R-squared", e(r2_a), "Joint F-test interaction",`F1') adec(2) dec(2) word append 
reg aspired_destination2 i.t_extremes##c.norm_urban_distance $socio_economic $damages i.country_id, vce(robust)
testparm i.t_extremes##i.norm_urban_distance
local F1 = r(p)
outreg2 using "$output\02_supplemental\tableS18_heterogeneous_aspirations_by_distance_urban", drop()  addstat("Adjusted R-squared", e(r2_a), "Joint F-test interaction",`F1') adec(2) dec(2) word append 
reg aspired_destination3 i.t_extremes##c.norm_urban_distance $socio_economic $damages i.country_id, vce(robust)
testparm i.t_extremes##i.norm_urban_distance
local F1 = r(p)
outreg2 using "$output\02_supplemental\tableS18_heterogeneous_aspirations_by_distance_urban", drop()  addstat("Adjusted R-squared", e(r2_a), "Joint F-test interaction",`F1') adec(2) dec(2) word append 
reg aspired_destination4 i.t_extremes##c.norm_urban_distance $socio_economic $damages i.country_id, vce(robust)
testparm i.t_extremes##i.norm_urban_distance
local F1 = r(p)
outreg2 using "$output\02_supplemental\tableS18_heterogeneous_aspirations_by_distance_urban", drop()  addstat("Adjusted R-squared", e(r2_a), "Joint F-test interaction",`F1') adec(2) dec(2) word append 




***SECTION S4	International migration aspirations, likelihood and reasons
* Figure S5.	Migration likelihood and financial feasibility
*PANEL A:
lab def likely 1 "Very unlikely (<0.2)" 2 "Neither (>=0.2 <0.8)" 3 "Very likely (>=0.8)", replace
lab val likelihood_next3y likely
* Migration Likelihood in the next 3 years?
tab likelihood_next3y 
*Only 6.3% (n=22) perceive it as very likely to move abroad in the next three years considering the legal and financial obstacles, On the other hand, 71.4% perceive it as very unlikely (n=262) and 22.3% as neither very likely nor very unlikely (n=82)

mylabels 0(20)100, myscale(@) local(pctlabel) suffix("%")
catplot likelihood_next3y if costliness_destinations!=0, over(costliness_destinations, label(labsize(8pt))) asyvar  percent(costliness_destinations) stack  yla(`pctlabel') bar(1, bcolor(538r)) title("{bf:a  }Likelihood of migration in the next 3 years", size(10pt))  bar(2, bcolor(538y))  bar(3, bcolor(538g))  blabel(bar, format(%9.0f) size(8pt) pos(center))  l1title("")  b1title("") legend(rows(1)) xsize(4) ysize(2.5)
gr save  "$output\likelihood.gph", replace

tab likelihood_next3y mr_abroad if ma_afford_hhsize_adj==1
tab likelihood_next3y mr_abroad if ma_afford_hhsize_adj==1 & ma_reason_rel==1
*Only one respondents perceives to be able to afford movement, has a network connection and does not assess the legal requirements as “complicated”. 
ranksum likelihood_next3y, by(ma_reason_rel)
ttest likelihood_next3y, by(ma_reason_rel)

// PANEL B
bysort costliness_destination: sum asset_sum, detail
*no:  median 20.619
*yes: median 20.882
ttest asset_sum, by(migrate_abroad)
ranksum asset_sum, by(migrate_abroad)
* Respondents with no intention to migrate internationally are not significantly less wealthy than respondents with the intention to migrate (Mann-Whitney U-Test, z=-.83, p=.41)

vioplot asset_sum if ma_region!=7 & asset_sum <100000, over(costliness_destination)  horizontal median(msymbol(D) mcolor(white)) obs title("{bf:b  }Assets owned by aspired destination", size(7pt)) xla(0(20000)100000, nogrid) xtitle("Total asset value (PPP adjusted)", size(6pt)) 
gr save  "$output\value_assets.gph", replace

// PANEL C
separate asset_sum_adjusted_hh, by(costliness_destinations) veryshortlabel gen(perceived_affordability)
tab ma_afford_hhsize_adj 
pwcorr ia_migration_costs avg_mc_abroad
graph twoway (scatter  perceived_affordability1 perceived_affordability2 perceived_affordability3  mc_abroad if mc_abroad < 40000 & (perceived_affordability1  < 40000 | perceived_affordability2 < 40000 | perceived_affordability3 < 40000),   msymbol(O D S) mcolor(538g%70 538y%50 538r%50)) (function y = x if mc_abroad < 40000, ra(mc_abroad) clpat(dash) lwidth(medium) lcolor(black)), title("{bf:c  }Perceived individual affordability") l1title("Total asset value per person (in PPP)", size(mediumsmall)) b1title("Perceived individual migration costs (in PPP)",size(mediumsmall))  xtitle() yla(0(10000)40000, nogrid) xla(0(10000)40000, nogrid) legend(rows(2) lab(4 "45° line"))
gr save  "$output\perceived_affordability.gph", replace

*PANEL D
* independent of aspirations: How many respondents could afford moving abroad? to high cost and low-cost destinations
gen likelihood_new = likelihood_next3y
replace likelihood_new = 0 if costliness_destinations==0
lab def likely2 0 "No Aspiration" 1 "Very unlikely (<0.2)" 2 "Neither (>=0.2 <0.8)" 3 "Very likely (>=0.8)", replace
lab val likelihood_new likely2
tab afford_destination likelihood_new, chi2

mylabels 0(20)100, myscale(@) local(pctlabel) suffix("%")
catplot afford_destination, over(costliness_destinations, label(labsize(8pt))) asyvar percent(costliness_destinations) stack  yla(`pctlabel') bar(1, bcolor(538r)) title("{bf:d } What moves could respondents afford?", size(10pt))  bar(1, bcolor(538b)) bar(2, bcolor(538g)) bar(3, bcolor(538y)) bar(4, bcolor(538r))  blabel(bar, format(%9.0f) size(8pt) pos(center))  l1title("")  b1title("") legend(rows(1)) xsize(4) ysize(2.5)
gr save  "$output\affordable_moves2.gph", replace

*combine panels to one graph
gr combine "$output\likelihood.gph" "$output\value_assets.gph"  "$output\perceived_affordability.gph" "$output\affordable_moves2.gph", cols(2) scale(1)  xsize(5) ysize(3) graphregion(margin(zero))
gr save  "$output\figureS5_migration_likelihood_feasibility.gph", replace
gr export "$output\02_supplemental\figureS5_migration_likelihood_feasibility.tif", replace width(3460)


* Table S19.	Reasons and steps for international migration by destination region
*set all reponses to missing if the respondent did not name a place to move abroad (as all answers are related to that place...)
global m_tab1  mr_abroad ma_likeliness mc_abroad asset_sum_adjusted_hh ma_afford_hhsize_adj ma_reason_relig ma_reason_econ ma_reason_rel ma_reason_prox ma_reason_lifesat m_steps_passport m_steps_visa m_steps_language m_steps_money m_steps_id m_steps_ticket m_steps_none

estpost tabstat $m_tab1 if ma_region < 7, by(ma_region) statistics(mean count) columns(statistics)
esttab using "$output\02_supplemental\tableS19_reasons_steps_costs.rtf", main(mean) b(%9.2f) nostar unstack  nonote replace

bysort country_id: tab mc_abroad if ma_region1==1
*56% of respondents in Bangladesh think it costs less than $5000 to move to North America
bysort country_id: tab mc_abroad if ma_region2==1
*30% of respondents in Bangladesh think it costs less than $5000 to move to Europe


bysort t_extremes: sum mean_extremes
* problems with this measure: even respondents that did not report the experience of any hazards in the past five years get assigned on average 2.6 hazards - which is similar to the average among respondents who reported 1 or 2 hazards --> indication that the reported hazards are not covariate shocks that affect the entire community (only to some degree) but rather idiosyncratic

