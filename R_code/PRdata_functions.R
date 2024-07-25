# Project: This code is part of the manuscript "Multi-country settlement level database of health indicators and covariate-free estimation method"
# Manuscript authors: Amir Hossein Darooneh, Jean-Luc Kortenaar, Celine Goulart, Katie McLaughlin, Sean Cornelius, and Diego G. Bassani
# Suggested citation: Darooneh, A.H., et al. Multi-country settlement level database of health indicators and covariate-free estimation method. (2024)
# Program: Calculate indicator prevalence at the cluster level for each survey
# Author: Jean-Luc Kortenaar, The Hospital for Sick Children
# Date Created: 2024-07-23
# Last Updated:  2024-07-23
# Description:  Calculates all indicators needed from the DHS Household Member Recode (PR)
###################
# Attributions:
# DHS indicator calculations were adapted from the DHS Github: https://github.com/DHSProgram/DHS-Indicators-R
###################
#Notes:
# Variables created in this file:
# cov_anemia_children "Percentage of children 6-59 months with anemia"
# cov_wasted "Percentage of children 0-59m wasted
# cov_stunted "Percentage of children 0-59m stunted"
###################

PR_function<-function(PRdata){
  
PRdata <- PRdata %>%
  mutate(wt = hv005/1000000)

dates<-PRdata$hv007
year<-min(dates)
PRdata$year<-year
# *** Anthropometry indicators ***

#//Stunted.  For old surveys need to remove instances were any of hc70, hc71, hc72 are missing
#https://dhsprogram.com/data/Guide-to-DHS-Statistics/index.htm#t=Nutritional_Status.htm&rhsearch=stunting&rhhlterm=stunting&rhsyns=%20
PRdata <- PRdata %>%
  mutate(nt_ch_stunt2 =
           case_when(
             hv103==1 &  hc70< -200  ~ 1 ,
             hv103==1 &  hc70>= -200 ~ 0 ,
             hc70>=600 ~ 99,
             hc70<= -600 ~ 99)) %>%
  replace_with_na(replace = list(nt_ch_stunt2 = c(99))) %>%
  set_value_labels(nt_ch_stunt2 = c("Yes" = 1, "No"=0  )) %>%
  set_variable_labels(nt_ch_stunt2 = "Stunted child under 5 years")

PR_version<-first(substr(PRdata$hv000, 3, 3))
if (PR_version == "6"){
PRdata$nt_ch_stunt2<-ifelse(PRdata$hc70>=9996|PRdata$hc71>=9996|PRdata$hc72>=9996, NA, PRdata$nt_ch_stunt2)
}
PRdata$nt_ch_stunt2<-ifelse(PRdata$hc70>=9996, NA, PRdata$nt_ch_stunt2)


#//Wasted. For old surveys need to remove instances were any of hc70, hc71, hc72 are missing
PRdata <- PRdata %>%
  mutate(nt_ch_wast2 =
           case_when(
             hv103==1 &  hc72< -200  ~ 1 ,
             hv103==1 &  hc72>= -200 ~ 0 ,
             hc72>=9996 ~ 99)) %>%
  replace_with_na(replace = list(nt_ch_wast2 = c(99))) %>%
  set_value_labels(nt_ch_wast2 = c("Yes" = 1, "No"=0  )) %>%
  set_variable_labels(nt_ch_wast2 = "Wasted child under 5 years")

if (PR_version == "6"){
  PRdata$nt_ch_wast2<-ifelse(PRdata$hc70>=9996|PRdata$hc71>=9996|PRdata$hc72>=9996, NA, PRdata$nt_ch_wast2)
}
PRdata$nt_ch_wast2<-ifelse(PRdata$hc72>=9996, NA, PRdata$nt_ch_wast2)




# *** Anemia indicators ***

#//Any anemia
PRdata <- PRdata %>%
  mutate(nt_ch_any_anem2 =
           case_when(
             hv042 ==1 & hv103==1 & hc1>5 & hc1<60 & hc57>=1 & hc57<=3 ~ 1 ,
             hv042 == 1 & hv103==1 & hc1>5 & hc1<60 & hc55==0 ~ 0)) %>%
  set_value_labels(nt_ch_any_anem2 = c("Yes" = 1, "No"=0  )) %>%
  set_variable_labels(nt_ch_any_anem2 = "Any anemia - child 6-59 months")

#//Unique ID created for merging purposes
PRdata$UniqueID <- paste(PRdata$hv000, PRdata$year, PRdata$hv001)
PRdata$region <- to_character(PRdata$hv024)
PRdata$country_code <- paste0(PRdata$hv000, PRdata$year)


#Creates Cluster dataset
summary_data <- PRdata %>%
  group_by(UniqueID)%>%
  summarize(
    #anemia
    cov_anemia_children = w_mean(nt_ch_any_anem2, wt, na.rm = TRUE),
    sd_anemia_children = w_sd(nt_ch_any_anem2, wt, na.rm = TRUE),
    se_anemia_children = w_se(nt_ch_any_anem2, wt, na.rm = TRUE),
    var_anemia_children = w_var(nt_ch_any_anem2, wt, na.rm = TRUE),
    num_anemia_children = w_sum(nt_ch_any_anem2, wt, na.rm = TRUE)*1000000,
    den_anemia_children = w_n(nt_ch_any_anem2, wt, na.rm = TRUE)*1000000,
    unwgtnum_anemia_children = sum(nt_ch_any_anem2, na.rm=TRUE),
    unwgtden_anemia_children = sum(!is.na(nt_ch_any_anem2)),
    #stunted
    cov_stunted = w_mean(nt_ch_stunt2, wt, na.rm = TRUE),
    sd_stunted = w_sd(nt_ch_stunt2, wt, na.rm = TRUE),
    se_stunted = w_se(nt_ch_stunt2, wt, na.rm = TRUE),
    var_stunted = w_var(nt_ch_stunt2, wt, na.rm = TRUE),
    num_stunted = w_sum(nt_ch_stunt2, wt, na.rm = TRUE)*1000000,
    den_stunted = w_n(nt_ch_stunt2, wt, na.rm = TRUE)*1000000,
    unwgtnum_stunted = sum(nt_ch_stunt2, na.rm=TRUE),
    unwgtden_stunted = sum(!is.na(nt_ch_stunt2)),
    #nt_ch_wast
    cov_wasted = w_mean(nt_ch_wast2, wt, na.rm = TRUE),
    sd_wasted = w_sd(nt_ch_wast2, wt, na.rm = TRUE),
    se_wasted = w_se(nt_ch_wast2, wt, na.rm = TRUE),
    var_wasted = w_var(nt_ch_wast2, wt, na.rm = TRUE),
    num_wasted = w_sum(nt_ch_wast2, wt, na.rm = TRUE)*1000000,
    den_wasted = w_n(nt_ch_wast2, wt, na.rm = TRUE)*1000000,
    unwgtnum_wasted = sum(nt_ch_wast2, na.rm=TRUE),
    unwgtden_wasted = sum(!is.na(nt_ch_wast2))
  )

#Creates Regional dataset
PRdata$UniqueID_region <- paste(PRdata$hv000, PRdata$year, PRdata$hv024)

summary_data_region <- PRdata %>%
  group_by(UniqueID_region) %>%
  dplyr::summarise(
    region = first(region),
    #anemia
    cov_anemia_children = w_mean(nt_ch_any_anem2, wt, na.rm = TRUE),
    sd_anemia_children = w_sd(nt_ch_any_anem2, wt, na.rm = TRUE),
    se_anemia_children = w_se(nt_ch_any_anem2, wt, na.rm = TRUE),
    var_anemia_children = w_var(nt_ch_any_anem2, wt, na.rm = TRUE),
    num_anemia_children = w_sum(nt_ch_any_anem2, wt, na.rm = TRUE)*1000000,
    den_anemia_children = w_n(nt_ch_any_anem2, wt, na.rm = TRUE)*1000000,
    unwgtnum_anemia_children = sum(nt_ch_any_anem2, na.rm=TRUE),
    unwgtden_anemia_children = sum(!is.na(nt_ch_any_anem2)),
    #stunted
    cov_stunted = w_mean(nt_ch_stunt2, wt, na.rm = TRUE),
    sd_stunted = w_sd(nt_ch_stunt2, wt, na.rm = TRUE),
    se_stunted = w_se(nt_ch_stunt2, wt, na.rm = TRUE),
    var_stunted = w_var(nt_ch_stunt2, wt, na.rm = TRUE),
    num_stunted = w_sum(nt_ch_stunt2, wt, na.rm = TRUE)*1000000,
    den_stunted = w_n(nt_ch_stunt2, wt, na.rm = TRUE)*1000000,
    unwgtnum_stunted = sum(nt_ch_stunt2, na.rm=TRUE),
    unwgtden_stunted = sum(!is.na(nt_ch_stunt2)),
    #nt_ch_wast
    cov_wasted = w_mean(nt_ch_wast2, wt, na.rm = TRUE),
    sd_wasted = w_sd(nt_ch_wast2, wt, na.rm = TRUE),
    se_wasted = w_se(nt_ch_wast2, wt, na.rm = TRUE),
    var_wasted = w_var(nt_ch_wast2, wt, na.rm = TRUE),
    num_wasted = w_sum(nt_ch_wast2, wt, na.rm = TRUE)*1000000,
    den_wasted = w_n(nt_ch_wast2, wt, na.rm = TRUE)*1000000,
    unwgtnum_wasted = sum(nt_ch_wast2, na.rm=TRUE),
    unwgtden_wasted = sum(!is.na(nt_ch_wast2))
  )

#Creates Country-level dataset

summary_data_country <- PRdata %>%
  group_by(country_code) %>%
  dplyr::summarise(
    #anemia
    cov_anemia_children = w_mean(nt_ch_any_anem2, wt, na.rm = TRUE),
    sd_anemia_children = w_sd(nt_ch_any_anem2, wt, na.rm = TRUE),
    se_anemia_children = w_se(nt_ch_any_anem2, wt, na.rm = TRUE),
    var_anemia_children = w_var(nt_ch_any_anem2, wt, na.rm = TRUE),
    num_anemia_children = w_sum(nt_ch_any_anem2, wt, na.rm = TRUE)*1000000,
    den_anemia_children = w_n(nt_ch_any_anem2, wt, na.rm = TRUE)*1000000,
    unwgtnum_anemia_children = sum(nt_ch_any_anem2, na.rm=TRUE),
    unwgtden_anemia_children = sum(!is.na(nt_ch_any_anem2)),
    #stunted
    cov_stunted = w_mean(nt_ch_stunt2, wt, na.rm = TRUE),
    sd_stunted = w_sd(nt_ch_stunt2, wt, na.rm = TRUE),
    se_stunted = w_se(nt_ch_stunt2, wt, na.rm = TRUE),
    var_stunted = w_var(nt_ch_stunt2, wt, na.rm = TRUE),
    num_stunted = w_sum(nt_ch_stunt2, wt, na.rm = TRUE)*1000000,
    den_stunted = w_n(nt_ch_stunt2, wt, na.rm = TRUE)*1000000,
    unwgtnum_stunted = sum(nt_ch_stunt2, na.rm=TRUE),
    unwgtden_stunted = sum(!is.na(nt_ch_stunt2)),
    #nt_ch_wast
    cov_wasted = w_mean(nt_ch_wast2, wt, na.rm = TRUE),
    sd_wasted = w_sd(nt_ch_wast2, wt, na.rm = TRUE),
    se_wasted = w_se(nt_ch_wast2, wt, na.rm = TRUE),
    var_wasted = w_var(nt_ch_wast2, wt, na.rm = TRUE),
    num_wasted = w_sum(nt_ch_wast2, wt, na.rm = TRUE)*1000000,
    den_wasted = w_n(nt_ch_wast2, wt, na.rm = TRUE)*1000000,
    unwgtnum_wasted = sum(nt_ch_wast2, na.rm=TRUE),
    unwgtden_wasted = sum(!is.na(nt_ch_wast2))
  )
if (exists("PR_data")) {
  PR_data <<- rbind(PR_data, summary_data)
} else {
  PR_data <<- summary_data
}
saveRDS(PR_data, file="PR_data.rds")

if (exists("PR_data_region")) {
  PR_data_region <<- rbind_labelled(PR_data_region, summary_data_region)
} else {
  PR_data_region <<- summary_data_region
}
saveRDS(PR_data_region, file="PR_data_region.rds")


if (exists("PR_data_country")) {
  PR_data_country <<- rbind_labelled(PR_data_country, summary_data_country)
} else {
  PR_data_country <<- summary_data_country
}
saveRDS(PR_data_country, file="PR_data_country.rds")
}