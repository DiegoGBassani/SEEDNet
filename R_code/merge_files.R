# Project: This code is part of the manuscript "Multi-country settlement level database of health indicators and covariate-free estimation method"
# Manuscript authors: Amir Hossein Darooneh, Jean-Luc Kortenaar, Celine Goulart, Katie McLaughlin, Sean Cornelius, and Diego G. Bassani
# Suggested citation: Darooneh, A.H., et al. Multi-country settlement level database of health indicators and covariate-free estimation method. (2024)
# Program: Calculate indicator prevalence at the cluster level for each survey
# Author: Jean-Luc Kortenaar, The Hospital for Sick Children
# Date Created: 2024-07-23
# Last Updated:  2024-07-23
# Description: Merges all the DHS recodes together and renames some of the columns
###################
# Attributions:

###################
#Notes:
#Produces dataset D (dataset for cluster-level estimates), D_region (regional-level estimates), D_country (country-level estimates)

###################

df_list<- list(HR_data, PR_data, IR_data, KR_data, HRPR_data)
df_list_region<-list(HR_data_region, PR_data_region, IR_data_region, KR_data_region, HRPR_data_region)
df_list_country<-list(HR_data_country, PR_data_country, IR_data_country, KR_data_country, HRPR_data_country)


D<-df_list %>% reduce(left_join, by="UniqueID") #keeps all observations from HR_data
D$UniqueID <- paste0(substr(D$UniqueID, 1, 2), substr(D$UniqueID, 4, nchar(D$UniqueID)))
GE_data <- sf::st_drop_geometry(GE_data) #drops geometry
D<-merge(D, GE_data, by="UniqueID") 
D_region<-df_list_region %>% reduce(full_join, by= "UniqueID_region")
D_country<-df_list_country %>% reduce(full_join, by= "country_code")

#rename columns in D for other steps
names(D)[names(D) == "Country"] <- "country"
names(D)[names(D) == "Cluster"] <- "cluster"
names(D)[names(D) == "Year"] <- "year"
names(D)[names(D) == "LATNUM"] <- "LAT"
names(D)[names(D) == "LONGNUM"] <- "LNG"
