# Project: This code is part of the manuscript "Multi-country settlement level database of health indicators and covariate-free estimation method"
# Manuscript authors: Amir Hossein Darooneh, Jean-Luc Kortenaar, Celine Goulart, Katie McLaughlin, Sean Cornelius, and Diego G. Bassani
# Suggested citation: Darooneh, A.H., et al. Multi-country settlement level database of health indicators and covariate-free estimation method. (2024)
# Program: Create cluster level indicators by cluster for each survey
# Author: Jean-Luc Kortenaar, The Hospital for Sick Children
# Date Created: 2024-07-23
# Last Updated:  2024-07-23
# Description: Calculates all indicators that require both the DHS's household recode (HR) and household member recode (PR)
###################
# Attributions:
# DHS indicator calculations were adapted from the DHS Github: https://github.com/DHSProgram/DHS-Indicators-R
###################
#Notes:
# Variables created in this file:
# cov_itn_u5 - Children under 5 who slept under an ITN-treated mosquito-net
###################

HRPR_function<-function(HRdata, PRdata){
  
  # Get current column names #needed for SPSS data files
  current_names <- colnames(HRdata)
  
  # Replace periods with underscores in column names
  new_names <- make.unique(gsub("\\.", "_", current_names))
  
  # Assign new column names to the data frame
  colnames(HRdata) <- new_names
  
  HRdata <- HRdata %>%
    mutate(wt = hv005/1000000)
  
  if("hml10_01" %in% colnames(HRdata)){ #The related variables is differently named in the Senegal continuous DHS
    HRdata$hml10_1<-HRdata$hml10_01
    HRdata$hml10_2<-HRdata$hml10_02
    HRdata$hml10_3<-HRdata$hml10_03
    HRdata$hml10_4<-HRdata$hml10_04
    HRdata$hml10_5<-HRdata$hml10_05
    HRdata$hml10_6<-HRdata$hml10_06
    HRdata$hml10_7<-HRdata$hml10_07
  }
  if ("hml10_1" %in% colnames(HRdata)) {
  HRdata <- HRdata %>%
    mutate(itnhh_01 = case_when(hml10_1==1 ~ 1,TRUE ~ 0)) %>%
    mutate(itnhh_02 = case_when(hml10_2==1 ~ 1,TRUE ~ 0)) %>%
    mutate(itnhh_03 = case_when(hml10_3==1 ~ 1,TRUE ~ 0)) %>%
    mutate(itnhh_04 = case_when(hml10_4==1 ~ 1,TRUE ~ 0)) %>%
    mutate(itnhh_05 = case_when(hml10_5==1 ~ 1,TRUE ~ 0)) %>%
    mutate(itnhh_06 = case_when(hml10_6==1 ~ 1,TRUE ~ 0)) %>%
    mutate(itnhh_07 = case_when(hml10_7==1 ~ 1,TRUE ~ 0)) %>%
    mutate(ml_numitnhh = itnhh_01 + itnhh_02 + itnhh_03 + itnhh_04 + itnhh_05 + itnhh_06 + itnhh_07,
           ml_numitnhh = set_label(ml_numitnhh, label = "Number of ITNs per household"))
  
  HRdata_ <- HRdata %>% 
    select(hv001, hv002, ml_numitnhh, starts_with("hml10"))
  
  HRmerge <- merge(HRdata_,
                   PRdata, by = c("hv001","hv002"))
  #HRmerge<-subset(HRmerge, HRmerge$hv103==1) #De facto
  
  # Households with > 1 ITN per 2 members
  # Potential users divided by defacto household members is greater or equal to one
  HRmerge <- HRmerge %>%
    mutate(ml_potuse = ml_numitnhh*2,
           ml_potuse = set_label(ml_potuse, label = "Potential ITN users in household"))
  
  HRmerge <- HRmerge %>%
    mutate(ml_pop_access0 =ml_potuse/hv013) %>%
    mutate(ml_pop_access = case_when(
      ml_pop_access0 >= 1   ~ 1,
      TRUE   ~ ml_pop_access0),
      ml_pop_access = set_label(ml_pop_access, label = "Population with access to an ITN"))
  
  
  HRmerge <- HRmerge %>%
    mutate(wt = hv005/1000000)
  
  # number of de-facto persons
  HRmerge <- HRmerge %>%
    mutate(numdefacto = case_when(hv013>8 ~ 8,TRUE ~ hv013)) 
  
  # Categorizing nets
  HRmerge <- HRmerge %>%
    mutate(ml_netcat = case_when(
      hml12==0  ~ 0,
      hml12==1|hml12==2  ~ 1,
      hml12==3 ~ 2),
      ml_netcat = set_label(ml_netcat, label = "Mosquito net categorization"))
  
  # Slept under an ITN last night among households with at least 1 ITN
  HRmerge <- HRmerge %>%
    mutate(ml_slept_itn_hhitn = case_when((hml10_1==1|hml10_2==1|hml10_3==1|hml10_4==1|hml10_5==1|hml10_6==1|hml10_7==1) & ml_netcat==1 ~ 1,
                                          (hml10_1==1|hml10_2==1|hml10_3==1|hml10_4==1|hml10_5==1|hml10_6==1|hml10_7==1) & ml_netcat!=1 ~ 0),
           ml_slept_itn_hhitn = set_label(ml_slept_itn_hhitn, label = "Slept under an ITN last night amound household population with at least 1 ITN"))
  
  # recode age
  HRmerge <- HRmerge %>%
    mutate(age = case_when(
      hv105 %in%  (0:4) ~ 1,
      hv105 %in%  (5:14) ~ 2,
      hv105 %in%  (15:34) ~ 3,
      hv105 %in%  (35:49) ~ 4,
      hv105 %in%  (50:95) ~ 5,
      hv105 %in%  (96:99) ~ 99),
      age = add_labels(age, labels = c("0-4"=1, "5-14"=2,"15-34"=3, "35-49"=4,"50+"=5)),
      age = set_label(age, label = "Age"))%>%
    replace_with_na(replace = list(age = c(99)))

HRmerge <- HRmerge %>%
  mutate(ml_slept_itn = case_when(
    ml_netcat==1  ~ 1,
    TRUE ~ 0),
    ml_slept_itn = set_label(ml_slept_itn, label = "Slept under an ITN last night"))

HRmerge$itn_u5<-ifelse(HRmerge$ml_slept_itn==1 & HRmerge$hml16<5 & HRmerge$hv103==1, 1, NA) # de facto
HRmerge$itn_u5<-ifelse(HRmerge$ml_slept_itn==0 &HRmerge$hml16<5& HRmerge$hv103==1, 0, HRmerge$itn_u5)
  }else{
    HRmerge<-HRdata
    HRmerge$itn_u5<-NA
  }

HRmerge$year<-min(HRmerge$hv007)



  
HRmerge$UniqueID <- paste(HRmerge$hv000, HRmerge$year, HRmerge$hv001)
# Group data by a grouping variable (replace 'group_var' with your actual grouping variable)

HRmerge$region <- to_character(HRmerge$hv024)
  
HRmerge$country_code<-paste0(HRmerge$hv000, HRmerge$year)
HRmerge$UniqueID_region <- paste(HRmerge$hv000, HRmerge$year,  HRmerge$hv024)

# Compute weighted mean and standard error for a variable
summary_data <- HRmerge %>%
  group_by(UniqueID)%>%
  dplyr::summarize(
    #children u5 itn
    cov_itn_u5 = w_mean(itn_u5, wt, na.rm = TRUE),
    sd_itn_u5 = w_sd(itn_u5, wt, na.rm = TRUE),
    se_itn_u5 = w_se(itn_u5, wt, na.rm = TRUE),
    var_itn_u5 = w_var(itn_u5, wt, na.rm = TRUE),
    num_itn_u5 = w_sum(itn_u5, wt, na.rm = TRUE)*1000000,
    den_itn_u5 = w_n(itn_u5, wt, na.rm = TRUE)*1000000,
    unwgtnum_itn_u5 = sum(itn_u5, na.rm=TRUE),
    unwgtden_itn_u5 = sum(!is.na(itn_u5)))

HRmerge$UniqueID_region <- paste(HRmerge$hv000, HRmerge$year, HRmerge$hv024)

  # Summary operation by group (region)
summary_data_region <- HRmerge %>%
    group_by(UniqueID_region) %>%
    dplyr::summarize(
      #children u5 itn
      cov= w_mean(itn_u5, wt, na.rm = TRUE),
      sd = w_sd(itn_u5, wt, na.rm = TRUE),
      se = w_se(itn_u5, wt, na.rm = TRUE),
      var = w_var(itn_u5, wt, na.rm = TRUE),
      num = w_sum(itn_u5, wt, na.rm = TRUE)*1000000,
      den = w_n(itn_u5, wt, na.rm = TRUE)*1000000,
      unwgtnum = sum(itn_u5, na.rm =TRUE),
      unwgtden = sum(!is.na(itn_u5)))

summary_data_country <- HRmerge %>%
  group_by(country_code)%>%
  summarize(
    #children u5 itn
    cov_itn_u5 = w_mean(itn_u5, wt, na.rm = TRUE),
    sd_itn_u5 = w_sd(itn_u5, wt, na.rm = TRUE),
    se_itn_u5 = w_se(itn_u5, wt, na.rm = TRUE),
    var_itn_u5 = w_var(itn_u5, wt, na.rm = TRUE),
    num_itn_u5 = w_sum(itn_u5, wt, na.rm = TRUE)*1000000,
    den_itn_u5 = w_n(itn_u5, wt, na.rm = TRUE)*1000000,
    unwgtnum_itn_u5 = sum(itn_u5, na.rm=TRUE),
    unwgtden_itn_u5 = sum(!is.na(itn_u5)))

if (exists("HRPR_data")) {
  HRPR_data <<- rbind_labelled(HRPR_data, summary_data)
} else {
  HRPR_data <<- summary_data
}
saveRDS(HRPR_data, file="HRPR_data.rds")

if (exists("HRPR_data_region")) {
  HRPR_data_region <<- rbind_labelled(HRPR_data_region, summary_data_region)
} else {
  HRPR_data_region <<- summary_data_region
}
saveRDS(HRPR_data_region, file="HRPR_data_region.rds")

if (exists("HRPR_data_country")) {
  HRPR_data_country <<- rbind_labelled(HRPR_data_country, summary_data_country)
} else {
  HRPR_data_country <<- summary_data_country
}
saveRDS(HRPR_data_country, file="HRPR_data_country.rds")
}
