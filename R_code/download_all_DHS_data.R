# Project: This code is part of the manuscript "Multi-country settlement level database of health indicators and covariate-free estimation method"
# Manuscript authors: Amir Hossein Darooneh, Jean-Luc Kortenaar, Celine Goulart, Katie McLaughlin, Sean Cornelius, and Diego G. Bassani
# Suggested citation: Darooneh, A.H., et al. Multi-country settlement level database of health indicators and covariate-free estimation method. (2024)
# Program:  Create cluster level indicators by cluster for each survey
# Author: Jean-Luc Kortenaar, The Hospital for Sick Children
# Date Created: 2024-07-23
# Last Updated:  2024-07-23
# Description: Downloads all datasets from the DHS for the paper
###################
# Attributions:
  # Code was adapted from: Watson OJ, FitzJohn R, Eaton JW (2019). “rdhs: an R package to interact with The Demographic and Health Surveys (DHS) Program datasets.” Wellcome Open Research, 4, 103. doi:10.12688/wellcomeopenres.15311.1, https://wellcomeopenresearch.org/articles/4-103/v1.
###################
#Notes:
# This code will download all DHS datasets used in the paper
# Requires requesting access to the DHS repository for the relevant countries and surveys here: https://dhsprogram.com/data/new-user-registration.cfm
####################

survs <- dhs_surveys(surveyType = "DHS",
                     surveyIds = c("AO2015DHS", "BJ2017DHS","KH2014DHS","GA2012DHS","MW2015DHS","ML2018DHS", "MZ2011DHS", "NG2013DHS", "SN2019DHS","ZM2018DHS")) #Can add specific countryIds = "PK" etc

#This lists all the recodes required.
#IR = Individual recode
#PR = Personal recode
#KR = Child recode
#HR = Household recode
#GE = Geographic Data
datasets <- dhs_datasets(surveyIds = survs$SurveyId, 
                         fileFormat = "flat",
                         fileType = c("IR","PR","KR","HR","GE")) #This should list the datasets being downloaded
str(datasets)

#set credentials
set_rdhs_config(email = email,
                project = project_name,
                config_path = "~/.rdhs.json",
                cache_path<-output_directory,
                password_prompt = TRUE,
                global = TRUE)


#download datasets
downloads <- get_datasets(datasets$FileName, output_dir_root = output_directory, clear_cache=TRUE)


