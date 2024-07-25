# Project: This code is part of the manuscript "Multi-country settlement level database of health indicators and covariate-free estimation method"
# Manuscript authors: Amir Hossein Darooneh, Jean-Luc Kortenaar, Celine Goulart, Katie McLaughlin, Sean Cornelius, and Diego G. Bassani
# Suggested citation: Darooneh, A.H., et al. Multi-country settlement level database of health indicators and covariate-free estimation method. (2024)
# Program: Calculate indicator prevalence at the cluster level for each survey
# Author: Jean-Luc Kortenaar, The Hospital for Sick Children
# Date Created: 2024-07-23
# Last Updated:  2024-07-23
# Description:  Identifies all relevant saved surveys
###################
# Attributions:

###################
#Notes:

###################



# Get the list of file names matching the pattern
file_names_PR <- list.files(folder_path, pattern = ".*PR.*\\.rds", full.names = TRUE)
file_names_IR <- list.files(folder_path, pattern = ".*IR.*\\.rds", full.names = TRUE)
file_names_HR <- list.files(folder_path, pattern = ".*HR.*\\.rds", full.names = TRUE)
file_names_KR <- list.files(folder_path, pattern = ".*KR.*\\.rds", full.names = TRUE)
file_names_GC <- list.files(folder_path, pattern ="^..GC.*\\.rds", full.names = TRUE) 
file_names_GE <- list.files(folder_path, pattern =".*GE.*\\.rds", full.names = TRUE)
