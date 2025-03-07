'''
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
'''
import pandas as pd
import pyreadstat
import numpy as np
import os
import matplotlib.pyplot as plt
import geopandas as gpd
import rasterio
import rasterio.mask
import fiona
import pycountry
import networkx as nx
from math import sin, cos, sqrt, atan2, radians

from shapely.geometry import Point, Polygon, MultiPoint, MultiPolygon
from shapely.ops import voronoi_diagram

import pyproj
from pyproj import Transformer
from shapely.ops import transform
from functools import partial

import multiprocessing

import warnings
warnings.filterwarnings('ignore')

from lidw_functions import *





   
###################################################################################################
###################################################################################################

def main():

    indicators=read_list_of_indicators()

    country_year = read_list_of_country_years()
    
    inputs = [('Cambodia', '2014', 'cov_ph_electric'), 
              ('Cambodia', '2014', 'cov_sourcewater'), 
              ('Cambodia', '2014', 'cov_iodized_salt'), 
              ('Cambodia', '2014', 'cov_anemia_women'), 
              ('Cambodia', '2014', 'cov_anc42'), 
              ('Cambodia', '2014', 'cov_ORS_treatment'),
              ('Gabon', '2012', 'cov_ph_electric'), 
              ('Gabon', '2012', 'cov_sourcewater'), 
              ('Gabon', '2012', 'cov_iodized_salt'), 
              ('Gabon', '2012', 'cov_anemia_women'), 
              ('Gabon', '2012', 'cov_anc42'), 
              ('Nigeria', '2013', 'cov_ph_electric'),
              ('Nigeria', '2013', 'cov_sourcewater'), 
              ('Nigeria', '2013', 'cov_anc42'), 
              ('Nigeria', '2013', 'cov_anemia_children'), 
              ('Zambia', '2018', 'cov_ph_electric'), 
              ('Zambia', '2018', 'cov_sourcewater'), 
              ('Zambia', '2018', 'cov_iodized_salt'), 
              ('Zambia', '2018', 'cov_anemia_women'), 
              ('Zambia', '2018', 'cov_anc42'), 
              ('Zambia', '2018', 'cov_itn_u5')]
    
    
    
    with multiprocessing.Pool(processes=os.cpu_count()) as pool:
        outputs=pool.map(local_inverse_distance_weighting_interpolation, inputs)
    
    
    
    
       
if __name__ == "__main__":
    main()
    
    
    
  
