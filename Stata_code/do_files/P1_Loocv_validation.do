// Project: This code is part of the manuscript "Multi-country settlement level database of health indicators and covariate-free estimation method"
// Manuscript authors: Amir Hossein Darooneh, Jean-Luc Kortenaar, Celine Goulart, Katie McLaughlin, Sean Cornelius, and Diego G. Bassani
// Suggested citation: Darooneh, A.H., et al. Multi-country settlement level database of health indicators and covariate-free estimation method. (2024)
// Program: Produces plots of prediction metrics (out of sample LOOCV) by indicator quality (SRE) and coverage values (prevalence) by survey (country_year) and indicator type
// Author: Diego G Bassani, The Hospital for Sick Children
// Date Created: 2024-06-14
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

cap mkdir "$path/stata_gph_files/LOOCV"
cap mkdir "$path/stata_png_files/LOOCV"

***************************** ***************************** ***************************** 
global datafiles "$path/stata_data_files"
global inputfiles "$path/input_files"
global graphs "$path/stata_gph_files/LOOCV"
global pngs "$path/stata_png_files/LOOCV"
global grec "$path/grec_files"
global logs "$path/stata_log_files"
global tables "$path/tables"
***************************** ***************************** ***************************** 


*Assessment of model predictions/validation
*removing Iodized Salt Indicator

cd "$path"
clear

import delimited "$inputfiles/VALIDATION_combined.csv", clear 

* Create survey name variable by concatenating country name and year of survey

egen ssurv = concat(country year), punct(-)
tab ssurv
encode ssurv, gen(surv)
tab surv
drop ssurv
label variable surv "Survey (Country-year)" 


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
			

* Merge with survey information (prevalence, s.d., variance, s.e., ratio s.e. to prevalence. )

merge 1:1 ind_order surv using "$inputfiles/survey_estimates_indicators.dta"
drop if _merge==2

cap destring prevalence, force replace 
cap destring standarderror, force replace 
cap destring ratioseest, force replace 
cap destring standarddeviation, force replace 
cap destring variance, force replace


* Create numeric version of country and indicator variable

cap encode country, gen(country_n)
encode indicator, gen(ind)

* create alternative evaluation metrics

gen sd_prev= standarddeviation/prevalence
label var sd_prev "Ratio S.D./Prevalence"

gen rse = ratioseest*100
label variable rse "Ratio SE/Est (%)"

**************************************************
* https://github.com/aarondwolf/wrap
* net install wrap, from("https://aarondwolf.github.io/wrap")

set graph off

ds  loocv_bias loocv_ratio loocv_mae loocv_rmse loocv_p95 settl_rmsd settl_mad settl_ratio ///
settl_mad_to_maxpred settl_mad_to_maxdhs adm1_rmsd adm1_mad adm1_ratio adm1_mad_to_maxpred ///
adm1_mad_to_maxdhs adm2_rmsd adm2_mad adm2_ratio adm2_mad_to_maxpred adm2_mad_to_maxdhs 

ds `r(varlist)'

global varlist `r(varlist)'

	foreach var in $varlist {
		
	wrap `var', local(`var'_lab) at(30)
	colorpalette sfso parties, select(1/9) / plottig, select(1/6) / plottig, select(9)/ set3, select(1/3) / set3, select(5/9) nograph
		twoway scatter `var' prevalence, ///
		colorvar(ind_order) colordiscrete colorlist(`r(p) ') mlcolor(gray) colorfillonly mlwidth(vthin) ///
		zlabel(, valuelabel) coloruseplegend plegend(order(- "Indicators" 15 14 13 - 12 11 10 9 - 8 7 6 - 5 4 - 3 2 1) size(tiny)) ///
		xlab(0(.2)1) ztitle("") legend(off) aspectratio(1) title("", size(vsmall)) ///
		ytitle( ``var'_lab', size(small)) ///
		saving("$graphs/`var'_p_ci.gph", replace)
		graph save "$graphs/`var'_p_ci_l.gph", replace
		graph play hide_legend
		graph save "$graphs/`var'_p_ci.gph", replace
	
	colorpalette sfso parties, select(1/9) / plottig, select(1/6) / plottig, select(9)/ set3, select(1/3) / set3, select(5/9) nograph
		twoway scatter `var' standarderror, ///
		colorvar(ind_order) colordiscrete colorlist(`r(p) ') mlcolor(gray) colorfillonly mlwidth(vthin) ///
		zlabel(, valuelabel) coloruseplegend plegend(order(- "Indicators" 15 14 13 - 12 11 10 9 - 8 7 6 - 5 4 - 3 2 1) size(tiny)) ///
		ztitle("") legend(off) aspectratio(1) title("", size(vsmall)) ///
		ytitle( ``var'_lab', size(small)) ///
		saving("$graphs/`var'_se_ci.gph", replace)
		graph save "$graphs/`var'_se_ci_l.gph", replace
		graph play hide_legend
		graph save "$graphs/`var'_se_ci.gph", replace
		
	colorpalette sfso parties, select(1/9) / plottig, select(1/6) / plottig, select(9)/ set3, select(1/3) / set3, select(5/9) nograph
		twoway scatter `var' rse, xscale(log) xlabel(5 10 20, labsize(small)) ///
		colorvar(ind_order) colordiscrete colorlist(`r(p) ') mlcolor(gray) colorfillonly mlwidth(vthin) ///
		zlabel(, valuelabel) coloruseplegend plegend(order(- "Indicators" 15 14 13 - 12 11 10 9 - 8 7 6 - 5 4 - 3 2 1) size(tiny)) ///
		ztitle("") legend(off) aspectratio(1) title("", size(vsmall)) ///
		ytitle( ``var'_lab', size(small)) ///
		saving("$graphs/`var'_rse_ci.gph", replace)
		graph save "$graphs/`var'_rse_ci_l.gph", replace
		graph play hide_legend
		graph save "$graphs/`var'_rse_ci.gph", replace
	}
	
	
	
	colorpalette sfso parties, select(1/9) / plottig, select(1/6) / plottig, select(9)/ set3, select(1/3) / set3, select(5/9) nograph
		twoway scatter loocv_bias rse, xscale(log) xlabel(5 10 20, labsize(small)) ///
		colorvar(ind_order) colordiscrete colorlist(`r(p)') mlcolor(gray) colorfillonly mlwidth(vthin) ///
		zlabel(, valuelabel) coloruseplegend plegend(order(- "Indicators" 15 14 13 - 12 11 10 9 - 8 7 6 - 5 4 - 3 2 1) size(vsmall)) ///
		ztitle("") legend(off) aspectratio(1.2) title("") ///
		saving("$graphs/legend.gph", replace)
		graph play ind_lab
		graph save "$graphs/legend.gph", replace
		*graph export "$pngs/legend.png", replace  wid(5000)

		
cd "$grec"
		
				
** Figure 7			
		
graph combine   "$graphs/loocv_bias_p_ci.gph" ///
				"$graphs/loocv_bias_se_ci.gph" ///
				"$graphs/loocv_bias_rse_ci.gph" ///
				"$graphs/loocv_rmse_p_ci.gph"  ///
				"$graphs/loocv_rmse_se_ci.gph"  ///
				"$graphs/loocv_rmse_rse_ci.gph"  ///
				"$graphs/loocv_mae_p_ci.gph"  ///
				"$graphs/loocv_mae_se_ci.gph"  ///	
				"$graphs/loocv_mae_rse_ci.gph"  ///
				"$graphs/loocv_p95_p_ci.gph"  ///
				"$graphs/loocv_p95_se_ci.gph"  ///
				"$graphs/loocv_p95_rse_ci.gph"  ///				
				"$graphs/loocv_ratio_p_ci.gph"  ///
				"$graphs/loocv_ratio_se_ci.gph"  ///
				"$graphs/loocv_ratio_rse_ci.gph"  ///
				, col(3) imargin(tiny) ysize(7) xsize(4) saving("$graphs/combined_loocv_ci_nl.gph", replace)
				graph play combining
				graph save "$graphs/combined_loocv_ci_nl.gph", replace
				graph export "$pngs/combined_loocv_ci_nl.png", replace  wid(5000)
				graph combine "$graphs/combined_loocv_ci_nl.gph" "$graphs/legend.gph", col(2) ///
				title("Leave-one-out cross-validation metrics for the network of DHS clusters (Voronoi cells)", size(vsmall) color(none))
				graph play comb_legend
				graph play cl
				graph play loocv
				graph export "$pngs/combined_loocv_ci.png", replace  wid(5000)
				
				
** Figure 8		
	
graph combine   "$graphs/adm1_ratio_p_ci.gph"   ///
				"$graphs/adm1_ratio_se_ci.gph"   ///
				"$graphs/adm1_ratio_rse_ci.gph"  ///
				"$graphs/adm2_ratio_p_ci.gph"  ///
				"$graphs/adm2_ratio_se_ci.gph"  ///
				"$graphs/adm2_ratio_rse_ci.gph"  ///	
				"$graphs/settl_ratio_p_ci.gph"  ///
				"$graphs/settl_ratio_se_ci.gph"  ///
				"$graphs/settl_ratio_rse_ci.gph"   ///
				, col(3) ycommon imargin(tiny) ysize(4) xsize(4) saving("$graphs/combined_ratio_ci_nl.gph", replace)
				graph play combining
				graph save "$graphs/combined_ratio_ci_nl.gph", replace
				graph export "$pngs/combined_ratio_ci_nl.png", replace  wid(5000)
				graph combine "$graphs/combined_ratio_ci_nl.gph" "$graphs/legend.gph", col(2) ///
				title("Validation metrics (Ratio) for the LIDW predictions compared to DHS estimates by aggregation level", size(vsmall) color(none))
				graph play comb_legend
				graph play cl
				graph export "$pngs/combined_ratio_ci.png", replace  wid(5000)

				
** Figure 9					
				
graph combine   "$graphs/adm1_mad_to_maxdhs_rse_ci.gph"  ///
				"$graphs/adm1_mad_to_maxpred_rse_ci.gph"  ///
				"$graphs/adm1_mad_rse_ci.gph"  ///
				"$graphs/adm1_rmsd_rse_ci.gph"  ///
				"$graphs/adm2_mad_to_maxdhs_rse_ci.gph"  ///
				"$graphs/adm2_mad_to_maxpred_rse_ci.gph"  ///
				"$graphs/adm2_mad_rse_ci.gph"  ///
				"$graphs/adm2_rmsd_rse_ci.gph"   ///
				"$graphs/settl_mad_to_maxdhs_rse_ci.gph"  ///
				"$graphs/settl_mad_to_maxpred_rse_ci.gph"  ///
				"$graphs/settl_mad_rse_ci.gph"  ///
				"$graphs/settl_rmsd_rse_ci.gph" ///
				, col(4) ycommon xcommon imargin(tiny)  ysize(4) xsize(4)  saving("$graphs/combined_other_rse_ci_nl.gph", replace)
				graph play combining
				graph play comb_other_rse_ci_nl
				graph save "$graphs/combined_other_rse_ci_nl.gph", replace
				graph export "$pngs/combined_other_rse_ci_nl.png", replace  wid(5000)
				graph combine "$graphs/combined_other_rse_ci_nl.gph" "$graphs/legend.gph", col(2) ///
				title("Validation metrics for the LIDW predictions compared to DHS estimates by Ratio SE/Est (%) and aggregation level", size(vsmall) color(none))
				graph play comb_legend
				graph play cl
				graph export "$pngs/combined_other_rse_ci.png", replace  wid(5000)				

** Figure 9.a (not shown), changing x-axis to prevalence			
				
graph combine 	"$graphs/adm1_mad_to_maxdhs_p_ci.gph" ///
				"$graphs/adm1_mad_to_maxpred_p_ci.gph" ///
				"$graphs/adm1_mad_p_ci.gph"  ///
				"$graphs/adm1_rmsd_p_ci.gph"  ///
				"$graphs/adm2_mad_to_maxdhs_p_ci.gph"  ///
				"$graphs/adm2_mad_to_maxpred_p_ci.gph"  ///
				"$graphs/adm2_mad_p_ci.gph"  ///
				"$graphs/adm2_rmsd_p_ci.gph"   ///
				"$graphs/settl_mad_to_maxdhs_p_ci.gph"  ///
				"$graphs/settl_mad_to_maxpred_p_ci.gph"  ///
				"$graphs/settl_mad_p_ci.gph"  ///
				"$graphs/settl_rmsd_p_ci.gph" ///
				, col(4) ycommon xcommon imargin(tiny) saving("$graphs/combined_other_p_ci_nl.gph", replace)
				graph play combining
				graph play comb_other_rse_ci_nl
				graph save "$graphs/combined_other_p_ci_nl.gph", replace
				graph export "$pngs/combined_other_p_ci_nl.png", replace wid(5000)
				graph combine "$graphs/combined_other_p_ci_nl.gph" "$graphs/legend.gph", col(2) ///
				title("Validation metrics for the LIDW predictions compared to DHS estimates by value of the indicator (prevalence) and aggregation level", size(vsmall) color(none))
				graph play comb_legend
				graph play cl  
				graph export "$pngs/combined_other_p_ci.png", replace  wid(5000)

** Figure 9.b (not shown), changing x-axis to standard error				

graph combine   "$graphs/adm1_mad_to_maxdhs_se_ci.gph"  ///
				"$graphs/adm1_mad_to_maxpred_se_ci.gph"  ///
				"$graphs/adm1_mad_se_ci.gph"  ///
				"$graphs/adm1_rmsd_se_ci.gph"  ///
				"$graphs/adm2_mad_to_maxdhs_se_ci.gph"  ///
				"$graphs/adm2_mad_to_maxpred_se_ci.gph"  ///
				"$graphs/adm2_mad_se_ci.gph"  ///
				"$graphs/adm2_rmsd_se_ci.gph"   ///
				"$graphs/settl_mad_to_maxdhs_se_ci.gph"  ///
				"$graphs/settl_mad_to_maxpred_se_ci.gph"  ///
				"$graphs/settl_mad_se_ci.gph"  ///
				"$graphs/settl_rmsd_se_ci.gph" ///
				, col(4) ycommon xcommon imargin(tiny) saving("$graphs/combined_other_se_ci_nl.gph", replace)				
			    graph play combining
				graph play comb_other_rse_ci_nl
				graph save "$graphs/combined_other_se_ci_nl.gph", replace
				graph export "$pngs/combined_other_se_ci_nl.png", replace  wid(5000)
				graph combine "$graphs/combined_other_se_ci_nl.gph" "$graphs/legend.gph", col(2) ///
				title("Validation metrics for the LIDW predictions compared to DHS estimates by Standard Error of the indicator and aggregation level", size(vsmall) color(none))
				graph play comb_legend
				graph play cl
				graph export "$pngs/combined_other_se_ci.png", replace  wid(5000)

