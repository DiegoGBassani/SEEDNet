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
    
    for country,year in country_year :
    
        code, CODE = get_country_alpha3_code(country)
        
        path_to_country_shape = country_shapefile(country)
        
        with fiona.open(path_to_country_shape, "r") as shapefile:
        
            country_shape = [shape(feature["geometry"]) for feature in shapefile] 
            
            plot_shapes(country_shape, border='k',transparency=0)
    
        path_to_settlements = settlements_shapefile(country, year)
    
        with fiona.open(path_to_settlements, "r") as stlm_shapes:
        
            shapes = [shape(feature["geometry"]) for feature in stlm_shapes]
            
            plot_shapes_with_holes(shapes, transparency=0.3)
            
            plt.axis('off')
    
            plt.gca().set_aspect('equal')
            
            title = 'SETTLEMENTS IN '+country.upper()
            
            plt.title(title)
            
            output = result_root+country+'/'+year+'/'+code+'_'+year+'_sett.png'
            
            plt.savefig(output,dpi=600,bbox_inches='tight',pad_inches=0.05)
            
            plt.clf()
            
            print(country)

    
       
if __name__ == "__main__":
    main()
    
    
    
  
