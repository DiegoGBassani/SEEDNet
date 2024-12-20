
// Project: This code is part of the manuscript "Multi-country settlement level database of health indicators and covariate-free estimation method"
// Manuscript authors: Amir Hossein Darooneh, Jean-Luc Kortenaar, Celine Goulart, Katie McLaughlin, Sean Cornelius, and Diego G. Bassani
// Suggested citation: Darooneh, A.H., et al. Multi-country settlement level database of health indicators and covariate-free estimation method. (2024)
// Program: Figures describing K-fold Validation results
// Author: Diego G Bassani, The Hospital for Sick Children
// Date Created: 2024-07-16
// Last Updated:  2024-07-22
// Description: Produces plots comparing predicted versus observed values for selected indicators by settlemet, by survey (country_year)
// ###################
// Attributions:
// List any attributions
// ###################
// Notes:
	// Legend:
	// * description of what the code that follows does
	// *** commented out line of code (not running)
	// ***************************** ***************************** ***************************** 
	// Lines above and below (as seen here) are used to mark beggining and end of code used for 
	// plotting, or setting locals and globals
	// ***************************** ***************************** ***************************** 
// ###################

***************************** ***************************** ***************************** 
cap mkdir "$path/stata_gph_files/KFOLD"
cap mkdir "$path/stata_png_files/KFOLD"
***************************** ***************************** ***************************** 
global datafiles "$path/stata_data_files"
global inputfiles "$path/input_files"
global graphs "$path/stata_gph_files/KFOLD"
global pngs "$path/stata_png_files/KFOLD"
global grec "$path/grec_files"
global logs "$path/stata_log_files"
global tables "$path/tables"
***************************** ***************************** ***************************** 

* Import csv file with out-of-sample leave-one-out cross validation output
import delimited "$inputfiles/kfold_validation_diff.csv", clear

* Create survey name variable by concatenating country name and year of survey

egen ssurv = concat(country year), punct(-)
tab ssurv
encode ssurv, gen(surv)
tab surv
drop ssurv
label variable surv "Survey (Country-year)" 


* Create numeric version of indicator variable

cap encode country, gen(country_n)
encode indicator, gen(ind)


 * Variable to order indicators in plots
			
			
			gen ind_order = .
			recode ind_order .=1 if strmatch(indicator, "*Electricity*" )
			recode ind_order .=2 if strmatch(indicator, "*Water*" )
			recode ind_order .=3 if strmatch(indicator, "*Salt*" )
			recode ind_order .=4 if strmatch(indicator, "*Women*" )
			recode ind_order .=5 if strmatch(indicator, "*4+*" )
			recode ind_order .=6 if strmatch(indicator, "*Low*" )
			recode ind_order .=7 if strmatch(indicator, "*Breast*" )
			recode ind_order .=8 if strmatch(indicator, "*BCG*" )
			recode ind_order .=9 if strmatch(indicator, "*DTP3*" )
			recode ind_order .=9 if strmatch(indicator, "*DPT3*" )
			recode ind_order .=10 if strmatch(indicator, "*Measles*" )
			recode ind_order .=11 if strmatch(indicator, "*Mosquito*" )
			recode ind_order .=12 if strmatch(indicator, "*ORS*" )
			recode ind_order .=13 if strmatch(indicator, "*Stunting*" )
			recode ind_order .=14 if strmatch(indicator, "*Wasting*" )
			recode ind_order .=15 if strmatch(indicator, "*Anemia in Children*" )
			
			label def ind_order ///
			1 "Access to Electricity" ///
            2 "Access to Improved Water Source" ///
            3 "Iodized Salt Intake in Household" ///	   
			4 "Prevalence of any Anemia in Women" ///	   
			5 "Antenatal Care Visits (4+) during Pregnancy" ///
			6 "Low Birth Weight Prevalence" ///		   
			7 "Exclusive Breastfeeding (0-6 months)" ///
			8 "BCG Immunization (12-23 months)" ///
			9 "DPT3 Immunization (12-23 months)" ///
			10 "Measles Immunization (12-23 months)" ///
			11 "Use of Mosquito Nets; Children (0-59 months)" ///
			12 "Diarrhea Treatment with ORS (0-59 months)" ///
			13 "Stunting Prevalence (0-59 months)" ///
			14 "Wasting Prevalence (0-59 months)" ///
			15 "Prevalence of Anemia in Children (6-59 months)", replace
			
			label val ind_order ind_order
			label var ind_order "Indicator"
			
**** * labeling validation metrics

cap label var country "Country"
cap label var year "Year"
cap label var indicator "Indicator"
cap label var tot_clust "Total clusters (DHS)"
cap label var num_clust "Total clusters with valid ind. value (DHS)"

cap label var loocv_bias "Bias; pred. and dir. est.; (cluster level)"
cap label var loocv_ratio "Ratio (pred/dir); (cluster level)"
cap label var loocv_mae "Mean Abs. Error; (pred-dir); (cluster level)"
cap label var loocv_rmse "Root Mean Square Error; (pred-dir); (cluster level)"
cap label var loocv_p95 "Pseudo-value of 95% Pred. Int. of LIDW pred.; (cluster level)"

cap label var settl_bias "Bias; pred. and dir. est.; (settl.)"
cap label var settl_rmsd "Root Mean Square Diff. (pred-dir); (settl.)"
cap label var settl_mad "Mean Abs. Diff. (pred-dir); (settl.)"
cap label var settl_ratio "Ratio of ((pred/dir)); (settl.)"
cap label var settl_mad_to_maxpred "MAD/max(LIDW) (pred-dir)/(max(pred)); (settl.)"
cap label var settl_mad_to_maxdhs "MAD/max(DHS) (pred-dir)/(max(dir)); (settl.)"

cap label var adm1_bias "Bias; pred. and dir. est.; (adm.L1)"
cap label var adm1_rmsd "Root Mean Square Error; (pred-dir); (adm.L1)"
cap label var adm1_mad "Mean Abs. Diff. (pred-dir); (adm.L1)"
cap label var adm1_ratio "Ratio of (pred/dir); (adm.L1)"
cap label var adm1_mad_to_maxpred "MAD/max(LIDW) (pred-dir)/(max(pred)); (adm.L1)"
cap label var adm1_mad_to_maxdhs "MAD/max(DHS) (pred-dir)/(max(dir)); (adm.L1)"

cap label var adm2_bias "Bias; pred. and dir. est.; (adm.L2)"
cap label var adm2_rmsd "Root Mean Square Error; (pred-dir); (adm.L2)"
cap label var adm2_mad "Mean Abs. Diff. (pred-dir); (adm.L2)"
cap label var adm2_ratio "Ratio of (pred/dir); (adm.L2)"
cap label var adm2_mad_to_maxpred "Mean Abs. Diff. (pred-dir)/(max(pred)); (adm.L2)"
cap label var adm2_mad_to_maxdhs "Mean Abs. Diff. (pred-dir)/(max(dir)); (adm.L2)"

cap label var country_n "Country"
cap label var ind "Indicator"
cap label var ind_order "Indicator"

cap label var tot_num_sett "Total number of settlements in country"
cap label var tot_dhs_clust "Total number of survey clusters in country"          
cap label var valid_dhs_clust "Number of valid survey clusters (country-indicator pair)"              
cap label var num_dhs_sett "N. of settlements overlapping with any survey clusters"             
cap label var sett_idx "Index of survey settlement"          
cap label var num_dhs_clust_sett "N. of survey clusters overlapping settlement"              
cap label var num_pixels "Settlement area (pixels)"     
     
cap label var dir_est "Direct estimate (LIDW)"       
cap label var kfold_est "K-fold estimate"

cap label var num_settl "Number of Settlements"	
cap label var Bias "Bias; pred. and dir. est."	
cap label var mad "Mean Abs. Diff. (pred-dir)"	
cap label var rmsd	"Root Mean Square Diff. (pred-dir)"

			
**************************************************

* Check for duplicates

duplicates list

* Identify (create flag) indicators whose values are zero across all settlements in the sample

sort ind_order surv 
egen tempmean = mean(dir_est), by(ind_order surv)
gen flag = 1 if tempmean==0
tab flag

label var flag "Indicator is zero for all settlements within a country"
cap drop temp*

* The next step recodes the dir_est and kfold_est from zero to a special missing (.a) if the indicator has not been measured in any settlements in the country (i.e. not available in the original survey)

recode dir_est 0=.a if flag==1
recode kfold_est 0=.a if flag==1

* Note: Not recoding these values from zero to .a will underestimate the error in predictions

* Create variable containing the difference between the direct estimate and the prediction
gen diff = kfold_est - dir_est
recode diff .=0 if (dir_est==0 & kfold_est==0)
label var diff "Difference (predicted-direct)"


* Creates unique ID for all settlements in sample (combined dataset of surveys)
sort surv sett_idx
egen id = group(surv sett_idx)
label var id "Settlement Unique ID"


* Creates a count variable to compute frequencies (used in plots)
gen count=1
label var count "Simple counter for frequencies"


* Compresses dataset

compress

* Merge with survey information (prevalence, s.d., variance, s.e., ratio s.e. to prevalence. )

merge m:1 ind_order surv using "$inputfiles/survey_estimates_indicators.dta"
drop if _merge==2

cap destring prevalence, force replace 
cap destring standarderror, force replace 
cap destring ratioseest, force replace 
cap destring standarddeviation, force replace 
cap destring variance, force replace

* create alternative evaluation metrics

gen sd_prev= standarddeviation/prevalence
label var sd_prev "Ratio S.D./Prevalence"

gen rse = ratioseest*100
label variable rse "Ratio SE/Est (%)"

**************************************************

* Creates derived variables with deciles of settlement size across all surveys (full sample, referred to as 'global')

xtile pix_cat = num_pixels, nquantiles(10)
label var pix_cat "Global Dec. of settlement area (pixels)"

* Resulting distribution can be visualized using these scatterplots

*** /*
colorpalette plasma, n(9) nograph
scatter pix_cat num_pixels, jitter(0.5) yscale() xscale(log) ///
			ylabel(1(1)10) ///
			xlabel(1 4 10 50 100 500 1000 10000 50000) xlab(, angle(vert)) ///
			msymbol(pipe) msize(huge) mlwidth(vvthin) ///
			colorvar(pix_cat) colorlist(`r(p)') colordiscrete clegend(off)
			*graph save "$graphs/pix_cat_distribution.gph", replace   
			graph export "$pngs/pix_cat_distribution.png", replace wid(4000)
*/

* Creates derived variables with deciles of settlement size across all surveys (survey sample, referred to as 'local')

egen pix_cat_loc=xtile(num_pixels), nq(10) by(surv)
label var pix_cat_loc "Local Dec. of settlement area (pixels)"

* Creates derived variables with centiles of settlement size across all surveys (full sample, referred to as 'global')

egen pix_cat_loc_cent = xtile(num_pixels), nquantiles(100) by(surv)
label var pix_cat_loc_cent "Local Cent. of settlement area (pixels)"


* Resulting distribution can be visualized using these scatterplots

*** /*
colorpalette plasma, n(9) nograph
scatter pix_cat_loc num_pixels, jitter(0.5) yscale() xscale(log) ///
			ylabel(1(1)10) ///
			xlabel(1 4 10 50 100 500 1000 10000 50000) xlab(, angle(vert)) ///
			msymbol(pipe) msize(large) mlwidth(vvthin) ///
			colorvar(pix_cat_loc) colorlist(`r(p)') colordiscrete clegend(on) ///
			by(surv, col(5) scale(0.8) note("Note: Marker colors correspond to deciles of global settlement size distribution", size(vvtiny))) ///
			subtitle( , nobox) ///
			ysize(2) xsize(4) 
			graph export "$pngs/pix_cat_loc_distribution.png", replace wid(4000)
*/

* Creates derived variable with settlement area in the log scale (full sample, referred to as 'global')

gen num_pixels_log=log(num_pixels)
label var num_pixels_log "Settlement Area (log)"

* Resulting distribution can be visualized using these scatterplots

*** /*
colorpalette inferno, n(9) nograph
scatter num_pixels_log num_pixels, jitter(0.5) yscale(log) xscale(log) ///
			ylabel(1(1)10) ///
			xlabel(1 4 10 50 100 500 1000 10000 50000) xlab(, angle(vert)) ///
			msymbol(pipe) msize(large) mlwidth(vvthin) ///
			colorvar(pix_cat) colordiscrete colorlist(`r(p)') clegend(off) ///
			by(surv, col(5) scale(0.8) note("Note: Marker colors correspond to deciles of global settlement size distribution", size(vvtiny))) ///
			subtitle( , nobox) ///
			ysize(2) xsize(4)
			graph export "$pngs/num_pix_log_distribution.png", replace wid(4000)
*/

* Creates derived variable categorizing the deciles of settlement area in the log scale (by survey sample, referred to as 'local')

egen quant_log=xtile(num_pixels_log), nq(10) by(surv)
label var quant_log "Local Dec. of Settlement Area (log)"

* Resulting distribution can be visualized using these scatterplots

*** /*
colorpalette plasma, n(9) nograph
scatter quant_log num_pixels, jitter(0.5) yscale() xscale(log) ///
			ylabel(1(1)10) ///
			xlabel(1 4 10 50 100 500 1000 10000 50000) xlab(, angle(vert)) ///
			msymbol(pipe) msize(large) mlwidth(vvthin) ///
			colorvar(quant_log) colorlist(`r(p)') colordiscrete clegend(off) ///
			by(surv, col(5) scale(0.8) note("Note: Marker colors correspond to deciles of global settlement size distribution", size(vvtiny))) ///
			subtitle( , nobox) ///
			ysize(2) xsize(4)
			graph export "$pngs/quant_log_distribution_local.png", replace wid(4000)
*/


* Creates derived variable categorizing the quitiles of settlement area in the log scale (by survey sample, referred to as 'local')


egen quant5_log=xtile(num_pixels_log), nq(5) by(surv)
label var quant5_log "Local Quint. of Settlement Area (log)"

* Resulting distribution can be visualized using these scatterplots

*** /*
colorpalette plasma, n(5) nograph
scatter quant5_log num_pixels, jitter(0.5) yscale() xscale(log) ///
			ylabel(1(1)5) ///
			xlabel(1 4 10 50 100 500 1000 10000 50000) xlab(, angle(vert)) ///
			msymbol(pipe) msize(large) mlwidth(vvthin) ///
			colorvar(quant5_log) colorlist(`r(p)') colordiscrete clegend(off) ///
			by(surv, col(5) scale(0.8) note("Note: Marker colors correspond to deciles of global settlement size distribution", size(vvtiny))) ///
			subtitle( , nobox) ///
			ysize(2) xsize(4)
			graph export "$pngs/quant5_log_distribution_local.png", replace wid(4000)
*/



gen npl=round(num_pixels_log) // **rounded to integers
label var npl "Settlement area in pixels (log; integers)"

* Resulting distribution can be visualized using these scatterplots
*** /*
sort surv num_pixels
colorpalette plasma, n(10) nograph
scatter npl num_pixels, jitter(0.5) yscale(log) xscale(log) ///
			ylabel(1 5 10,) ///
			xlabel(4 10 50 100 500 1000 5000 10000 30000 ,) xlab(, angle(vert)) ///
			msymbol(Oh) msize(large) mlwidth(vvvthin) ///
			colorvar(npl) colorlist(`r(p)') colordiscrete clegend(off) ///
			by(surv, col(5) scale(0.8) note("Note: Marker colors correspond to deciles of global settlement size distribution", size(vvtiny))) ///
			subtitle( , nobox) ///
			ysize(2) xsize(4)
			graph export "$pngs/npl_distribution.png", replace wid(4000)
*/


**************************************************

* Outputs

* Option to turn plot rendering off for increasing processing speed
set graph off


***************************** ***************************** ***************************** 
cd "$grec"

**Figure 10

cap drop freq_sett_tot
egen freq_sett_tot = sum(count), by(npl ind_order)
twoway bar freq_sett_tot npl if ind_order==1, ///
		title("Distribution of Settlements by settlement area", size(vvtiny) color(none)) ///
		subtitle("Total", size(small) color(none)) ///
		xlab(0(1)10, labsize(small)) yscale(log) yscale(r(1)) ///
		ylab(1 10 100 200 400 800 1600 3200 6400 12800 25600 51200, labsize(small)) /// 
		ytitle("Number of settlements (log scale)", size(small)) ///
		ysize(3) xsize(6) ///
		barwidth(0.9) ///
		base(1) ///
		note( , size(vtiny)) 
		graph save "$graphs/settlement_areas_t_log.gph", replace
		graph export "$pngs/settlement_areas_t_log.png", replace wid(5000)
***************************** ***************************** ***************************** 


**Supplementary Figure 2

twoway (scatteri 1 0 1 0, by(surv) mcolor(none)) || (bar freq_sett_tot npl if ind_order==1, ///
		by(surv,  col(5) ///
		title("Distribution of Settlements by area by survey", size(vvtiny) color(none))) ///
		xlab(0(1)10, labsize(small)) /// 
		xtitle("Settlement area in pixels (log)", size(small)) ///
		yscale(log) yscale(r(1)) ///
		ylab(1 10 100 200 400 800 1600 3200 6400 12800 25600 51200, labsize(small)) /// yline(line2) ///
		ytitle("Number of settlements (log scale)", size(small)) ///
		ysize(3) xsize(6) ///
		barwidth(0.9) ///
		base(1) ///
		note( , size(vtiny) color(none)))
		graph play v_loocv_set
		graph play ratio_op_loocv
		graph play hide_legend2
		graph play set_size
		graph save "$graphs/settlement_areas_log.gph", replace
        graph export "$pngs/settlement_areas_log.png", replace wid(5000)		
***************************** ***************************** ***************************** 


* Plots - Supplementary Figures 35 to 49.

***************************** ***************************** ***************************** 


*Scatterplots of Direct Estimates and Predictions by indicator with equations

cap gen dir_est_z=0
cap gen kfold_est_z=0

levelsof surv, local(surv)
foreach s of local surv {
	local st : label (surv) `s'
levelsof ind_order, local(ind_order)
foreach i of local ind_order {
	local vt : label (ind_order) `i'
	capture regress kfold_est dir_est if ind_order==`i' & surv==`s' 
	if c(rc) == 0 { 	// EVERTHING IS OK, PROCEED
	colorpalette matplotlib autumn, n(11) nograph
		aaplot kfold_est dir_est if ind_order==`i' & surv==`s', /// 
					ysize(2) xsize(2.5) /// 
					note(, size(vsmall)) ///
					title("`st'", size(vvsmall)) ///
					msymbol(O) msize(vsmall) mlwidth(vthin) mlcolor(%20) mcolor(%20) ///
					aformat(%9.4f) bformat(%9.4f) cformat(%9.4f) rsqformat(%9.2f) rmseformat(%9.4f) ///
					ylabel(0(0.2)1, labsize(vsmall)) xlabel(0(0.2)1, labsize(vsmall)) ///
					yscale() xscale() ytitle("Predicted estimate" "(K-fold)", size(vsmall)) xtitle("Direct estimate" "(LIDW)", size(vsmall)) ///
					lopts(range(0 1) estopts(nocons) lwidth(thin) lcolor("`r(p6)'")) ///
					backdrop(scatteri 1 1 0 0, connect(l) lcolor(black) lpattern(dot) lwidth(thin) msymbol(i) legend(off))
		graph play eq_rmse
		graph save "$graphs/loocv_eq_`i'_`s'_kfold.gph", replace 
		*graph export "$pngs/loocv_eq_`i'_`s'_kfold.png", replace wid(5000)
	}
	else {  // NO OBSERVATIONS 
	aaplot kfold_est_z dir_est_z if surv==`s',  ///
					ysize(2) xsize(2.5) /// 
					note(, size(vsmall)) ///
					title("`st'", size(vvsmall) color(none)) ///
					msymbol(O) msize(vsmall) mlwidth(vthin) mlcolor(%20) mcolor(%20) ///
					aformat(%9.4f) bformat(%9.4f) cformat(%9.4f) rsqformat(%9.2f) rmseformat(%9.4f) ///
					ylabel(0(0.2)1, labsize(vsmall)) xlabel(0(0.2)1, labsize(vsmall)) ///
					yscale() xscale() ytitle("Predicted estimate" "(K-fold)", size(vsmall)) xtitle("Direct estimate" "(LIDW)", size(vsmall)) ///
					lopts(range(0 1) estopts(nocons) lwidth(thin) lcolor("none")) ///
					backdrop(scatteri 1 1 0 0, connect(l) lcolor(black) lpattern(dot) lwidth(thin) msymbol(i) legend(off))
		graph play eq_rmse
		graph play no_observations
		graph save "$graphs/loocv_eq_`i'_`s'_kfold.gph", replace 
		*graph export "$pngs/loocv_eq_`i'_`s'_kfold.png", replace wid(5000)
			}
		}
	}
***************************** ***************************** ***************************** 

* Combines the individual scatterplots generated in lines above

set graph off
levelsof ind_order, local(ind_order)
foreach i of local ind_order {
	local vt : label (ind_order) `i'
	graph combine "$graphs/loocv_eq_`i'_1_kfold.gph" ///
		"$graphs/loocv_eq_`i'_2_kfold.gph" ///
		"$graphs/loocv_eq_`i'_3_kfold.gph" ///
		"$graphs/loocv_eq_`i'_4_kfold.gph" ///
		"$graphs/loocv_eq_`i'_5_kfold.gph" ///
		"$graphs/loocv_eq_`i'_6_kfold.gph" ///
		"$graphs/loocv_eq_`i'_7_kfold.gph" ///
		"$graphs/loocv_eq_`i'_8_kfold.gph" ///
		"$graphs/loocv_eq_`i'_9_kfold.gph" ///
		"$graphs/loocv_eq_`i'_10_kfold.gph" ///
		"$graphs/loocv_eq_`i'_10_kfold.gph" , col(5) ycommon xcommon title("`vt' by settlement", size(small) color(none))
		graph play combine_eq_sc
		graph save "$graphs/comb_eq_`i'_kfold_nl.gph", replace
        graph export "$pngs/comb_eq_`i'_kfold_nl.png", replace wid(5000)
		}
***************************** ***************************** ***************************** 

***************************** ***************************** ***************************** 

* Combines the individual scatterplots generated in lines above

set graph off
levelsof ind_order, local(ind_order)
foreach i of local ind_order {
	local vt : label (ind_order) `i'
	graph combine "$graphs/loocv_eq_`i'_1_kfold.gph" ///
		"$graphs/loocv_eq_`i'_2_kfold.gph" ///
		"$graphs/loocv_eq_`i'_3_kfold.gph" ///
		"$graphs/loocv_eq_`i'_4_kfold.gph" ///
		"$graphs/loocv_eq_`i'_5_kfold.gph" ///
		"$graphs/loocv_eq_`i'_6_kfold.gph" ///
		"$graphs/loocv_eq_`i'_7_kfold.gph" ///
		"$graphs/loocv_eq_`i'_8_kfold.gph" ///
		"$graphs/loocv_eq_`i'_9_kfold.gph" ///
		"$graphs/loocv_eq_`i'_10_kfold.gph" ///
		"$graphs/loocv_eq_`i'_10_kfold.gph" , col(5) ycommon xcommon title("`vt' by settlement", size(small) color())
		graph play combine_eq_sc
		graph save "$graphs/comb_eq_`i'_kfold.gph", replace
        graph export "$pngs/comb_eq_`i'_kfold.png", replace wid(5000)
		}
***************************** ***************************** ***************************** 



cap drop freq
