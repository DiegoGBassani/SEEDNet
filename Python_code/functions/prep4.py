"""
# Project: This code is part of the manuscript "SEEDNet: A covariate-free multi-country settlement-level database of epidemiological estimates for network analysis"
# Manuscript authors: Amir Hossein Darooneh, Jean-Luc Kortenaar, Celine Goulart, Katie McLaughlin, Sean Cornelius, and Diego G. Bassani
# Suggested citation: Darooneh, A.H., et al. SEEDNet: A covariate-free multi-country settlement-level database of epidemiological estimates for network analysis. (2024)
# Program: Python functions for estimation, validation and results
# Author: Darooneh, A.H., The Hospital for Sick Children
# Date Created: 2024-06-19
# Last Updated:  2024-07-29
# Description: Functions for settlement identification
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
    
    for country,year in country_year :
    
        polygonize_settlements(country,year)
    
    
    
    
       
if __name__ == "__main__":
    main()
    
    
    
  
