# Project: This code is part of the manuscript "Multi-country settlement level database of health indicators and covariate-free estimation method"
# Manuscript authors: Amir Hossein Darooneh, Jean-Luc Kortenaar, Celine Goulart, Katie McLaughlin, Sean Cornelius, and Diego G. Bassani
# Suggested citation: Darooneh, A.H., et al. Multi-country settlement level database of health indicators and covariate-free estimation method. (2024)
# Program: Create cluster level indicators by cluster for each survey
# Author: Jean-Luc Kortenaar, The Hospital for Sick Children
# Date Created: 2024-07-23
# Last Updated:  2024-07-23
# Description: Calculates all indicators needed from the DHS Individual Recode (IR)
###################
# Attributions:
# DHS indicator calculations were adapted from the DHS Github: https://github.com/DHSProgram/DHS-Indicators-R
###################
#Notes:
# Variables created in this file:
# cov_anemia_women "Percentage of women with any anemia (mild, moderate, severe)
# cov_anc42 "Percentage of women who gave birth in the last two years who received ANC 4+ visits"
###################

IR_function<-function(IRdata){
IRdata <- IRdata %>%
  mutate(wt = v005/1000000)

dates<-IRdata$v007
year<-min(dates)
IRdata$year<-year

# *** Anemia indicators ***
# 
# //Any anemia
IRdata <- IRdata %>%
  mutate(nt_wm_any_anem =
           case_when(
             v042==1 & v457<4 ~ 1 ,
             v042==1 &  v455==0 ~ 0)) %>%
  set_value_labels(nt_wm_any_anem = c("Yes" = 1, "No"=0  )) %>%
  set_variable_labels(nt_wm_any_anem = "Any anemia - women")


#####Reproductive health##########
IRdata <- IRdata %>%
  mutate(period = 60)

# age of child. If b19_01 is not available in the data use v008 - b3_01
if ("TRUE" %in% (!("b19_01" %in% names(IRdata))))
  IRdata [[paste("b19_01")]] <- NA
if ("TRUE" %in% all(is.na(IRdata $b19_01)))
{ b19_included <- 0} else { b19_included <- 1}

if (b19_included==1) {
  IRdata <- IRdata %>%
    mutate(age = b19_01)
} else {
  IRdata <- IRdata %>%
    mutate(age = v008 - b3_01)}

### *** ANC visit indicators *** ###

# //Number of ANC visits in 4 categories that match the table in the final report
IRdata <- IRdata %>%
  mutate(rh_anc_numvs =
           case_when(
             m14_1 == 0 ~ 0 ,
             m14_1 == 1 ~ 1 ,
             m14_1  %in% c(2,3)   ~ 2 ,
             m14_1>=4 & m14_1<=90  ~ 3 ,
             m14_1>90  ~ 9 ,
             age>=period ~ 99 )) %>%
  replace_with_na(replace = list(rh_anc_numvs = c(99))) %>%
  set_value_labels(rh_anc_numvs = c(none = 0, "1"=1, "2-3"=2, "4+"=3, "don't know/missing"=9  )) %>%
  set_variable_labels(rh_anc_numvs = "Number of ANC visits")

# //4+ ANC visits last 2 years

IRdata <- IRdata %>%
  mutate(rh_anc_4vs2 =
           case_when(
             age <= 23 & midx_1 ==1 & rh_anc_numvs == 3 ~ 1,
             age <= 23 & midx_1 ==1 & rh_anc_numvs %in% c(0, 1, 2, 9, NA) ~ 0,
             TRUE ~ NA_real_  # To handle cases where age is not < 2
           )) %>%
  set_value_labels(rh_anc_4vs2 = c("Yes" = 1, "No"=0)) %>%
  set_variable_labels(rh_anc_4vs2 = "Attended 4+ ANC  last 2 years")

####SUMMARIZE data############
IRdata$UniqueID <- paste(IRdata$v000, IRdata$year, IRdata$v001)
# Group data by a grouping variable (replace 'group_var' with your actual grouping variable)

IRdata$region <- to_character(IRdata$v024)

#variables exported
#local IRindicList = "anemia_women cp mcp dfps anc42 ancskilled12 iptp pncmother vtetanus iron hiv_test bp_anc urine_anc blood_anc sba2 pnc_nb facility_delivery csection2"
# nt_wm_any_anem		"Any anemia - women"

IRdata$country_code<-paste0(IRdata$v000, IRdata$year)

summary_data <- IRdata %>%
  group_by(UniqueID)%>%
  summarize(
    UniqueID = first(UniqueID),
    #anemia women
    cov_anemia_women = w_mean(nt_wm_any_anem, wt, na.rm = TRUE),
    sd_anemia_women = w_sd(nt_wm_any_anem, wt, na.rm = TRUE),
    se_anemia_women = w_se(nt_wm_any_anem, wt, na.rm = TRUE),
    var_anemia_women = w_var(nt_wm_any_anem, wt, na.rm = TRUE),
    num_anemia_women = w_sum(nt_wm_any_anem, wt, na.rm = TRUE)*1000000,
    den_anemia_women = w_n(nt_wm_any_anem, wt, na.rm = TRUE)*1000000,
    unwgtnum_anemia_women = sum(nt_wm_any_anem, na.rm=TRUE),
    unwgtden_anemia_women = sum(!is.na(nt_wm_any_anem)),
    # rh_anc_4vs			"Attended 4+ ANC visits last 2 years"
    cov_anc42 = w_mean(rh_anc_4vs2, wt, na.rm = TRUE),
    sd_anc42 = w_sd(rh_anc_4vs2, wt, na.rm = TRUE),
    se_anc42 = w_se(rh_anc_4vs2, wt, na.rm = TRUE),
    var_anc42 = w_var(rh_anc_4vs2, wt, na.rm = TRUE),
    num_anc42 = w_sum(rh_anc_4vs2, wt, na.rm = TRUE)*1000000,
    den_anc42 = w_n(rh_anc_4vs2, wt, na.rm = TRUE)*1000000,
    unwgtnum_anc42 = sum(rh_anc_4vs2, na.rm=TRUE),
    unwgtden_anc42 = sum(!is.na(rh_anc_4vs2))
   )

IRdata$UniqueID_region <- paste(IRdata$v000, IRdata$year, IRdata$v024)
# Group data by a grouping variable (replace 'group_var' with your actual grouping variable)


#variables exported
#local IRindicList = "anemia_women cp mcp dfps anc42 ancskilled12 iptp pncmother vtetanus iron hiv_test bp_anc urine_anc blood_anc sba2 pnc_nb facility_delivery csection2"
# nt_wm_any_anem		"Any anemia - women"

summary_data_region <- IRdata %>%
  group_by(UniqueID_region)%>%
  summarize(
    Region = first(region),
    #anemia women
    cov_anemia_women = w_mean(nt_wm_any_anem, wt, na.rm = TRUE),
    sd_anemia_women = w_sd(nt_wm_any_anem, wt, na.rm = TRUE),
    se_anemia_women = w_se(nt_wm_any_anem, wt, na.rm = TRUE),
    var_anemia_women = w_var(nt_wm_any_anem, wt, na.rm = TRUE),
    num_anemia_women = w_sum(nt_wm_any_anem, wt, na.rm = TRUE)*1000000,
    den_anemia_women = w_n(nt_wm_any_anem, wt, na.rm = TRUE)*1000000,
    unwgtnum_anemia_women = sum(nt_wm_any_anem, na.rm=TRUE),
    unwgtden_anemia_women = sum(!is.na(nt_wm_any_anem)),
    # rh_anc_4vs			"Attended 4+ ANC visits last 2 years"
    cov_anc42 = w_mean(rh_anc_4vs2, wt, na.rm = TRUE),
    sd_anc42 = w_sd(rh_anc_4vs2, wt, na.rm = TRUE),
    se_anc42 = w_se(rh_anc_4vs2, wt, na.rm = TRUE),
    var_anc42 = w_var(rh_anc_4vs2, wt, na.rm = TRUE),
    num_anc42 = w_sum(rh_anc_4vs2, wt, na.rm = TRUE)*1000000,
    den_anc42 = w_n(rh_anc_4vs2, wt, na.rm = TRUE)*1000000,
    unwgtnum_anc42 = sum(rh_anc_4vs2, na.rm=TRUE),
    unwgtden_anc42 = sum(!is.na(rh_anc_4vs2)))


summary_data_country <- IRdata %>%
  group_by(country_code)%>%
  summarize(
    #anemia women
    cov_anemia_women = w_mean(nt_wm_any_anem, wt, na.rm = TRUE),
    sd_anemia_women = w_sd(nt_wm_any_anem, wt, na.rm = TRUE),
    se_anemia_women = w_se(nt_wm_any_anem, wt, na.rm = TRUE),
    var_anemia_women = w_var(nt_wm_any_anem, wt, na.rm = TRUE),
    num_anemia_women = w_sum(nt_wm_any_anem, wt, na.rm = TRUE)*1000000,
    den_anemia_women = w_n(nt_wm_any_anem, wt, na.rm = TRUE)*1000000,
    unwgtnum_anemia_women = sum(nt_wm_any_anem, na.rm=TRUE),
    unwgtden_anemia_women = sum(!is.na(nt_wm_any_anem)),
    # rh_anc_4vs			"Attended 4+ ANC visits last 2 years"
    cov_anc42 = w_mean(rh_anc_4vs2, wt, na.rm = TRUE),
    sd_anc42 = w_sd(rh_anc_4vs2, wt, na.rm = TRUE),
    se_anc42 = w_se(rh_anc_4vs2, wt, na.rm = TRUE),
    var_anc42 = w_var(rh_anc_4vs2, wt, na.rm = TRUE),
    num_anc42 = w_sum(rh_anc_4vs2, wt, na.rm = TRUE)*1000000,
    den_anc42 = w_n(rh_anc_4vs2, wt, na.rm = TRUE)*1000000,
    unwgtnum_anc42 = sum(rh_anc_4vs2, na.rm=TRUE),
    unwgtden_anc42 = sum(!is.na(rh_anc_4vs2)))

if (exists("IR_data")) {
  IR_data <<- rbind_labelled(IR_data, summary_data)
} else {
  IR_data <<- summary_data
}
saveRDS(IR_data, file="IR_data.rds")

if (exists("IR_data_region")) {
  IR_data_region <<- rbind_labelled(IR_data_region, summary_data_region)
} else {
  IR_data_region <<- summary_data_region
}
saveRDS(IR_data_region, file="IR_data_region.rds")

if (exists("IR_data_country")) {
  IR_data_country <<- rbind_labelled(IR_data_country, summary_data_country)
} else {
  IR_data_country <<- summary_data_country
}
saveRDS(IR_data_country, file="IR_data_country.rds")

}