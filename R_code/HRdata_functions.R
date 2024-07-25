# Project: This code is part of the manuscript "Multi-country settlement level database of health indicators and covariate-free estimation method"
# Manuscript authors: Amir Hossein Darooneh, Jean-Luc Kortenaar, Celine Goulart, Katie McLaughlin, Sean Cornelius, and Diego G. Bassani
# Suggested citation: Darooneh, A.H., et al. Multi-country settlement level database of health indicators and covariate-free estimation method. (2024)
# Program: Create cluster level indicators by cluster for each survey
# Author: Jean-Luc Kortenaar, The Hospital for Sick Children
# Date Created: 2024-07-23
# Last Updated:  2024-07-23
# Description: Calculates all indicators needed from the DHS Household Recode (HR)
###################
# Attributions:
# DHS indicator calculations were adapted from the DHS Github: https://github.com/DHSProgram/DHS-Indicators-R
###################
#Notes:
# Variables created in this file:
# cov_ph_electric
# cov_iodized_salt
# cov_sourcewater
###################


HR_function<-function(HRdata){

HRdata <- HRdata %>%
  mutate(wt = hv005/1000000)

dates<-HRdata$hv007
year<-min(dates)
HRdata$year<-year

# //Have iodized salt
HRdata <- HRdata %>%
  mutate(nt_salt_iod =
           case_when(
             hv234a ==1 & hv234a<3  ~ 1 ,
             hv234a ==0 & hv234a<3 ~ 0)) %>%
  set_value_labels(nt_salt_iod = c("Yes" = 1, "No"=0  )) %>%
  set_variable_labels(nt_salt_iod = "Households with iodized salt")

# *** Household characteristics ***
# //Have electricity

code<-first(HRdata$hv000)
if(code == "NG6"){
HRdata <- HRdata %>%
  mutate(ph_electric = ifelse(hv206 == 9, 0, hv206)) %>% #Nigeria 2013 did not exclude missing from the denominator
  set_value_labels(ph_electric = c("Yes" = 1, "No"=0)) %>%
  set_variable_labels(ph_electric = "Have electricity")
}else{
  HRdata <- HRdata %>%
    mutate(ph_electric = ifelse(hv206 == 9, NA, hv206)) %>%
    mutate(ph_electric = as.numeric(ph_electric)) %>%
    set_value_labels(ph_electric = c("Yes" = 1, "No"=0)) %>%
    set_variable_labels(ph_electric = "Have electricity")
}

# generate water source indicator ----------------------------------------------
# create a variable for water source, this var will be overwritten if country-specific coding is needed
HRdata <- HRdata %>% mutate(ph_sani_type = hv205)

HRdata$ph_wtr_source <- NA #initialized as NA
HRdata$ph_wtr_source_dry <- NA #TBC
HRdata$ph_wtr_source_wet <- NA #TBC
# country-specific coding ------------------------------------------------------
if (HRdata$hv000[1]=="AF7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==14 ~ 13,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="AL7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==14 ~ 13,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="AM4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==23 ~ 32,
    hv201==32 ~ 31,
    hv201==33 ~ 31,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="AM4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==32 ~ 41,
    hv201==41 ~ 43,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="AM6")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==14 ~ 11,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="AM7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==14 ~ 13,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="AO7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    hv201==33 ~ 21,
    hv201==63 ~ 62,
    TRUE ~ hv201  
  )) }
# same recode for 3 surveys that all have hv000=BD3 (BDHR31, BDHR3A, and BDHR41). BDHR41 does not have category 41 for hv201
if (HRdata$hv000[1]=="BD3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==22 ~ 32,
    hv201==31 ~ 43,
    hv201==32 ~ 43,
    hv201==41 ~ 51,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="BD4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==22 ~ 32,
    hv201==23 ~ 31,
    hv201==24 ~ 32,
    hv201==41 ~ 43,
    hv201==42 ~ 43,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="BD6")  { #had to add this one in
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="BD7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="BF2")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    hv201==51 ~ 61,
    hv201==61 ~ 71,
    hv201==71 ~ 96,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="BF3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 11,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==23 ~ 21,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    hv201==51 ~ 71,
    hv201==61 ~ 65,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="BF4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==23 ~ 32,
    hv201==32 ~ 31,
    hv201==33 ~ 31,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    hv201==44 ~ 43,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="BF7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="BJ3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==22 ~ 31,
    hv201==23 ~ 32,
    hv201==31 ~ 41,
    hv201==32 ~ 43,
    hv201==41 ~ 51,
    hv201==42 ~ 51,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="BJ4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==22 ~ 31,
    hv201==23 ~ 32,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    hv201==52 ~ 51,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="BJ5")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==52 ~ 51,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="BJ7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    hv201==72 ~ 73,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="BO3" & HRdata$hv007[1]<95)  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==13 ~ 14,
    hv201==21 ~ 30,
    hv201==32 ~ 43,
    hv201==51 ~ 61,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="BO3" & HRdata$hv007[1]==98)  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 15,
    hv201==21 ~ 30,
    hv201==31 ~ 43,
    hv201==51 ~ 61,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="BO4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 15,
    hv201==22 ~ 32,
    hv201==42 ~ 43,
    hv201==45 ~ 14,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="BO5")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==44 ~ 43,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="BR2")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==61 ~ 71,
    hv201==71 ~ 96,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="BR3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==61 ~ 71,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="BU7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="CD5")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==32 ~ 31,
    hv201==33 ~ 31,
    hv201==34 ~ 32,
    hv201==35 ~ 32,
    hv201==36 ~ 32,
    hv201==44 ~ 43,
    hv201==45 ~ 43,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="CF3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==11 ~ 12,
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==23 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="CG5" & HRdata$hv007[1]==2005)  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==32 ~ 31,
    hv201==42 ~ 43,
    TRUE ~ hv201   
  )) }
# same recode for two surveys: CIHR35 and CIHR3A both are hv000=CI3. Only survey CIHR35 has categories 51 and 61 for hv201
if (HRdata$hv000[1]=="CI3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==61 ~ 71,
    TRUE ~ hv201
  ))}
if (HRdata$hv000[1]=="CI5")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==23 ~ 32,
    hv201==32 ~ 31,
    hv201==33 ~ 31,
    hv201==42 ~ 40,
    hv201==44 ~ 43,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="CI8")  {
  HRdata$ph_wtr_source <- NA
  HRdata$ph_wtr_source <- as.numeric(HRdata$ph_wtr_source)} #TBC Not updated online yet
if (HRdata$hv000[1]=="CM2")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    hv201==22 ~ 32,
    hv201==31 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 96,
    hv201==61 ~ 71,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="CM3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    hv201==22 ~ 32,
    hv201==31 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 65,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="CM4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 15,
    hv201==22 ~ 32,
    hv201==31 ~ 32,
    hv201==41 ~ 43,
    hv201==42 ~ 41,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="CM7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    hv201==92 ~ 73,
    TRUE ~ hv201 
  )) }
# same recode for two surveys: COHR22 and COHR31. Only survey COHR22 has category 71 for hv201
if (HRdata$hv000[1] %in% c("CO2", "CO3"))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 11,
    hv201==13 ~ 15,
    hv201==14 ~ 13,
    hv201==21 ~ 30,
    hv201==31 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==71 ~ 96,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="CO4" & HRdata$hv007[1]==2000)  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 11,
    hv201==21 ~ 30,
    hv201==41 ~ 43,
    TRUE ~ hv201   
  )) }
# same recode for two surveys COHR53, COHR61, COHR72
if (HRdata$hv000[1]=="CO4" & HRdata$hv007[1]>=2004 | (HRdata$hv000[1] %in% c("CO5", "CO7")))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 11,
    hv201==22 ~ 32,
    hv201==42 ~ 43,
    TRUE ~ hv201 
  )) }
# same recode for two surveys: DRHR21 and DRHR32. Only survey DRHR21 has category 71 for hv201
if (HRdata$hv000[1]=="DR2" | (HRdata$hv000[1]=="DR3" & HRdata$hv007[1]==96))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 30,
    hv201==31 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==61 ~ 71,
    hv201==71 ~ 96,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="DR3" & HRdata$hv007[1]==99 )  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==22 ~ 32,
    hv201==23 ~ 32,
    hv201==25 ~ 31,
    hv201==26 ~ 31,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==61 ~ 71,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="DR4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 30,
    hv201==41 ~ 43,
    TRUE ~ hv201 
  )) }
# same recode for two surveys: EGHR21 and EGHR33. Only survey EGHR21 has category 71 for hv201
if (HRdata$hv000[1] %in% c("EG2", "EG3"))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 43,
    hv201==71 ~ 96,
    TRUE ~ hv201   
  )) }
# same recode for two surveys: EGHR42 and EGHR4A. Both surveys are hv000=EG4. Only survey EGHR42 has category 72 for hv201
if (HRdata$hv000[1]=="EG4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==23 ~ 30,
    hv201==31 ~ 30,
    hv201==32 ~ 30,
    hv201==33 ~ 30,
    hv201==41 ~ 43,
    hv201==72 ~ 65,
    TRUE ~ hv201   
  )) }
# this is survey EGHR51 which is also hv000=EG4 as the previous two surveys. Use hv007=2005 to specify 
if (HRdata$hv000[1]=="EG4" & HRdata$hv007[1]==2005)  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==22 ~ 42,
    hv201==31 ~ 21,
    hv201==32 ~ 31,
    hv201==33 ~ 41,
    hv201==41 ~ 43,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="ET4" & HRdata$hv007[1]==1992)  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 15,
    hv201==21 ~ 32,
    hv201==22 ~ 42,
    hv201==23 ~ 31,
    hv201==24 ~ 41,
    hv201==31 ~ 43,
    hv201==32 ~ 43,
    hv201==41 ~ 51,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="ET4" & HRdata$hv007[1]==1997)  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 15,
    hv201==21 ~ 32,
    hv201==22 ~ 42,
    hv201==31 ~ 21,
    hv201==32 ~ 31,
    hv201==33 ~ 41,
    hv201==41 ~ 43,
    TRUE ~ hv201    
  )) }
# same recode for ETHR71 and ETHR81
if (HRdata$hv000[1]=="ET7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="GA3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==11 ~ 12,
    hv201==12 ~ 13,
    hv201==21 ~ 31,
    hv201==22 ~ 31,
    hv201==23 ~ 32,
    hv201==24 ~ 32,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==41 ~ 51,
    hv201==61 ~ 71,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="GA6")  { 
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==32 ~ 31,
    hv201==33 ~ 32,
    hv201==34 ~ 32,
    hv201==99 ~ 96, #added - not in DHS github
    TRUE ~ hv201   
  ))}
# same recode for two surveys: GHHR31 and GHHR41. Only survey GHHR41 has category 61 for hv201
if (HRdata$hv000[1] %in% c("GH2", "GH3"))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==23 ~ 21,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    hv201==35 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==61 ~ 71,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="GH4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==23 ~ 32,
    hv201==32 ~ 31,
    hv201==33 ~ 31,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    hv201==44 ~ 43,
    hv201==81 ~ 73,
    TRUE ~ hv201 
  )) }
# same recode for two surveys: GHHR5A and GHHR72
if (HRdata$hv000[1] %in% c("GH5", "GH6"))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==72 ~ 73,
    TRUE ~ hv201   
  )) }
# same recode for two surveys: GHHR7B and GHHR82. Both are hv000=GH7
if (HRdata$hv000[1]=="GH7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    hv201==72 ~ 73,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="GM7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="GN3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 41,
    hv201==32 ~ 42,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    hv201==35 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="GN4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==23 ~ 32,
    hv201==32 ~ 31,
    hv201==33 ~ 31,
    hv201==34 ~ 21,
    hv201==44 ~ 43,
    hv201==45 ~ 43,
    TRUE ~ hv201   
  )) }
# same recode for GNHR71 and GNHR81. Both are hv000==GN7
if (HRdata$hv000[1]=="GN7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="GU3" & HRdata$hv007[1]==95)  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==11 ~ 13,
    hv201==12 ~ 13,
    hv201==13 ~ 15,
    hv201==22 ~ 30,
    hv201==32 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==61 ~ 71,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="GU3" & HRdata$hv007[1]==98)  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==11 ~ 13,
    hv201==12 ~ 13,
    hv201==13 ~ 15,
    hv201==14 ~ 13,
    hv201==21 ~ 30,
    hv201==31 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==61 ~ 71,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="GU6")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==14 ~ 15,
    hv201==31 ~ 13,
    hv201==32 ~ 30,
    hv201==41 ~ 43,
    hv201==42 ~ 43,
    hv201==43 ~ 41,
    hv201==44 ~ 42,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="GY4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==22 ~ 32,
    hv201==81 ~ 43,
    hv201==91 ~ 62,
    hv201==92 ~ 72,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="HN5")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 11,
    hv201==14 ~ 11,
    hv201==21 ~ 32,
    hv201==31 ~ 30,
    hv201==32 ~ 21,
    hv201==41 ~ 43,
    hv201==62 ~ 13,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="HN6")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 11,
    hv201==14 ~ 11,
    hv201==31 ~ 30,
    hv201==44 ~ 13,
    hv201==45 ~ 43,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="HT3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==35 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==52 ~ 65,
    hv201==61 ~ 71,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="HT4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 30,
    hv201==32 ~ 30,
    hv201==44 ~ 43,
    hv201==45 ~ 43,
    hv201==81 ~ 65,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="HT5")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==63 ~ 43,
    hv201==64 ~ 65,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="HT6")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    hv201==32 ~ 31,
    hv201==33 ~ 32,
    hv201==34 ~ 32,
    hv201==72 ~ 65,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="HT7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    hv201==72 ~ 65,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="IA2")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==23 ~ 21,
    hv201==24 ~ 21,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==71 ~ 96,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="IA3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==11 ~ 12,
    hv201==12 ~ 13,
    hv201==22 ~ 21,
    hv201==23 ~ 30,
    hv201==24 ~ 32,
    hv201==25 ~ 31,
    hv201==26 ~ 32,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="IA7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    hv201==92 ~ 72,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="ID2")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==22 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==41 ~ 51,
    hv201==71 ~ 96,
    TRUE ~ hv201  
  )) }
# same recode for two surveys: IDHR31 (1994) and IDHR3A (1997). Both are hv000=ID3
if (HRdata$hv000[1]=="ID3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==22 ~ 31,
    hv201==23 ~ 32,
    hv201==31 ~ 41,
    hv201==32 ~ 42,
    hv201==33 ~ 43,
    hv201==41 ~ 51,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="ID4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==23 ~ 32,
    hv201==32 ~ 31,
    hv201==33 ~ 31,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    hv201==44 ~ 43,
    TRUE ~ hv201  
  )) }
# same recode for two surveys: IDHR51 (2002) and IDHR63 (2007). Only IDHR63 has category 81 for hv201
if (HRdata$hv000[1] %in% c("ID5", "ID6"))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==33 ~ 32,
    hv201==34 ~ 32,
    hv201==35 ~ 32,
    hv201==36 ~ 31,
    hv201==37 ~ 31,
    hv201==38 ~ 31,
    hv201==44 ~ 40,
    hv201==45 ~ 43,
    hv201==46 ~ 43,
    hv201==47 ~ 43,
    hv201==81 ~ 72,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="ID7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    hv201==72 ~ 71,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="JO3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 40,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==61 ~ 71,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="JO4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==41 ~ 40,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="KE2")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==22 ~ 32,
    hv201==31 ~ 43,
    hv201==32 ~ 43,
    hv201==41 ~ 51,
    hv201==71 ~ 96,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="KE3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 43,
    hv201==32 ~ 43,
    hv201==41 ~ 51,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="KE4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==32 ~ 31,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    hv201==44 ~ 43,
    TRUE ~ hv201    )) }
if (HRdata$hv000[1]=="KE6")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==14 ~ 13,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="KE7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="KH4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==11 ~ 12,
    hv201==12 ~ 13,
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==32 ~ 31,
    hv201==33 ~ 21,
    hv201==34 ~ 31,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="KH8")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="KK3" & HRdata$hv007[1]==95)  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==51 ~ 61,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="KK3" & HRdata$hv007[1]==99)  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==23 ~ 32,
    hv201==24 ~ 43,
    hv201==51 ~ 61,
    hv201==61 ~ 71,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="KM3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==41 ~ 51,
    hv201==42 ~ 51,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="KY3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==51 ~ 61,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="LB7" & HRdata$hv007[1]==2016)  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    hv201==72 ~ 73,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="LB7" & HRdata$hv007[1] >=2019)  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    hv201==92 ~ 73,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="LS4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==23 ~ 32,
    hv201==32 ~ 31,
    hv201==33 ~ 31,
    hv201==34 ~ 31,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="LS5")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==44 ~ 43,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="MA2")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==61 ~ 71,
    hv201==71 ~ 96,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="MA4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==23 ~ 32,
    hv201==32 ~ 31,
    hv201==33 ~ 31,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    hv201==44 ~ 43,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="MB4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==63 ~ 62,
    hv201==81 ~ 41,
    hv201==82 ~ 42,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="MD2")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==61 ~ 71,
    hv201==71 ~ 96,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="MD3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==22 ~ 30,
    hv201==23 ~ 32,
    hv201==24 ~ 21,
    hv201==25 ~ 30,
    hv201==26 ~ 32,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="MD4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==23 ~ 32,
    hv201==32 ~ 31,
    hv201==33 ~ 31,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    hv201==44 ~ 43,
    TRUE ~ hv201   
  )) }
# same recode for two surveys: MDHR7- (2016) and MDHR8- (2021), both have hv000==MD7
if (HRdata$hv000[1]=="MD7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="ML3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==23 ~ 21,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    hv201==41 ~ 51,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="ML4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==23 ~ 32,
    hv201==32 ~ 31,
    hv201==33 ~ 31,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    hv201==44 ~ 43,
    TRUE ~ hv201  
  )) }
# same recode for two surveys: MLHR7- (2018) and MDHR8- (2021), both have hv000==ML7
if (HRdata$hv000[1]=="ML7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    hv201==72 ~ 73,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="MM7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==14 ~ 13,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="MR7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="MV5")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==52 ~ 51,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="MV7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==14 ~ 13,
    hv201==52 ~ 51,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="MW2")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==13 ~ 12,
    hv201==22 ~ 30,
    hv201==23 ~ 31,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="MW4" & HRdata$hv007[1]==2000)  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==32 ~ 21,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    hv201==44 ~ 43,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="MW4" & HRdata$hv007[1] %in% c(2004,2005))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==22 ~ 32,
    hv201==23 ~ 32,
    hv201==32 ~ 31,
    hv201==33 ~ 31,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    hv201==44 ~ 43,
    TRUE ~ hv201  
  )) }
# same recode for two surveys: MWHR7A (2015) and MWHR7I (2017). Both are hv000=MW7
if (HRdata$hv000[1]=="MW7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="MZ3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 14,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==23 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="MZ4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==11 ~ 12,
    hv201==12 ~ 14,
    hv201==21 ~ 12,
    hv201==22 ~ 14,
    hv201==23 ~ 32,
    hv201==41 ~ 43,
    TRUE ~ hv201  
  )) }
# same recode for two surveys: MZHR62 (2011) and MZHR71 (2015). Both are hv000=MZ6
if (HRdata$hv000[1]=="MZ6")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==33 ~ 21,
    TRUE ~ hv201    )) }
if (HRdata$hv000[1]=="MZ7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="NC3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 43,
    hv201==32 ~ 40,
    hv201==41 ~ 51,
    hv201==61 ~ 65,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="NC4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==31 ~ 30,
    hv201==32 ~ 30,
    hv201==41 ~ 43,
    hv201==42 ~ 40,
    hv201==61 ~ 72,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="NG3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==11 ~ 12,
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==52 ~ 61,
    hv201==61 ~ 71,
    hv201==71 ~ 21,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="NG4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==23 ~ 32,
    hv201==32 ~ 31,
    hv201==33 ~ 31,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    hv201==44 ~ 43,
    hv201==62 ~ 65,
    TRUE ~ hv201 
  )) }
# same recode for three surveys: NGHR61 (2010), NGHR6A (2013), and NGHR71 (2015). All are hv000=NG6
if (HRdata$hv000[1]=="NG6")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==72 ~ 73,
    hv201==99 ~ 96, #added - not in DHS github code
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="NG7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    hv201==92 ~ 73,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="NG8")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    hv201==72 ~ 73,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="NI2")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==61 ~ 71,
    hv201==71 ~ 96,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="NI3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 31,
    hv201==23 ~ 32,
    hv201==24 ~ 32,
    hv201==25 ~ 21,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 62,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="NI5")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==41 ~ 40,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="NI6")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==63 ~ 65,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="NI7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    hv201==72 ~ 73,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="NM2")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    hv201==35 ~ 21,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==71 ~ 96,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="NM4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==22 ~ 42,
    hv201==31 ~ 21,
    hv201==32 ~ 31,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="NP3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==23 ~ 21,
    hv201==24 ~ 21,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==34 ~ 41,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="NP4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==11 ~ 12,
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 21,
    hv201==32 ~ 21,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    hv201==43 ~ 41,
    TRUE ~ hv201 
  )) }
#	same recode for two surveys: NPHR51 (2006) and NPHR61 (2011). 
if (HRdata$hv000[1] %in% c("NP5", "NP6"))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==44 ~ 41,
    TRUE ~ hv201   
  )) }
#	same recode for two surveys: NPHR7H (2016) and NPHR81 (2022). 
if (HRdata$hv000[1] %in% c("NP7", "NP8"))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="NP8")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201    
  )) }
if (HRdata$hv000[1]=="PE2")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==13 ~ 12,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==71 ~ 96,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="PE3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 11,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    TRUE ~ hv201   
  )) }
# same recode for six surveys: PEHR41,51,5I,61,6A,and 6I. The last three surveys all are hv000=PE6. Only survey PEHR41 has category 42 for hv201
if (HRdata$hv000[1] %in% c("PE4", "PE5", "PE6"))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="PG7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="PH2")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 11,
    hv201==22 ~ 12,
    hv201==23 ~ 30,
    hv201==24 ~ 30,
    hv201==31 ~ 32,
    hv201==71 ~ 96,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="PH3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 31,
    hv201==22 ~ 32,
    hv201==31 ~ 41,
    hv201==32 ~ 42,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    hv201==35 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==61 ~ 71,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="PH4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    FTRUE ~ hv201  
  )) }
# same recode for two surveys: PHHR52 (2008) and PHHR61 (2013). Only survey PHHR52 has categories 72 and 73 fpr hv201 
if (HRdata$hv000[1] %in% c("PH5", "PH6"))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==33 ~ 32,
    hv201==72 ~ 14,
    hv201==73 ~ 14,
    TRUE ~ hv201
  )) }
# same recode for two surveys: PHHR71 (2017) and PHHR81 (2022)	
if (HRdata$hv000[1] %in% c("PH7", "PH8"))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="PK2")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==13 ~ 12,
    hv201==23 ~ 21,
    hv201==24 ~ 32,
    hv201==32 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==71 ~ 96,
    TRUE ~ hv201  
  )) }
# same recode for two surveys: PKHR52 (2006) and PKHR61 (2012). Only survey PKHR61 has category 63 for hv201
if (HRdata$hv000[1] %in% c("PK5", "PK6"))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==22 ~ 21,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="PK7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    hv201==63 ~ 72,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="RW2")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==13 ~ 12,
    hv201==23 ~ 21,
    hv201==24 ~ 21,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    TRUE ~ hv201    
  )) }
# same recode for three surveys: RWHR41, RWHR53, and RWHR5A. Survey RWHR41 does not have category 21 for hv201
if (HRdata$hv000[1] %in% c("RW4", "RW5"))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==23 ~ 32,
    hv201==32 ~ 31,
    hv201==33 ~ 31,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    hv201==44 ~ 43,
    TRUE ~ hv201
  )) }
# same recode for two surveys: RWHR7- (2017) and RWHR8- (2019-20), both have hv000=="RW7"
if (HRdata$hv000[1]=="RW7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201
  )) }
# same recode for two surveys: SLHR73 (2016) and SLHR7A- (2019), both have hv000=="SL7"
if (HRdata$hv000[1]=="SL7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    hv201==72 ~ 73,
    TRUE ~ hv201
  )) }
# same recode for two surveys: SNHR21 (1992-93) and SNHR32 (1997). Both are hv000=SN2. Only survey SNHR32 has categories 34, 41, and 61 for variable hv201
if (HRdata$hv000[1]=="SN2")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==11 ~ 12,
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==23 ~ 21,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==61 ~ 71,
    hv201==71 ~ 96,
    TRUE ~ hv201
  )) }
# same recode for two surveys: SNHR4A (2005) and SNHR51 (2006).
if (HRdata$hv000[1] %in% c("SN4", "SN5"))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==23 ~ 32,
    hv201==32 ~ 31,
    hv201==33 ~ 31,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    TRUE ~ hv201
  )) }
# same recode for four surveys: SNHR7Z (2017), SNHR80 (2018), SNHR8B (2019), SNHR8I (2020-21), all are hv000==SN7
if (HRdata$hv000[1]=="SN7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="TD3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 32,
    hv201==22 ~ 31,
    hv201==23 ~ 32,
    hv201==24 ~ 31,
    hv201==31 ~ 43,
    hv201==32 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==61 ~ 65,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="TD4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==11 ~ 12,
    hv201==12 ~ 13,
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==32 ~ 31,
    hv201==44 ~ 43,
    hv201==52 ~ 65,
    hv201==53 ~ 65,
    hv201==54 ~ 65,
    hv201==55 ~ 65,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="TG3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 14,
    hv201==22 ~ 31,
    hv201==23 ~ 32,
    hv201==31 ~ 41,
    hv201==32 ~ 43,
    hv201==41 ~ 51,
    hv201==42 ~ 51,
    hv201==51 ~ 61,
    hv201==61 ~ 71,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="TG6")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==72 ~ 73,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="TG7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    hv201==72 ~ 73,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="TJ7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="TL7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="TR2")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    hv201==41 ~ 51,
    hv201==42 ~ 43,
    hv201==51 ~ 61,
    hv201==61 ~ 71,
    hv201==71 ~ 96,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="TR3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==11 ~ 12,
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 41,
    hv201==32 ~ 40,
    hv201==33 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==61 ~ 71,
    hv201==71 ~ 72,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="TR4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==11 ~ 12,
    hv201==21 ~ 30,
    hv201==31 ~ 30,
    hv201==42 ~ 40,
    hv201==81 ~ 72,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="TR7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==14 ~ 13,
    TRUE ~ hv201
  )) }
# same recode for two surveys: TZHR21 (1991-92) and TZHR3A (1996). Only survey TZHR21 has categories 51 and 71 for hv201
if (HRdata$hv000[1]=="TZ2" | (HRdata$hv000[1]=="TZ3" & HRdata$hv007[1]==96))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    hv201==35 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==71 ~ 96,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="TZ3" & HRdata$hv007[1]==99)  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==22 ~ 31,
    hv201==23 ~ 21,
    hv201==31 ~ 41,
    hv201==32 ~ 42,
    hv201==33 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==61 ~ 71,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="TZ5" & HRdata$hv007[1] %in% c(2003,2004))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==32 ~ 21,
    hv201==44 ~ 43,
    hv201==45 ~ 43,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="TZ4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==23 ~ 32,
    hv201==24 ~ 32,
    hv201==32 ~ 31,
    hv201==33 ~ 31,
    hv201==34 ~ 21,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    hv201==44 ~ 43,
    hv201==62 ~ 65,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="TZ5" & HRdata$hv007[1] %in% c(2007,2008))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==23 ~ 32,
    hv201==24 ~ 32,
    hv201==32 ~ 31,
    hv201==33 ~ 31,
    hv201==34 ~ 21,
    hv201==42 ~ 43,
    hv201==44 ~ 43,
    hv201==62 ~ 65,
    hv201==91 ~ 62,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="TZ5" & HRdata$hv007[1] %in% c(2009, 2010))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==22 ~ 32,
    hv201==23 ~ 32,
    hv201==24 ~ 32,
    hv201==25 ~ 32,
    hv201==33 ~ 31,
    hv201==34 ~ 31,
    hv201==35 ~ 31,
    hv201==36 ~ 21,
    hv201==45 ~ 40,
    TRUE ~ hv201
  )) }
#	same recode for two surveys: TZHR7B (2015-16) and TZHR7I (2017), both are hv000=TZ7
if (HRdata$hv000[1]=="TZ7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="UG3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==23 ~ 21,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==34 ~ 41,
    hv201==41 ~ 51,
    hv201==61 ~ 71,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="UG4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==32 ~ 31,
    hv201==33 ~ 21,
    hv201==34 ~ 21,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    hv201==44 ~ 43,
    hv201==81 ~ 41,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="UG5" & HRdata$hv007[1]==2006)  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==22 ~ 21,
    hv201==23 ~ 21,
    hv201==33 ~ 31,
    hv201==34 ~ 31,
    hv201==35 ~ 32,
    hv201==36 ~ 32,
    hv201==44 ~ 43,
    hv201==45 ~ 43,
    hv201==46 ~ 43,
    hv201==91 ~ 41,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="UG5" & HRdata$hv007[1] %in% c(2009,2010))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==22 ~ 32,
    hv201==23 ~ 32,
    hv201==33 ~ 31,
    hv201==34 ~ 31,
    hv201==35 ~ 21,
    hv201==44 ~ 43,
    hv201==45 ~ 43,
    hv201==46 ~ 43,
    TRUE ~ hv201
  )) }
# same recode can be used for two surveys: UGHR61 and UGHR6A. Only survey UGHR61 has categories 22,23,33,34,35,36,44,45 and 46 and only survey UGHR6A has category 81 for hv201. Both surveys are hv000=UG6 and both are also hv007=2011
if (HRdata$hv000[1]=="UG6")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==22 ~ 21,
    hv201==23 ~ 21,
    hv201==33 ~ 31,
    hv201==34 ~ 31,
    hv201==35 ~ 32,
    hv201==36 ~ 32,
    hv201==44 ~ 43,
    hv201==45 ~ 43,
    hv201==46 ~ 43,
    hv201==81 ~ 41,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="UG6" & HRdata$hv007[1] %in% c(2014,2015))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==22 ~ 21,
    hv201==44 ~ 41,
    hv201==63 ~ 62,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="UG7" & HRdata$hv007[1]==2016)  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    hv201==63 ~ 62,
    hv201==72 ~ 73,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="UG7" & HRdata$hv007[1] %in% c(2018,2019))  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    hv201==63 ~ 62,
    hv201==72 ~ 73,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="UZ3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==61 ~ 71,
    TRUE ~ hv201
  )) }
# same recode for two surveys VNHR31 and VNHR41. Both are hv000=VNT. Only survey VNHR31 has category 61 for hv201
if (HRdata$hv000[1]=="VNT")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==61 ~ 71,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="VNT")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==34 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="VN5")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==11 ~ 12,
    hv201==12 ~ 13,
    hv201==31 ~ 30,
    hv201==32 ~ 30,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    hv201==44 ~ 43,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="YE2")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 11,
    hv201==14 ~ 12,
    hv201==23 ~ 21,
    hv201==24 ~ 32,
    hv201==32 ~ 43,
    hv201==35 ~ 51,
    hv201==36 ~ 43,
    hv201==71 ~ 96,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="YE6")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==14 ~ 72,
    hv201==15 ~ 72,
    hv201==32 ~ 30,
    hv201==43 ~ 40,
    hv201==44 ~ 41,
    hv201==45 ~ 43,
    hv201==72 ~ 62,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="ZA3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==31 ~ 43,
    hv201==41 ~ 51,
    hv201==51 ~ 61,
    hv201==61 ~ 71,
    TRUE ~ hv201
  )) }
if (HRdata$hv000[1]=="ZA7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="ZM2")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 30,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==51 ~ 61,
    hv201==71 ~ 96,
    TRUE ~ hv201 
  )) }
if (HRdata$hv000[1]=="ZM3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 30,
    hv201==22 ~ 32,
    hv201==23 ~ 32,
    hv201==24 ~ 21,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="ZM4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==22 ~ 32,
    hv201==23 ~ 32,
    hv201==24 ~ 32,
    hv201==32 ~ 31,
    hv201==33 ~ 31,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="ZM7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="ZW3")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==12 ~ 13,
    hv201==21 ~ 31,
    hv201==22 ~ 32,
    hv201==23 ~ 21,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    TRUE ~ hv201  
  )) }
if (HRdata$hv000[1]=="ZW4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==21 ~ 31,
    hv201==22 ~ 32,
    hv201==23 ~ 21,
    hv201==31 ~ 40,
    hv201==32 ~ 43,
    hv201==33 ~ 43,
    hv201==41 ~ 51,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="ZW5")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==71 ~ 62,
    hv201==81 ~ 43,
    TRUE ~ hv201   
  )) }
if (HRdata$hv000[1]=="ZW7")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    hv201==13 ~ 14,
    hv201==14 ~ 13,
    TRUE ~ hv201  
  )) }


# special code for Cambodia ----------------------------------------------------

# NOTE: Cambodia collects data on water source for both the wet season and dry season. Below, an indicator is created for the dry season and water source and a wet	season water source. For all following indicators that use water source, only	the water source that corresponds to the season of interview (hv006 = month	of interview) is used.

# 	e.g. If the interview took place during the dry season, then the dry season	water source is used for standard indicators in this code. 


if (HRdata$hv000[1]=="KH4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source_wet= case_when( 
    hv201==11 ~ 12,
    hv201==12 ~ 13,
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==32 ~ 31,
    hv201==33 ~ 21,
    hv201==34 ~ 31,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    TRUE ~ hv201  
  )) }

if (HRdata$hv000[1]=="KH4")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source_dry= case_when( 
    hv201==11 ~ 12,
    hv201==12 ~ 13,
    hv201==21 ~ 32,
    hv201==22 ~ 32,
    hv201==32 ~ 31,
    hv201==33 ~ 21,
    hv201==34 ~ 31,
    hv201==41 ~ 40,
    hv201==42 ~ 43,
    TRUE ~ hv201    
  )) }
if (HRdata$hv000[1]=="KH5" & HRdata$hv007[1]<=2006)  {
  HRdata <- HRdata %>% mutate(ph_wtr_source_wet = hv201w)
}
if (HRdata$hv000[1]=="KH5" & HRdata$hv007[1]<=2006)  {
  HRdata <- HRdata %>% mutate(ph_wtr_source_dry = hv201d)
}
# KHHR61 and KHHR73 used the same variables for wet and dry season
if ((HRdata$hv000[1]=="KH5" & HRdata$hv007[1]>=2010) | HRdata$hv000[1]=="KH6")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source_wet = sh104b)
}
if ((HRdata$hv000[1]=="KH5" & HRdata$hv007[1]>=2010) | HRdata$hv000[1]=="KH6")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source_dry = sh102) #had to change this to ph_wtr_source_dry. Mistake in original DHS code had this also as wet
}


# check if interview took place in dry season or wet season
if (HRdata$hv000[1] %in% c("KH4", "KH5", "KH6")) {
  HRdata <- HRdata %>% mutate(interview_season = case_when(
    hv006 %in% c(2, 3, 4, 11, 12) ~ 1,
    hv006 %in% c(5, 6, 7, 8, 9, 10) ~ 2)) %>%
    set_value_labels(interview_season = c(
      "dry season" = 1,
      "wet season" = 2)) %>%
    set_variable_labels(interview_season = "Interview in dry or rainy season") %>%
    # now replace water_source variable with the variable that matches the interview season
    mutate(ph_wtr_source = case_when( #had to change dhs code from ph_water_source to ph_wtr_source
      interview_season==1 ~ ph_wtr_source_dry,
      interview_season==2 ~ ph_wtr_source_wet))
}
if (HRdata$hv000[1]=="KH6")  {
  HRdata <- HRdata %>% mutate(ph_wtr_source= case_when( 
    ph_wtr_source==99 ~ 96, #added - not in DHS github code
    TRUE ~ ph_wtr_source
  )) }

# create water source indicators -----------------------------------------------

# create water source labels
HRdata$ph_wtr_source<-as.numeric(HRdata$ph_wtr_source)
HRdata <- HRdata %>% mutate(ph_wtr_source = case_when(
  is.na(ph_wtr_source) ~ NA,
  TRUE ~ ph_wtr_source)) %>%
  set_value_labels(ph_wtr_source =
                     c("piped into dwelling" = 11,
                       "piped to yard/plot" = 12,
                       "public tap/standpipe" = 13,
                       "piped to neighbor" = 14,
                       "piped outside of yard/lot" = 15,
                       "tube well or borehole" = 21,
                       "well - protection unspecified" = 30,
                       "protected well" = 31,
                       "unprotected well" = 32,
                       "spring - protection unspecified" = 40,
                       "protected spring" = 41,
                       "unprotected spring" = 42,
                       "surface water (river/dam/lake/pond/stream/canal/irrigation channel)" = 43,
                       "rainwater" = 51,
                       "tanker truck" = 61,
                       "cart with small tank, cistern, drums/cans" = 62,
                       "purchased water" = 65,
                       "bottled water" = 71,
                       "purified water, filtration plant" = 72,
                       "satchet water" = 73,
                       "other" = 96,
                       "missing" = NA)) %>%
  set_variable_labels(ph_wtr_source = "Source of drinking water")

# improved water source
HRdata <- HRdata %>% mutate(ph_wtr_improve = case_when(
  ph_wtr_source %in% c(11, 12, 13, 14, 15, 21, 31, 41, 51, 61, 62, 65, 71, 72, 73) ~ 1,
  ph_wtr_source %in% c(30, 32, 40, 42, 43, 96) ~ 0,
  ph_wtr_source==NA ~ NA)) %>%
  set_value_labels(ph_wtr_improve = c(
    "improved" = 1,
    "unimproved/surface water" = 0,
    "missing" = NA)) %>%
  set_variable_labels(ph_wtr_improve = "Improved Water Source")

HRdata$UniqueID <- paste(HRdata$hv000, HRdata$year, HRdata$hv001)
# Group data by a grouping variable (replace 'group_var' with your actual grouping variable)

HRdata$region <- to_character(HRdata$hv024)
HRdata$country_code<-paste0(HRdata$hv000, HRdata$year)


# Compute weighted mean and standard error for a variable
summary_data <- HRdata %>%
  group_by(UniqueID)%>%
  dplyr::summarize(
    UniqueID = first(UniqueID), # not sure if this line works yet
    #Country
    Region = first(hv024),
    Region_name = first(region),
    Rurality = first(hv025),
    Cluster = first(hv001),
    Country = first(hv000),
    Year = first(year),
    #survey Code
    #region number
    #households with iodized salt
    cov_iodized_salt = w_mean(nt_salt_iod, wt, na.rm = TRUE),
    sd_iodized_salt = w_sd(nt_salt_iod, wt, na.rm = TRUE),
    se_iodized_salt = w_se(nt_salt_iod, wt, na.rm = TRUE),
    var_iodized_salt = w_var(nt_salt_iod, wt, na.rm = TRUE),
    num_iodized_salt = w_sum(nt_salt_iod, wt, na.rm = TRUE)*1000000,
    den_iodized_salt = w_n(nt_salt_iod, wt, na.rm = TRUE)*1000000,
    unwgtnum_iodized_salt = sum(nt_salt_iod, na.rm=TRUE),
    unwgtden_iodized_salt = sum(!is.na(nt_salt_iod)),
    #electricity
    cov_ph_electric = w_mean(ph_electric, wt, na.rm = TRUE),
    sd_ph_electric = w_sd(ph_electric, wt, na.rm = TRUE),
    se_ph_electric = w_se(ph_electric, wt, na.rm = TRUE),
    var_ph_electric = w_var(ph_electric, wt, na.rm = TRUE),
    num_ph_electric= w_sum(ph_electric, wt, na.rm = TRUE)*1000000,
    den_ph_electric = w_n(ph_electric, wt, na.rm = TRUE)*1000000,
    unwgtnum_ph_electric = sum(ph_electric, na.rm=TRUE),
    unwgtden_ph_electric = sum(!is.na(ph_electric)),
    #Improved water source
    cov_sourcewater = w_mean(ph_wtr_improve, wt, na.rm = TRUE),
    sd_sourcewater = w_sd(ph_wtr_improve, wt, na.rm = TRUE),
    se_sourcewater = w_se(ph_wtr_improve, wt, na.rm = TRUE),
    var_sourcewater = w_var(ph_wtr_improve, wt, na.rm = TRUE),
    num_sourcewater= w_sum(ph_wtr_improve, wt, na.rm = TRUE)*1000000,
    den_sourcewater = w_n(ph_wtr_improve, wt, na.rm = TRUE)*1000000,
    unwgtnum_sourcewater = sum(ph_wtr_improve, na.rm=TRUE),
    unwgtden_sourcewater = sum(!is.na(ph_wtr_improve)))
    

HRdata$UniqueID_region <- paste(HRdata$hv000, HRdata$year, HRdata$hv024)
# Group data by a grouping variable (replace 'group_var' with your actual grouping variable)


summary_data_region <- HRdata %>%
  group_by(UniqueID_region)%>%
  dplyr::summarize(
    Region = first(hv024),
    Region_name = first(region),
    Rurality = first(hv025),
    Cluster = first(hv001),
    Country = first(hv000),
    Year = first(year),
    #survey Code
    #region number
    #households with iodized salt
    cov_iodized_salt = w_mean(nt_salt_iod, wt, na.rm = TRUE),
    sd_iodized_salt = w_sd(nt_salt_iod, wt, na.rm = TRUE),
    se_iodized_salt = w_se(nt_salt_iod, wt, na.rm = TRUE),
    var_iodized_salt = w_var(nt_salt_iod, wt, na.rm = TRUE),
    num_iodized_salt = w_sum(nt_salt_iod, wt, na.rm = TRUE)*1000000,
    den_iodized_salt = w_n(nt_salt_iod, wt, na.rm = TRUE)*1000000,
    unwgtnum_iodized_salt = sum(nt_salt_iod, na.rm=TRUE),
    unwgtden_iodized_salt = sum(!is.na(nt_salt_iod)),
    #electricity
    cov_ph_electric = w_mean(ph_electric, wt, na.rm = TRUE),
    sd_ph_electric = w_sd(ph_electric, wt, na.rm = TRUE),
    se_ph_electric = w_se(ph_electric, wt, na.rm = TRUE),
    var_ph_electric = w_var(ph_electric, wt, na.rm = TRUE),
    num_ph_electric= w_sum(ph_electric, wt, na.rm = TRUE)*1000000,
    den_ph_electric = w_n(ph_electric, wt, na.rm = TRUE)*1000000,
    unwgtnum_ph_electric = sum(ph_electric, na.rm=TRUE),
    unwgtden_ph_electric = sum(!is.na(ph_electric)),
    #Improved water source
    cov_sourcewater = w_mean(ph_wtr_improve, wt, na.rm = TRUE),
    sd_sourcewater = w_sd(ph_wtr_improve, wt, na.rm = TRUE),
    se_sourcewater = w_se(ph_wtr_improve, wt, na.rm = TRUE),
    var_sourcewater = w_var(ph_wtr_improve, wt, na.rm = TRUE),
    num_sourcewater= w_sum(ph_wtr_improve, wt, na.rm = TRUE)*1000000,
    den_sourcewater = w_n(ph_wtr_improve, wt, na.rm = TRUE)*1000000,
    unwgtnum_sourcewater = sum(ph_wtr_improve, na.rm=TRUE),
    unwgtden_sourcewater = sum(!is.na(ph_wtr_improve)))

summary_data_country <- HRdata %>%
  group_by(country_code)%>%
  summarize(
    Year = first(year),
    #survey Code
    #region number
    #households with iodized salt
    cov_iodized_salt = w_mean(nt_salt_iod, wt, na.rm = TRUE),
    sd_iodized_salt = w_sd(nt_salt_iod, wt, na.rm = TRUE),
    se_iodized_salt = w_se(nt_salt_iod, wt, na.rm = TRUE),
    var_iodized_salt = w_var(nt_salt_iod, wt, na.rm = TRUE),
    num_iodized_salt = w_sum(nt_salt_iod, wt, na.rm = TRUE)*1000000,
    den_iodized_salt = w_n(nt_salt_iod, wt, na.rm = TRUE)*1000000,
    unwgtnum_iodized_salt = sum(nt_salt_iod, na.rm=TRUE),
    unwgtden_iodized_salt = sum(!is.na(nt_salt_iod)),
    #electricity
    cov_ph_electric = w_mean(ph_electric, wt, na.rm = TRUE),
    sd_ph_electric = w_sd(ph_electric, wt, na.rm = TRUE),
    se_ph_electric = w_se(ph_electric, wt, na.rm = TRUE),
    var_ph_electric = w_var(ph_electric, wt, na.rm = TRUE),
    num_ph_electric= w_sum(ph_electric, wt, na.rm = TRUE)*1000000,
    den_ph_electric = w_n(ph_electric, wt, na.rm = TRUE)*1000000,
    unwgtnum_ph_electric = sum(ph_electric, na.rm=TRUE),
    unwgtden_ph_electric = sum(!is.na(ph_electric)),
    #Improved water source
    cov_sourcewater = w_mean(ph_wtr_improve, wt, na.rm = TRUE),
    sd_sourcewater = w_sd(ph_wtr_improve, wt, na.rm = TRUE),
    se_sourcewater = w_se(ph_wtr_improve, wt, na.rm = TRUE),
    var_sourcewater = w_var(ph_wtr_improve, wt, na.rm = TRUE),
    num_sourcewater = w_sum(ph_wtr_improve, wt, na.rm = TRUE)*1000000,
    den_sourcewater = w_n(ph_wtr_improve, wt, na.rm = TRUE)*1000000,
    unwgtnum_sourcewater = sum(ph_wtr_improve, na.rm=TRUE),
    unwgtden_sourcewater = sum(!is.na(ph_wtr_improve)))

if (exists("HR_data")) {
  HR_data <<- rbind_labelled(HR_data, summary_data)
} else {
  HR_data <<- summary_data
}
saveRDS(HR_data, file="HR_data.rds")

if (exists("HR_data_region")) {
  HR_data_region <<- rbind_labelled(HR_data_region, summary_data_region)
} else {
  HR_data_region <<- summary_data_region
}
saveRDS(HR_data_region, file="HR_data_region.rds")

if (exists("HR_data_country")) {
  HR_data_country <<- rbind_labelled(HR_data_country, summary_data_country)
} else {
  HR_data_country <<- summary_data_country
}
saveRDS(HR_data_country, file="HR_data_country.rds")
}

