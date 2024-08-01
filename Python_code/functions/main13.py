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
import multiprocessing
import warnings
from lidw_functions import *

warnings.filterwarnings('ignore')


###################################################################################################
###################################################################################################

def main():
    indicators = read_list_of_indicators()
    country_year = read_list_of_country_years()

    inputs = []
    range10 = list(range(10)) + [100]

    for country, year in country_year:
        for indicator in indicators:
            inputs = inputs + [(country, year, indicator, n) for n in range10]

    with multiprocessing.Pool(processes=os.cpu_count()) as pool:
        outputs = pool.map(validation_settlement_level_10, inputs)

    # [plot_indicator_raster_with_border_10(('Senegal', '2019', 'cov_exclusivelybf',n)) for n in range(10)]


if __name__ == "__main__":
    main()




