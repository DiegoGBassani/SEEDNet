# Project: This code is part of the manuscript "Multi-country settlement level database of health indicators and covariate-free estimation method"
# Manuscript authors: Amir Hossein Darooneh, Jean-Luc Kortenaar, Celine Goulart, Katie McLaughlin, Sean Cornelius, and Diego G. Bassani
# Suggested citation: Darooneh, A.H., et al. Multi-country settlement level database of health indicators and covariate-free estimation method. (2024)
# Program: Calculate indicator prevalence at the cluster level for each survey
# Author: Jean-Luc Kortenaar, The Hospital for Sick Children
# Date Created: 2024-07-23
# Last Updated:  2024-07-23
# Description:  This file converts the country level estimates to the long format
###################
# Attributions:
# DHS indicator calculations were adapted from the DHS Github: https://github.com/DHSProgram/DHS-Indicators-R
###################
#Notes:
#Output File:
#summary_validation_data.csv
###################

list_of_indicators<-c("iodized_salt",	"ph_electric","sourcewater","anemia_children","stunted","wasted","anemia_women","anc42","ORS_treatment","lbw","exclusivelybf","ch_meas_either","ch_bcg_either","ch_dtp", "itn_u5")	

#create new variables
D2<-D_country
column_list<-c()
for (indicator in list_of_indicators){
  D2[[paste0("ratio_se_est_", indicator)]]<-D2[[paste0("se_", indicator)]]/D2[[paste0("cov_", indicator)]]
  columns<-c(paste0("cov_", indicator),paste0("se_", indicator),paste0("ratio_se_est_", indicator),paste0("sd_", indicator),paste0("var_", indicator))
  column_list <<- rbind_labelled(column_list, columns)
}

D_long<-c()
D_subset <- D2[, c("country_code", column_list[,1])]
D_long<- pivot_longer(D_subset, cols=column_list[,1], names_to = "Indicator", values_to = "Prevalence")
D_long$Indicator <- gsub("^cov_", "", D_long$Indicator)
D_subset <- D2[, c("country_code", column_list[,2])]
D_long2<<- pivot_longer(D_subset, cols=column_list[,2], names_to = "Indicator", values_to = "Standard Error")
D_long2$Indicator <- gsub("^se_", "", D_long2$Indicator)
D_subset <- D2[, c("country_code", column_list[,3])]
D_long3<<- pivot_longer(D_subset, cols=column_list[,3], names_to = "Indicator", values_to = "Ratio SE/Est")
D_long3$Indicator <- gsub("^ratio_se_est_", "", D_long3$Indicator)
D_subset <- D2[, c("country_code", column_list[,4])]
D_long4<<- pivot_longer(D_subset, cols=column_list[,4], names_to = "Indicator", values_to = "Standard Deviation")
D_long4$Indicator <- gsub("^sd_", "", D_long4$Indicator)
D_subset <- D2[, c("country_code", column_list[,5])]
D_long5<<- pivot_longer(D_subset, cols=column_list[,5], names_to = "Indicator", values_to = "Variance")
D_long5$Indicator <- gsub("^var_", "", D_long5$Indicator)
all_data_long <- Reduce(function(x, y) merge(x, y, by = c("country_code", "Indicator")), list(D_long,D_long2,D_long3,D_long4,D_long5))

colnames(all_data_long)[colnames(all_data_long) == "country_code"] <- "Survey"
all_data_long$Survey<- gsub( "AO7", "Angola 2015", all_data_long$Survey)
all_data_long$Survey<- gsub( "BJ7", "Benin 2017", all_data_long$Survey)
all_data_long$Survey<- gsub( "KH6", "Cambodia 2014", all_data_long$Survey)
all_data_long$Survey<- gsub( "GA6", "Gabon 2012", all_data_long$Survey)
all_data_long$Survey<- gsub( "ML7", "Mali 2018", all_data_long$Survey)
all_data_long$Survey<- gsub( "MW7", "Malawi 2015", all_data_long$Survey)
all_data_long$Survey<- gsub( "MZ6", "Mozambique 2011", all_data_long$Survey)
all_data_long$Survey<- gsub( "NG6", "Nigeria 2013", all_data_long$Survey)
all_data_long$Survey<- gsub( "SN7", "Senegal 2019", all_data_long$Survey)
all_data_long$Survey<- gsub( "ZM7", "Zambia 2018", all_data_long$Survey)


all_data_long$Indicator<- gsub( "iodized_salt", "Iodized Salt Intake in Household", all_data_long$Indicator)
all_data_long$Indicator<- gsub( "ph_electric", "Household with Electricity	", all_data_long$Indicator)
all_data_long$Indicator<- gsub( "sourcewater", "Improved Water Source", all_data_long$Indicator)
all_data_long$Indicator<- gsub( "anemia_children", "Prevalence of any Anemia in Children (0-59 months)", all_data_long$Indicator)
all_data_long$Indicator<- gsub( "stunted", "Stunting Prevalence (0-59 months)", all_data_long$Indicator)
all_data_long$Indicator<- gsub( "wasted", "Wasting Prevalence (0-59 months)", all_data_long$Indicator)
all_data_long$Indicator<- gsub( "anemia_women", "Prevalence of any Anemia in Women", all_data_long$Indicator)
all_data_long$Indicator<- gsub( "anc42", "Antenatal Care Visits (4+) during Pregnancy", all_data_long$Indicator)
all_data_long$Indicator<- gsub( "ORS_treatment", "Diarrhea Treatment with ORS (0-59 months)	", all_data_long$Indicator)
all_data_long$Indicator<- gsub( "lbw", "Low Birth Weight Prevalence", all_data_long$Indicator)
all_data_long$Indicator<- gsub( "exclusivelybf", "Exclusive Breastfeeding (0-6 months)", all_data_long$Indicator)
all_data_long$Indicator<- gsub( "ch_meas_either", "Measles Immunization (0-59 months)", all_data_long$Indicator)
all_data_long$Indicator<- gsub( "ch_bcg_either", "BCG Immunization (12-23 months)", all_data_long$Indicator)
all_data_long$Indicator<- gsub( "ch_dtp", "DPT3 Immunization (12-23 months)", all_data_long$Indicator)
all_data_long$Indicator<- gsub( "itn_u5", "Children (0-59 months) Slept under Mosquito Net", all_data_long$Indicator)

write.csv(all_data_long, "summary_validation_data.csv")
