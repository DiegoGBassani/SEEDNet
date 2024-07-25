# Project: This code is part of the manuscript "Multi-country settlement level database of health indicators and covariate-free estimation method"
# Manuscript authors: Amir Hossein Darooneh, Jean-Luc Kortenaar, Celine Goulart, Katie McLaughlin, Sean Cornelius, and Diego G. Bassani
# Suggested citation: Darooneh, A.H., et al. Multi-country settlement level database of health indicators and covariate-free estimation method. (2024)
# Program: Create cluster level indicators by cluster for each survey
# Author: Jean-Luc Kortenaar, The Hospital for Sick Children
# Date Created: 2024-07-23
# Last Updated:  2024-07-23
# Description: Main files that (1) downloads all DHS data and (2) produces cluster, regional and national level estimates for the select indicators, for each survey
###################
# Attributions:
  # DHS indicator calculations were adapted from the DHS Github: https://github.com/DHSProgram/DHS-Indicators-R
###################
#Notes:
#This is the master file that runs all associated functions in order to create the DHS enumeration area estimates as well as regional and country level estimates
#All lines that require input from the user (4) are stored in !main.R with the comment #EDIT

#Step 2 requires signing up to the DHS data repository: https://dhsprogram.com/data/new-user-registration.cfm
#This analysis used the following datasets IR,PR,KR,HR,GE (geospatial dataset) for each of the following countries:
#Angola 2015
#Benin 2017
#Cambodia 2014
#Gabon 2012
#Malawi 2015
#Mali 2018
#Mozambique 2011
#Nigeria 2013
#Senegal 2019
#Zambia 2018
#Step 2 can be skipped if you already have the relevant DHS datasets downloaded.
###############################################################################################################################

#1. Load Libraries
source("libraries.R") #downloads and/or loads all libraries required to run all subsequent scripts

#2. Download and clean data
#2.1 Download data
  #Use the email and project name you used for the sign-up here:
  email<- "youremail@email.com" #EDIT
  project_name<-"Your Full Project Name" #EDIT
  output_directory<- "Your output subdirectory here for all datasets" #EDIT

source("download_all_DHS_data.R") 
  # requires email, project_name, and output_directory
  # Do not need to run if files already downloaded; 

#3.0 Clean data
  folder_path <- "Your folder path here" #EDIT Set main directory

source("clean_datasets.R") 
  #runs through and cleans each dataset in PR, HR, IR, KR, GE
  #HRPR is for indicators that require the merging of the HR and PR datasets
  #code creates appended files _data (cluster level), _data_region, _data_country for each of the datasets (for instance HR_data, HR_data_region...)

source("merge_files.R")
  #merges all cleaned datasets together 
  #by cluster (dataset "D") 
  #by first administrative level (dataset "D_region")
  #at the national level (dataset "D_country")

#Exports clean datasets at the cluster, region and country level
  write.csv(D, "dataset_cluster.csv")
  write.csv(D_region, "dataset_region.csv")
  write.csv(D_country, "dataset_country.csv")
