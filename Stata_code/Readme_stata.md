
# Instructions
This repository contains the stata code required to replicate the plots submitted with the manuscript.

The files found in the input_files folder are produced after executing the estimation and validation functions that are found in the Python_code folder.

After executing the python code, move the following files to the input_files folder:

    LOOCV_SETTLEMENTS.csv
  
    LOOCV_SETT_DIFF.csv
  
    VALIDATION_combined.csv
  
    kfold_validation.csv
  
    kfold_validation_data.csv (found zipped in this directory)
  
    summary_validation_data.csv (this file is produced using the code found in the R_code folder and is a summary of the indicators from DHS surveys). 
  

The stata .do files can be found in the do_files folder. They can be executed individually or through the P1_Runner_all_do_files.do file

Fine tuning of plots has been done with recorded .grec files, those can be found in the grec_files folder.

