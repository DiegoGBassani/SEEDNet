# Project: This code is part of the manuscript "Multi-country settlement level database of health indicators and covariate-free estimation method"
# Manuscript authors: Amir Hossein Darooneh, Jean-Luc Kortenaar, Celine Goulart, Katie McLaughlin, Sean Cornelius, and Diego G. Bassani
# Suggested citation: Darooneh, A.H., et al. Multi-country settlement level database of health indicators and covariate-free estimation method. (2024)
# Program: Calculate indicator prevalence at the cluster level for each survey
# Author: Jean-Luc Kortenaar, The Hospital for Sick Children
# Date Created: 2024-07-23
# Last Updated:  2024-07-23
# Description: Cleans the downloaded datasets by calculating the relevant indicators for all survey datasets
###################
# Attributions:
# DHS indicator calculations were adapted from the DHS Github: https://github.com/DHSProgram/DHS-Indicators-R
###################
#Notes:

###################
#Step 1: Run through each dataset and clean
source("identify_datasets.R") #creates vector (lists) of all datasets in folder_path that are HR, PR, IR, KR ...
source("PRdata_functions.R")
source("HRdata_functions.R")
source("IRdata_functions.R")
source("KRdata_functions.R")
source("HRPR_function.R")
# Loop through the file names and apply the PRdata function to each dataset
for (file_name in file_names_PR) {
  # Load the dataset
  dataset <- readRDS(file_name)
  

  # Call the PR function on the dataset
  PR_function(dataset)
  print(file_name)
  
  # Save the modified dataset back to disk if desired
  saveRDS(dataset, file_name)
}

PR_data<-readRDS("PR_data.rds")
PR_data_region<-readRDS("PR_data_region.rds")
PR_data_country<-readRDS("PR_data_country.rds")


#HR data
for (file_name in file_names_HR) {
  # Load the dataset
  dataset <- readRDS(file_name)
  
  # Call the HR function on the dataset
  HR_function(dataset)
  print(file_name)
  
  # Save the modified dataset back to disk if desired
  saveRDS(dataset, file_name)
}
HR_data<-readRDS("HR_data.rds")
HR_data_region<-readRDS("HR_data_region.rds")
HR_data_country<-readRDS("HR_data_country.rds")


#IR data
#ngir <- readRDS("project_one/datasets/NGIR7BFL.rds")
#IR_function(ngir)

for (file_name in file_names_IR) {
  # Load the dataset
  dataset <- readRDS(file_name)
  
  # Call the IR function on the dataset
  IR_function(dataset)
  
  print(file_name)
  # Save the modified dataset back to disk if desired
  saveRDS(dataset, file_name)
}
IR_data<-readRDS("IR_data.rds")
IR_data_region<-readRDS("IR_data_region.rds")
IR_data_country<-readRDS("IR_data_country.rds")


#KR data
for (file_name in file_names_KR) {
  # Load the dataset
  dataset <- readRDS(file_name)
  
  # Call the KR function on the dataset
  KR_function(dataset)
  print(file_name)
  
  # Save the modified dataset back to disk if desired
  saveRDS(dataset, file_name)
}

KR_data<-readRDS("KR_data.rds")
KR_data_region<-readRDS("KR_data_region.rds")
KR_data_country<-readRDS("KR_data_country.rds")

for (file_name in file_names_HR){
  data1<- paste0(substr(file_name, nchar(file_name) - 11, nchar(file_name) - 10),
                 substr(file_name, nchar(file_name) - 7, nchar(file_name) - 6))
  for (file in file_names_PR){
    data2<- paste0(substr(file, nchar(file) - 11, nchar(file) - 10),
                   substr(file, nchar(file) - 7, nchar(file) - 6))
    if(data1==data2){
    dataset1<-readRDS(file_name)
    dataset2<-readRDS(file)
    print(file)
    HRPR_function(dataset1, dataset2)
    print(file_name)
    }else{}
  }
}
HRPR_data<-readRDS("HRPR_data.rds")
HRPR_data_region<-readRDS("HRPR_data_region.rds")
HRPR_data_country<-readRDS("HRPR_data_country.rds")


myColumns<- c("DHSCC", "DHSYEAR","DHSCLUST", "URBAN_RURA", "LATNUM", "LONGNUM")
if (!exists("GE_data")) {
  # If GE_data doesn't exist, initialize it as NULL
  GE_data <- NULL
}

for (file_name in file_names_GE) {
  # Load the dataset
  print(file_name)
  dataset <- readRDS(file_name)
  dataset<-select(dataset, all_of(myColumns))
  if (exists("GE_data")) {
    # Merge datasets based on common columns
    GE_data <<- bind_rows(GE_data, dataset)
  } else {
    GE_data <<- dataset
  }
}
CCC<-read.csv("Country code converter DHS.csv")
GE_data<-merge(GE_data, CCC, by.x ="DHSCC", by.y="code", all.x=TRUE)
GE_data$UniqueID <- paste(GE_data$DHSCC, GE_data$DHSYEAR, GE_data$DHSCLUST)
saveRDS(GE_data, file="GE_data.rds")




