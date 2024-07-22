
// Project: This code is part of the manuscript "Multi-country settlement level database of health indicators and covariate-free estimation method"
// Manuscript authors: Amir Hossein Darooneh, Jean-Luc Kortenaar, Celine Goulart, Katie McLaughlin, Sean Cornelius, and Diego G. Bassani
// Suggested citation: Darooneh, A.H., et al. Multi-country settlement level database of health indicators and covariate-free estimation method. (2024)
// Program: Runs all do files, produces the Stata Figures and tables 
// Author: Diego G Bassani, The Hospital for Sick Children
// Date Created: 2024-06-19
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
global path "UPDATE WITH PATH TO PROJECT FOLDER"
***************************** ***************************** ***************************** 

cap mkdir "$path/stata_do_files" // place these *.do files inside this folder
cap mkdir "$path/input_files" // place the *.csv input files inside this folder
cap mkdir "$path/grec_files" // place the *.grec files inside this folder

***************************** ***************************** ***************************** 

cap mkdir "$path/stata_gph_files"
cap mkdir "$path/stata_png_files"
cap mkdir "$path/stata_log_files"
cap mkdir "$path/stata_data_files"
cap mkdir "$path/tables"

***************************** ***************************** ***************************** 
	
	
etime, start
clear 
set min_memory 16G
set niceness 2
set max_preservemem 0
set segmentsize 1500m

do "$dofiles/P1_Survey_estimates_indicator_file.do" 

do "$dofiles/P1_Loocv_validation.do" 
do "$dofiles/P1_Loocv_settl_validation.do"
do "$dofiles/P1_Loocv_settl_validation_summary.do"

do "$dofiles/P1_k-fold_settl_validation.do"
do "$dofiles/P1_k-fold_settl_validation_summary.do"


etime
