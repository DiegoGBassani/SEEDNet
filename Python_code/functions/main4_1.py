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

from lidw_functions import *


###################################################################################################
###################################################################################################

def main():
    error_analysis_network_level_utazi()

    res = pd.DataFrame()

    df = []

    for country, year in [('Cambodia', '2014'), ('Mozambique', '2011'), ('Nigeria', '2013')]:
        code, CODE = get_country_alpha3_code(country)

        # input_path = result_root + country + '/' + year + '/' + CODE + '_VAL2_UTAZI.csv'
        input_path = f"{result_root}{country}/{year}/{CODE}_VAL2_UTAZI.csv"

        df.append(pd.read_csv(input_path))

    res = pd.concat(df, ignore_index=True)

    res.to_csv(result_root + 'LOOCV_NET_UTAZI.csv')


if __name__ == "__main__":
    main()




