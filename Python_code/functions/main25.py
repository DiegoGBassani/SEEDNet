"""
# Project: This code is part of the manuscript "SEEDNet: A covariate-free multi-country settlement-level database of epidemiological estimates for network analysis"
# Manuscript authors: Amir Hossein Darooneh, Jean-Luc Kortenaar, Celine Goulart, Katie McLaughlin, Sean Cornelius, and Diego G. Bassani
# Suggested citation: Darooneh, A.H., et al. SEEDNet: A covariate-free multi-country settlement-level database of epidemiological estimates for network analysis. (2024)
# Program: Python functions for estimation, validation and results
# Author: Darooneh, A.H., The Hospital for Sick Children
# Date Created: 2024-06-19
# Last Updated:  2024-07-29
# Description: Functions for settlement identification, LIDW estimation and validation of estimates
# ###################
# Attributions:
# List any attributions
# ###################
"""
import warnings
warnings.filterwarnings('ignore')
import multiprocessing
import os
import pandas as pd
from lidw_functions import *

###################################################################################################
###################################################################################################

def process_country_year(x):
    return x[0], x[1], *ghs_population_count(x)


def main():
    country_year = read_list_of_country_years()

    with multiprocessing.Pool(processes=os.cpu_count()) as pool:
        results = pool.map(process_country_year, country_year)

    res = pd.DataFrame(results, columns=['COUNTRY', 'YEAR', 'POP_TOT', 'SETT_TOT', 'FRAC_TOT'])
    res.to_csv(result_root + 'pop_sett.csv')


if __name__ == "__main__":
    main()