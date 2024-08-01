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

warnings.filterwarnings('ignore')

from lidw_functions import *


###################################################################################################
###################################################################################################

def main():
    inputs = [('Cambodia', '2014', 'cov_ch_meas_either_u5'),

              ('Mozambique', '2011', 'cov_ch_meas_either_u5'),

              ('Nigeria', '2013', 'cov_ch_meas_either_u5')]

    with multiprocessing.Pool(processes=os.cpu_count()) as pool:
        outputs = pool.map(validation_network_level, inputs)


if __name__ == "__main__":
    main()




