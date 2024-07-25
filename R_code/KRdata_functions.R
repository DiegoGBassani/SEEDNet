# Project: This code is part of the manuscript "Multi-country settlement level database of health indicators and covariate-free estimation method"
# Manuscript authors: Amir Hossein Darooneh, Jean-Luc Kortenaar, Celine Goulart, Katie McLaughlin, Sean Cornelius, and Diego G. Bassani
# Suggested citation: Darooneh, A.H., et al. Multi-country settlement level database of health indicators and covariate-free estimation method. (2024)
# Program: Create cluster level indicators by cluster for each survey
# Author: Jean-Luc Kortenaar, The Hospital for Sick Children
# Date Created: 2024-07-23
# Last Updated:  2024-07-23
# Description: Calculates all indicators needed from the DHS Children's Recode (KR)
###################
# Attributions:
# DHS indicator calculations were adapted from the DHS Github: https://github.com/DHSProgram/DHS-Indicators-R
###################
#Notes:
# Variables created in this file:
# cov_exclusivelybf "Percentage of children 0-5 months exclusively breastfed"
# cov_lbw "Percentage of children 0-59 months who were born under 2.5kg)
# cov_ORS_treatment "Percentage of children 0-59 months with diarrhea in the last two weeks treated with Oral Rehydration Salts"
# cov_bcg_either "Percentage of children 12-23 months with BCG vaccine according to mother or card"
# cov_dtp_either "Percentage of children 12-23 months with DTP vaccine according to mother or card"
# cov_meas_either "Percentage of children 12-23 months with Measles vaccine according to mother or card"
###################


KR_function<-function(KRdata){
  
# age of child. If b19 is not available in the data use v008 - b3
if ("TRUE" %in% (!("b19" %in% names(KRdata))))
  KRdata [[paste("b19")]] <- NA
if ("TRUE" %in% all(is.na(KRdata$b19)))
{ b19_included <- 0} else { b19_included <- 1}

if (b19_included==1) {
  KRdata <- KRdata %>%
    mutate(age = b19)
} else {
  KRdata <- KRdata %>%
    mutate(age = v008 - b3)
}

dates<-KRdata$v007
year<-min(dates)
KRdata$year<-year
KRdata$country_code<-paste0(KRdata$v000, KRdata$year)


KRdata <- KRdata %>%
  mutate(wt = v005/1000000)

KRdata$UniqueID <- paste(KRdata$v000, KRdata$year, KRdata$v001)
KRdata$region <- to_character(KRdata$v024)
KRdata$UniqueID_region <- paste(KRdata$v000, KRdata$year,  KRdata$v024)

KRdata$b5<-as.integer(KRdata$b5)
KRdata$b9<-as.integer(KRdata$b9)

KRiycf <- KRdata %>%
  subset(age < 24 & b9==0) %>% # children under 24 months living at home
  arrange(caseid, bidx) %>% # make sure the data is sorted
  subset(is.na(lag(caseid)) | caseid!=lag(caseid)) # select just the youngest

KRiycf <- KRiycf %>%
  mutate(wt = v005/1000000)

# *** Breastfeeding and complementary feeding ***
# 
# //currently breastfed
KRiycf <- KRiycf %>%
  mutate(nt_bf_curr =
           case_when(
             m4==95  ~ 1 ,
             m4 %in% c(93,94,98,99) ~ 0)) %>%
  set_value_labels(nt_bf_curr = c("Yes" = 1, "No"=0  )) %>%
  set_variable_labels(nt_bf_curr = "Currently breastfeeding - last-born under 2 years")

# //breastfeeding status
KRiycf <- KRiycf %>%
  mutate(water  = case_when(v409==1  ~ 1 , v409!=1 ~ 0)) %>%
  mutate(liquids= case_when(v409a==1 | v410==1 | v410a==1 | v412c==1 | v413==1 | v413a==1 | v413b==1 | v413c==1 | v413d==1  ~ 1 , 
                            v409a!=1 | v410!=1 | v410a!=1 | v412c!=1 | v413!=1 | v413a!=1 | v413b!=1 | v413c!=1 | v413d!=1 ~ 0)) %>%
  mutate(milk   = case_when(v411==1 | v411a==1 ~ 1 , v411!=1 | v411a!=1 ~ 0)) %>%
  mutate(solids = case_when(v414a==1 | v414b==1 | v414c==1 | v414d==1 | v414e==1 | v414f==1 | v414g==1 | v414h==1 | v414i==1 | 
                              v414j==1 | v414k==1 | v414l==1 | v414m==1 | v414n==1 | v414o==1 | v414p==1 | v414q==1 | v414r==1 | 
                              v414s==1 | v414t==1 | v414u==1 | v414v==1 | v414w==1 | v412a==1 | v412b==1 | m39a==1 ~ 1 ,
                            v414a!=1 | v414b!=1 | v414c!=1 | v414d!=1 | v414e!=1 | v414f!=1 | v414g!=1 | v414h!=1 | v414i!=1 | 
                              v414j!=1 | v414k!=1 | v414l!=1 | v414m!=1 | v414n!=1 | v414o!=1 | v414p!=1 | v414q!=1 | v414r!=1 | 
                              v414s!=1 | v414t!=1 | v414u!=1 | v414v!=1 | v414w!=1 | v412a!=1 | v412b!=1 | m39a!=1~ 0) ) %>%
  mutate(nt_bf_status = case_when(nt_bf_curr==0 ~ 0, solids==1 ~ 5, milk==1 ~ 4, liquids==1 ~3, water==1 ~2, TRUE~1 )) %>%
  set_value_labels(nt_bf_status = c("not bf"=0, "exclusively bf"=1, "bf & plain water"=2, "bf & non-milk liquids"=3, "bf & other milk"=4, "bf & complemenatry foods"=5 )) %>%
  set_variable_labels(nt_bf_status = "Breastfeeding status for last-born child under 2 years")

# //exclusively breastfed
KRiycf <- KRiycf %>%
  mutate(nt_ebf =
           case_when(
             age<6 & nt_bf_status==1  ~ 1 ,
             age<6 & nt_bf_status!=1 ~ 0)) %>%
  set_value_labels(nt_ebf = c("Yes" = 1, "No"=0  )) %>%
  set_variable_labels(nt_ebf = "Exclusively breastfed - last-born under 6 months")

# //Diarrhea symptoms
KRdata <- KRdata %>%
  mutate(ch_diar = 
           case_when(
             (h11==1 | h11==2) & b5==1 ~ 1,
             b5==1 ~ 0  )) %>%
  set_value_labels(ch_diar = c("Yes" = 1, "No"=0)) %>%
  set_variable_labels(ch_diar = "Diarrhea in the 2 weeks before the survey")


# //Diarrhea treatment	
# This is country specific and the footnote for the final table needs to be checked to see what sources are included. 
# The code below only excludes traditional practitioner (usually h12t). 
# The variable for traditional healer may be different for different surveys (you can check this checking all the h12* variables). 


# //ORS
KRdata <- KRdata %>%
  mutate(ch_diar_ors =
           case_when(
             ch_diar==1 & (h13==1 | h13==2 | h13b==1)  ~ 1 ,
             ch_diar==1 ~ 0)) %>%
  set_value_labels(ch_diar_ors = c("Yes" = 1, "No"=0)) %>%
  set_variable_labels(ch_diar_ors = "Given oral rehydration salts for diarrhea")


####VACCINATIONS/VACCINES##########

KRdata <- KRdata %>%
  mutate(agegroup = 
           case_when(
             age>=12 & age<=23 ~ 1,
             age>=24 & age<=35 ~ 2  )) %>%
  set_value_labels(agegroup = c("12-23" = 1, "24-35"=2)) %>%
  set_variable_labels(agegroup = "age group of child for vaccination")

# *** Measles ***

# Selecting children
# Create subset of KRfile to select for children for VAC indicators
# Select agegroup 1 or agegroup 2
KRvac <- KRdata %>%
  subset(agegroup==1 & b5==1) # select age group (12-23m) and live children 

# Source of vaccination information. We need this variable to code vaccination indicators by source.
KRvac <- KRvac %>%
  mutate(source = 
           case_when(h1==1 ~ 1, h1==0 | h1==2 | h1==3 ~ 2  )) %>%
  set_value_labels(source = c("card" = 1, "mother"=2)) %>%
  set_variable_labels(source = "source of vaccination information")

# *** BCG ***
# //BCG either source
KRvac <- KRvac %>%
  mutate(ch_bcg_either = 
           case_when(h2%in%c(1,2,3) ~ 1, h2%in%c(0,8,9)   ~ 0  )) %>%
  set_value_labels(ch_bcg_either = c("Yes" = 1, "No"=0)) %>%
  set_variable_labels(ch_bcg_either = "BCG vaccination according to either source")

######Gabon includes pentavalent, pentacoq, pentaxim and tetracoq in the dtp indicator
#pentacoq =s506e1, s506e2, s506e3 - includes pentavalent, pentacoq and pentaxim (according to the DHS report)
#Tetracoq = s506t1, s506t2, s506t3

code<-first(KRvac$v000)
if(code == "GA6"){ #76.9%
KRvac <- KRvac %>% #triedc(0,8,9,NA)
  mutate(dpt1 = case_when(h3%in%c(1,2,3) ~ 1, h3%in%c(0,8,9) ~ 0  )) %>%
  mutate(dpt2 = case_when(h5%in%c(1,2,3) ~ 1, h5%in%c(0,8,9) ~ 0  )) %>%
  mutate(dpt3 = case_when(h7%in%c(1,2,3) ~ 1, h7%in%c(0,8,9) ~ 0  )) %>%
  mutate(dpt4 = case_when(s506e1%in%c(1,2,3) ~ 1, s506e1%in%c(0,8,9) ~ 0  )) %>%
  mutate(dpt5 = case_when(s506e2%in%c(1,2,3) ~ 1, s506e2%in%c(0,8,9) ~ 0  )) %>%
  mutate(dpt6 = case_when(s506e3%in%c(1,2,3) ~ 1, s506e3%in%c(0,8,9) ~ 0  )) %>%
  mutate(dpt7 = case_when(s506t1%in%c(1,2,3) ~ 1, s506t1%in%c(0,8,9) ~ 0  )) %>%
  mutate(dpt8 = case_when(s506t2%in%c(1,2,3) ~ 1, s506t2%in%c(0,8,9) ~ 0  )) %>%
  mutate(dpt9 = case_when(s506t3%in%c(1,2,3) ~ 1, s506t3%in%c(0,8,9) ~ 0  )) %>%
  mutate(dptsum = dpt1+dpt2+dpt3+dpt4+dpt5+dpt6+dpt7+dpt8+dpt9)%>%
  mutate(dptwg = dptsum*wt)
KRvac <- KRvac %>%
  mutate(ch_pent1_either = case_when(dptsum >=1 ~ 1, dptsum<1 ~ 0  )) %>%
  set_value_labels(ch_pent1_either = c("Yes" = 1, "No"=0)) %>%
  set_variable_labels(ch_pent1_either = "Pentavalent 1st dose vaccination according to either source") %>%
  mutate(ch_pent2_either = case_when(dptsum >=2 ~ 1, dptsum<2 ~ 0  )) %>%
  set_value_labels(ch_pent2_either = c("Yes" = 1, "No"=0)) %>%
  set_variable_labels(ch_pent2_either = "Pentavalent 2nd dose vaccination according to either source") %>%
  mutate(ch_pent3_either = case_when(dptsum >=3 ~ 1, dptsum<3 ~ 0  )) %>%
  set_value_labels(ch_pent3_either = c("Yes" = 1, "No"=0)) %>%
  set_variable_labels(ch_pent3_either = "Pentavalent 3rd dose vaccination according to either source") 
}else{# *** Pentavalent ***
  # //DPT 1, 2, 3 either source
  KRvac <- KRvac %>%
    mutate(dpt1 = case_when(h3%in%c(1,2,3) ~ 1, h3%in%c(0,8) ~ 0  )) %>%
    mutate(dpt2 = case_when(h5%in%c(1,2,3) ~ 1, h5%in%c(0,8) ~ 0  )) %>%
    mutate(dpt3 = case_when(h7%in%c(1,2,3) ~ 1, h7%in%c(0,8) ~ 0  )) %>%
    mutate(dptsum = dpt1 + dpt2 + dpt3)
  
  # See DHS guide to statistics for further explanation
  KRvac <- KRvac %>%
    mutate(ch_pent1_either = case_when(dptsum >=1 ~ 1, TRUE ~ 0  )) %>%
    set_value_labels(ch_pent1_either = c("Yes" = 1, "No"=0)) %>%
    set_variable_labels(ch_pent1_either = "Pentavalent 1st dose vaccination according to either source") %>%
    mutate(ch_pent2_either = case_when(dptsum >=2 ~ 1, TRUE ~ 0  )) %>%
    set_value_labels(ch_pent2_either = c("Yes" = 1, "No"=0)) %>%
    set_variable_labels(ch_pent2_either = "Pentavalent 2nd dose vaccination according to either source") %>%
    mutate(ch_pent3_either = case_when(dptsum >=3 ~ 1, TRUE ~ 0  )) %>%
    set_value_labels(ch_pent3_either = c("Yes" = 1, "No"=0)) %>%
    set_variable_labels(ch_pent3_either = "Pentavalent 3rd dose vaccination according to either source") 
}

# *** Measles ***
# //Measles either source
if("h9a" %in% names(KRdata)){
KRvac <- KRvac %>%
  mutate(ch_meas_either = case_when(
    h9 %in% c(1, 2, 3) | h9a %in% c(1, 2, 3) ~ 1,
    h9 %in% c(0, 8, 9, NA) & h9a %in% c(0,8,9,NA) ~ 0,
    TRUE ~ NA_real_
  )) %>%
  set_value_labels(ch_meas_either = c("Yes" = 1, "No" = 0)) %>%
  set_variable_labels(ch_meas_either = "Measles vaccination according to either source")

KRdata <- KRdata %>%
  mutate(ch_meas_either_u5 = case_when(
    b5 != 1 ~ NA_real_, # If b5 is not 1, set ch_meas_either_u5 to NA
    h9 %in% c(1, 2, 3) | h9a %in% c(1, 2, 3) ~ 1,  # If b5 is 1 and h9 or h9a is in 1, 2, 3, set to 1
    h9 %in% c(0, 8, 9, NA) & h9a %in% c(0, 8, 9, NA) ~ 0, # If b5 is 1 and both h9 and h9a are in 0, 8, 9, or NA, set to 0
    TRUE ~ NA_real_ # Default case
  )) %>%
  set_value_labels(ch_meas_either_u5 = c("Yes" = 1, "No" = 0)) %>%
  set_variable_labels(ch_meas_either_u5 = "Measles vaccination according to either source 0-59 months")
}else{
  KRvac <- KRvac %>%
    mutate(ch_meas_either = case_when(
      h9 %in% c(1, 2, 3) ~ 1,
      h9 %in% c(0, 8, 9, NA) ~ 0,
      TRUE ~ NA_real_
    )) %>%
    set_value_labels(ch_meas_either = c("Yes" = 1, "No" = 0)) %>%
    set_variable_labels(ch_meas_either = "Measles vaccination according to either source")
  
  KRdata <- KRdata %>%
    mutate(ch_meas_either_u5 = case_when(
      b5 != 1 ~ NA_real_, # If b5 is not 1, set ch_meas_either_u5 to NA
      h9 %in% c(1, 2, 3) ~ 1,  # If b5 is 1 and h9 or h9a is in 1, 2, 3, set to 1
      h9 %in% c(0, 8, 9, NA) ~ 0, # If b5 is 1 and both h9 and h9a are in 0, 8, 9, or NA, set to 0
      TRUE ~ NA_real_ # Default case
    )) %>%
    set_value_labels(ch_meas_either_u5 = c("Yes" = 1, "No" = 0)) %>%
    set_variable_labels(ch_meas_either_u5 = "Measles vaccination according to either source 0-59 months")
}
####BIRTH WEIGHT###########

# /*----------------------------------------------------------------------------
# Variables created in this file:
# ch_size_birth	"Size of child at birth as reported by mother"
# ch_report_bw	"Has a reported birth weight"
# ch_below_2p5	"Birth weight less than 2.5 kg"
# ----------------------------------------------------------------------------*/

# //Child's size at birth
KRdata <- KRdata %>%
  mutate(ch_size_birth =
           case_when(
             m18==5  ~ 1 ,
             m18==4  ~ 2 ,
             m18<=3  ~ 3 ,
             m18==8 | m18==9 ~ 9)) %>%
  set_value_labels(ch_size_birth = c("Very small" = 1, "Smaller than average"=2, "Average or larger"=3, "Don't know/missing"=9)) %>%
  set_variable_labels(ch_size_birth = "Size of child at birth as reported by mother")

# //Child's reported birth weight
KRdata <- KRdata %>%
  mutate(ch_report_bw = 
           case_when(
             m19<=9000 ~ 1 ,
             TRUE ~ 0 )) %>%
  set_value_labels(ch_report_bw = c("Yes" = 1, "No"=0)) %>%
  set_variable_labels(ch_report_bw = "Has a reported birth weight")

# //Child before 2.5kg
KRdata <- KRdata %>%
  mutate(ch_below_2p5 = 
           case_when(
             m19<2500 & ch_report_bw==1 ~ 1 ,
             ch_report_bw==1 ~ 0 )) %>%
  set_value_labels(ch_below_2p5 = c("Yes" = 1, "No"=0)) %>%
  set_variable_labels(ch_below_2p5 = "Birth weight less than 2.5 kg")


# Compute weighted mean and standard error for a variable (replace 'var' with your actual variable name)
summary_data <- KRdata %>%
  group_by(UniqueID)%>%
  summarize(
    country_code = first(country_code),
    #diarrhea ORS
    cov_ORS_treatment = w_mean(ch_diar_ors, wt, na.rm = TRUE),
    sd_ORS_treatment = w_sd(ch_diar_ors, wt, na.rm = TRUE),
    se_ORS_treatment = w_se(ch_diar_ors, wt, na.rm = TRUE),
    var_ORS_treatment = w_var(ch_diar_ors, wt, na.rm = TRUE),
    num_ORS_treatment = w_sum(ch_diar_ors, wt, na.rm = TRUE)*1000000,
    den_ORS_treatment = w_n(ch_diar_ors, wt, na.rm = TRUE)*1000000,
    unwgtnum_ORS_treatment = sum(ch_diar_ors, na.rm=TRUE),
    unwgtden_ORS_treatment = sum(!is.na(ch_diar_ors)),
    #ch_below_2p5
    cov_lbw = w_mean(ch_below_2p5, wt, na.rm = TRUE),
    sd_lbw = w_sd(ch_below_2p5, wt, na.rm = TRUE),
    se_lbw = w_se(ch_below_2p5, wt, na.rm = TRUE),
    var_lbw = w_var(ch_below_2p5, wt, na.rm = TRUE),
    num_lbw = w_sum(ch_below_2p5, wt, na.rm = TRUE)*1000000,
    den_lbw = w_n(ch_below_2p5, wt, na.rm = TRUE)*1000000,
    unwgtnum_lbw = sum(ch_below_2p5, na.rm=TRUE),
    unwgtden_lbw = sum(!is.na(ch_below_2p5)),
    #measles vaccination under 0-59 months
    cov_ch_meas_either_u5 = w_mean(ch_meas_either_u5, wt, na.rm = TRUE),
    sd_ch_meas_either_u5 = w_sd(ch_meas_either_u5, wt, na.rm = TRUE),
    se_ch_meas_either_u5 = w_se(ch_meas_either_u5, wt, na.rm = TRUE),
    var_ch_meas_either_u5 = w_var(ch_meas_either_u5, wt, na.rm = TRUE),
    num_ch_meas_either_u5 = w_sum(ch_meas_either_u5, wt, na.rm = TRUE)*1000000,
    den_ch_meas_either_u5 = w_n(ch_meas_either_u5, wt, na.rm = TRUE)*1000000,
    unwgtnum_ch_meas_either_u5 = sum(ch_meas_either_u5, na.rm=TRUE),
    unwgtden_ch_meas_either_u5 = sum(!is.na(ch_meas_either_u5))
  )

summary_data_iycf <- KRiycf %>%
  group_by(UniqueID) %>%
  summarize(
    #nt_ebf
    cov_exclusivelybf = w_mean(nt_ebf, wt, na.rm = TRUE),
    sd_exclusivelybf = w_sd(nt_ebf, wt, na.rm = TRUE),
    se_exclusivelybf = w_se(nt_ebf, wt, na.rm = TRUE),
    var_exclusivelybf = w_var(nt_ebf, wt, na.rm = TRUE),
    num_exclusivelybf = w_sum(nt_ebf, wt, na.rm = TRUE)*1000000,
    den_exclusivelybf = w_n(nt_ebf, wt, na.rm = TRUE)*1000000,
    unwgtnum_exclusivelybf = sum(nt_ebf, na.rm=TRUE),
    unwgtden_exclusivelybf = sum(!is.na(nt_ebf))
  )

summary_data_vac <- KRvac %>%
  group_by(UniqueID)%>%
  summarize(
    #ch_meas_either
    cov_ch_meas_either = w_mean(ch_meas_either, wt, na.rm = TRUE),
    sd_ch_meas_either = w_sd(ch_meas_either, wt, na.rm = TRUE),
    se_ch_meas_either = w_se(ch_meas_either, wt, na.rm = TRUE),
    var_ch_meas_either = w_var(ch_meas_either, wt, na.rm = TRUE),
    num_ch_meas_either = w_sum(ch_meas_either, wt, na.rm = TRUE)*1000000,
    den_ch_meas_either = w_n(ch_meas_either, wt, na.rm = TRUE)*1000000,
    unwgtnum_ch_meas_either = sum(ch_meas_either, na.rm=TRUE),
    unwgtden_ch_meas_either = sum(!is.na(ch_meas_either)),
    #ch_bcg_either
    cov_ch_bcg_either = w_mean(ch_bcg_either, wt, na.rm = TRUE),
    sd_ch_bcg_either = w_sd(ch_bcg_either, wt, na.rm = TRUE),
    se_ch_bcg_either = w_se(ch_bcg_either, wt, na.rm = TRUE),
    var_ch_bcg_either = w_var(ch_bcg_either, wt, na.rm = TRUE),
    num_ch_bcg_either = w_sum(ch_bcg_either, wt, na.rm = TRUE)*1000000,
    den_ch_bcg_either = w_n(ch_bcg_either, wt, na.rm = TRUE)*1000000,
    unwgtnum_ch_bcg_either = sum(ch_bcg_either, na.rm=TRUE),
    unwgtden_ch_bcg_either = sum(!is.na(ch_bcg_either)),
    #ch_dtp = ch_pent3_either
    cov_ch_dtp = w_mean(ch_pent3_either, wt, na.rm = TRUE),
    sd_ch_dtp = w_sd(ch_pent3_either, wt, na.rm = TRUE),
    se_ch_dtp = w_se(ch_pent3_either, wt, na.rm = TRUE),
    var_ch_dtp = w_var(ch_pent3_either, wt, na.rm = TRUE),
    num_ch_dtp = w_sum(ch_pent3_either, wt, na.rm = TRUE)*1000000,
    den_ch_dtp = w_n(ch_pent3_either, wt, na.rm = TRUE)*1000000,
    unwgtnum_ch_dtp = sum(ch_pent3_either, na.rm=TRUE),
    unwgtden_ch_dtp = sum(!is.na(ch_pent3_either))
  )


#Summary Data
summary_data_region <- KRdata %>%
  group_by(UniqueID_region) %>%
  dplyr::summarise(
    region = first(region),
    #diarrhea ORS
    cov_ORS_treatment = w_mean(ch_diar_ors, wt, na.rm = TRUE),
    sd_ORS_treatment = w_sd(ch_diar_ors, wt, na.rm = TRUE),
    se_ORS_treatment = w_se(ch_diar_ors, wt, na.rm = TRUE),
    var_ORS_treatment = w_var(ch_diar_ors, wt, na.rm = TRUE),
    num_ORS_treatment = w_sum(ch_diar_ors, wt, na.rm = TRUE)*1000000,
    den_ORS_treatment = w_n(ch_diar_ors, wt, na.rm = TRUE)*1000000,
    unwgtnum_ORS_treatment = sum(ch_diar_ors, na.rm=TRUE),
    unwgtden_ORS_treatment = sum(!is.na(ch_diar_ors)),
    #ch_below_2p5
    cov_lbw = w_mean(ch_below_2p5, wt, na.rm = TRUE),
    sd_lbw = w_sd(ch_below_2p5, wt, na.rm = TRUE),
    se_lbw = w_se(ch_below_2p5, wt, na.rm = TRUE),
    var_lbw = w_var(ch_below_2p5, wt, na.rm = TRUE),
    num_lbw = w_sum(ch_below_2p5, wt, na.rm = TRUE)*1000000,
    den_lbw = w_n(ch_below_2p5, wt, na.rm = TRUE)*1000000,
    unwgtnum_lbw = sum(ch_below_2p5, na.rm=TRUE),
    unwgtden_lbw = sum(!is.na(ch_below_2p5)),
    #measles vaccination under 0-59 months
    cov_ch_meas_either_u5 = w_mean(ch_meas_either_u5, wt, na.rm = TRUE),
    sd_ch_meas_either_u5 = w_sd(ch_meas_either_u5, wt, na.rm = TRUE),
    se_ch_meas_either_u5 = w_se(ch_meas_either_u5, wt, na.rm = TRUE),
    var_ch_meas_either_u5 = w_var(ch_meas_either_u5, wt, na.rm = TRUE),
    num_ch_meas_either_u5 = w_sum(ch_meas_either_u5, wt, na.rm = TRUE)*1000000,
    den_ch_meas_either_u5 = w_n(ch_meas_either_u5, wt, na.rm = TRUE)*1000000,
    unwgtnum_ch_meas_either_u5 = sum(ch_meas_either_u5, na.rm=TRUE),
    unwgtden_ch_meas_either_u5 = sum(!is.na(ch_meas_either_u5)))

summary_data_iycf_region <- KRiycf %>%
  group_by(UniqueID_region) %>%
  dplyr::summarise(
    #nt_ebf
    cov_exclusivelybf = w_mean(nt_ebf, wt, na.rm = TRUE),
    sd_exclusivelybf = w_sd(nt_ebf, wt, na.rm = TRUE),
    se_exclusivelybf = w_se(nt_ebf, wt, na.rm = TRUE),
    var_exclusivelybf = w_var(nt_ebf, wt, na.rm = TRUE),
    num_exclusivelybf = w_sum(nt_ebf, wt, na.rm = TRUE)*1000000,
    den_exclusivelybf = w_n(nt_ebf, wt, na.rm = TRUE)*1000000,
    unwgtnum_exclusivelybf = sum(nt_ebf, na.rm=TRUE),
    unwgtden_exclusivelybf = sum(!is.na(nt_ebf))
  )

summary_data_vac_region <- KRvac %>%
  group_by(UniqueID_region) %>%
  dplyr::summarise(
    #ch_meas_either
    cov_ch_meas_either = w_mean(ch_meas_either, wt, na.rm = TRUE),
    sd_ch_meas_either = w_sd(ch_meas_either, wt, na.rm = TRUE),
    se_ch_meas_either = w_se(ch_meas_either, wt, na.rm = TRUE),
    var_ch_meas_either = w_var(ch_meas_either, wt, na.rm = TRUE),
    num_ch_meas_either = w_sum(ch_meas_either, wt, na.rm = TRUE)*1000000,
    den_ch_meas_either = w_n(ch_meas_either, wt, na.rm = TRUE)*1000000,
    unwgtnum_ch_meas_either = sum(ch_meas_either, na.rm=TRUE),
    unwgtden_ch_meas_either = sum(!is.na(ch_meas_either)),
    #ch_bcg_either
    cov_ch_bcg_either = w_mean(ch_bcg_either, wt, na.rm = TRUE),
    sd_ch_bcg_either = w_sd(ch_bcg_either, wt, na.rm = TRUE),
    se_ch_bcg_either = w_se(ch_bcg_either, wt, na.rm = TRUE),
    var_ch_bcg_either = w_var(ch_bcg_either, wt, na.rm = TRUE),
    num_ch_bcg_either = w_sum(ch_bcg_either, wt, na.rm = TRUE)*1000000,
    den_ch_bcg_either = w_n(ch_bcg_either, wt, na.rm = TRUE)*1000000,
    unwgtnum_ch_bcg_either = sum(ch_bcg_either, na.rm=TRUE),
    unwgtden_ch_bcg_either = sum(!is.na(ch_bcg_either)),
    #ch_dtp = ch_pent3_either
    cov_ch_dtp = w_mean(ch_pent3_either, wt, na.rm = TRUE),
    sd_ch_dtp = w_sd(ch_pent3_either, wt, na.rm = TRUE),
    se_ch_dtp = w_se(ch_pent3_either, wt, na.rm = TRUE),
    var_ch_dtp = w_var(ch_pent3_either, wt, na.rm = TRUE),
    num_ch_dtp = w_sum(ch_pent3_either, wt, na.rm = TRUE)*1000000,
    den_ch_dtp = w_n(ch_pent3_either, wt, na.rm = TRUE)*1000000,
    unwgtnum_ch_dtp = sum(ch_pent3_either, na.rm=TRUE),
    unwgtden_ch_dtp = sum(!is.na(ch_pent3_either))
  )

#Summary Data
summary_data_country <- KRdata %>%
  group_by(country_code) %>%
  dplyr::summarise(
    #diarrhea ORS
    cov_ORS_treatment = w_mean(ch_diar_ors, wt, na.rm = TRUE),
    sd_ORS_treatment = w_sd(ch_diar_ors, wt, na.rm = TRUE),
    se_ORS_treatment = w_se(ch_diar_ors, wt, na.rm = TRUE),
    var_ORS_treatment = w_var(ch_diar_ors, wt, na.rm = TRUE),
    num_ORS_treatment = w_sum(ch_diar_ors, wt, na.rm = TRUE)*1000000,
    den_ORS_treatment = w_n(ch_diar_ors, wt, na.rm = TRUE)*1000000,
    unwgtnum_ORS_treatment = sum(ch_diar_ors, na.rm=TRUE),
    unwgtden_ORS_treatment = sum(!is.na(ch_diar_ors)),
    #ch_below_2p5
    cov_lbw = w_mean(ch_below_2p5, wt, na.rm = TRUE),
    sd_lbw = w_sd(ch_below_2p5, wt, na.rm = TRUE),
    se_lbw = w_se(ch_below_2p5, wt, na.rm = TRUE),
    var_lbw = w_var(ch_below_2p5, wt, na.rm = TRUE),
    num_lbw = w_sum(ch_below_2p5, wt, na.rm = TRUE)*1000000,
    den_lbw = w_n(ch_below_2p5, wt, na.rm = TRUE)*1000000,
    unwgtnum_lbw = sum(ch_below_2p5, na.rm=TRUE),
    unwgtden_lbw = sum(!is.na(ch_below_2p5)),
    #measles vaccination under 0-59 months
    cov_ch_meas_either_u5 = w_mean(ch_meas_either_u5, wt, na.rm = TRUE),
    sd_ch_meas_either_u5 = w_sd(ch_meas_either_u5, wt, na.rm = TRUE),
    se_ch_meas_either_u5 = w_se(ch_meas_either_u5, wt, na.rm = TRUE),
    var_ch_meas_either_u5 = w_var(ch_meas_either_u5, wt, na.rm = TRUE),
    num_ch_meas_either_u5 = w_sum(ch_meas_either_u5, wt, na.rm = TRUE)*1000000,
    den_ch_meas_either_u5 = w_n(ch_meas_either_u5, wt, na.rm = TRUE)*1000000,
    unwgtnum_ch_meas_either_u5 = sum(ch_meas_either_u5, na.rm=TRUE),
    unwgtden_ch_meas_either_u5 = sum(!is.na(ch_meas_either_u5))
  )

summary_data_iycf_country <- KRiycf %>%
  group_by(country_code) %>%
  dplyr::summarise(
    #nt_ebf
    cov_exclusivelybf = w_mean(nt_ebf, wt, na.rm = TRUE),
    sd_exclusivelybf = w_sd(nt_ebf, wt, na.rm = TRUE),
    se_exclusivelybf = w_se(nt_ebf, wt, na.rm = TRUE),
    var_exclusivelybf = w_var(nt_ebf, wt, na.rm = TRUE),
    num_exclusivelybf = w_sum(nt_ebf, wt, na.rm = TRUE)*1000000,
    den_exclusivelybf = w_n(nt_ebf, wt, na.rm = TRUE)*1000000,
    unwgtnum_exclusivelybf = sum(nt_ebf, na.rm=TRUE),
    unwgtden_exclusivelybf = sum(!is.na(nt_ebf))
  )

summary_data_vac_country <- KRvac %>%
  group_by(country_code) %>%
  dplyr::summarise(
    #ch_meas_either
    cov_ch_meas_either = w_mean(ch_meas_either, wt, na.rm = TRUE),
    sd_ch_meas_either = w_sd(ch_meas_either, wt, na.rm = TRUE),
    se_ch_meas_either = w_se(ch_meas_either, wt, na.rm = TRUE),
    var_ch_meas_either = w_var(ch_meas_either, wt, na.rm = TRUE),
    num_ch_meas_either = w_sum(ch_meas_either, wt, na.rm = TRUE)*1000000,
    den_ch_meas_either = w_n(ch_meas_either, wt, na.rm = TRUE)*1000000,
    unwgtnum_ch_meas_either = sum(ch_meas_either, na.rm=TRUE),
    unwgtden_ch_meas_either = sum(!is.na(ch_meas_either)),
    #ch_bcg_either
    cov_ch_bcg_either = w_mean(ch_bcg_either, wt, na.rm = TRUE),
    sd_ch_bcg_either = w_sd(ch_bcg_either, wt, na.rm = TRUE),
    se_ch_bcg_either = w_se(ch_bcg_either, wt, na.rm = TRUE),
    var_ch_bcg_either = w_var(ch_bcg_either, wt, na.rm = TRUE),
    num_ch_bcg_either = w_sum(ch_bcg_either, wt, na.rm = TRUE)*1000000,
    den_ch_bcg_either = w_n(ch_bcg_either, wt, na.rm = TRUE)*1000000,
    unwgtnum_ch_bcg_either = sum(ch_bcg_either, na.rm=TRUE),
    unwgtden_ch_bcg_either = sum(!is.na(ch_bcg_either)),
    #ch_dtp = ch_pent3_either
    cov_ch_dtp = w_mean(ch_pent3_either, wt, na.rm = TRUE),
    sd_ch_dtp = w_sd(ch_pent3_either, wt, na.rm = TRUE),
    se_ch_dtp = w_se(ch_pent3_either, wt, na.rm = TRUE),
    var_ch_dtp = w_var(ch_pent3_either, wt, na.rm = TRUE),
    num_ch_dtp = w_sum(ch_pent3_either, wt, na.rm = TRUE)*1000000,
    den_ch_dtp = w_n(ch_pent3_either, wt, na.rm = TRUE)*1000000,
    unwgtnum_ch_dtp = sum(ch_pent3_either, na.rm=TRUE),
    unwgtden_ch_dtp = sum(!is.na(ch_pent3_either))
  )

cluster_list <- list(summary_data, summary_data_iycf, summary_data_vac)
region_list <- list(summary_data_region, summary_data_iycf_region, summary_data_vac_region)
country_list <- list(summary_data_country, summary_data_iycf_country, summary_data_vac_country)


merged_cluster<- cluster_list %>% reduce(full_join, by="UniqueID")
merged_region<-region_list %>% reduce(full_join, by = "UniqueID_region")
merged_country<-country_list %>% reduce(full_join, by = "country_code")



if (exists("KR_data")) {
  KR_data <<- rbind(KR_data, merged_cluster)
} else {
  KR_data <<- merged_cluster
}
saveRDS(KR_data, file="KR_data.rds")

if (exists("KR_data_region")) {
  KR_data_region <<- rbind_labelled(KR_data_region, merged_region)
} else {
  KR_data_region <<- merged_region
}
saveRDS(KR_data_region, file="KR_data_region.rds")

if (exists("KR_data_country")) {
  KR_data_country <<- rbind_labelled(KR_data_country, merged_country)
} else {
  KR_data_country <<- merged_country
}
saveRDS(KR_data_country, file="KR_data_country.rds")
}
