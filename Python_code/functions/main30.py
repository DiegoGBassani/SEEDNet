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
import matplotlib.cm as cm
import matplotlib as mpl
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap, LinearSegmentedColormap
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
    country_year = read_list_of_country_years()

    for country, year in country_year:
        try:
            code, CODE = get_country_alpha3_code(country)
            if code is None:
                print(f"Skipping {country} due to invalid country code")
                continue

            path_to_country_shape = country_shapefile(country)
            print(f"Attempting to open country shapefile: {path_to_country_shape}")
            if not os.path.exists(path_to_country_shape):
                print(f"Country shapefile not found for {country}. Skipping.")
                continue

            with fiona.open(path_to_country_shape, "r") as shapefile:
                country_shape = [shape(feature["geometry"]) for feature in shapefile]
                plot_shapes(country_shape, border='k', transparency=0)

            shapefile_year = str(nearest_settlement_year(year))
            path_to_settlements = settlements_shapefile(country, shapefile_year)
            print(f"Attempting to open settlements shapefile: {path_to_settlements}")

            while not os.path.exists(path_to_settlements) and int(shapefile_year) >= 1980:
                print(f"Settlements shapefile not found for {country} {shapefile_year}. Trying earlier year.")
                shapefile_year = str(int(shapefile_year) - 5)
                path_to_settlements = settlements_shapefile(country, shapefile_year)

            if not os.path.exists(path_to_settlements):
                print(f"No settlements shapefile found for {country} for any year. Skipping.")
                continue

            with fiona.open(path_to_settlements, "r") as stlm_shapes:
                shapes = [shape(feature["geometry"]) for feature in stlm_shapes]
                plot_shapes_with_holes(shapes, transparency=0.3)

                plt.axis('off')
                plt.gca().set_aspect('equal')
                title = f'SETTLEMENTS IN {country.upper()}'
                plt.title(title)

                output = f"{result_root}{country}/{year}/{code}_{year}_sett.png"
                os.makedirs(os.path.dirname(output), exist_ok=True)
                plt.savefig(output, dpi=600, bbox_inches='tight', pad_inches=0.05)
                plt.clf()

                print(f"Successfully processed {country} for year {year}")

        except Exception as e:
            print(f"Error processing {country} for year {year}: {str(e)}")
            plt.clf()  # Clear the current figure in case of an error
            continue

    print("All countries processed.")


if __name__ == "__main__":
    main()




