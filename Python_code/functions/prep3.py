"""
# Project: This code is part of the manuscript "SEEDNet: A covariate-free multi-country settlement-level database of epidemiological estimates for network analysis"
# Manuscript authors: Amir Hossein Darooneh, Jean-Luc Kortenaar, Celine Goulart, Katie McLaughlin, Sean Cornelius, and Diego G. Bassani
# Suggested citation: Darooneh, A.H., et al. SEEDNet: A covariate-free multi-country settlement-level database of epidemiological estimates for network analysis. (2024)
# Program: Python functions for estimation, validation and results
# Author: Darooneh, A.H., The Hospital for Sick Children
# Date Created: 2024-06-19
# Last Updated:  2024-07-29
# Description: Functions for settlement identification, extraction of settlement population
# ###################
# Attributions:
# List any attributions
# ###################
"""

import warnings
warnings.filterwarnings('ignore')

from lidw_functions import *




   
###################################################################################################
###################################################################################################

def main():

    country_year = read_list_of_country_years()

    # Download GHS population files for all unique years
    unique_years = set(year for _, year in country_year)
    for year in unique_years:
        download_ghs_pop_file(year)

    #download_ghs_pop_file(country_year)
    
    for x in country_year :
    
        extract_ghs_country_population_raster(x)
    
    
       
if __name__ == "__main__":
    main()
    
    
    
  
