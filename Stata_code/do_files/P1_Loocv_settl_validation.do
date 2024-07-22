// Project: This code is part of the manuscript "Multi-country settlement level database of health indicators and covariate-free estimation method"
// Manuscript authors: Amir Hossein Darooneh, Jean-Luc Kortenaar, Celine Goulart, Katie McLaughlin, Sean Cornelius, and Diego G. Bassani
// Suggested citation: Darooneh, A.H., et al. Multi-country settlement level database of health indicators and covariate-free estimation method. (2024)
// Program: Plotting validation metrics for initial assessment _ Settlement level LOOCV; Produces plots comparing predicted versus observed values for selected indicators by settlemet, by survey (country_year)
// Author: Diego G Bassani, The Hospital for Sick Children
// Date Created: 2024-05-15
// Last Updated:  2024-06-19
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

cap mkdir "$path/stata_gph_files/Settlement_OOS_LOOCV"
cap mkdir "$path/stata_png_files/Settlement_OOS_LOOCV"

***************************** ***************************** ***************************** 

global datafiles "$path/stata_data_files"
global inputfiles "$path/input_files"
global graphs "$path/stata_gph_files/Settlement_OOS_LOOCV"
global pngs "$path/stata_png_files/Settlement_OOS_LOOCV"
global grec "$path/grec_files"
global logs "$path/stata_log_files"
global tables "$path/tables"
global tabout "$path/Tabout"

***************************** ***************************** ***************************** 

* Import csv file with out-of-sample leave-one-out cross validation output
import delimited "$inputfiles/LOOCV_SETT_DIFF.csv", clear

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
cap label var idx_dhs_sett_cntry "Index of survey settlement"          
cap label var num_dhs_clust_sett "N. of survey clusters overlapping settlement"              
cap label var num_pixels "Settlement area (pixels)"     
     
cap label var dir_est "Direct estimate (LIDW; all survey clusters)"       
cap label var loocv_est "Predicted estimate (Out-of-Sample; overlapping survey clusters removed)"

cap label var num_settl "Number of Settlements; (Out-of-Sample Validation)"	
cap label var Bias "Bias; pred. and dir. est.; (Out-of-Sample; settl.)"	
cap label var mad "Mean Abs. Diff. (pred-dir); (Out-of-Sample; settl.)"	
cap label var rmsd	"Root Mean Square Diff. (pred-dir); (Out-of-Sample; settl.)"

			
**************************************************

* Check for duplicates

duplicates list



* Identify (create flag) indicators whose values are zero across all settlements in the loocv sample

sort ind_order surv 
egen tempmean = mean(dir_est), by(ind_order surv)
gen flag = 1 if tempmean==0
tab flag

label var flag "Indicator is zero for all settlements within a country"
cap drop temp*

* The next step recodes the dir_est and loocv_est from zero to a special missing (.a) if the indicator has not been measured in any settlements in the country (i.e. not available in the original survey)

recode dir_est 0=.a if flag==1
recode loocv_est 0=.a if flag==1

* Note: Not recoding these values from zero to .a will underestimate the error in predictions


* Create variable containing the difference between the direct estimate and the loocv prediction
gen diff = loocv_est - dir_est
recode diff .=0 if (dir_est==0 & loocv_est==0)
label var diff "Difference (predicted-direct)"

* Create variable containing the ratio between the direct estimate and the loocv prediction

gen ratio = loocv_est/dir_est
recode ratio .=1 if (diff==0 & flag==.)
label var ratio "Ratio (pred/dir)"


* Uses lowest observed value of dir_est or loocv_est to produce a ratio where ratio is missing (due to division of 0/x or of x/0)

gen temp_loocv_est = log(1+loocv_est) // if (loocv_est==0 | dir_est==0)
gen temp_dir_est = log(1+dir_est) // if (loocv_est==0 | dir_est==0)
gen alt_ratio = temp_loocv_est/temp_dir_est

su dir_est if (dir_est!=. & dir_est>0 & loocv_est!=. & loocv_est!=0 & flag==.)
replace alt_ratio = log(loocv_est)/log(`r(min)') if alt_ratio==. & dir_est==0

su loocv_est if (loocv_est!=. & loocv_est>0 & dir_est!=. & dir_est!=0 & flag==.)
replace alt_ratio = log(`r(min)')/log(dir_est) if dir_est!=0 & loocv_est==0 & ratio==0

sort ratio
order diff dir_est temp_dir_est loocv_est temp_loocv_est  ratio alt_ratio 
gen ratio_flag = 1 if ratio==.
replace ratio_flag = 2 if ratio==. & alt_ratio!=.
replace ratio = alt_ratio if ratio==.
replace ratio = alt_ratio if ratio==0

order diff dir_est temp_dir_est loocv_est temp_loocv_est  ratio alt_ratio ratio_flag
label var alt_ratio "Alt. Ratio (pred/dir)"

drop temp_dir_est temp_loocv_est

label var ratio_flag "Alternative ratio calculation "

* Creates unique ID for all settlements in sample (combined dataset of surveys)
sort surv idx_dhs_sett_cntry
egen id = group(surv idx_dhs_sett_cntry)
label var id "Settlement Unique ID"


* Generate variable for plots labeled as number of survey clusters excluded from estimation sample. This is the same variable as num_dhs_clust_sett

gen num_dhs_clust = num_dhs_clust_sett
label var num_dhs_clust "Number of survey clusters excluded from estimation sample"


* Calculates the number of expected observations after expanding the dataset in the following (reshape) step.

quietly {
	su id
    return list
    local n = `r(max)'
    su ind_order
    return list
    local i = `r(max)'
}

* The result of di calculation below is the number of observations that the next step should generate

di `i'*`n'

* Expands the dataset, creating a settlement id with missing values for the indicators that are missing as long as the settlement has a valid value (non-missing) value for any other indicator, this step should increase the number of observations from r(N) from id variable to the product of r(max) of id variable and r(max) of indicators


aorder
order id ind_order
reshape wide ///
alt_ratio-year ///
, i(id) j(ind_order)
reshape long

* Check if resulting number of observations matches result above.

* Repeating the code here works as welll to check the number of observation in the dataset matches the expected number

//* Repeated code: 

* Calculates the number of expected observations after expanding the dataset in the following (reshape) step.

quietly {
	su id
    return list
    local n = `r(max)'
    su ind_order
    return list
    local i = `r(max)'
}
* The result of di calculation below is the number of observations that the next step should generate

di `i'*`n'

//* End of repeated code


* Fills in missing information for the expanded lines in the dataset using only the fixed information about the settlement

sort id num_dhs_sett
foreach var in country idx_dhs_sett_cntry num_dhs_clust num_dhs_clust_sett num_dhs_sett num_pixels surv tot_dhs_clust tot_num_sett year {
	replace `var'=`var'[_n-1] if missing(`var')
}

* Recodes the count of valid clusters to 0 for the expanded lines (placeholders for settlements without a value for a given indicator)

recode valid_dhs_clust .=0


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

****Use these to select most complete version of num_dhs_clust

gen num_dhs_clust_log=log(num_dhs_clust)
label var num_dhs_clust_log "Number of survey clusters excluded from estimation sample (log)"

* Resulting distribution can be visualized using these scatterplots

*** /*
sort surv num_pixels
colorpalette plasma, n(10) nograph
scatter num_dhs_clust_log num_pixels, jitter(0.5) yscale() xscale(log) ///
			ylabel( ,) ///
			xlabel(4 10 50 100 500 1000 5000 10000 30000 ,) xlab(, angle(vert)) ///
			msymbol(Oh) msize(large) mlwidth(vvvthin) ///
			colorvar(num_dhs_clust_log) colorlist(`r(p)') colordiscrete clegend(off) ///
			by(surv, col(5) scale(0.8) note("Note: Marker colors correspond to deciles of global settlement size distribution", size(vvtiny))) ///
			subtitle( , nobox) ///
			ysize(2) xsize(4)
			graph export "$pngs/num_dhs_clust_log_distribution.png", replace wid(4000)
*/

* The original distribution (not using the log transformed variable) can be visualized using these scatterplots

*** /*
sort surv num_pixels
colorpalette plasma, n(10) nograph
scatter num_dhs_clust num_pixels, jitter(0.5) yscale() xscale(log) ///
			ylabel( ,) ///
			xlabel(4 10 50 100 500 1000 5000 10000 30000 ,) xlab(, angle(vert)) ///
			msymbol(Oh) msize(large) mlwidth(vvvthin) ///
			colorvar(num_dhs_clust_log) colorlist(`r(p)') colordiscrete clegend(off) ///
			by(surv, col(5) scale(0.8) note("Note: Marker colors correspond to deciles of global settlement size distribution", size(vvtiny))) ///
			subtitle( , nobox) ///
			ysize(2) xsize(4) 
			graph export "$pngs/num_dhs_clust_distribution.png", replace wid(4000)
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

gen ncl=round(num_dhs_clust_log) // **rounded to integers
label var ncl "Number of survey clusters removed from sample (log; integers)"

* Resulting distribution can be visualized using these scatterplots
*** /*
sort surv num_pixels
colorpalette plasma, n(10) nograph
scatter ncl num_pixels, jitter(0.5) yscale(log) xscale(log) ///
			ylabel(1 5 10,) ///
			xlabel(4 10 50 100 500 1000 5000 10000 30000 ,) xlab(, angle(vert)) ///
			msymbol(Oh) msize(large) mlwidth(vvvthin) ///
			colorvar(npl) colorlist(`r(p)') colordiscrete clegend(off) ///
			by(surv, col(5) scale(0.8) note("Note: Marker colors correspond to deciles of global settlement size distribution", size(vvtiny))) ///
			subtitle( , nobox) ///
			ysize(2) xsize(4)
			graph export "$pngs/npl_distribution.png", replace wid(4000)
*/


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



* Outputs

* GLM to test association between difference (pred-direct) and settlement size, number of survey clusters overlapping with settlement, indicator quality (rse=s.e./estimate)

gen mod_diff = abs(diff)

levelsof ind_order, local(ind_order)
foreach i of local ind_order {
	local v : label (ind_order) `i'
	di "`v'"
	xi: glm mod_diff c.num_dhs_clust_log##c.pix_cat ratioseest i.surv  if ind_order==`i', eform
	
}

* GLM to test association between ratio (pred/direct) and settlement size, number of survey clusters overlapping with settlement, indicator quality (rse=s.e./estimate)


levelsof ind_order, local(ind_order)
foreach i of local ind_order {
	local v : label (ind_order) `i'
	di "`v'"
	xi: glm ratio c.num_dhs_clust_log##c.pix_cat ratioseest i.surv  if ind_order==`i', eform
	
}

* Plots

* Option to turn plot rendering off for increasing processing speed
set graph off


***************************** ***************************** ***************************** 
cd "$grec"


**Figure 12

* Boxplots - overall

*Differences
wrap ind_order, at(30)	
graph box diff, over(npl)  ///
		by(ind_order, title(, size(small) color(none)) ///
		col(5) note("")) yline(0, lstyle(foreground)) ylabel(-1(0.5)1) marker(1, msymbol(o) msize(vtiny))
graph play box_titles
graph play boxtuning
graph play thinbox
graph save "$graphs/d_npl_box_plot_all", replace
graph export "$pngs/d_npl_box_plot_all.png", replace wid(5000)


**Figure 13

*Differences by clusters excluded

graph box diff, over(ncl)  /// *or num_dhs_clust_log
		by(ind_order, title(, size(small) color(none)) ///
		col(5) note("")) yline(0, lstyle(foreground)) ylabel(-1(0.5)1) marker(1, msymbol(o) msize(vtiny))
graph play box_titles
graph play boxtuning
graph play thinbox
graph play ncl
graph play boxcolor
graph save "$graphs/d_num_dhs_clust_box_plot_all", replace
graph export "$pngs/d_num_dhs_clust_box_plot_all.png", replace wid(5000)



***************************** ***************************** ***************************** 

**Supplementary Figures 4 to 18

*Differences

levelsof ind_order, local(ind)
foreach i of local ind {
	local v : label (ind_order) `i'
graph box diff if ind_order==`i', over(npl)  ///
		by(surv, title("`v'", size(small)) ///
		col(5) note("")) yline(0, lstyle(foreground)) ylabel(-1(0.25)1) marker(1, msymbol(o) msize(vtiny))
graph play box_titles
graph play boxtuning
graph play thinbox
graph save "$graphs/d_npl_box_plot_`i'", replace
graph export "$pngs/d_npl_box_plot_`i'.png", replace wid(5000)
}

***************************** ***************************** ***************************** 

**Supplementary Figures 19 to 33

*Differences by survey clusters excluded

levelsof ind_order, local(ind)
foreach i of local ind {
	local v : label (ind_order) `i'
graph box diff if ind_order==`i', over(ncl)  /// *or num_dhs_clust_log
		by(surv, title("`v'", size(small)) ///
		col(5) note("")) yline(0, lstyle(foreground)) ylabel(-1(0.25)1) marker(1, msymbol(o) msize(vtiny))
graph play box_titles
graph play boxtuning
graph play thinbox
graph play ncl
graph play boxcolor
graph save "$graphs/d_num_dhs_clust_box_plot_`i'", replace
graph export "$pngs/d_num_dhs_clust_box_plot_`i'.png", replace wid(5000)
}


***************************** ***************************** ***************************** 
