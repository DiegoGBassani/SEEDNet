import pandas as pd
import numpy as np
import os
os.environ['GDAL_USE_GPU'] = 'YES'
import sys
import wget
import warnings
from pprint import pprint
import zipfile

from math import sin, cos, sqrt, atan2, radians
import random
from functools import partial

import matplotlib.cm as cm
import matplotlib as mpl
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap, LinearSegmentedColormap

from osgeo import gdal, ogr, osr
import pyproj
from pyproj import transformer
from shapely.geometry import Point, Polygon, MultiPoint, MultiPolygon, shape, mapping
from shapely.ops import voronoi_diagram, nearest_points, transform
import fiona
import rasterio
import rasterio.mask
from rasterio.features import rasterize
from rasterio.warp import calculate_default_transform, reproject, Resampling
import geopandas as gpd
import xlsxwriter

import pycountry
import networkx as nx

warnings.filterwarnings('ignore')

standard_crs = "EPSG:4326"


#       THE MAIN PATHS
#----------------------------------------------------------------------------------------------------------

# Setting the base path as an environment variable
base_path = '.'

list_of_country_years = base_path+'/Data/Globe/list_of_countries.csv'
list_of_indicators = base_path+'/Data/Globe/list_of_indicators.csv'
result_root = base_path+'/Results/'
data_root = base_path+'/Data/'
path_to_dhs = data_root + 'Globe/dataset_cluster.csv'


#       THE UTILITY FUNCTION
#------------------------------------------------------------------------------------------------------------
def unzip_file(zip_file_path, extract_to):
    with zipfile.ZipFile(zip_file_path, 'r') as zip_ref:
        zip_ref.extractall(extract_to)


def find_files_by_extension(folder_path, extension):
    matching_files = []
    for root, dirs, files in os.walk(folder_path):
        for file in files:
            if file.endswith(extension):
                matching_files.append(os.path.join(root, file))
    return matching_files


def read_list_of_country_years(path: str = list_of_country_years):
    # Read the CSV file at the given path using pandas
    cy = pd.read_csv(path)

    # Extract the 'country' column and convert it to a list
    countries = []
    for name in cy['country']:
        try:
            country = pycountry.countries.search_fuzzy(name)[0]
            countries.append(country.name)
        except LookupError:
            countries.append(name)  # Keep original if not found

    # Extract the 'country' column and convert it to a list # replaced with lines above
    # country = cy['country'].tolist() # replaced with lines above

    # Extract the 'year' column and convert it to a list
    year = cy['year'].tolist()

    # Create a list of tuples, where each tuple contains a country and its corresponding year
    # result = [(c, str(y)) for c, y in zip(country, year)]
    result = [(c, str(y)) for c, y in zip(countries, year)]

    # Return the resulting list
    return result

def read_list_of_indicators(path: str = list_of_indicators):
    # Read the CSV file at the given path using pandas
    ind=pd.read_csv(path)

    # Create a list of indicators from dataframe
    result = ind['indicator'].tolist()

    # Return the resulting list
    return result

def dictionary_of_indicators(path: str = list_of_indicators):

    result_dict = {}  # Initialize an empty dictionary

    # Read the CSV file using pandas
    df = pd.read_csv(path, header=None)

    # Iterate through the DataFrame rows and populate the dictionary
    for index, row in df.iterrows():
        if len(row) == 2:  # Ensure there are two columns in each row
            key, value = row
            result_dict[key] = value

    return result_dict

def get_country_alpha3_code(name: str):
    name = ' '.join(word.capitalize() for word in name.split())

    # Special cases
    special_cases = {
        "Cape Verde": "CPV",
        "Congo Democratic Republic": "COD",
        # Add more special cases here if needed
    }
    if name in special_cases:
        code = special_cases[name]
        return code.lower(), code

    try:
        # Attempt to find the country object based on the given name
        countries = pycountry.countries.search_fuzzy(name)
        country = pycountry.countries.get(name=name)
        if countries:
            country = countries[0]
            return country.alpha_3.lower(), country.alpha_3
        else:
            print(f"Country not found: {name}")
            return None, None
    except LookupError:
        print(f"Error looking up country: {name}")
        return None, None

        # Extract the three-letter abbreviation (Alpha-3 code) from the country object
        CODE = country.alpha_3

        # Convert the 'Alpha-3 code' to lowercase
        code = CODE.lower()

        # Return the Alpha-3 code
        return code,CODE
    except AttributeError:
        # Handle the case when the country or Alpha-3 code is not found
        return None, None

def get_country_alpha2_code(name: str):
    name = ' '.join(word.capitalize() for word in name.split())
    try:
        countries = pycountry.countries.search_fuzzy(name)
        if countries:
            country = countries[0]
            return country.alpha_2.lower(), country.alpha_2
        else:
            print(f"Country not found: {name}")
            return None, None
    except LookupError:
        print(f"Error looking up country: {name}")
        return None, None

        # Attempt to find the country object based on the given name
        country = pycountry.countries.get(name=name)

        # Extract the three-letter abbreviation (Alpha-2 code) from the country object
        CODE = country.alpha_2

        # Convert the 'Alpha-2 code' to lowercase
        code = CODE.lower()

        # Return the Alpha-2 code
        return code,CODE
    except AttributeError:
        # Handle the case when the country or Alpha-2 code is not found
        return None



def directory_generator(country: str, year: str):
    # Create subfolders for the given country inside the data and result roots
    subfolder_data = data_root + country  # Construct the path for the subfolder in data root
    subfolder_result = result_root + country  # Construct the path for the subfolder in result root

    # Check if the subfolders for the country exist, and if not, create them
    if not os.path.exists(subfolder_data):
        os.makedirs(subfolder_data)  # Create the subfolder in the data root

    if not os.path.exists(subfolder_result):
        os.makedirs(subfolder_result)  # Create the subfolder in the result root

    # Create subsubfolders for the given year inside the country subfolders
    subsubfolder_data = data_root + country + '/' + year  # Construct the path for the subsubfolder in data root
    subsubfolder_result = result_root + country + '/' + year  # Construct the path for the subsubfolder in result root

    # Check if the subsubfolders for the year exist, and if not, create them
    if not os.path.exists(subsubfolder_data):
        os.makedirs(subsubfolder_data)  # Create the subsubfolder in the data root

    if not os.path.exists(subsubfolder_result):
        os.makedirs(subsubfolder_result)  # Create the subsubfolder in the result root

def download_ghs_smod_files(*years, publish_year='2023'):
    # Define the subfolder to save the downloaded files
    subfolder = data_root + 'Globe/'
    print(f"Creating subfolder: {subfolder}")
    os.makedirs(subfolder, exist_ok=True)

    # Create the subfolder if it doesn't exist
    if not os.path.exists(subfolder):
        os.makedirs(subfolder)

    path_to_extracted_files = []

    # Iterate through the specified years
    for year in years:
        # Construct the URL for downloading the file
        url = f'https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_SMOD_GLOBE_R{publish_year}A/GHS_SMOD_E{year}_GLOBE_R{publish_year}A_54009_1000/V1-0/GHS_SMOD_E{year}_GLOBE_R{publish_year}A_54009_1000_V1_0.zip'

        # Define the path to the downloaded zip file and the folder for extracted shapefiles
        file = subfolder + f'GHS_SMOD_GLOBE_R{publish_year}A_{year}.zip'
        folder = subfolder + f'GHS_SMOD_GLOBE_R{publish_year}A_{year}'

        # Download the file using wget
        print(f"Downloading file from: {url}")
        try:
            wget.download(url, file)
            print(f"\nDownload complete: {file}")
        except Exception as e:
            print(f"Error downloading file: {e}")
            continue


        # Extract the downloaded zip file
        print(f"Extracting to folder: {folder}")
        os.makedirs(folder, exist_ok=True)
        try:
            with zipfile.ZipFile(file, 'r') as zip_ref:
                zip_ref.extractall(folder)
            print("Extraction complete")
            tif_files = find_files_by_extension(folder, '.tif')
            if tif_files:
                path_to_extracted_files.append(tif_files[0])
                print(f"Found TIF file: {tif_files[0]}")
            else:
                print("No TIF file found in extracted contents")
        except Exception as e:
            print(f"Error extracting file: {e}")
            continue
        # Remove the downloaded zip file
        if os.path.exists(file):
            try:
                os.remove(file)
                print(f"Removed downloaded zip file: {file}")
            except Exception as e:
                print(f"Error removing zip file {file}: {e}")
        else:
            print(f"Zip file not found: {file}")

    # Reproject all extracted files
    for path_src in path_to_extracted_files:
        # Construct a consistent name for the reprojected file
        base_name = os.path.basename(path_src)
        new_base_name = base_name.replace('_54009_1000_V1_0', '_WGS84')
        path_dst = os.path.join(os.path.dirname(path_src), new_base_name)

        if not os.path.exists(path_dst):
            print(f"Reprojecting: {path_dst}")
            reproject_tif(path_src, path_dst)
        else:
            print(f"File already exists: {path_dst}")

    return path_to_extracted_files


def download_ghs_pop_file():
        # Define the subfolder to save the downloaded files
        subfolder = data_root + 'Globe/'

        # Create the subfolder if it doesn't exist
        if not os.path.exists(subfolder):
            os.makedirs(subfolder)


        # Construct the URL for downloading the file
        url = f'https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_POP_GLOBE_R2023A/GHS_POP_E2015_GLOBE_R2023A_4326_30ss/V1-0/GHS_POP_E2015_GLOBE_R2023A_4326_30ss_V1_0.zip'

        # Define the path to the downloaded zip file and the folder for extracted file
        file = subfolder + f'GHS_POP_E2015_GLOBE_R2023A_4326_30ss_V1_0.tif.zip'
        folder = subfolder + f'GHS_POP_E2015_GLOBE_R2023A_4326_30ss_V1_0'

        # Download the file using wget
        wget.download(url, file)


        # Extract the downloaded zip file
        with zipfile.ZipFile(file, 'r') as zip_ref:
            zip_ref.extractall(folder)


        # Remove the downloaded zip file
        os.remove(file)

def download_ghs_ucdb_file():

        # Define the subfolder to save the downloaded files
        subfolder = data_root + 'Globe/'

        # Create the subfolder if it doesn't exist
        if not os.path.exists(subfolder):
            os.makedirs(subfolder)

        # Construct the URL for downloading the file
        url = f'https://jeodpp.jrc.ec.europa.eu/ftp/jrc-opendata/GHSL/GHS_STAT_UCDB2015MT_GLOBE_R2019A/V1-2/GHS_STAT_UCDB2015MT_GLOBE_R2019A_V1_2.zip'

        # Define the path to the downloaded zip file and the folder for extracted file
        file = subfolder + f'GHS_STAT_UCDB2015MT_GLOBE_R2019A_V1_2.zip'
        folder = subfolder + f'GHS_STAT_UCDB2015MT_GLOBE_R2019A_V1_2'


        # Download the file using wget
        wget.download(url, file)

        # Extract the downloaded zip file
        with zipfile.ZipFile(file, 'r') as zip_ref:
            zip_ref.extractall(folder)

        # Remove the downloaded zip file
        os.remove(file)

        shp_folder = folder + f'/GHS_UCDB/'

        if not os.path.exists(shp_folder):
            os.makedirs(shp_folder)

        gpkg_paths = find_files_by_extension(folder,'.gpkg')

        for gpkg_path in gpkg_paths :

            m = gpkg_path.rfind('/')+1

            layer_name = gpkg_path[m:-5]

            shp_path = shp_folder + f'/'+layer_name+'.shp'

            convert_gpkg_to_shp(gpkg_path, layer_name, shp_path)

def download_measles_tiff(*countries):

    # Create a subfolder for the given country and year inside the data root
    subfolder = data_root + '/Utazi/'   # Construct the path for the subfolder

    if not os.path.exists(subfolder):
            os.makedirs(subfolder)

    for country in countries :

        # Obtain the country's alpha-3 code from the function get_country_alpha3_code(country)
        code, CODE = get_country_alpha3_code(country)

        # Define the URL to download the population TIFF using the country's alpha-3 code and year
        url = 'https://data.worldpop.org/GIS/Development_and_health_indicators/VaxPop/'+country+'/Measles/'+CODE+'_mean_pred_total_perc.tif'

        # Define the path to save the downloaded population TIFF
        image_name = subfolder + '/' + CODE+'_mean_pred_total_perc.tif'

        # Download the population TIFF from the URL and save it to the specified file path
        wget.download(url, image_name)




def download_adminstrative_shapefile(country :str, year :str):

    # Create a subfolder for the given country inside the data root
    subfolder = data_root + country + '/'  # Construct the path for the subfolder in data root

    # Obtain the country's alpha-3 code from the function get_country_alpha3_code(country)
    code, CODE = get_country_alpha3_code(country)
    if CODE is None:
        print(f"Unable to find country code for: {country}")
        return  # or handle this error appropriately

    # Define the URL to download the administrative shapefile using the country's alpha-3 code
    url = 'https://geodata.ucdavis.edu/gadm/gadm4.1/shp/gadm41_' + CODE + '_shp.zip'

    # Define the path to save the downloaded zip file and the folder to extract the shapefiles
    file = subfolder + 'adm.zip'  # Path to the downloaded zip file
    folder = subfolder + CODE + '_adm_shp'  # Path to the folder for extracted shapefiles

    # Download the shapefile zip from the URL and save it to the specified file path
    wget.download(url, file)

    # Check the Python version and import the appropriate zipfile module
    if sys.version_info >= (3, 6):
        import zipfile
    else:
        import zipfile36 as zipfile

    # Extract the contents of the downloaded zip file to the specified folder
    with zipfile.ZipFile(file, 'r') as zip_ref:
        zip_ref.extractall(folder)

    # Remove the downloaded zip file to clean up the directory
    os.remove(file)



def extract_ghs_country_population_raster(x):

    country, year = x

    # Obtain the country's alpha-3 code from the function get_country_alpha3_code(country)
    code, CODE = get_country_alpha3_code(country)


    # Define the path to the global settlement TIFF file

    path_to_globe_tiff = data_root + 'Globe/GHS_POP_E2015_GLOBE_R2023A_4326_30ss_V1_0/GHS_POP_E2015_GLOBE_R2023A_4326_30ss_V1_0.tif'

    # Obtain the path to the country shapefile using the country_shapefile(country) function
    path_to_country_shp = country_shapefile(country)

    # Open the country shapefile and extract the geometries to be used for polygonization
    with fiona.open(path_to_country_shp, "r") as shapefile:
        polygons = [[feature["geometry"]] for feature in shapefile]  # List of geometries for the country

    # Define the folder path where the output settlement shapefile will be saved
    subfolder = data_root + country + '/'+year+'/'

    # Check if the shape folder exists, and if not, create it
    if not os.path.exists(subfolder):
        os.makedirs(subfolder)

    output = subfolder + code + '_GHS_POP_E2015_R2023_30arcsec.tif'

    # Open the global settlement raster TIFF and crop it using the country boundaries
    with rasterio.open(path_to_globe_tiff) as src:

        out_image, out_transform = rasterio.mask.mask(src, polygons[0], crop=True, filled=True, nodata=-9999.0)
        out_meta = src.meta
        out_meta.update({"driver": "GTiff",
                             "height": out_image.shape[1],
                             "width": out_image.shape[2],
                             "nodata": -9999.0,
                             #"dtype": float,
                             "dtypes": float,
                             "transform": out_transform})

    # Define the output path for the settlement raster TIFF
    with rasterio.open(output, "w", **out_meta) as dest:
        dest.write(out_image)

# def ghsl_year(year: str):
    # Convert the input year from a string to an integer and compare it with 2015
#    if int(year) < 2015:
        # If the input year is less than 2015, return '2010'
#        return '2010'
#    else:
        # If the input year is greater than or equal to 2015, return '2015'
#        return '2015'

def ghsl_year(year: str) -> str:
    """
    This function takes a year as a string, converts it to an integer,
    calculates the nearest year by dividing it by 5 and then adjusting
    the result to return a year rounded to the nearest 0 or 5.
    """
    # Convert the input year from a string to an integer
    year_int = int(year)

    # Calculate the quotient and remainder of the division of the input year by 5
    quotient, remainder = divmod(year_int, 5)

    # Calculate and return the nearest year by subtracting the remainder from the next multiple of 5
    return str((quotient + 1) * 5 - remainder)

# Use this version for replication, the version above for new estimates.
# def ghsl_year(year: str):
    # Convert the input year from a string to an integer and compare it with 2015
#     if int(year) < 2015:
        # If the input year is less than 2015, return '2010'
#         return '2010'
#     else:
        # If the input year is greater than or equal to 2015, return '2015'
#         return '2015'


def indicator_raster(country :str, year :str, indicator: str):
    # Obtain the country code
    code,CODE=get_country_alpha3_code(country)

    # Construct the file path for the indicator raster using the country, year, and code
    raster_path = result_root+country+'/'+year+'/tiff/'+code+'_'+year+'_idw'+indicator[3:]+'.tif'

    # Return the generated file path
    return raster_path



def population_raster(country :str, year :str):
    '''
    # Obtain the country code
    code,CODE=get_country_alpha3_code(country)

    # Construct the file path for the population raster using the country, year, and code
    raster_path = data_root+country+'/'+year+'/'+code+'_ppp_'+year+'_1km_Aggregated_UNadj.tif'

    # Return the generated file path
    return raster_path
    '''
    # Obtain the country code
    code,CODE=get_country_alpha3_code(country)

    # Construct the file path for the population raster using the country, year, and code
    raster_path = data_root+country+'/'+year+'/'+code+'_GHS_POP_E2015_R2023_30arcsec.tif'

    # Return the generated file path
    return raster_path



def ghs_population_raster(country :str, year :str):
    # Obtain the country code
    code,CODE=get_country_alpha3_code(country)

    # Construct the file path for the population raster using the country, year, and code
    raster_path = data_root+country+'/'+year+'/'+code+'_GHS_POP_E2015_R2023_30arcsec.tif'

    # Return the generated file path
    return raster_path

def settlements_shapefile(country: str, year: str):
    # Obtain the country code
    code, CODE = get_country_alpha3_code(country)

    # Obtain the GHSL dataset year
    syear = ghsl_year(year)

    # Construct the file path for the settlements shapefile
    shapefile_path = data_root + country + '/' + CODE + '_settlements_' + syear + '/' + CODE + '_settlements_' + syear + '.shp'

    # Return the generated file path
    return shapefile_path

def country_shapefile(country: str):
    # Obtain the country code
    code,CODE=get_country_alpha3_code(country)

    # Construct the file path for the country shapefile
    shapefile_path = data_root+country+'/'+CODE+'_adm_shp/gadm41_'+CODE+'_0.shp'

    # Return the generated file path
    return shapefile_path

def subnational_shapefile(country: str, level=1):
    # Obtain the country code
    code,CODE=get_country_alpha3_code(country)

    # Construct the file path for the provinces shapefile
    shapefile_path = data_root+country+'/'+CODE+'_adm_shp/gadm41_'+CODE+'_'+str(level)+'.shp'

    # Return the generated file path
    return shapefile_path




def generate_country_dhs_csv_file(country: str, year: str):
    # Define the path to the global DHS CSV file
    #path_to_dhs = data_root + 'Globe/all_surveys_Sept5_with_GIS.csv'
    #path_to_dhs = data_root + 'Globe/all_surveys_update_June 12.csv'


    # Read the global DHS CSV file into a pandas DataFrame
    dhs = pd.read_csv(path_to_dhs)

    # Filter the DataFrame to only keep data for the given country and year
    dhs = dhs[(dhs['country'] == country) & (dhs['year'] == int(year))]

    # Define the output path for the new merged CSV file
    name = data_root + '/' + country + '/' + year + '/' + country + '_DHS_' + year + '.csv'

    dhs.to_csv(name, index=False)


def dhs_csv_file(country: str, year: str):
    # Obtain the country code
    code, CODE = get_country_alpha3_code(country)

    # Construct the file path for the DHS csv file
    csv_path = data_root+country+'/'+year+'/'+country+'_DHS_'+year+'.csv'

    # Return the generated file path
    return csv_path

def removing_sporious_data(df):
    # Removind data with longitude and latitude near (0,0)
    df = df.drop(df[(abs(df['LNG'])< 1e-2) & (abs(df['LAT'])< 1e-2)].index)

    # Return clean data
    return df









#       THE FUNCTIONS FOR EXTRACTING DATA
#---------------------------------------------------------------------------------------------------

def dhs_cluster_locations(df):
    # Extract the longitude of locations from the DataFrame
    longitude = df['LNG'].tolist()

    # Extract the latitude of locations from the DataFrame
    latitude = df['LAT'].tolist()

    # Create a list of location pairs by zipping the longitude and latitude lists
    location = [(x, y) for x, y in zip(longitude, latitude)]

    # Return the list of location pairs
    return location


def dhs_cluster_numbers(df):
    # Extract the cluster identification numbers from the DataFrame
    clust_num=df['cluster'].tolist()

    # Return list of cluster numbers
    return clust_num


def dhs_cluster_areas_type(df):
    # Extract the cluster area types from the DataFrame
    urban=df['URBAN_RURA'].tolist()

    # Return list of cluster area types
    return urban


def append_country_bounds_to_locations(locations,country_shape):
    # Extract country bounds
    min_lng,min_lat,max_lng,max_lat = country_shape.total_bounds

    # Append country bounds to locations
    new_locations = np.append(locations, [[max_lng+1,max_lat+1], [min_lng-1,max_lat+1], [max_lng+1,min_lat-1], [min_lng-1,min_lat-1]], axis = 0)

    # Return list of new locations
    return new_locations



def dhs_clusters_inside_settlements(path, locations, urban_rural):
    """
    Identifies DHS clusters inside settlements based on their spatial relationships.

    Args:
        path (str): Path to the shapefile containing settlement polygons.
        locations (list): List of cluster locations (coordinates).
        urban_rural (list): List of binary values indicating urban (1) or rural (0) classification for each cluster.

    Returns:
        dhs_locations_in_settlement (list): List of lists, where each sublist represents the DHS cluster indices within a settlement.
        settlements_with_common_cluster (list): List of lists, where each sublist represents the settlement indices sharing a common DHS cluster.
        settlement_representative_point (list): List of representative points (coordinates) for each settlement.
    """
    longitudes = [l[0] for l in locations]
    latitudes = [l[1] for l in locations]

    # Calculate buffer distances based on urban/rural classification
    cluster_buffer = [
        point_buffer(g, t, 2000) if u == 'U' else point_buffer(g, t, 5000)
        for g, t, u in zip(longitudes, latitudes, urban_rural)
    ]

    with fiona.open(path, "r") as shapefile:
        shapes = [feature["geometry"]["coordinates"] for feature in shapefile]

        dhs_locations_in_settlement = [[] for _ in shapes]
        settlement_representative_point = [None for _ in shapes]
        settlements_with_common_cluster = [[] for _ in cluster_buffer]

        for i, shape in enumerate(shapes):
            poly = Polygon(shape[0])
            point = poly.representative_point()
            settlement_representative_point[i] = (point.x, point.y)

            for j, b in enumerate(cluster_buffer):
                if b.intersects(poly):
                    dhs_locations_in_settlement[i].append(j)
                    settlements_with_common_cluster[j].append(i)

    return dhs_locations_in_settlement, settlements_with_common_cluster, settlement_representative_point



def dhs_settlements(dhs_locations_in_settlement):
    """
    Extracts DHS settlement information from the list of DHS locations in settlements.

    Args:
        dhs_locations_in_settlement (list): List of lists, where each sublist represents the DHS cluster indices within a settlement.

    Returns:
        dhs_settlement_clusters (list): List of lists, where each sublist represents the DHS cluster indices for each settlement.
        dhs_settlement_id (list): List of settlement IDs.
    """
    dhs_settlement_id, dhs_settlement_clusters = [ ], []

    for i, s in enumerate(dhs_locations_in_settlement):
        if len(s) > 0:
            dhs_settlement_id.append(i)
            dhs_settlement_clusters.append(s)

    return dhs_settlement_clusters, dhs_settlement_id


def non_dhs_settlements (dhs_locations_in_settlement):

    non_dhs_sett = []

    for i, s in enumerate(dhs_locations_in_settlement):
        if len(s) == 0 :
            non_dhs_sett.append(i)

    return non_dhs_sett


def dhs_clusters_inside_subnational_divisions(path, locations, urban_rural):
    # Extract longitudes and latitudes from the provided locations list
    longitudes = [l[0] for l in locations]
    latitudes = [l[1] for l in locations]

    # Create cluster buffers based on urban/rural classification
    cluster_buffer = [
        point_buffer(g, t, 2000) if u == 1 else point_buffer(g, t, 5000)
        for g, t, u in zip(longitudes, latitudes, urban_rural)
    ]

    # Open the shapefile and read shapes from it
    with fiona.open(path, "r") as shapefile:
        shapes = [feature["geometry"] for feature in shapefile]

        # Lists to store information for each division
        dhs_locations_in_division = [[] for _ in shapes]
        division_representative_point = [None for _ in shapes]
        divisions_with_common_cluster = [[] for _ in cluster_buffer]

        # Iterate through each division and check for intersections with clusters
        for i, shapei in enumerate(shapes):
            shapei = shape(shapei)

            # Calculate the representative point for the division
            point = shapei.representative_point()
            division_representative_point[i] = (point.x, point.y)

            # Check each cluster buffer for intersection with the division
            for j, b in enumerate(cluster_buffer):
                if b.intersects(shapei):
                    # Store information about clusters within the division
                    dhs_locations_in_division[i].append(j)

                    # Store information about divisions sharing the same cluster
                    divisions_with_common_cluster[j].append(i)

    return dhs_locations_in_division, divisions_with_common_cluster, division_representative_point












#       THE FUNCTIONS FOR WORKING WITH SHAPES AND RASTERS
#---------------------------------------------------------------------------------------------------

def reproject_tif(input_tif_path, output_tif_path):

    dst_crs = 'EPSG:4326'

    with rasterio.open(input_tif_path) as src:
        transform, width, height = calculate_default_transform(
            src.crs, dst_crs, src.width, src.height, *src.bounds)

        kwargs = src.meta.copy()
        kwargs.update({
            'crs': dst_crs,
            'transform': transform,
            'width': width,
            'height': height
        })

        with rasterio.open(output_tif_path, 'w', **kwargs) as dst:
            for i in range(1, src.count + 1):
                reproject(
                    source=rasterio.band(src, i),
                    destination=rasterio.band(dst, i),
                    src_transform=src.transform,
                    src_crs=src.crs,
                    dst_transform=transform,
                    dst_crs=dst_crs,
                    resampling=Resampling.nearest)



def polygonize_settlements(country: str, year: str):
    # Obtain the country's alpha-3 code from the function get_country_alpha3_code(country)
    code, CODE = get_country_alpha3_code(country)

    # Convert the input year to a specific year format based on the ghsl_year(year) function
    syear = ghsl_year(year)

    # Define the path to the global settlement TIFF file
    #path_to_globe_tiff = data_root + 'Globe/GHS_SMOD_E' + syear + '_GLOBE_R2023A_54009_1000_V1_0/GHS_SMOD_' + syear + '_WGS84.tif'

    path_to_globe_tiff = data_root + 'Globe/GHS_SMOD_GLOBE_R2023A_' + syear+'/GHS_SMOD_E' + syear + '_GLOBE_R2023A_WGS84.tif'

    # Define a suffix for the settlement shapefile folder and output files
    settl_year = '_settlements_' + syear

    # Obtain the path to the country shapefile using the country_shapefile(country) function
    path_to_country_shp = country_shapefile(country)

    # Define the folder path where the output settlement shapefile will be saved
    shape_folder = data_root + country + '/' + CODE + settl_year + '/'

    # Check if the shape folder exists, and if not, create it
    if not os.path.exists(shape_folder):
        os.makedirs(shape_folder)

    # Open the country shapefile and extract the geometries to be used for polygonization
    with fiona.open(path_to_country_shp, "r") as shapefile:
        polygons = [[feature["geometry"]] for feature in shapefile]  # List of geometries for the country

        # Open the global settlement raster TIFF and crop it using the country boundaries
        with rasterio.open(path_to_globe_tiff) as src:
            out_image, out_transform = rasterio.mask.mask(
                src, polygons[0], crop=True, filled=True, nodata=-9999.0)
            out_meta = src.meta
            out_meta.update({"driver": "GTiff",
                             "height": out_image.shape[1],
                             "width": out_image.shape[2],
                             "transform": out_transform})

            # Reclassify the settlement pixel values to 1 (settlement) and 0 (non-settlement)
            out_image[out_image == 30] = 1
            out_image[out_image == 23] = 1
            out_image[out_image == 22] = 1
            out_image[out_image == 21] = 1
            out_image[out_image == 13] = 1
            out_image[out_image == 12] = 1
            out_image[out_image != 1] = 0  # Non-settlement pixels are set to 0

            # Define the output path for the settlement raster TIFF
            output = data_root + country + '/' + CODE + settl_year + '.tif'

            # Create the settlement raster TIFF and write the reclassified data to it
            with rasterio.open(output, "w", **out_meta) as dest:
                dest.write(out_image)

            # Open the created raster file and create a corresponding shapefile with polygonized settlements
            raster = gdal.Open(output)
            band = raster.GetRasterBand(1)

            proj = raster.GetProjection()
            shp_proj = osr.SpatialReference()
            shp_proj.ImportFromWkt(proj)

            output_file = shape_folder + CODE + settl_year + '.shp'
            call_drive = ogr.GetDriverByName('ESRI Shapefile')

            create_shp = call_drive.CreateDataSource(output_file)
            shp_layer = create_shp.CreateLayer('density', srs=shp_proj)
            new_field = ogr.FieldDefn(str('ID'), ogr.OFTInteger)
            shp_layer.CreateField(new_field)

            gdal.Polygonize(band, band, shp_layer, 0, [], callback=None)
            create_shp.Destroy()
            raster = None


def distance(loc1, loc2):
    # Convert the latitude and longitude of loc1 from degrees to radians
    lon1, lat1 = radians(loc1[0]), radians(loc1[1])

    # Convert the latitude and longitude of loc2 from degrees to radians
    lon2, lat2 = radians(loc2[0]), radians(loc2[1])

    # Calculate the differences in longitude and latitude between the two locations
    dlon, dlat = lon2 - lon1, lat2 - lat1

    # Calculate the square of half the chord length between the locations using the haversine formula
    a = sin(dlat / 2) ** 2 + cos(lat1) * cos(lat2) * sin(dlon / 2) ** 2

    # Calculate the angular distance in radians using the inverse tangent function
    # Multiply it by the Earth's radius (6373.0 kilometers) to get the distance in kilometers
    distance_km = 6373.0 * 2 * atan2(sqrt(a), sqrt(1 - a))

    return distance_km

def point_buffer(lon: float, lat: float, radius: int):
    """
    Returns the geometry of a circle around a point with a given radius in meters.
    """

    # Create a Point object using the lon and lat coordinates
    point = Point(lon, lat)

    # Define a local azimuthal projection based on the lon and lat of the point
    local_azimuthal_projection = f"+proj=aeqd +R=6371000 +units=m +lat_0={point.y} +lon_0={point.x}"

    # Define a partial function for transforming from WGS84 to the local azimuthal projection
    wgs84_to_aeqd = partial(
        pyproj.transform,
        pyproj.Proj("+proj=longlat +datum=WGS84 +no_defs"),
        pyproj.Proj(local_azimuthal_projection),
    )

    # Define a partial function for transforming from the local azimuthal projection to WGS84
    aeqd_to_wgs84 = partial(
        pyproj.transform,
        pyproj.Proj(local_azimuthal_projection),
        pyproj.Proj("+proj=longlat +datum=WGS84 +no_defs"),
    )

    # Transform the point from WGS84 to the local azimuthal projection
    point_transformed = transform(wgs84_to_aeqd, point)

    # Create a buffer circle around the transformed point with the given radius
    buffer_circle = point_transformed.buffer(radius)

    # Transform the buffer circle from the local azimuthal projection back to WGS84
    buffer_circle_wgs84 = transform(aeqd_to_wgs84, buffer_circle)

    # Return the buffer circle in WGS84 coordinates
    return buffer_circle_wgs84

def polygon_area(polygon):
    # Define the projection transformations
    # wgs84 = pyproj.CRS("EPSG:4326")  # WGS84 coordinate reference system
    wgs84 = pyproj.CRS.from_epsg(4326)

    # Azimuthal Equidistant projection centered at the polygon centroid
    aeqd = pyproj.CRS(proj="aeqd", ellps="WGS84",
                      lat_0=polygon.centroid.y, lon_0=polygon.centroid.x)

    # Create transformation functions between the projections
    project_to_aeqd = pyproj.Transformer.from_crs(wgs84, aeqd, always_xy=True).transform
    project_to_wgs84 = pyproj.Transformer.from_crs(aeqd, wgs84, always_xy=True).transform

    # Project the polygon to the Azimuthal Equidistant projection
    projected_polygon = transform(project_to_aeqd, polygon)

    # Calculate the area of the projected polygon
    projected_area = projected_polygon.area

    # Return real value of the polygon area
    return projected_area


def aggregate_raster_within_shape(path_to_raster,shape, touched=True):
    # Open the raster file
    with rasterio.open(path_to_raster) as raster:
        try :
            # Mask the raster with the shape
            out_image, _ = rasterio.mask.mask(raster, [shape],all_touched=touched, crop=True,filled=True)

            # Get the valid pixels
            #valid_pixels = [x for x in out_image.flatten() if x>0 ]

            out_image[out_image <0]=0

            # Calculate the average of valid pixels
            aggregate = np.sum(out_image) #if len(valid_pixels)>0 else 0

            # Return average value of the masked raster
            return aggregate

        except ValueError:
            return 0


def average_raster_within_shape(path_to_raster,shape, touched=True):
    # Open the raster file
    with rasterio.open(path_to_raster) as raster:
        try :
            # Mask the raster with the shape
            out_image, _ = rasterio.mask.mask(raster, [shape],all_touched=touched, crop=True,filled=True)

            # Get the valid pixels
            valid_pixels = [x for x in out_image.flatten() if x>0 ]

            # Calculate the average of valid pixels
            average = np.mean(valid_pixels) if len(valid_pixels)>0 else 0

            # Return average value of the masked raster
            return average

        except ValueError:
            return 0

def valid_raster_pixels_within_shape(path_to_raster,shape, touched=True):
    # Open the raster file
    with rasterio.open(path_to_raster) as raster:
        try :
            # Mask the raster with the shape
            out_image, _ = rasterio.mask.mask(raster, [shape],all_touched=touched, crop=True,filled=True)

            # Get the valid pixels
            valid_pixels = [x for x in out_image.flatten() if x>0 ]


            return valid_pixels

        except ValueError:
            return []


def list_of_shapes(path_to_shapefile):
    # Open the shapefile in read mode using Fiona
    with fiona.open(path_to_shapefile, "r") as source:
        shapes = []  # Initialize an empty list to store the shapes

        # Iterate over each feature in the shapefile
        for feature in source:
            # Check the type of the geometry
            if feature["geometry"]["type"] == "Polygon":
                # Create a Polygon object from the coordinates
                shapes.append(Polygon(feature["geometry"]["coordinates"][0]))
            elif feature["geometry"]["type"] == "MultiPolygon":
                # Extract the coordinates of each polygon in the MultiPolygon
                list_of_polygons = [Polygon(f[0]) for f in feature["geometry"]["coordinates"]]
                # Create a MultiPolygon object from the list of polygons
                shapes.append(MultiPolygon(list_of_polygons))

    # Return the list of shapes
    return shapes



#       THE FUNCTIONS FOR NETWORK CONSTRUCTION
#---------------------------------------------------------------------------------------------------

def voronoi_raw_regions(locations):
    # Create a MultiPoint object from the new locations
    points = MultiPoint(locations)

    # Compute the Voronoi diagram for the points
    polygons = voronoi_diagram(points)

    # Create a list to store the regions
    regions = []

    # Iterate over the Voronoi polygons
    for polygon in polygons.geoms:


        # Iterate over the original locations
        for i, l in enumerate(locations):
            # Create a Point object from the location
            point = Point(l)

            # Check if the point is within the current Voronoi polygon
            if point.within(polygon):
                # Store the region information as a tuple of the polygon, location, and index
                regions.append([polygon, l, i])
                break

    # Return the list of regions
    return regions




def voronoi_regions(locations, country_shape):
    # Extract the polygon representing the country
    country_polygon = country_shape['geometry'][0]

    # Append the country bounds to the locations list
    new_locations = append_country_bounds_to_locations(locations, country_shape)

    # Create a MultiPoint object from the new locations
    points = MultiPoint(new_locations)

    # Compute the Voronoi diagram for the points
    polygons = voronoi_diagram(points)

    # Create a list to store the regions
    regions = [None for _ in locations]

    # Iterate over the Voronoi polygons
    for polygon in polygons.geoms:
        # Find the intersection between the country polygon and the current Voronoi polygon
        intersect = country_polygon.intersection(polygon)

        # Iterate over the original locations
        for i, l in enumerate(locations):
            # Create a Point object from the location
            point = Point(l)

            # Check if the point is within the current Voronoi polygon
            if point.within(polygon):
                # Store the region information as a tuple of the intersection, location, and index
                regions[i] = [intersect, l, i]
                break

    # Return the list of regions
    return regions


def dhs_clusters_network(regions, self_loop=False):
    # Create an empty list of lists to represent the network
    if self_loop == True:
        # If self-loop is allowed, each region is connected to itself in the network
        net = [[i] for i in range(len(regions))]
    else:
        # If self-loop is not allowed, each region starts with an empty list in the network
        net = [[] for _ in range(len(regions))]

    # Iterate over the regions
    for i in range(len(regions)):
        # Get the polygon of the current region
        p1 = regions[i][0]

        # Iterate over the remaining regions
        for j in range(i + 1, len(regions)):
            # Get the intersection polygon of the other region
            p2 = regions[j][0]

            # Check if the polygons of the two regions intersect
            if p1.intersects(p2):
                # Add the index of the other region to the current region's network list
                net[i].append(j)
                # Add the index of the current region to the other region's network list
                net[j].append(i)

    # Return the network representation
    return net


def dhs_settlements_network(path, settlement_dhs, net):
    """
    Constructs a network of settlements based on their DHS clusters and a given network representation.

    Args:
        path (str): Path to the settlement shapefile.
        settlement_dhs (list): List of lists, where each sublist represents the DHS cluster indices within a settlement.
        net (list): Network representation as a list of lists.

    Returns:
        network (list): Network representation of settlements as a list of lists.
    """
    network = [[] for _ in range(len(settlement_dhs))]  # Initialize an empty network for settlements

    # Check for common DHS clusters between settlements
    for i in range(len(settlement_dhs)):
        A = set(settlement_dhs[i])
        for j in range(i + 1, len(settlement_dhs)):
            B = set(settlement_dhs[j])
            if len(A.intersection(B)) > 0:
                network[i].append(j)
                network[j].append(i)

    # Check for common neighbors based on the network representation
    for i in range(len(settlement_dhs)):
        neighbor = []
        for k in settlement_dhs[i]:
            neighbor += net[k]

        A = set(neighbor).difference(set(settlement_dhs[i]))
        for j in range(i + 1, len(settlement_dhs)):
            B = set(settlement_dhs[j])
            if len(A.intersection(B)) > 0:
                network[i].append(j)
                network[j].append(i)

    return network



def dhs_settlements_networkx(path, settlement_dhs, settlement_id, net):
    """
    Constructs a weighted network of settlements using NetworkX based on their DHS clusters and settlement shapes.

    Args:
        path (str): Path to the settlement shapefile.
        settlement_dhs (list): List of lists, where each sublist represents the DHS cluster indices within a settlement.
        settlement_id (list): List of settlement IDs.
        net (list): Network representation as a list of lists.

    Returns:
        G (networkx.Graph): Weighted network representation of settlements using NetworkX.
    """
    with fiona.open(path, "r") as shapefile:
        # Extract shapes (geometry coordinates) from the settlement shapefile
        shapes = [feature["geometry"]['coordinates'] for feature in shapefile]

        # Initialize an empty weighted graph using NetworkX
        G = nx.Graph()

        # Check for common DHS clusters between settlements and add edges with weights based on distances
        for i in range(len(settlement_dhs)):
            A = set(settlement_dhs[i])
            for j in range(i + 1, len(settlement_dhs)):
                B = set(settlement_dhs[j])
                if len(A.intersection(B)) > 0:
                    # Get the shapes of the two settlements from the shapefile based on their IDs
                    shape_i = Polygon(shapes[settlement_id[i]][0])
                    shape_j = Polygon(shapes[settlement_id[j]][0])

                    # Find the nearest points between the two shapes
                    nps = list(nearest_points(shape_i, shape_j))
                    li = nps[0].coords[0]
                    lj = nps[1].coords[0]

                    # Calculate the distance between the nearest points and add an edge to the graph with the distance as weight
                    d = distance(li, lj)
                    G.add_edge(i, j, weight=d)

        # Check for common neighbors based on the network representation and add edges with weights based on distances
        for i in range(len(settlement_dhs)):
            shape = Polygon(shapes[settlement_id[i]][0])
            neighbor = []
            for k in settlement_dhs[i]:
                neighbor += net[k]
            A = set(neighbor).difference(set(settlement_dhs[i]))
            for j in range(i + 1, len(settlement_dhs)):
                B = set(settlement_dhs[j])
                if len(A.intersection(B)) > 0:
                    # Get the shapes of the two settlements from the shapefile based on their IDs
                    shape_i = Polygon(shapes[settlement_id[i]][0])
                    shape_j = Polygon(shapes[settlement_id[j]][0])

                    # Find the nearest points between the two shapes
                    nps = list(nearest_points(shape_i, shape_j))
                    li = nps[0].coords[0]
                    lj = nps[1].coords[0]

                    # Calculate the distance between the nearest points and add an edge to the graph with the distance as weight
                    d = distance(li, lj)
                    G.add_edge(i, j, weight=d)

    return G


def dhs_settlements_weighted_networkx(path, settlement_dhs, settlement_id, net, weight_function = None):
    # Open the shapefile specified by the 'path' parameter in read mode using Fiona
    with fiona.open(path, "r") as shapefile:
        # Extract the coordinates of the geometry for each feature in the shapefile and store them in a list called 'shapes'
        shapes = [feature["geometry"]['coordinates'] for feature in shapefile]

        # Create an empty undirected graph using NetworkX
        G = nx.Graph()

        # Iterate over each pair of settlements for potential connections
        for i in range(len(settlement_dhs)):
            A = set(settlement_dhs[i])

            for j in range(i + 1, len(settlement_dhs)):
                B = set(settlement_dhs[j])

                # Check if there is any common element between set A and set B
                if len(A.intersection(B)) > 0:
                    d = 1  # Default edge weight is 1

                    # If a custom weight function is provided, calculate the edge weight based on the shapes
                    if weight_function is not None:
                        shape_i = Polygon(shapes[settlement_id[i]][0])
                        shape_j = Polygon(shapes[settlement_id[j]][0])

                        # Find the nearest points between the two shapes
                        nps = list(nearest_points(shape_i, shape_j))
                        li = nps[0].coords[0]
                        lj = nps[1].coords[0]

                        # Calculate the edge weight using the provided weight function
                        d = weight_function(li, lj)

                    # Add an edge between settlements i and j with the calculated weight to the graph G
                    G.add_edge(settlement_id[i], settlement_id[j], weight=d)

        # Iterate over each settlement
        for i in range(len(settlement_dhs)):
            shape = Polygon(shapes[settlement_id[i]][0])
            neighbor = []

            # Collect neighbors for the current settlement from the 'net' list
            for k in settlement_dhs[i]:
                neighbor += net[k]

            # Calculate set A as the difference between the neighbors and the current settlement's members
            A = set(neighbor).difference(set(settlement_dhs[i]))

            # Iterate over pairs of settlements for potential connections
            for j in range(i + 1, len(settlement_dhs)):
                B = set(settlement_dhs[j])

                # Check if there is any common element between set A and set B
                if len(A.intersection(B)) > 0:
                    d = 1  # Default edge weight is 1

                    # If a custom weight function is provided, calculate the edge weight based on the shapes
                    if weight_function is not None:
                        shape_i = Polygon(shapes[settlement_id[i]][0])
                        shape_j = Polygon(shapes[settlement_id[j]][0])

                        # Find the nearest points between the two shapes
                        nps = list(nearest_points(shape_i, shape_j))
                        li = nps[0].coords[0]
                        lj = nps[1].coords[0]

                        # Calculate the edge weight using the provided weight function
                        d = weight_function(li, lj)

                    # Add an edge between settlements i and j with the calculated weight to the graph G
                    G.add_edge(settlement_id[i], settlement_id[j], weight=d)

    # Return the constructed graph G
    return G






def nodes_position(dhs_settlement_id, settlement_representative_point):
    """
    Get node positions based on settlement IDs.

    Args:
        dhs_settlement_id (list): List of settlement IDs.
        settlement_representative_point (list): List of representative points (tuples) for each settlement.

    Returns:
        position (list): List of node positions (tuples) corresponding to the settlement IDs.
    """
    # Create a list of node positions (tuples) based on settlement IDs
    position = [settlement_representative_point[d] for d in dhs_settlement_id]

    return position


def local_inverse_distance_weighting_interpolation(x):
    # Unpack the tuple 'x' containing 'country', 'year', and 'indicator'
    country, year, indicator = x

    # Print the provided country, year, and indicator values
    print(country, year, indicator)

    # Obtain the country's alpha-3 code from the function get_country_alpha3_code(country)
    code, CODE = get_country_alpha3_code(country)

    # Get the path to the indicator CSV file and the shapefile for the country
    path_to_indicator_file = dhs_csv_file(country, year)
    path_to_shapefile = country_shapefile(country)

    # Read the indicator CSV file into a pandas DataFrame
    df = pd.read_csv(path_to_indicator_file)

    # Keep only relevant columns from the DataFrame (including 'cluster', the indicator, longitude, and latitude)
    df = df[['cluster', indicator, 'LNG', 'LAT']]

    # Remove spurious data from the DataFrame using a custom function removing_spurious_data(df)
    df = removing_sporious_data(df)

    # Drop rows with missing values in the DataFrame
    df = df.dropna()

    # Extract the indicator percentages from the DataFrame as a list
    indicator_percentages = df[indicator].tolist()

    # Check if there are indicator percentages available in the DataFrame
    if len(indicator_percentages) > 0:
        # Read the country shapefile into a GeoDataFrame
        country_shape = gpd.read_file(path_to_shapefile)

        # Get the locations of DHS clusters from the DataFrame as a list of (longitude, latitude) tuples
        locations = dhs_cluster_locations(df)

        # Create Voronoi polygons based on the cluster locations and the country shape
        regions = voronoi_regions(locations, country_shape)

        # Create a network representation of regions based on intersection polygons (including self-loops)
        net = dhs_clusters_network(regions, self_loop=True)

        # Get the path to the population raster for the country and year
        path_to_population_raster = population_raster(country, year)

        # Read the population raster using rasterio
        raster = rasterio.open(path_to_population_raster)
        band = raster.read(1)

        # Get height, width, and nodata value from the raster
        height = raster.height
        width = raster.width
        nodata = raster.nodata

        # Get the known pixels' indices (DHS cluster locations) in the raster
        known_pixels = [raster.index(x, y) for x, y in locations]

        # Create an empty grid to store the indicator values
        grid = np.full((height, width), -9999.0, dtype=float)

        # Fill the grid with the known indicator percentages at the corresponding locations
        for e, p in zip(known_pixels, indicator_percentages):
            grid[e[0], e[1]] = p

        # Perform local inverse distance weighting interpolation for unknown indicator values
        for i in range(height):
            for j in range(width):
                if grid[i, j] < 0.0 and band[i, j] > 0.0:
                    loc = raster.xy(i, j)
                    point = Point(loc)
                    # Find the regions that have influence on the current pixel (point) and calculate weights
                    for k in range(len(regions)):
                        polygon = regions[k][0]
                        if point.within(polygon):
                            weight = [1.0 / distance(loc, regions[a][1]) for a in net[k]]
                            predict = [indicator_percentages[regions[a][2]] * w / sum(weight)
                                       for a, w in zip(net[k], weight)]
                            grid[i, j] = sum(predict)
                            break

        # Define the subfolder to save the interpolated TIFF file
        subfolder = result_root + country + '/' + year + '/tiff/'
        if not os.path.exists(subfolder):
            os.makedirs(subfolder)

        # Define the output path for the interpolated TIFF file
        output_path = subfolder + code + '_' + year + '_idw_' + indicator[4:] + '.tif'

        # Create a new raster using rasterio to save the interpolated values as a TIFF file
        with rasterio.open(
            output_path, 'w',
            driver='GTiff',
            dtype=rasterio.float32,
            count=1,
            width=width,
            height=height,
            nodata=-9999.0,
            #nodatavals=raster.nodatavals,
            crs='+proj=latlong',
            transform=raster.transform  # Affine.translation(left, top) * Affine.scale(scale)
        ) as dst:
            dst.write(grid, indexes=1)


def settlement_intersect_with_region(path_to_settlement_shapefile, regions):
    # Open the settlement shapefile using fiona
    with fiona.open(path_to_settlement_shapefile, "r") as shapefile:
        # Extract coordinates of settlement shapes
        shapes = [feature["geometry"]["coordinates"][0] for feature in shapefile]

        # Initialize lists to store intersections
        settlement_intersections = [[] for _ in shapes]
        region_intersections = [[] for _ in regions]

        # Iterate through settlements
        for i, settlement in enumerate(shapes):
            settlement = Polygon(settlement)

            # Iterate through regions
            for j, region in enumerate(regions):
                region = region[0]
                # Check for intersection between settlement and region
                if settlement.intersects(region):
                    settlement_intersections[i].append(j)
                    region_intersections[j].append(i)

    return settlement_intersections, region_intersections


def dhs_estimation_for_settlements(numerator, denominator, dhs_settlement_clusters, dhs_settlement_id):
    # Initialize a dictionary to store DHS estimations
    dhs_estimation_dict = {}

    # Iterate through DHS settlement IDs
    for i, id in enumerate(dhs_settlement_id):
        # Get clusters within the current settlement
        clusters_within_settlement = dhs_settlement_clusters[i]

        # Calculate numerator and denominator sums for the settlement
        n_dhs = np.sum([numerator[c] for c in clusters_within_settlement])
        d_dhs = np.sum([denominator[c] for c in clusters_within_settlement])

        # Calculate the DHS estimation (avoid division by zero)
        tmp = np.nan
        if d_dhs > 0:
            tmp = n_dhs / d_dhs

        # Store the estimation in the dictionary
        dhs_estimation_dict[id] = tmp

    return dhs_estimation_dict


def lidw_estimation_for_settlements(country, year, indicator, settlement_polygons, dhs_settlement_id, touched=True):
    # Initialize a dictionary to store LIDW estimations
    lidw_estimation_dict = {}

    # Iterate through DHS settlement IDs
    for i, id in enumerate(dhs_settlement_id):
        # Get the polygon shape for the current settlement
        shapei = Polygon(settlement_polygons[id])

        # Get the path to the indicator raster for the given country, year, and indicator
        path_to_indicator_raster = indicator_raster(country, year, indicator)

        # Calculate the average raster value within the settlement polygon
        lidw_estimation_dict[id] = average_raster_within_shape(path_to_indicator_raster, shapei, touched=touched)

    return lidw_estimation_dict

#       THE FUNCTIONS FOR VALIDATION
#---------------------------------------------------------------------------------------------------


def validation_network_level(x):
    # Unpack the input tuple
    country, year, indicator = x

    print(x, '    starts')

    # Get alpha3 country code
    code, CODE = get_country_alpha3_code(country)

    # Paths to data files
    path_to_dhs_file = dhs_csv_file(country, year)
    path_to_shapefile = country_shapefile(country)

    # Read DHS data CSV file
    df = pd.read_csv(path_to_dhs_file)

    # Select relevant columns and remove NaN rows
    df = df[['cluster', indicator, 'LNG', 'LAT']]
    df = removing_sporious_data(df)
    df = df.dropna()

    # Extract indicator values and cluster locations
    indicator_percentages = df[indicator].tolist()
    locations = dhs_cluster_locations(df)

    # Read country shapefile
    country_shape = gpd.read_file(path_to_shapefile)

    # Extract boundaries from country shapefile
    min_lng, min_lat, max_lng, max_lat = country_shape.total_bounds
    boundaries = [(max_lng + 1, max_lat + 1), (min_lng - 1, max_lat + 1), (max_lng + 1, min_lat - 1), (min_lng - 1, min_lat - 1)]

    # Initialize lists to store computed values
    indicator_mean, indicator_std = [0 for f in indicator_percentages], [0 for f in indicator_percentages]

    # Iterate through locations for validation
    for q, location in enumerate(locations):
        print(q)
        # Get remaining locations and indicator values
        remaining_locations = [l for i, l in enumerate(locations) if i != q]
        remaining_indicator_percentages = [indicator_percentages[i] for i, l in enumerate(locations) if i != q]

        # Combine remaining locations with boundary points
        remaining_locations_plus_boundaries = remaining_locations + boundaries
        points = MultiPoint(remaining_locations_plus_boundaries)

        # Calculate Voronoi diagram
        polygons = voronoi_diagram(points)

        regions=[]

        # Identify Voronoi regions for each remaining location
        for poly in polygons.geoms:
            for l,f in zip(remaining_locations,remaining_indicator_percentages) :
                point=Point(l)
                if point.within(poly) :
                    regions.append([poly,l,f])
                    b=True
                    break


        # Build a network connecting intersecting Voronoi regions
        net = [[i] for i, r in enumerate(regions)]
        for i in range(len(regions)):
            p1 = regions[i][0]
            for j in range(i + 1, len(regions)):
                p2 = regions[j][0]
                if p1.intersects(p2) :
                    net[i].append(j)
                    net[j].append(i)

        # Find the index of polygon that include the location
        k = None
        point = Point(location)
        for i in range(len(regions)):
            polygon = regions[i][0]
            if point.within(polygon):
                k = i
                break

        # Calculate the indicator percentage prediction for the location based on the LIDW interpolation
        neighbors_indicator_percentage = [regions[a][2] for a in net[k]]

        inverse_distance = [1 / distance(location, regions[a][1]) for a in net[k]]
        weight = [d / sum(inverse_distance) for d in inverse_distance]

        v1 = sum([v * w for v, w in zip(neighbors_indicator_percentage, weight)])
        v2 = sum([v * v * w for v, w in zip(neighbors_indicator_percentage, weight)])
        vs = np.sqrt(v2 - v1 * v1)

        indicator_mean[q] = v1
        indicator_std[q] = vs

    # Create a subfolder for saving results
    subfolder = result_root + country + '/' + year + '/validation/'
    if not os.path.exists(subfolder):
        os.makedirs(subfolder)

    # Define output file path
    output = subfolder + CODE + '_VAL2_' + indicator + '_' + year + '.csv'

    # Create a result DataFrame and save to CSV
    result = pd.DataFrame()
    result['CLUST_NUM'] = df['cluster'].tolist()
    result['DHS_VAL'] = indicator_percentages
    result['PRED_VAL'] = indicator_mean
    result['VAL_STD'] = indicator_std
    result.to_csv(output)

    #result.to_csv('test.csv')
    print(x, '   ends')


def get_end_part_after_substring(full_string, substring):
    """
    Return the part of the string that comes after the given substring.
    If the substring is not found, return an empty string.

    :param full_string: The original string
    :param substring: The substring to search for
    :return: The part of the string after the substring
    """
    # Find the starting index of the substring
    start_index = full_string.find(substring)

    # If the substring is found, get the end part of the string
    if start_index != -1:
        return full_string[start_index + len(substring):]

    # If the substring is not found, return an empty string
    return ""


def error_analysis_network_level(path: str =  list_of_country_years):
    # Read a list of country-year combinations from the provided path
    country_year = read_list_of_country_years(path)

    indicator_files = read_list_of_indicators()

    # Loop through each (country, year) combination
    for (country, year) in country_year:
        # Get the alpha-3 country code
        code, CODE = get_country_alpha3_code(country)

        # Define paths to relevant files
        csv_path = result_root + country + '/' + year + '/' + CODE + '_VAL2_' + year + '.csv'
        dhs_path = data_root + country + '/' + year + '/' + country + '_DHS_' + year + '.csv'
        dir_path = result_root + country + '/' + year + '/validation'

        # Read DHS data for the given country and year
        dhs = pd.read_csv(dhs_path)
        tot_clust = len(dhs.index)  # Total number of clusters

        # Initialize empty lists to store indicator-wise metrics
        INDICATOR, BIAS, MAE, RMSE, P95, RATIO, TOT_CLUST, NUM_CLUST = [], [], [], [], [], [], [], []

        # Collect indicator files in the 'validation' directory
        indicators = []
        for root, dirs, files in os.walk(dir_path):
            for file in files:
                if file.endswith(".csv"):
                    s = get_end_part_after_substring(file,'VAL2_')
                    s = s[:-9]
                    #print(country,file,s)
                    #input('****')
                    if s in indicator_files :
                        #print(s)
                        #input('****')
                        indicators.append(os.path.join(root, file))

        # Loop through each indicator file
        for indicator in indicators:
            df = pd.read_csv(indicator)  # Read the indicator validation data

            # Initialize metrics as NaN (Not a Number)
            bias, mae, rmse, p95, ratio = np.nan, np.nan, np.nan, np.nan, np.nan

            name = indicator[len(dir_path) + 1 + 13:-9]  # Extract indicator name from the path
            num_clust = len(df.index)  # Number of clusters in the validation data

            if num_clust > 0:
                vac_dhs = df['DHS_VAL'].to_numpy()  # True DHS values
                vac_pred = df['PRED_VAL'].to_numpy()  # Predicted values
                vac_std = df['VAL_STD'].to_numpy()  # Standard deviations of predicted values

                err = vac_pred - vac_dhs #vac_dhs - vac_pred  # Calculate errors

                rmse = np.sqrt(np.sum(err ** 2) / len(err))  # Calculate RMSE
                rmse = np.round(rmse, 3)

                # Calculate the percentage of predictions within 95% confidence interval
                p95 = sum([1 for vr, vp, vs in zip(vac_dhs, vac_pred, vac_std)
                           if vp - 1.96 * vs <= vr <= vp + 1.96 * vs]) / len(err)
                p95 = np.round(p95, 3) * 100

                mae = np.mean(abs(err))  # Calculate MAE
                mae = np.round(mae, 3)

                av = np.mean(vac_dhs)  # Mean of true DHS values
                bias = np.mean(err)  # Calculate bias
                bias = np.round(bias, 4)

                ratio = np.nan

                if av > 0 : #np.mean(vac_pred) > 0:
                    ratio = np.mean(vac_pred) / av #/ np.mean(vac_pred)  # Calculate ratio of mean values
                    ratio = np.round(ratio, 3)

            # Append metrics to respective lists
            INDICATOR.append(name)
            TOT_CLUST.append(tot_clust)
            NUM_CLUST.append(num_clust)
            BIAS.append(bias)
            MAE.append(mae)
            RMSE.append(rmse)
            P95.append(p95)
            RATIO.append(ratio)

        # Create a DataFrame to store the results
        res = pd.DataFrame()
        res['INDICATOR'] = INDICATOR
        res['TOT_CLUST'] = TOT_CLUST
        res['NUM_CLUST'] = NUM_CLUST
        res['BIAS'] = BIAS
        res['RATIO'] = RATIO
        res['MAE'] = MAE
        res['RMSE'] = RMSE
        res['P95'] = P95

        # Define the output path for the summary CSV file
        output_path = result_root + country + '/' + year + '/' + CODE + '_VAL2_' + year
        res.to_csv(output_path + '.csv')  # Save the DataFrame as a CSV file

        # Print the processed country and year
        print(country, year)



def merge_error_analysis_network_level(path: str =  list_of_country_years):

    # Create a dictionary of abbreviation and full name for indicators using the dictionary_of_indicators function
    indicator_dict = dictionary_of_indicators()

    # Create an Excel writer and workbook
    writer = pd.ExcelWriter(result_root+'LOOCV_network.xlsx', engine='xlsxwriter')
    workbook = writer.book

    # Read a list of country years
    country_year = read_list_of_country_years(path)

    # Iterate over each country and year
    for (country, year) in country_year:

        # Get alpha-3 country code
        code, CODE = get_country_alpha3_code(country)

        # Path to the error analysis CSV file
        error_csv_path = result_root + country + '/' + year + '/' + CODE + '_VAL2_' + year + '.csv'

        # Read the error analysis CSV file into a DataFrame
        df = pd.read_csv(error_csv_path)

        # Extract data columns from the DataFrame
        INDICATOR = df['INDICATOR'].tolist()
        TOT_CLUST = df['TOT_CLUST'].tolist()
        NUM_CLUST = df['NUM_CLUST'].tolist()
        BIAS = df['BIAS'].tolist()
        MAE = df['MAE'].tolist()
        RMSE = df['RMSE'].tolist()
        P95 = df['P95'].tolist()
        RATIO = df['RATIO'].tolist()

        # Sort data based on indicator names
        z = zip(INDICATOR, TOT_CLUST, NUM_CLUST, BIAS, MAE, RMSE, P95, RATIO)
        z = sorted(z, key=lambda x: x[0])
        INDICATOR, TOT_CLUST, NUM_CLUST, BIAS, MAE, RMSE, P95, RATIO = zip(*z)

        # Map indicator abbreviations to full names to descriptions
        INDICATOR = [indicator_dict['cov_'+indic] for indic in INDICATOR]

        # Create a new DataFrame with formatted error analysis data
        res = pd.DataFrame()
        res['INDICATOR'] = INDICATOR
        res['TOT_CLUST'] = TOT_CLUST
        res['NUM_CLUST'] = NUM_CLUST
        res['BIAS'] = np.round(BIAS,3)
        res['RATIO'] = np.round(RATIO,3)
        res['MAE'] = np.round(MAE,3)
        res['RMSE'] = np.round(RMSE,3)
        res['P95'] = np.round(P95,3)





        # Read the list of indicators
        indicators = read_list_of_indicators()

        # Create a dictionary of indicators
        indicator_dict = dictionary_of_indicators()

        # Create a list of indicator names using the indicator dictionary
        INDICATOR = [indicator_dict[indic] for indic in indicators]

        # Define the ordered list for the column you want to use for reordering
        ordered_list = INDICATOR  # Replace with the actual ordered list

        # Create a custom sorting index based on the ordered list
        sorting_index = {value: index for index, value in enumerate(ordered_list)}

        # Apply the custom sorting index to the specified column
        res['INDICATOR'] = res['INDICATOR'].map(sorting_index)

        # Sort the DataFrame based on the new sorting index
        res.sort_values(by='INDICATOR', inplace=True)

        # Drop the temporary sorting index column if needed
        #res.drop(columns=['INDICATOR'], inplace=True)

        res['INDICATOR']=INDICATOR

        # Get the dimensions of the DataFrame
        (max_row, max_column) = res.shape

        # Fill NaN values with 'nan'
        res = res.fillna('NaN')

        # Add a worksheet to the workbook and set column widths
        worksheet = workbook.add_worksheet(country + year)
        writer.sheets[country + year] = worksheet
        worksheet.set_column('A:A', 45)
        worksheet.set_column('B:G', 15)

        # Write the DataFrame to the Excel worksheet
        res.to_excel(writer, sheet_name=country + year, index=False)

        # Format the header row
        header_format = workbook.add_format({
            'bg_color': '#d8d8d8',
            'bold': True,
            'text_wrap': True,
            'font_size': 14,
            'valign': 'top',
            'align': 'center'})

        for col_num, value in enumerate(res.columns.values):
            worksheet.write(0, col_num, value, header_format)

        # Define a formatting function for different rows
        def format_func(i, j):
            if i % 3 == 0:
                if j == 0:
                    return workbook.add_format({'bg_color': '#ddf8e7', 'align': 'left', 'font_size': 12, 'bold': True})
                else:
                    return workbook.add_format({'bg_color': '#ddf8e7', 'align': 'center', 'font_size': 12})
            elif i % 3 == 1:
                if j == 0:
                    return workbook.add_format({'bg_color': '#ddeef8', 'align': 'left', 'font_size': 12, 'bold': True})
                else:
                    return workbook.add_format({'bg_color': '#ddeef8', 'align': 'center', 'font_size': 12})
            elif i % 3 == 2:
                if j == 0:
                    return workbook.add_format({'bg_color': '#f3e5fb', 'align': 'left', 'font_size': 12, 'bold': True})
                else:
                    return workbook.add_format({'bg_color': '#f3e5fb', 'align': 'center', 'font_size': 12})

        # Apply formatting to each cell in the worksheet
        for row in range(max_row):
            for col_num in range(max_column):
                format_row = format_func(row, col_num)
                worksheet.write(row + 1, col_num, res.iloc[row, col_num], format_row)

    # Save the Excel workbook
    # writer.save()
    workbook.close()

def rmse_error_analysis_network_level(path: str =  list_of_country_years):
    # Create a dictionary of indicators (replace with your actual function or data)
    indicator_dict = dictionary_of_indicators()

    # Read the list of country and year pairs
    country_year = read_list_of_country_years(path)

    # Initialize an empty DataFrame to store the results
    res = pd.DataFrame()

    # Loop through each country and year pair
    for i, (country, year) in enumerate(country_year):
        # Get the alpha3 country code and uppercase version
        code, CODE = get_country_alpha3_code(country)

        # Construct the path to the CSV file containing the RMSE data
        csv_path = result_root + country + '/' + year + '/' + CODE + '_VAL2_' + year + '.csv'

        # Read the CSV file into a DataFrame
        df = pd.read_csv(csv_path)

        # Extract lists of INDICATOR and RMSE values from the DataFrame
        INDICATOR = df['INDICATOR'].tolist()
        RMSE = df['RMSE'].tolist()

        # Zip and sort the INDICATOR and RMSE values based on INDICATOR
        z = zip(INDICATOR, RMSE)
        z = sorted(z, key=lambda x: x[0])
        INDICATOR, RMSE = zip(*z)

        # Map the INDICATOR values to their corresponding names using the indicator_dict
        INDICATOR = [indicator_dict['cov_'+indic] for indic in INDICATOR]

        # If it's the first iteration, create the 'INDICATOR' column in the result DataFrame
        if i == 0:
            res['INDICATOR'] = INDICATOR

        # Add the RMSE values for the current country and year pair to the result DataFrame
        res[country + ' ' + year] = np.round(RMSE,2)

    # Replace missing and zero RMSE values with 'nan'
    res = res.fillna('NaN')
    res.replace(0, 'NaN', inplace=True)



    # Read the list of indicators
    indicators = read_list_of_indicators()

    # Create a dictionary of indicators
    indicator_dict = dictionary_of_indicators()

    # Create a list of indicator names using the indicator dictionary
    INDICATOR = [indicator_dict[indic] for indic in indicators]

    # Define the ordered list for the column you want to use for reordering
    ordered_list = INDICATOR  # Replace with the actual ordered list

    # Create a custom sorting index based on the ordered list
    sorting_index = {value: index for index, value in enumerate(ordered_list)}

    # Apply the custom sorting index to the specified column
    res['INDICATOR'] = res['INDICATOR'].map(sorting_index)

    # Sort the DataFrame based on the new sorting index
    res.sort_values(by='INDICATOR', inplace=True)

    # Drop the temporary sorting index column if needed
    #res.drop(columns=['INDICATOR'], inplace=True)

    res['INDICATOR']=INDICATOR


    # Save the result DataFrame to a CSV file
    res.to_csv(result_root + 'LOOCV_network_RMSE.csv')


def validation_settlement_level(x):
    # Unpack country and year from the input tuple
    country, year = x
    print(x, '    starts')

    # Read the list of indicators
    indicators = read_list_of_indicators()

    # Generate indicator density and numerator lists
    indic_den = ['den' + x[3:] for x in indicators]
    indic_num = ['num' + x[3:] for x in indicators]

    # Get paths to relevant data files
    path_to_settlements = settlements_shapefile(country, year)
    path_to_dhs_survey = dhs_csv_file(country, year)
    path_to_country_shapefile = country_shapefile(country)

    # Read DHS survey data into a DataFrame
    df = pd.read_csv(path_to_dhs_survey)

    # Perform data cleaning on the DataFrame
    df = removing_sporious_data(df)

    # Extract cluster locations, areas type, and cluster numbers from the DataFrame
    locations = dhs_cluster_locations(df)
    areas_type = dhs_cluster_areas_type(df)
    cluster_numbers = dhs_cluster_numbers(df)

    # Read country shapefile using GeoPandas
    country_shape = gpd.read_file(path_to_country_shapefile)

    # Find DHS cluster locations inside settlements and get cluster IDs
    dhs_locations_in_settlement, _, _ = dhs_clusters_inside_settlements(path_to_settlements, locations, areas_type)

    # Get DHS settlement clusters and IDs
    dhs_settlement_clusters, dhs_settlement_id = dhs_settlements(dhs_locations_in_settlement)

    # Initialize lists for Lidw prediction and DHS estimation
    lidw_prediction, dhs_estimation = [], []

    # Open the settlements shapefile using Fiona
    with fiona.open(path_to_settlements, "r") as shapefile:
        shapes = [feature["geometry"]['coordinates'][0] for feature in shapefile]

        # Loop through settlement IDs and associated data
        for i, id in enumerate(dhs_settlement_id):
            polygon = Polygon(shapes[id])
            clusters_within_settlement = dhs_settlement_clusters[i]

            tmp_pred = [np.nan for _ in indicators]
            tmp_esti = [np.nan for _ in indicators]

            # Loop through indicators
            for j, indicator in enumerate(indicators):
                path_to_indicator_raster = indicator_raster(country, year, indicator)

                # Check if indicator raster file exists
                if os.path.exists(path_to_indicator_raster):
                    tmp_pred[j] = average_raster_within_shape(path_to_indicator_raster, polygon)

                indic_den = 'den' + indicator[3:]
                indic_num = 'num' + indicator[3:]

                den = df[indic_den].to_numpy()
                num = df[indic_num].to_numpy()

                n_dhs = np.nansum([num[c] for c in clusters_within_settlement])
                d_dhs = np.nansum([den[c] for c in clusters_within_settlement])

                if d_dhs > 0:
                    tmp_esti[j] = n_dhs / d_dhs

            lidw_prediction.append(tmp_pred)
            dhs_estimation.append(tmp_esti)

        # Create a DataFrame to store the results
        data = pd.DataFrame()
        data['SETTLEMENT_ID'] = dhs_settlement_id

        # Loop through indicators and add columns to the DataFrame
        for j, indicator in enumerate(indicators):
            tmp1 = [d[j] for d in lidw_prediction]
            tmp2 = [d[j] for d in dhs_estimation]

            data[indicator[4:].upper()] = tmp1
            data[('DHS_' + indicator[4:]).upper()] = tmp2

        # Define the output path for the result CSV file
        out_path = result_root + country + '/' + year + '/' + country + '_' + year + '_settlement.csv'

        # Save the data DataFrame to a CSV file
        data.to_csv(out_path)

        print(x, '    ends')


def merge_error_analysis_settlement_level():
    # Read the list of indicators
    indicators = read_list_of_indicators(list_of_indicators)

    # Create a dictionary of indicators (replace with your actual function or data)
    indicator_dict = dictionary_of_indicators(list_of_indicators)

    # Read the list of country and year pairs
    country_year = read_list_of_country_years(list_of_country_years)

    # Create an Excel writer and a workbook
    writer = pd.ExcelWriter(result_root + 'settlement_validation.xlsx', engine='xlsxwriter')
    workbook = writer.book

    # Loop through each country and year pair
    for (country, year) in country_year:
        # Initialize a DataFrame to store the results
        result = pd.DataFrame()

        # Map the indicators to their corresponding names using the indicator_dict
        INDICATOR = [indicator_dict[indic] for indic in indicators]

        # Add the 'INDICATOR' column to the result DataFrame
        result['INDICATOR'] = INDICATOR

        # Get the alpha3 country code and uppercase version
        code, CODE = get_country_alpha3_code(country)

        # Construct the path to the settlement result CSV file
        path_to_settlement_result = result_root + country + '/' + year + '/' + country + '_' + year + '_settlement.csv'

        # Read the settlement result CSV file into a DataFrame
        df = pd.read_csv(path_to_settlement_result)

        tmp = [[np.nan for _ in range(5)] for _ in indicators]

        # Loop through indicators and calculate error metrics
        for i, indicator in enumerate(indicators):
            pair = pd.DataFrame()
            a = indicator[4:].upper()
            b = ('DHS_' + indicator[4:]).upper()
            pair[a] = df[a]
            pair[b] = df[b]
            pair = pair.dropna()

            bias = np.mean(pair[a] - pair[b])
            rmsd = np.sqrt(np.mean(abs(pair[a] - pair[b])**2))
            mad = np.mean(abs(pair[a] - pair[b]))
            ratio = np.mean(pair[a]) / np.mean(pair[b])
            madv1 = mad / np.max(pair[a])
            madv2 = mad / np.max(pair[b])
            tmp[i] = np.round([rmsd, mad, ratio, madv1, madv2, bias],3)

        # Add error metrics columns to the result DataFrame
        result['BIAS'] = [t[5] for t in tmp]
        result['RMSD'] = [t[0] for t in tmp]
        result['MAD'] = [t[1] for t in tmp]
        result['RATIO'] = [t[2] for t in tmp]
        result['MAD_to_MaxPred'] = [t[3] for t in tmp]
        result['MAD_to_MaxDHS'] = [t[4] for t in tmp]

        # Get the shape of the result DataFrame
        (max_row, max_column) = result.shape

        # Fill missing values with 'NaN'
        result = result.fillna('NaN')

        # Add a new worksheet for the current country and year
        worksheet = workbook.add_worksheet(country + year)
        writer.sheets[country + year] = worksheet

        # Set column widths
        worksheet.set_column('A:A', 45)
        worksheet.set_column('B:F', 15)

        # Write the result DataFrame to the Excel worksheet
        result.to_excel(writer, sheet_name=country + year, index=False)

        # Define header format
        header_format = workbook.add_format({
            'bg_color': '#d8d8d8',
            'bold': True,
            'text_wrap': True,
            'font_size': 14,
            'valign': 'top',
            'align': 'center'
        })

        # Write column headers to the Excel worksheet
        for col_num, value in enumerate(result.columns.values):
            worksheet.write(0, col_num, value, header_format)

        # Define a function to format cells based on row and column
        def format_func(i, j):
            if i % 3 == 0:
                if j == 0:
                    return workbook.add_format({'bg_color': '#ddf8e7', 'align': 'left', 'font_size': 12, 'bold': True})
                else:
                    return workbook.add_format({'bg_color': '#ddf8e7', 'align': 'center', 'font_size': 12})
            elif i % 3 == 1:
                if j == 0:
                    return workbook.add_format({'bg_color': '#ddeef8', 'align': 'left', 'font_size': 12, 'bold': True})
                else:
                    return workbook.add_format({'bg_color': '#ddeef8', 'align': 'center', 'font_size': 12})
            elif i % 3 == 2:
                if j == 0:
                    return workbook.add_format({'bg_color': '#f3e5fb', 'align': 'left', 'font_size': 12, 'bold': True})
                else:
                    return workbook.add_format({'bg_color': '#f3e5fb', 'align': 'center', 'font_size': 12})

        # Apply formatting to cells in the Excel worksheet
        for row in range(max_row):
            for col_num in range(max_column):
                format_row = format_func(row, col_num)
                worksheet.write(row + 1, col_num, result.iloc[row, col_num], format_row)

    # Save the Excel workbook
    # writer.save()
    workbook.close()


def rmsd_error_analysis_settlement_level():
    # Read the list of indicators
    indicators = read_list_of_indicators(list_of_indicators)

    # Read a dictionary of indicator abbreviations and full names
    indicator_dict = dictionary_of_indicators(list_of_indicators)

    # Read the list of country years
    country_year = read_list_of_country_years(list_of_country_years)

    # Initialize an empty DataFrame to store the results
    result = pd.DataFrame()

    # Create a list of indicator names using the indicator dictionary
    INDICATOR = [indicator_dict[indic] for indic in indicators]

    # Add the indicator names to the result DataFrame
    result['INDICATOR'] = INDICATOR

    # Loop through each (country, year) pair
    for (country, year) in country_year:
        # Get alpha3 country code and uppercase version
        code, CODE = get_country_alpha3_code(country)

        # Define the path to the settlement result file
        path_to_settlement_result = result_root + country + '/' + year + '/' + country + '_' + year + '_settlement.csv'

        # Read the settlement result DataFrame
        df = pd.read_csv(path_to_settlement_result)

        # Initialize a temporary list to store RMSD values for each indicator
        tmp = [[np.nan for _ in range(5)] for _ in indicators]

        # Loop through each indicator
        for i, indicator in enumerate(indicators):
            pair = pd.DataFrame()

            # Extract column names for the current indicator
            a = indicator[4:].upper()
            b = ('DHS_' + indicator[4:]).upper()

            # Populate the pair DataFrame with relevant columns and drop NaN values
            pair[a] = df[a]
            pair[b] = df[b]
            pair = pair.dropna()

            # Calculate RMSD (Root Mean Square Deviation) for the indicator
            rmsd = np.sqrt(np.mean(abs(pair[a] - pair[b])**2))

            # Round the RMSD value and store it in the temporary list
            tmp[i] = np.round(rmsd, 2)

        # Add the temporary list of RMSD values to the result DataFrame
        result[country+' '+year] = tmp

    # Fill NaN values with 'NaN' and replace 0 with 'NaN'
    result = result.fillna('NaN')
    result.replace(0, 'NaN', inplace=True)

    # Save the result DataFrame to a CSV file
    result.to_csv(result_root+'SETTLEMENT_VALIDATION_RMSD.csv')


def validation_subnational_division_level(x, level=1):
    # Extract country and year from input tuple x
    country, year = x
    print(x, '    starts')

    # Read the list of indicators
    indicators = read_list_of_indicators()

    # Generate indicator denominator and numinator lists
    indic_den = ['den' + x[3:] for x in indicators]
    indic_num = ['num' + x[3:] for x in indicators]

    # Paths to necessary shapefiles and files
    path_to_divisions = subnational_shapefile(country,level=level)
    path_to_dhs_survey = dhs_csv_file(country, year)
    path_to_country_shapefile = country_shapefile(country)

    # Read DHS survey data and preprocess it
    df = pd.read_csv(path_to_dhs_survey)
    df = removing_sporious_data(df)
    locations = dhs_cluster_locations(df)
    areas_type = dhs_cluster_areas_type(df)
    cluster_numbers = dhs_cluster_numbers(df)

    # Read the country shapefile
    country_shape = gpd.read_file(path_to_country_shapefile)

    # Find DHS locations within subnational divisions
    dhs_locations_in_division, _, _ = dhs_clusters_inside_subnational_divisions(path_to_divisions, locations, areas_type)

    # Initialize lists for Lidw prediction and DHS estimation
    lidw_prediction, dhs_estimation = [], []

    # Open the shapefile and read shapes and division names
    with fiona.open(path_to_divisions, "r") as shapefile:
        shapes = [feature["geometry"] for feature in shapefile]
        #names  = [normalize(feature["properties"]['VARNAME_'+str(level)], prioritize_alpha=True)[0] \
                  #for feature in shapefile]

        # Iterate through each subnational division
        for i, shapei in enumerate(shapes):
            shapei = shape(shapei)

            # Get the clusters within the division
            clusters_within_division = dhs_locations_in_division[i]

            tmp_pred = [np.nan for _ in indicators]
            tmp_esti = [np.nan for _ in indicators]

            # Iterate through each indicator
            for j, indicator in enumerate(indicators):
                path_to_indicator_raster = indicator_raster(country, year, indicator)

                # Calculate Lidw prediction if the indicator raster exists
                if os.path.exists(path_to_indicator_raster):
                    tmp_pred[j] = average_raster_within_shape(path_to_indicator_raster, shapei)

                indic_den = 'den' + indicator[3:]
                indic_num = 'num' + indicator[3:]

                den = df[indic_den].to_numpy()
                num = df[indic_num].to_numpy()

                n_dhs = np.nansum([num[c] for c in clusters_within_division])
                d_dhs = np.nansum([den[c] for c in clusters_within_division])

                # Calculate DHS estimation
                if d_dhs > 0:
                    tmp_esti[j] = n_dhs / d_dhs

            lidw_prediction.append(tmp_pred)
            dhs_estimation.append(tmp_esti)

        # Create a DataFrame to store the results
        data = pd.DataFrame()
        data['DIVISION_NAME'] = range(len(shapes)) #names

        # Populate the DataFrame with Lidw prediction and DHS estimation
        for j, indicator in enumerate(indicators):
            tmp1 = [d[j] for d in lidw_prediction]
            tmp2 = [d[j] for d in dhs_estimation]

            data[indicator[4:].upper()] = tmp1
            data[('DHS_' + indicator[4:]).upper()] = tmp2

        # Define the output path for the results CSV file
        out_path = result_root + country + '/' + year + '/' + country + '_' + year + '_subnational_level_'+str(level)+'.csv'

        # Save the results to the CSV file
        data.to_csv(out_path)

        print(x, '    ends')


def merge_error_analysis_subnational_division_level(level=1):
    # Read the list of indicators
    indicators = read_list_of_indicators()

    # Create a dictionary of indicators
    indicator_dict = dictionary_of_indicators()

    # Read the list of country years
    country_year = read_list_of_country_years()

    # Create an Excel writer and workbook
    writer = pd.ExcelWriter(result_root + 'subnational_level_'+str(level)+'_validation.xlsx', engine='xlsxwriter')
    workbook = writer.book

    # Loop through each (country, year) pair
    for (country, year) in country_year:
        # Initialize an empty DataFrame to store the results
        result = pd.DataFrame()

        # Create a list of indicator names using the indicator dictionary
        INDICATOR = [indicator_dict[indic] for indic in indicators]

        # Add the indicator names to the result DataFrame
        result['INDICATOR'] = INDICATOR

        # Get alpha3 country code and uppercase version
        code, CODE = get_country_alpha3_code(country)

        # Define the path to the subnational division result file
        path_to_division_result = result_root + country + '/' + year + '/' + country + '_' + year + '_subnational_level_'+str(level)+'.csv'

        # Read the subnational division result DataFrame
        df = pd.read_csv(path_to_division_result)

        # Initialize a temporary list to store various metrics
        tmp = [[np.nan for _ in range(5)] for _ in indicators]

        # Loop through each indicator
        for i, indicator in enumerate(indicators):
            pair = pd.DataFrame()
            a = indicator[4:].upper()
            b = ('DHS_' + indicator[4:]).upper()
            pair[a] = df[a]
            pair[b] = df[b]
            pair = pair.dropna()

            # Calculate RMSD, MAD, ratio, MAD_to_MaxPred, and MAD_to_MaxDHS metrics
            bias = np.mean(pair[a] - pair[b])
            rmsd = np.sqrt(np.mean(abs(pair[a] - pair[b])**2))
            mad = np.mean(abs(pair[a] - pair[b]))
            ratio = np.mean(pair[a]) / np.mean(pair[b])
            madv1 = mad / np.max(pair[a])
            madv2 = mad / np.max(pair[b])
            tmp[i] = np.round([rmsd, mad, ratio, madv1, madv2, bias], 3)

        # Add the calculated metrics to the result DataFrame
        result['BIAS'] = [t[5] for t in tmp]
        result['RMSD'] = [t[0] for t in tmp]
        result['MAD'] = [t[1] for t in tmp]
        result['RATIO'] = [t[2] for t in tmp]
        result['MAD_to_MaxPred'] = [t[3] for t in tmp]
        result['MAD_to_MaxDHS'] = [t[4] for t in tmp]

        # Get the shape of the DataFrame
        (max_row, max_column) = result.shape

        # Fill NaN values with 'NaN'
        result = result.fillna('NaN')

        # Add a worksheet to the Excel workbook
        worksheet = workbook.add_worksheet(country + year)
        writer.sheets[country + year] = worksheet

        # Set column widths and save the DataFrame to the worksheet
        worksheet.set_column('A:A', 45)
        worksheet.set_column('B:F', 15)
        result.to_excel(writer, sheet_name=country + year, index=False)

        # Define a header format
        header_format = workbook.add_format({
            'bg_color': '#d8d8d8',
            'bold': True,
            'text_wrap': True,
            'font_size': 14,
            'valign': 'top',
            'align': 'center'
        })

        # Write the header row with the defined format
        for col_num, value in enumerate(result.columns.values):
            worksheet.write(0, col_num, value, header_format)

        # Define a function to format cells based on row and column
        def format_func(i, j):
            if i % 3 == 0:
                if j == 0:
                    return workbook.add_format({'bg_color': '#ddf8e7', 'align': 'left', 'font_size': 12, 'bold': True})
                else:
                    return workbook.add_format({'bg_color': '#ddf8e7', 'align': 'center', 'font_size': 12})
            elif i % 3 == 1:
                if j == 0:
                    return workbook.add_format({'bg_color': '#ddeef8', 'align': 'left', 'font_size': 12, 'bold': True})
                else:
                    return workbook.add_format({'bg_color': '#ddeef8', 'align': 'center', 'font_size': 12})
            elif i % 3 == 2:
                if j == 0:
                    return workbook.add_format({'bg_color': '#f3e5fb', 'align': 'left', 'font_size': 12, 'bold': True})
                else:
                    return workbook.add_format({'bg_color': '#f3e5fb', 'align': 'center', 'font_size': 12})

        # Apply the format function to cells in the worksheet
        for row in range(max_row):
            for col_num in range(max_column):
                format_row = format_func(row, col_num)
                worksheet.write(row + 1, col_num, result.iloc[row, col_num], format_row)

    # Save the Excel workbook
    # writer.save()
    workbook.close()


def rmsd_error_analysis_subnational_division_level(level=1):
    # Read the list of indicators
    indicators = read_list_of_indicators()

    # Create a dictionary of indicators
    indicator_dict = dictionary_of_indicators()

    # Read the list of country years
    country_year = read_list_of_country_years()

    # Initialize an empty DataFrame to store the results
    result = pd.DataFrame()

    # Create a list of indicator names using the indicator dictionary
    INDICATOR = [indicator_dict[indic] for indic in indicators]

    # Add the indicator names to the result DataFrame
    result['INDICATOR'] = INDICATOR

    # Loop through each (country, year) pair
    for (country, year) in country_year:
        # Get alpha3 country code and uppercase version
        code, CODE = get_country_alpha3_code(country)

        # Define the path to the subnational division result file
        path_to_division_result = result_root + country + '/' + year + '/' + country + '_' + year + '_subnational_level_'+str(level)+'.csv'

        # Read the subnational division result DataFrame
        df = pd.read_csv(path_to_division_result)

        # Initialize a temporary list to store RMSD values for each indicator
        tmp = [[np.nan for _ in range(5)] for _ in indicators]

        # Loop through each indicator
        for i, indicator in enumerate(indicators):
            pair = pd.DataFrame()

            # Extract column names for the current indicator
            a = indicator[4:].upper()
            b = ('DHS_' + indicator[4:]).upper()

            # Populate the pair DataFrame with relevant columns and drop NaN values
            pair[a] = df[a]
            pair[b] = df[b]
            pair = pair.dropna()

            # Calculate RMSD (Root Mean Square Deviation) for the indicator
            rmsd = np.sqrt(np.mean(abs(pair[a] - pair[b])**2))

            # Round the RMSD value and store it in the temporary list
            tmp[i] = np.round(rmsd, 2)

        # Add the temporary list of RMSD values to the result DataFrame
        result[country+' '+year] = tmp

    # Fill NaN values with 'NaN' and replace 0 with 'NaN'
    result = result.fillna('NaN')
    result.replace(0, 'NaN', inplace=True)

    # Save the result DataFrame to a CSV file
    result.to_csv(result_root+'SUBNATIONAL_LEVEL_'+str(level)+'_VALIDATION_RMSD.csv')



def aggregate_error_analysis():
    # Read lists of indicators and country-year pairs
    indicators = read_list_of_indicators()
    country_year = read_list_of_country_years()

    # Create dictionary of indicators
    indicator_dict = dictionary_of_indicators()
    INDICATORS = [indicator_dict[indic] for indic in indicators]

    # Initialize DataFrame to store results
    res = pd.DataFrame()

    for country, year in country_year:
        # Get country code
        code, CODE = get_country_alpha3_code(country)

        # Read CSV and Excel files
        csv_path = os.path.join(result_root, country, year, f'{CODE}_VAL2_{year}.csv')
        df = pd.read_csv(csv_path)
        df.columns = [f'LOOCV_{col}' for col in df.columns]

        settl_validation_path = os.path.join(result_root, 'settlement_validation.xlsx')
        df_set = pd.read_excel(settl_validation_path, sheet_name=f'{country}{year}')
        df_set.columns = [f'SETTL_{col}' for col in df_set.columns]

        adm1_validation_path = os.path.join(result_root, 'subnational_level_1_validation.xlsx')
        df_adm1 = pd.read_excel(adm1_validation_path, sheet_name=f'{country}{year}')
        df_adm1.columns = [f'ADM1_{col}' for col in df_adm1.columns]

        adm2_validation_path = os.path.join(result_root, 'subnational_level_2_validation.xlsx')
        df_adm2 = pd.read_excel(adm2_validation_path, sheet_name=f'{country}{year}')
        df_adm2.columns = [f'ADM2_{col}' for col in df_adm2.columns]

        # Merge data into new rows
        for ind, IND in zip(indicators, INDICATORS):
            filtered_row = df[df['LOOCV_INDICATOR'] == ind[4:]].iloc[0].to_dict()
            settl_row = df_set[df_set['SETTL_INDICATOR'] == IND].iloc[0].to_dict()
            adm1_row = df_adm1[df_adm1['ADM1_INDICATOR'] == IND].iloc[0].to_dict()
            adm2_row = df_adm2[df_adm2['ADM2_INDICATOR'] == IND].iloc[0].to_dict()

            new_row = {'COUNTRY': country, 'YEAR': int(year), 'INDICATOR': IND}
            new_row.update(filtered_row)
            new_row.update(settl_row)
            new_row.update(adm1_row)
            new_row.update(adm2_row)

            # res = res.append(new_row, ignore_index=True)
            res = pd.concat([res, pd.DataFrame([new_row])], ignore_index=True)

    # Remove unnecessary columns
    columns_to_remove = ['LOOCV_Unnamed: 0', 'LOOCV_INDICATOR', 'SETTL_INDICATOR', 'ADM1_INDICATOR', 'ADM2_INDICATOR']
    res = res.drop(columns=columns_to_remove)

    # Rename specific columns
    column_mapping = {'LOOCV_TOT_CLUST': 'TOT_CLUST', 'LOOCV_NUM_CLUST': 'NUM_CLUST'}
    res = res.rename(columns=column_mapping)

    # Save result to CSV
    res.to_csv(os.path.join(result_root, 'VALIDATION_combined.csv'))


















#       THE FUNCTIONS FOR PLOTTING
#---------------------------------------------------------------------------------------------------

def plot_shapes(shapes, clean_previous_plots=False, border=None, fill=None, transparency=1):
    # Clear the previous plots if specified
    if clean_previous_plots:
        plt.clf()

    # Iterate through the shapes
    for i, shape in enumerate(shapes):
        # Check if the shape is a Polygon
        if shape.type == 'Polygon':
            X, Y = shape.exterior.coords.xy
            # Plot the border if specified
            if border is None:
                plt.plot(X, Y, lw=0.3)
            elif isinstance(border, str):
                plt.plot(X, Y, color=border, lw=0.3)
            elif isinstance(border, list):
                plt.plot(X, Y, color=border[i%len(border)], lw=0.3)
            # Fill the shape if specified
            if fill is None:
                plt.fill(X, Y, alpha=transparency)
            elif isinstance(fill, str):
                plt.fill(X, Y, color=fill, alpha=transparency)
            elif isinstance(fill, list):
                plt.fill(X, Y, color=fill[i % len(fill)], alpha=transparency)
        # Check if the shape is a MultiPolygon
        elif shape.type == 'MultiPolygon':
            for part in shape.geoms:
                X, Y = part.exterior.coords.xy
                # Plot the border if specified
                if border is None:
                    plt.plot(X, Y, lw=0.3)
                elif isinstance(border, str):
                    plt.plot(X, Y, color=border, lw=0.3)
                elif isinstance(border, list):
                    plt.plot(X, Y, color=border[i%len(border)], lw=0.3)
                # Fill the shape if specified
                if fill is None:
                    plt.fill(X, Y, alpha=transparency)
                elif isinstance(fill, str):
                    plt.fill(X, Y, color=fill, alpha=transparency)
                elif isinstance(fill, list):
                    plt.fill(X, Y, color=fill[i % len(fill)], alpha=transparency)

def plot_shapes_with_holes(shapes,clean_previous_plots=False, border=None, fill=None, transparency=1):
    """
    Plots shapes represented as Polygon or MultiPolygon geometries.

    Args:
    - shapes: List of Polygon or MultiPolygon geometries.

    Returns:
    - None
    """
    # Clear the previous plots if specified
    if clean_previous_plots:
        plt.clf()

    # Iterate over each shape in the list of shapes
    for i, shapei in enumerate(shapes):
        # Check if the shape is a Polygon
        if shapei.type == 'Polygon':
            # Extract exterior and interior coordinates of the polygon
            extr, intr = polygon_coords(shapei)
            # Extract X and Y coordinates of the exterior ring
            X = [e[0] for e in extr]
            Y = [e[1] for e in extr]

            # Plot the exterior ring
            #plt.plot(X, Y, color='k', lw=0.3)
            #plt.fill(X, Y, alpha=0.3)

            if border is None:
                plt.plot(X, Y, lw=0.3)
            elif isinstance(border, str):
                plt.plot(X, Y, color=border, lw=0.3)
            elif isinstance(border, list):
                plt.plot(X, Y, color=border[i%len(border)], lw=0.3)
            # Fill the shape if specified
            if fill is None:
                plt.fill(X, Y, alpha=transparency)
            elif isinstance(fill, str):
                plt.fill(X, Y, color=fill, alpha=transparency)
            elif isinstance(fill, list):
                plt.fill(X, Y, color=fill[i % len(fill)], alpha=transparency)

            # Plot and fill the interior rings
            for a in intr:
                XX = [e[0] for e in a]
                YY = [e[1] for e in a]
                plt.plot(XX, YY, color='none', lw=0.2)
                plt.fill(XX, YY, color='w', alpha = transparency)

        # Check if the shape is a MultiPolygon
        elif shapei.type == 'MultiPolygon':
            # Iterate over each part of the MultiPolygon
            for part in shapei.geoms:
                # Extract exterior and interior coordinates of the part
                extr, intr = polygon_coords(part)
                # Extract X and Y coordinates of the exterior ring
                X = [e[0] for e in extr]
                Y = [e[1] for e in extr]

                # Plot the exterior ring
                #plt.plot(X, Y, color='k', lw=0.3)
                #plt.fill(X, Y, alpha=0.3)

                if border is None:
                    plt.plot(X, Y, lw=0.3)
                elif isinstance(border, str):
                    plt.plot(X, Y, color=border, lw=0.3)
                elif isinstance(border, list):
                    plt.plot(X, Y, color=border[i%len(border)], lw=0.3)
                # Fill the shape if specified
                if fill is None:
                    plt.fill(X, Y, alpha=transparency)
                elif isinstance(fill, str):
                    plt.fill(X, Y, color=fill, alpha=transparency)
                elif isinstance(fill, list):
                    plt.fill(X, Y, color=fill[i % len(fill)], alpha=transparency)

                # Plot and fill the interior rings
                for a in intr:
                    XX = [e[0] for e in a]
                    YY = [e[1] for e in a]
                    plt.plot(XX, YY, color='none', lw=0.2)
                    plt.fill(XX, YY, color='w', alpha = transparency)



def plot_spatial_network(net, locations, node_color='none'):
    """
    Plots a spatial network on a matplotlib figure.

    Args:
        net (list): Network representation as a list of lists.
        locations (list): List of locations (coordinates) corresponding to the network nodes.
        node_color (str, optional): Color of the network nodes. Default is 'tab:blue'.
    """
    for i, n in enumerate(net):
        for j in n:
            if i < j:
                # Plot a line segment between two connected nodes
                plt.plot([locations[i][0], locations[j][0]], [locations[i][1], locations[j][1]], color='tab:gray', lw=0.3)

    # Extract X and Y coordinates from the locations list
    X = [l[0] for l in locations]
    Y = [l[1] for l in locations]

    # Plot network nodes with specifice color
    plt.plot(X, Y, ls='none', color=node_color, marker='.')

def plot_ghsl_tiff(path_to_tiff_file,fig_name=None):

    plt.clf()

    dataset = rasterio.open(path_to_tiff_file)
    print(dataset.count)
    print(dataset.bounds)
    print(dataset.crs)

    band=dataset.read(1)
    print(band.shape)

    img=band

    img=img.astype('float')
    img[img< 0]='nan'

    img[img==30]=8
    img[img==23]=7
    img[img==22]=6
    img[img==21]=5
    img[img==13]=4
    img[img==12]=3
    img[img==11]=2
    img[img==10]=1
    img[img < 1]='nan'


    colors=[[122,182,245],[205,245,122],[171,205,102],[55,86,35],[255,255,0],[168,112,0],[115,38,0],[255,0,0]]

    colors=np.array(colors) /256.0

    ghsl_cmap=ListedColormap(colors)

    plt.imshow(img,cmap=ghsl_cmap,vmin=1,vmax=8)

    cbr=plt.colorbar(mpl.cm.ScalarMappable(cmap = ghsl_cmap),shrink=0.7)

    labels=['10','11','12','13','21','22','23','30']

    cbr.ax.set_yticks([0.5/8,1.5/8,2.5/8,3.5/8,4.5/8,5.5/8,6.5/8,7.5/8],
    labels=['WATER','MOSTLY UNINHABITED AREA','DISPERSED RURAL AREA','VILLAGE','SUBURBAN','SEMI-DENSE TOWN','DENSE TOWN','CITY'])

    #cbr.ax.set_yticklabels([10,11,12,13,21,22,23,30])

    if fig_name!= None :
        plt.savefig(fig_name,dpi=600,bbox_inches='tight',pad_inches=0.05)


def plot_population_tiff(x,ghs=False):

    country,year = x

    # Get the path to the population raster for the country and year
    if ghs==False :
        path_to_population_raster = population_raster(country, year)
    else :
        path_to_population_raster = ghs_population_raster(country, year)

    # Read the population raster using rasterio
    raster = rasterio.open(path_to_population_raster)
    band = raster.read(1)

    height = raster.height
    width = raster.width

    img=band

    img=img.astype('float')
    threshold=0
    img[img<= threshold]='nan'

    for i in range(height):
         for j in range(width):
             if img[i,j] > threshold :
                 img[i,j]=np.log10(img[i,j])

    plt.imshow(img,cmap='viridis_r',vmin=0,vmax=4)#'viridis_r')#

    cbr=plt.colorbar(mpl.cm.ScalarMappable(cmap = plt.cm.viridis_r), ticks=(0, 0.25,0.50,0.75, 1.0),shrink=0.7)

    cbr.ax.set_yticklabels([1,10,100,1000,10000])


def plot_indicator_tiff(x,min_max_scale = False):
    # Unpack the tuple 'x' containing 'country', 'year', and 'indicator'
    country, year, indicator = x
    print(country, year, indicator)  # Print the provided country, year, and indicator values

    # Obtain the country's alpha-3 code from the function get_country_alpha3_code(country)
    code, CODE = get_country_alpha3_code(country)

    # Get the path to the interpolated TIFF file for the given indicator
    path = result_root + country + '/' + year + '/tiff/' + code + '_' + year + '_idw_' + indicator[4:] + '.tif'

    dic_indic = dictionary_of_indicators()
    indic = dic_indic[indicator]

    # Check if the TIFF file exists
    if os.path.exists(path):
        # Open the TIFF file using rasterio and read the image data (band 1)
        dataset = rasterio.open(path)
        img = dataset.read(1)
        img = img.astype('float')
        img[img < 0] = np.nan

        # Compute statistics for color mapping
        mn = np.nanmin(img)
        #mx = (np.nanmedian(img) + np.nanmax(img)) * 0.5
        mx = np.nanmax(img)

        # Print the minimum and maximum values for reference
        #print(round(mn, 3), round(mx, 3))

        # Create the plot using matplotlib
        if min_max_scale == False :
            plt.imshow(img, cmap='RdYlGn', vmin=0, vmax=1)
        else :
            plt.imshow(img, cmap='RdYlGn', vmin=mn, vmax=mx)

        # Set the title and subtitle for the plot
        title = country + ' ' + year
        title = title.upper()
        subtitle = indic #indicator[4:].upper()
        plt.suptitle(title + '\n' + subtitle, y=1.02, fontsize=14)

        # Turn off axis ticks and labels
        plt.axis('off')

        # Add a colorbar to the plot with custom labels
        cbr = plt.colorbar(mpl.cm.ScalarMappable(cmap=plt.cm.RdYlGn), ticks=(0, 0.5, 1.0), shrink=0.7)

        if min_max_scale == False :
            cbr.ax.set_yticklabels([0,  50, 100])
        else :
            cbr.ax.set_yticklabels([int(mn * 100), int((mn+mx) * 50),int(mx * 100)])


        cbr.set_label('PERCENTAGE', rotation=270, labelpad=15)

        # Define the subfolder to save the plotted PNG file
        subfolder = result_root + country + '/' + year + '/tiff/png/'
        if not os.path.exists(subfolder):
            os.makedirs(subfolder)

        indic = dic_indic[indicator].replace(' ', '_')

        # Define the output path for the plotted PNG file
        out_path = subfolder + code + '_' + year + '_idw_' + indic + ' .png'

        # Save the plot as a PNG image file with specified resolution and layout parameters
        plt.savefig(out_path, dpi=300, bbox_inches='tight', pad_inches=0.05)
        plt.clf()  # Clear the current plot to avoid overlapping when used in a loop or batch processing

def plot_indicator_raster_with_border(x):

    country, year, indicator = x

    # Obtain the country's alpha-3 code from the function get_country_alpha3_code(country)
    code, CODE = get_country_alpha3_code(country)

    dic_indic = dictionary_of_indicators()
    indic = dic_indic[indicator]

    raster_path = indicator_raster(country, year, indicator)

    shapefile_path = country_shapefile(country)

    # Check if the TIFF file exists
    if os.path.exists(raster_path):

        # Load the shapefile
        with fiona.open(shapefile_path, "r") as shapefile:
            shapes = [shape(feature["geometry"]) for feature in shapefile]

        # Load the raster data
        with rasterio.open(raster_path) as src:
            raster_data = src.read(1)  # Read the first band
            raster_meta = src.meta
            raster_transform = src.transform

            # Mask the raster with the shapefile

            out_image, out_transform = rasterio.mask.mask(src, shapes, crop=True)
            out_meta = src.meta.copy()
            out_meta.update({"driver": "GTiff",
                             "height": out_image.shape[1],
                             "width": out_image.shape[2],
                             "transform": out_transform})

            out_image[out_image == src.nodata] = np.nan

        # Plot the raster
        raster_plot = plt.imshow(out_image[0], cmap='viridis', extent=(out_transform[2], out_transform[2] + out_transform[0] * out_meta['width'],out_transform[5] + out_transform[4] * out_meta['height'], out_transform[5]),vmin=0, vmax=1)

        # Set the title and subtitle for the plot
        title = country + ' ' + year
        title = title.upper()
        subtitle = indic #indicator[4:].upper()
        plt.suptitle(title + '\n' + subtitle, y=1.02, fontsize=14)

        cbr = plt.colorbar(raster_plot, orientation='vertical',shrink=0.5,ticks=(0, 0.5, 1.0))
        cbr.ax.set_yticklabels([0,  50, 100])
        cbr.set_label('PERCENTAGE', rotation=270, labelpad=15)

        # Plot the border
        plot_shapes(shapes,border='k',transparency=0)

        plt.axis('off')

        # Define the subfolder to save the plotted PNG file
        subfolder = result_root + country + '/' + year + '/tiff/png/'
        if not os.path.exists(subfolder):
            os.makedirs(subfolder)

        indic = dic_indic[indicator].replace(' ', '_')

        # Define the output path for the plotted PNG file
        out_path = subfolder + code + '_' + year + '_idw_' + indic + '.png'

        # Save the plot as a PNG image file with specified resolution and layout parameters
        plt.savefig(out_path, dpi=300, bbox_inches='tight', pad_inches=0.05)

        plt.clf()  # Clear the current plot to avoid overlapping when used in a loop or batch processing


def plot_population_raster_with_border(x):

    country, year = x

    # Obtain the country's alpha-3 code from the function get_country_alpha3_code(country)
    code, CODE = get_country_alpha3_code(country)



    raster_path = population_raster(country, year)

    shapefile_path = country_shapefile(country)

    # Check if the TIFF file exists
    if os.path.exists(raster_path):

        # Load the shapefile
        with fiona.open(shapefile_path, "r") as shapefile:
            shapes = [shape(feature["geometry"]) for feature in shapefile]

        # Load the raster data
        with rasterio.open(raster_path) as src:
            raster_data = src.read(1)  # Read the first band
            raster_meta = src.meta
            raster_transform = src.transform

            # Mask the raster with the shapefile

            out_image, out_transform = rasterio.mask.mask(src, shapes, crop=True)
            out_meta = src.meta.copy()
            out_meta.update({"driver": "GTiff",
                             "height": out_image.shape[1],
                             "width": out_image.shape[2],
                             "transform": out_transform})

            out_image[out_image == src.nodata] = np.nan

            out_image[out_image != src.nodata]=np.log10(out_image[out_image != src.nodata])

        # Plot the raster
        raster_plot = plt.imshow(out_image[0], cmap='jet', extent=(out_transform[2], out_transform[2] + out_transform[0] * out_meta['width'],out_transform[5] + out_transform[4] * out_meta['height'], out_transform[5]),vmin=0, vmax=4)

        cbr = plt.colorbar(raster_plot, orientation='vertical',shrink=0.5,ticks=(0, 1,2,3, 4))
        cbr.ax.set_yticklabels([1, 10, 100,1000,10000])
        cbr.set_label('PERCENTAGE', rotation=270, labelpad=15)

        # Plot the border
        plot_shapes(shapes,border='k',transparency=0)

        plt.axis('off')




def get_raster_indices(src,shape,touched=True):

    # masked_data, _ = mask(src, [shape], all_touched=touched, crop=False)
    masked_data, _ = rasterio.mask(src, [shape], all_touched=touched, crop=False)

    indices = []

    for i in range(src.height):
        for j in range(src.width):

            if masked_data[0][i,j] != src.nodata :
                indices.append((i,j))

    return indices

def get_masked_pixel_indices(src, shape):

    # Create a mask for the shape
    out_image, out_transform = rasterio.mask.mask(src, [shape], all_touched=True, crop=True)

    # Read the original data
    original_data = src.read(1)

    # Get the window from the original raster that corresponds to the masked area
    window = rasterio.windows.from_bounds(*shape.bounds, transform=src.transform)

    # Read the data within this window from the original raster
    data_in_window = src.read(1, window=window)

    # Create a mask for valid (non-zero) pixels
    mask = (out_image[0] != src.nodata) #& (out_image[0] != 0)

    # Get the indices of the masked pixels
    indices = np.argwhere(mask)

    # Adjust the indices to match the original raster
    adjusted_indices = [(int(idx[0] + window.row_off), int(idx[1] + window.col_off)) for idx in indices]

    return adjusted_indices

def loocv_settlements(x):

    country, year, indicator = x
    print(x,'start')
    code, CODE = get_country_alpha3_code(country)

    path_to_indicators_file = dhs_csv_file(country, year)

    path_to_indicator_raster = indicator_raster(country, year, indicator)

    path_to_settlements_shapefile = settlements_shapefile(country, year)

    path_to_shapefile = country_shapefile(country)

    dic_indic = dictionary_of_indicators()
    indic = dic_indic[indicator]

    country_shape = gpd.read_file(path_to_shapefile)

    df = pd.read_csv(path_to_indicators_file)

    df = df[['cluster', indicator, 'LNG', 'LAT', 'URBAN_RURA']]

    df = removing_sporious_data(df)

    df = df.dropna()

    if len(df) > 0 :

        locations = dhs_cluster_locations(df)

        areas_type = dhs_cluster_areas_type(df)

        cluster_num = dhs_cluster_numbers(df)

        dhs_locations_in_settlement, _, _ = dhs_clusters_inside_settlements(path_to_settlements_shapefile, locations, areas_type)

        dhs_settlement_clusters, dhs_settlement_id = dhs_settlements(dhs_locations_in_settlement)



        loocv_estimate, direct_estimate, num_pixels = [], [], []

        with fiona.open(path_to_settlements_shapefile, "r") as shapefile:

            shapes = [shape(feature["geometry"]) for feature in shapefile]

            lidw_estimation_dict = lidw_estimation_for_settlements(country, year, indicator, shapes, dhs_settlement_id)

            with rasterio.open(path_to_indicator_raster) as src:
                data = src.read(1)
                height = src.height
                width = src.width
                nodata = src.nodata

                for n,id in enumerate(dhs_settlement_id):

                    clusters_idx = dhs_settlement_clusters[n]

                    clusters_to_remove = [cluster_num[c] for c in clusters_idx]

                    filtered_df = df[~df['cluster'].isin(clusters_to_remove)]

                    indicator_percentages = filtered_df[indicator].tolist()

                    filtered_locations = dhs_cluster_locations(filtered_df)

                    regions = voronoi_regions(filtered_locations, country_shape)

                    net = dhs_clusters_network(regions, self_loop=True)

                    #indices = get_raster_indices(src,shapes[id])
                    indices = get_masked_pixel_indices(src,shapes[id])

                    average = 0.0

                    for i,j in indices:
                        loc = src.xy(i, j)
                        point = Point(loc)

                        for k in range(len(regions)):
                            polygon = regions[k][0]
                            if point.within(polygon):
                                weight = [1.0 / distance(loc, regions[a][1]) for a in net[k]]
                                predict = [indicator_percentages[regions[a][2]] * w / sum(weight) for a, w in zip(net[k], weight)]
                                average += sum(predict)
                                break
                    if len(indices) > 0 :
                        average /= len(indices)

                    direct_estimate.append(lidw_estimation_dict[id])

                    num_pixels.append(len(indices))

                    loocv_estimate.append(average)
                    if n%10 == 0 :
                        print(x,n,len(dhs_settlement_id))



                num_dhs_clust = [ len(c) for c in  dhs_settlement_clusters ]

                res = pd.DataFrame()

                res['NUM_DHS_CLUST'] = num_dhs_clust
                res['NUM_PIXELS'] = num_pixels
                res['DIR_EST'] = direct_estimate
                res['LOOCV_EST' ] = loocv_estimate

                subfolder = result_root + country + '/' + year + '/loocv_settl_valid/'
                if not os.path.exists(subfolder):
                    os.makedirs(subfolder)

                out_path =  subfolder + code + '_' + year + '_idw_loocv_settl_' + indicator[4:] +'.csv'

                res.to_csv(out_path)
                print(x,'end')

    else :
        print(x,'ended without result.')


def rmse_loocv_settlements(x):

    country, year, indicator = x

    code, CODE = get_country_alpha3_code(country)

    path_to_csv = result_root + country + '/' + year + '/loocv_settl_valid/' + code + '_' + year + '_idw_loocv_settl_' + indicator[4:] +'.csv'

    if os.path.exists(path_to_csv) :

        df = pd.read_csv(path_to_csv)

        dir_est = df['DIR_EST'].tolist()

        loocv_est = df['LOOCV_EST'].tolist()

        bias, std, mad = calculate_difference(dir_est,loocv_est)

        return len(dir_est), bias, mad, std

    else :
        return 0 , np.nan , np.nan, np.nan

def loocv_settlements_at_country_level():

    indicators = read_list_of_indicators()

    country_year = read_list_of_country_years()

    dic_indic = dictionary_of_indicators()

    COUNTRY, YEAR, NUM_SETTL, INDICATOR, BIAS, MAD, STD = [], [], [], [], [], [], []

    for country,year in country_year :

        for indicator in indicators :

            n,b,m,s = rmse_loocv_settlements((country, year, indicator))

            COUNTRY.append(country)
            YEAR.append(year)
            INDICATOR.append(dic_indic[indicator])
            NUM_SETTL.append(n)
            BIAS.append(format(b,".5f"))
            MAD.append(format(m,".4f"))
            STD.append(format(s,".4f"))

    res = pd.DataFrame()

    res['COUNTRY'] = COUNTRY
    res['YEAR'] = YEAR
    res['INDICATOR'] = INDICATOR
    res['NUM_SETTL'] = NUM_SETTL
    res['BIAS'] = BIAS
    res['MAD'] = MAD
    res['RMSD'] = STD

    res.to_csv(result_root+'LOOCV_SETTLEMENTS.csv')

def loocv_settlements_details():

    indicators = read_list_of_indicators()

    dict_indic = dictionary_of_indicators()

    country_year = read_list_of_country_years()

    df_all = []

    for country, year in country_year:

        path_to_settlements_shapefile = settlements_shapefile(country, year)

        num_sett = 0

        with fiona.open(path_to_settlements_shapefile, "r") as shapefile:

            shapes = [shape(feature["geometry"]) for feature in shapefile]

            num_sett = len(shapes)

        for indicator in indicators:

            code, CODE = get_country_alpha3_code(country)

            path_to_indicators_file = dhs_csv_file(country, year)

            dhs = pd.read_csv(path_to_indicators_file)

            dhs = dhs[['cluster', indicator, 'LNG', 'LAT', 'URBAN_RURA']]

            num_dhs = len(dhs)

            dhs = removing_sporious_data(dhs)

            dhs = dhs.dropna()

            num_valid_dhs = len(dhs)

            path_to_csv = result_root + country + '/' + year + '/loocv_settl_valid/' + code + '_' + year + '_idw_loocv_settl_' + indicator[4:] +'.csv'

            if os.path.exists(path_to_csv) :

                indic = dict_indic[indicator]

                df = pd.read_csv(path_to_csv)

                temp = pd.DataFrame()

                temp['COUNTRY'] = [country for _ in range(len(df))]

                temp['YEAR'] = [year for _ in range(len(df))]

                temp['TOT_NUM_SETT'] = [num_sett for _ in range(len(df))]

                temp['TOT_DHS_CLUST'] = [num_dhs for _ in range(len(df))]

                temp['VALID_DHS_CLUST'] = [num_valid_dhs for _ in range(len(df))]

                temp['NUM_DHS_SETT'] = [len(df) for _ in range(len(df))]

                temp['INDICATOR'] = [indic for _ in range(len(df))]

                temp['IDX_DHS_SETT_CNTRY'] = [i for i in range(len(df))]

                temp['NUM_DHS_CLUST_SETT'] = df['NUM_DHS_CLUST']

                temp['NUM_PIXELS'] = df['NUM_PIXELS']

                temp['DIR_EST'] = df['DIR_EST']

                temp['LOOCV_EST'] = df['LOOCV_EST']

                df_all.append(temp)

        combined_df = pd.concat(df_all, ignore_index=True)

        combined_df.to_csv(result_root+'LOOCV_SETT_DIFF.csv', index=False)

def int_to_str_with_length(number, length):
    # Convert the integer to a string and pad with leading zeros
    return str(number).zfill(length)



def settlements_indicators_to_csv(x):

    country, year = x

    code, CODE = get_country_alpha3_code(country)

    path_to_settlements_shapefile = settlements_shapefile(country, year)

    path_to_population_raster = ghs_population_raster(country, year)

    path_to_settlements_shapefile = settlements_shapefile(country, year)  #subnational_shapefile(country,level=2) #settlements_shapefile(country, year)

    indicators = read_list_of_indicators()

    total_population = 0

    with rasterio.open(path_to_population_raster) as src:

         data = src.read(1)

         data[data < 0] = 0

         total_population = np.sum(data)

    sett_code, sett_pop, sett_frac = [], [], []

    sett_indicator = [[] for _ in indicators]

    with fiona.open(path_to_settlements_shapefile, "r") as shapefile:

        shapes = [shape(feature["geometry"]) for feature in shapefile]

        for s,shapei in enumerate(shapes):

            shape_code = CODE+str(s).zfill(6)

            sett_code.append(shape_code)

            temp = aggregate_raster_within_shape(path_to_population_raster,shapei)

            sett_pop.append(temp)

            sett_frac.append (temp / total_population)

            for i, indicator in enumerate(indicators):

                path_to_indicator_raster = indicator_raster(country, year, indicator)

                if os.path.exists(path_to_indicator_raster):

                    temp = average_raster_within_shape(path_to_indicator_raster , shapei)

                else :

                    temp = -1

                sett_indicator[i].append(temp)

            if s%100 == 0 :
                print(x,s,len(shapes))

    res = pd.DataFrame()

    res['SETT_CODE'] = sett_code
    res['SETT_POP'] = sett_pop
    res['SETT_FRAC'] = sett_frac

    for i, indicator in enumerate(indicators):
        INDIC = indicators[i][4:].upper()
        res[INDIC] = sett_indicator[i]

    subfolder = result_root + country + '/' + year +'/'

    if not os.path.exists(subfolder):

        os.makedirs(subfolder)

    res.to_csv(subfolder+code+'_sett_indic.csv')


def add_properties_with_values_to_new_shapefile(shapefile_path, modified_shapefile_path, properties_with_values):
    # Open the existing shapefile to read
    with fiona.open(shapefile_path, 'r') as src:
        # Copy the original metadata
        meta = src.meta

        # Update the schema to include new properties
        for prop in properties_with_values.keys():
            sample_value = properties_with_values[prop][0]
            ptype = type(sample_value).__name__
            if ptype == 'str':
                meta['schema']['properties'][prop] = 'str'
            elif ptype == 'int':
                meta['schema']['properties'][prop] = 'int'
            elif ptype == 'float':
                meta['schema']['properties'][prop] = 'float'
            else:
                raise TypeError(f"Unsupported property type: {ptype}")

        # Create a new file to write updated features
        with fiona.open(modified_shapefile_path, 'w', **meta) as dst:
            for i, feature in enumerate(src):
                # Add new properties with specified values to each feature
                for prop, values in properties_with_values.items():
                    feature['properties'][prop] = values[i]
                dst.write(feature)



def settlements_indicators_to_shapefile(x) :

    country, year = x

    code, CODE = get_country_alpha3_code(country)

    path_to_settlements_shapefile = settlements_shapefile(country, year)

    path_to_sett_indic = result_root + country + '/' + year +'/'+ code+'_sett_indic.csv'

    indicators = read_list_of_indicators()

    headers = ['SETT_CODE','SETT_POP','SETT_FRAC']+[ indicator[4:].upper() for indicator in indicators]

    labels = ['SETT_CODE','SETT_POP','SETT_FRAC','ELEC_H_ELC','SRCE_H_IMP','IODZ_H_IOD','ANEM_W_ANY','ANCN_W_N4P','SZWT_C_L25',
              'IYCB_C_EXB','VACC_C_BCG','VACC_C_DP3','VACC_C_MSL','NETC_C_ITN','DIAT_C_ORS','NUTS_C_HA2',
              'NUTS_C_WH2','ANMC_C_ANY']


    df = pd.read_csv(path_to_sett_indic)

    properties = {}

    for l,h in zip(labels,headers) :

        properties[l] = df[h].tolist()


    subfolder = result_root + country + '/' + year +'/'+code+'_sett_indic_shapefile/'

    if not os.path.exists(subfolder):

        os.makedirs(subfolder)


    path_to_modified_settlements_shapefile = subfolder+code+'_sett_indic.shp'

    add_properties_with_values_to_new_shapefile(path_to_settlements_shapefile, path_to_modified_settlements_shapefile, properties)


def ghs_population_count(x) :

    country, year = x

    code, CODE = get_country_alpha3_code(country)

    path_to_sett_indic = result_root + country + '/' + year +'/'+ code+'_sett_indic.csv'


    path_to_population_raster = ghs_population_raster(country, year)

    pop_tot = 0

    with rasterio.open(path_to_population_raster) as src:

         data = src.read(1)

         data[data < 0] = 0

         pop_tot = np.sum(data)


    df = pd.read_csv(path_to_sett_indic)

    sett_tot = np.nansum(df['SETT_POP'].tolist())

    frac_tot = np.nansum(df['SETT_FRAC'].tolist())

    return pop_tot, sett_tot,frac_tot


def population_settlements():

    country_year = read_list_of_country_years()

    COUNTRY, YEAR, POP_TOT, SETT_TOT, FRAC_TOT = [], [], [], [], []

    for x in country_year :

        pop_tot, sett_tot,frac_tot =  ghs_population_count(x)

        COUNTRY.append(x[0])

        YEAR.append(x[1])

        POP_TOT.append(pop_tot)

        SETT_TOT.append(sett_tot)

        FRAC_TOT.append(frac_tot)

    res = pd.DataFrame()

    res['COUNTRY'] = COUNTRY

    res['YEAR'] = YEAR

    res['POP_TOT'] = POP_TOT

    res['SETT_TOT'] = SETT_TOT

    res['FRAC_TOT'] = FRAC_TOT

    res.to_csv(result_root+'pop_sett.csv')





def filter_ucdb_shapes_within_country(input_shapefile, output_shapefile, country_name):

    with fiona.open(input_shapefile, 'r') as input_shp:
        # Copy the schema and CRS from the input shapefile
        input_schema = input_shp.schema
        input_crs = input_shp.crs

        # Define a new schema if needed (optional)
        output_schema = input_schema

        # Open the output shapefile
        with fiona.open(output_shapefile, 'w', driver='ESRI Shapefile', crs=input_crs, schema=output_schema) as output_shp:
            # Loop over the input shapes
            for feature in input_shp:
                # Check if the feature matches the filter criteria
                if feature['properties']['CTR_MN_NM'] == country_name:
                    # Write the feature to the output shapefile
                    output_shp.write(feature)


def ucdb_country_shapefiles():

    input_shapefile = data_root+'Globe/GHS_STAT_UCDB2015MT_GLOBE_R2019A_V1_2/GHS_UCDB/GHS_STAT_UCDB2015MT_GLOBE_R2019A_V1_2.shp'

    country_year =read_list_of_country_years()

    for country, year in country_year:

        code, CODE = get_country_alpha3_code(country)

        subfolder = data_root +country+'/'+code+'_ucdb/'

        if not os.path.exists(subfolder):
            os.makedirs(subfolder)

        output_shapefile = subfolder+code+"_ucdb.shp"

        # Select shapes within the boundary and save to a new shapefile
        filter_ucdb_shapes_within_country(input_shapefile, output_shapefile, country)

        print(country)

def fraction_of_overlapping_shapes(shapes1_path, shapes2_path):
    # Read the first shapefile and convert geometries to shapely shapes
    with fiona.open(shapes1_path, 'r') as src1:
        shapes1 = [shape(feature['geometry']) for feature in src1]

    # Read the second shapefile and convert geometries to shapely shapes
    with fiona.open(shapes2_path, 'r') as src2:
        shapes2 = [shape(feature['geometry']) for feature in src2]

    # Initialize count of overlapping shapes
    overlap = [0 for _ in shapes1 ]
    count = [0 for _ in shapes1 ]
    # Check each shape in shapes1 for overlap with any shape in shapes2
    for i, geom1 in enumerate(shapes1):
        total_area = polygon_area(geom1)
        for geom2 in shapes2:
            if geom1.intersects(geom2):
                intersect = geom1.intersection(geom2)
                intersection_area = polygon_area(intersect)
                count[i] = 1
                overlap [i] += intersection_area / total_area

    return len(shapes1), np.sum(count), np.mean(overlap)


def overlap_with_ucdb():

    country_year =read_list_of_country_years()

    COUNTRY, YEAR, UCDB, NUM_OVER, FRAC_OVER = [], [], [], [], []

    for country, year in country_year:

        code, CODE = get_country_alpha3_code(country)

        shapes1_path = data_root +country+'/'+code+'_ucdb/'+code+"_ucdb.shp"
        shapes2_path = settlements_shapefile(country, year)

        a,b,c = fraction_of_overlapping_shapes(shapes1_path, shapes2_path)

        COUNTRY.append(country)
        YEAR.append(year)
        UCDB.append(a)
        NUM_OVER.append(b)
        FRAC_OVER.append(c)

        print(country, year, a,b,c)

    res = pd.DataFrame()

    res['COUNTRY'] = COUNTRY
    res['NUM_UCDB'] = UCDB
    res['NUM_OVER'] = NUM_OVER
    res['FRAC_OVER'] = FRAC_OVER

    res.to_csv(result_root+'overlap.csv')



def convert_gpkg_to_shp(gpkg_path, layer_name, shp_path):
    # Read the layer from the GeoPackage
    data = gpd.read_file(gpkg_path, layer=layer_name)

    # Write the data to a Shapefile
    data.to_file(shp_path, driver='ESRI Shapefile')


def generate_geotiff_from_shapefile(shapefile_path, reference_geotiff_path, attribute, output_geotiff_path):
    # Read the reference GeoTIFF to get the metadata
    with rasterio.open(reference_geotiff_path) as ref_tif:
        transform = ref_tif.transform
        out_shape = (ref_tif.height, ref_tif.width)
        crs = ref_tif.crs
        dtype = ref_tif.dtypes[0]

    # Read the shapes from the shapefile
    shapes = []
    with fiona.open(shapefile_path, 'r') as src:

        settlements = [ shape(feature['geometry']) for feature in src]

        values = [ feature['properties'][attribute] for feature in src]

        for value, settlement in zip(values,settlements):

            shapes.append((mapping(settlement), value))  # Assign a value to each shape for rasterization

    # Rasterize the shapes
    raster = rasterize(
        shapes=shapes,
        out_shape=out_shape,
        transform=transform,
        fill=-9999,  # Fill value for areas outside the shapes
        dtype=dtype
    )

    # Write the raster to a new GeoTIFF file
    with rasterio.open(
        output_geotiff_path,
        'w',
        driver='GTiff',
        height=out_shape[0],
        width=out_shape[1],
        count=1,
        dtype=dtype,
        crs=crs,
        transform=transform
    ) as dst:
        dst.write(raster, 1)

def calculate_difference(list1, list2):
    differences = [x - y for x, y in zip(list1, list2)]

    mean_absolute_difference = np.mean([abs(x - y) for x, y in zip(list1, list2)])

    mean_difference = np.mean(differences)
    std_dev_difference = np.std(differences)

    return mean_difference, std_dev_difference,  mean_absolute_difference

def compare_with_utazi(x):

    country, year = x

    indicator = 'cov_ch_meas_either_u5'

    indic_den = 'den' + indicator[3:]
    indic_num = 'num' + indicator[3:]

    code, CODE = get_country_alpha3_code(country)

    path_to_indicators_file = dhs_csv_file(country, year)

    path_to_indicator_raster = indicator_raster(country, year, indicator)

    path_to_utazi_indicator_raster = data_root+'Utazi/'+CODE+'_mean_pred_total_perc.tif'

    path_to_settlements_shapefile = settlements_shapefile(country, year)

    path_to_country_shapefile = country_shapefile(country)

    path_to_zone_shapefile =  data_root+'Utazi/'+country+'/sdr_subnational_boundaries.shp'

    df = pd.read_csv(path_to_indicators_file)

    df = df[['cluster', indicator, 'LNG', 'LAT', 'URBAN_RURA',indic_num,indic_den]]

    df = removing_sporious_data(df)

    df = df.dropna()

    locations = dhs_cluster_locations(df)

    areas_type = dhs_cluster_areas_type(df)

    numerator = df[indic_num].tolist()

    denominator = df[indic_den].tolist()

    longitudes = [l[0] for l in locations]
    latitudes = [l[1] for l in locations]


    lidw_sett, lidw, dhs, utazi, regname = [], [], [], [], []

    with fiona.open(path_to_zone_shapefile, "r") as shapefile:

        zones = [shape(feature["geometry"]) for feature in shapefile]

        names = [feature["properties"]["DHSREGEN"] for feature in shapefile]

        for z,zone in enumerate(zones):

            uz = average_raster_within_shape(path_to_utazi_indicator_raster, zone)

            utazi.append(uz/100.0)

            lz = average_raster_within_shape(path_to_indicator_raster, zone)

            lidw.append(lz)

            num, den = 0, 0

            for i,l in enumerate(locations) :

                point = Point(l)

                if point.within(zone) :

                    num += numerator[i]

                    den += denominator[i]

            dz = num/den

            dhs.append(dz)

            with fiona.open(path_to_settlements_shapefile, "r") as set_shapefile:

                settlements = [shape(feature["geometry"]) for feature in set_shapefile]

                valid_pixels = []

                for j, settlement in enumerate(settlements):

                    if settlement.intersects(zone):

                        intersect = settlement.intersection(zone)

                        val_p = valid_raster_pixels_within_shape(path_to_indicator_raster,intersect)

                        valid_pixels += val_p

                sz = np.mean(valid_pixels)

                lidw_sett.append(sz)

                regname.append(names[z])

    res = pd.DataFrame()

    res['REGNAME'] = regname
    res['LIDW_SETT_EST'] = lidw_sett
    res['LIDW_EST'] = lidw
    res['DHS_EST'] = dhs
    res['BGM_EST'] = utazi

    subfolder = result_root+'/Utazi/'
    if not os.path.exists(subfolder):
        os.makedirs(subfolder)

    res.to_csv(subfolder+country+'_measles_u5.csv')


def rmsd_lidw_dhs_utazi():

  count, first, second, rmsd = [], [], [], []
  for country in ['Cambodia', 'Mozambique', 'Nigeria'] :

    df = pd.read_csv(result_root+'Utazi/'+country+'_measles_u5.csv')

    lidw_s = df['LIDW_SETT_EST']
    lidw = df['LIDW_EST']
    dhs = df['DHS_EST']
    bgm = df['BGM_EST']

    du = pd.read_csv(data_root+'Utazi/'+country+'_Utazi.csv')

    utazi = du['UTAZI']
    utazi_dhs = du['UTAZI_DHS']

    lst = [lidw_s, lidw, dhs, bgm, utazi, utazi_dhs]
    name = ['LIDW_SETT_EST', 'LIDW_EST', 'DHS_EST', 'BGM_EST', 'UTAZI', 'UTAZI_DHS']


    for i,l in enumerate(lst):
        for j,u in enumerate(lst):
            if j > i :
                _, d, _ = calculate_difference(l,u)

                count.append(country)
                first.append(name[i])
                second.append(name[j])
                rmsd.append(d)
                print(country,name[i],name[j],d)

  res = pd.DataFrame()

  res['COUNTRY'] = count
  res['FIRST'] = first
  res['SECOND'] = second
  res['RMSD'] = rmsd

  res.to_csv(result_root+'MEASLES_U5_RMSD.csv')

def error_analysis_network_level_utazi():
    # Read a list of country-year combinations from the provided path
    country_year = [ ('Cambodia','2014'),
                     ('Mozambique','2011'),
                     ('Nigeria','2013')]

    indicator_name = 'cov_ch_meas_either_u5'

    # Loop through each (country, year) combination
    for (country, year) in country_year:
        # Get the alpha-3 country code
        code, CODE = get_country_alpha3_code(country)

        # Define paths to relevant files
        dhs_path = data_root + country + '/' + year + '/' + country + '_DHS_' + year + '.csv'

        indic_path = result_root + country + '/' + year + '/validation/'+CODE + '_VAL2_' + indicator_name + '_' + year + '.csv'

        # Read DHS data for the given country and year
        dhs = pd.read_csv(dhs_path)
        tot_clust = len(dhs.index)  # Total number of clusters

        # Initialize empty lists to store indicator-wise metrics
        COUNTRY, BIAS, MAE, RMSE, P95, RATIO, TOT_CLUST, NUM_CLUST = [], [], [], [], [], [], [], []

        # Collect indicator files in the 'validation' directory
        indicators = [indic_path]



        # Loop through each indicator file
        for indicator in indicators:
            df = pd.read_csv(indicator)  # Read the indicator validation data

            # Initialize metrics as NaN (Not a Number)
            bias, mae, rmse, p95, ratio = np.nan, np.nan, np.nan, np.nan, np.nan

            name = indicator[len(indic_path) + 1 + 13:-9]  # Extract indicator name from the path

            num_clust = len(df.index)  # Number of clusters in the validation data

            if num_clust > 0:
                vac_dhs = df['DHS_VAL'].to_numpy()  # True DHS values
                vac_pred = df['PRED_VAL'].to_numpy()  # Predicted values
                vac_std = df['VAL_STD'].to_numpy()  # Standard deviations of predicted values

                err = vac_pred - vac_dhs #vac_dhs - vac_pred  # Calculate errors

                rmse = np.sqrt(np.sum(err ** 2) / len(err))  # Calculate RMSE
                rmse = np.round(rmse, 3)

                # Calculate the percentage of predictions within 95% confidence interval
                p95 = sum([1 for vr, vp, vs in zip(vac_dhs, vac_pred, vac_std)
                           if vp - 1.96 * vs <= vr <= vp + 1.96 * vs]) / len(err)
                p95 = np.round(p95, 3) * 100

                mae = np.mean(abs(err))  # Calculate MAE
                mae = np.round(mae, 3)

                av = np.mean(vac_dhs)  # Mean of true DHS values
                bias = np.mean(err)  # Calculate bias
                bias = np.round(bias, 4)

                ratio = np.nan

                if av > 0 : #np.mean(vac_pred) > 0:
                    ratio = np.mean(vac_pred) / av #/ np.mean(vac_pred)  # Calculate ratio of mean values
                    ratio = np.round(ratio, 3)

            # Append metrics to respective lists
            COUNTRY.append(country)
            TOT_CLUST.append(tot_clust)
            NUM_CLUST.append(num_clust)
            BIAS.append(bias)
            MAE.append(mae)
            RMSE.append(rmse)
            P95.append(p95)
            RATIO.append(ratio)

        # Create a DataFrame to store the results
        res = pd.DataFrame()
        res['COUNTRY'] = COUNTRY
        res['TOT_CLUST'] = TOT_CLUST
        res['NUM_CLUST'] = NUM_CLUST
        res['BIAS'] = BIAS
        res['RATIO'] = RATIO
        res['MAE'] = MAE
        res['RMSE'] = RMSE
        res['P95'] = P95

        # Define the output path for the summary CSV file
        output_path = result_root + country + '/' + year + '/' + CODE + '_VAL2_UTAZI'
        res.to_csv(output_path + '.csv')  # Save the DataFrame as a CSV file

        # Print the processed country and year
        print(country, year)




def local_inverse_distance_weighting_interpolation_10(x):

    country, year, indicator, number = x

    code, CODE = get_country_alpha3_code(country)

    path_to_indicator_file = dhs_csv_file(country, year)
    path_to_shapefile = country_shapefile(country)

    df = pd.read_csv(path_to_indicator_file)

    df = df[['cluster', indicator, 'LNG', 'LAT']]

    df = removing_sporious_data(df)

    df = df.dropna()

    print(x,len(df))

    if len(df) > 0 :

        rows_to_remove = int(0.1 * len(df))

        ni = (number+1)*random.randint(0, 99)

        rows_to_keep = df.sample(frac=(len(df) - rows_to_remove) / len(df) , random_state= ni)

        print(x,rows_to_remove,ni,'  start')

        df = df.loc[rows_to_keep.index]

        indicator_percentages = df[indicator].tolist()

        country_shape = gpd.read_file(path_to_shapefile)

        locations = dhs_cluster_locations(df)

        regions = voronoi_regions(locations, country_shape)

        net = dhs_clusters_network(regions, self_loop=True)

        path_to_population_raster = population_raster(country, year)

        raster = rasterio.open(path_to_population_raster)
        band = raster.read(1)

        height = raster.height
        width = raster.width
        nodata = raster.nodata

        known_pixels = [raster.index(x, y) for x, y in locations]

        grid = np.full((height, width), -9999.0, dtype=float)

        for e, p in zip(known_pixels, indicator_percentages):
            grid[e[0], e[1]] = p

        for i in range(height):
            for j in range(width):
                if grid[i, j] < 0.0 and band[i, j] > 0.0:
                    loc = raster.xy(i, j)
                    point = Point(loc)

                    for k in range(len(regions)):
                        polygon = regions[k][0]
                        if point.within(polygon):
                            weight = [1.0 / distance(loc, regions[a][1]) for a in net[k]]
                            predict = [indicator_percentages[regions[a][2]] * w / sum(weight)
                                       for a, w in zip(net[k], weight)]
                            grid[i, j] = sum(predict)
                            break

        subfolder = result_root + country + '/' + year + '/tiff/kfold_valid/'
        if not os.path.exists(subfolder):
            os.makedirs(subfolder)



        output_path = subfolder + code + '_' + year + '_idw_' + indicator[4:]+ '_'+str(number) + '.tif'

        with rasterio.open(
            output_path, 'w',
            driver='GTiff',
            dtype=rasterio.float32,
            count=1,
            width=width,
            height=height,
            nodata=-9999,
            crs='+proj=latlong',
            transform=raster.transform
        ) as dst:
            dst.write(grid, indexes=1)

        print(x,'  end')

def plot_indicator_raster_with_border_10(x):

    country, year, indicator, number = x

    # Obtain the country's alpha-3 code from the function get_country_alpha3_code(country)
    code, CODE = get_country_alpha3_code(country)

    dic_indic = dictionary_of_indicators()
    indic = dic_indic[indicator]

    subfolder = result_root + country + '/' + year + '/tiff/kfold_valid/'

    raster_path = subfolder + code + '_' + year + '_idw_' + indicator[4:]+ '_'+str(number) + '.tif'

    shapefile_path = country_shapefile(country)

    # Check if the TIFF file exists
    if os.path.exists(raster_path):

        # Load the shapefile
        with fiona.open(shapefile_path, "r") as shapefile:
            shapes = [shape(feature["geometry"]) for feature in shapefile]

        # Load the raster data
        with rasterio.open(raster_path) as src:
            raster_data = src.read(1)  # Read the first band
            raster_meta = src.meta
            raster_transform = src.transform

            # Mask the raster with the shapefile

            out_image, out_transform = rasterio.mask.mask(src, shapes, crop=True)
            out_meta = src.meta.copy()
            out_meta.update({"driver": "GTiff",
                             "height": out_image.shape[1],
                             "width": out_image.shape[2],
                             "transform": out_transform})

            out_image[out_image == src.nodata] = np.nan

        # Plot the raster
        raster_plot = plt.imshow(out_image[0], cmap='RdYlGn', extent=(out_transform[2], out_transform[2] + out_transform[0] * out_meta['width'],out_transform[5] + out_transform[4] * out_meta['height'], out_transform[5]),vmin=0, vmax=1)

        # Set the title and subtitle for the plot
        title = country + ' ' + year
        title = title.upper()
        subtitle = indic #indicator[4:].upper()
        plt.suptitle(title + '\n' + subtitle, y=1.02, fontsize=14)

        cbr = plt.colorbar(raster_plot, orientation='vertical',shrink=0.5,ticks=(0, 0.5, 1.0))
        cbr.ax.set_yticklabels([0,  50, 100])
        cbr.set_label('PERCENTAGE', rotation=270, labelpad=15)

        # Plot the border
        plot_shapes(shapes,border='k',transparency=0)

        plt.axis('off')

        # Define the subfolder to save the plotted PNG file
        subfolder = result_root + country + '/' + year + '/tiff/png/'
        if not os.path.exists(subfolder):
            os.makedirs(subfolder)

        indic = dic_indic[indicator].replace(' ', '_')

        # Define the output path for the plotted PNG file
        out_path = subfolder + code + '_' + year + '_idw_' + indic + '.png'

        # Save the plot as a PNG image file with specified resolution and layout parameters

        plt.savefig(out_path, dpi=300, bbox_inches='tight', pad_inches=0.05)

        plt.clf()  # Clear the current plot to avoid overlapping when used in a loop or batch processing


def validation_settlement_level_10(x):
    # Unpack country and year from the input tuple
    country, year, indicator, number = x
    print(x, '    starts')
    code, CODE = get_country_alpha3_code(country)

    path_to_settlements = settlements_shapefile(country, year)

    lidw_prediction, num_pixels = [], []

    # Open the settlements shapefile using Fiona
    with fiona.open(path_to_settlements, "r") as shapefile:
        shapes = [shape(feature["geometry"]) for feature in shapefile]

        # Loop through settlement IDs and associated data
        for i, shapei in enumerate(shapes):


            tmp_pred = 0

            path_to_indicator_raster = result_root + country + '/' + year + '/tiff/kfold_valid/' + code + '_' + year + '_idw_' + indicator[4:] +"_"+str(number)+ '.tif'

            if number==100 :
                path_to_indicator_raster = result_root + country + '/' + year + '/tiff/' + code + '_' + year + '_idw_' + indicator[4:] + '.tif'
                np=valid_raster_pixels_within_shape(path_to_indicator_raster, shapei)

                num_pixels.append(len(np))

            tmp_pred = average_raster_within_shape(path_to_indicator_raster, shapei)

            lidw_prediction.append(tmp_pred)

        subfolder = result_root + country + '/' + year + '/kfold_valid/'
        if not os.path.exists(subfolder):
            os.makedirs(subfolder)
        out_path = subfolder + code + '_' + year + '_idw_' + indicator[4:] +'_'+str(number)+'.csv'

        res = pd.DataFrame()
        res[str(number)] = lidw_prediction
        if number==100 :
            res['NUM_PIXELS'] = num_pixels

        res.to_csv(out_path)

        print(x, '    ends')

def error_analysis_10(x):

    country, year, indicator = x
    print(x, '    starts')
    code, CODE = get_country_alpha3_code(country)

    indic=indicator[4:]

    l_tot = []

    count = 0
    for n in range(10):
        path = result_root + country + '/' + year + '/kfold_valid/'+ code + '_' + year + '_idw_' + indic +'_'+str(n)+'.csv'
        if os.path.exists(path):
            dfn = pd.read_csv(path)
            ln=dfn[str(n)].tolist()
            l_tot.append(ln)
            count += 1


    l_ave = []
    if count == 10 :
        l_ave = [np.mean([l_tot[n][i] for n in range(10)]) for i in range(len(l_tot[0]))]


    l = []
    path100 =  result_root + country + '/' + year + '/kfold_valid/'+ code + '_' + year + '_idw_' + indic +'_'+str(100)+'.csv'
    if os.path.exists(path100):
        df = pd.read_csv(path100)
        l=df[str(100)].tolist()

    mean_diff, std_diff, mean_abs_diff = np.nan, np.nan, np.nan
    if len(l) > 0 :
        mean_diff, std_diff, mean_abs_diff = calculate_difference(l_ave, l)
        print (x,'end')
    return  mean_diff, std_diff , mean_abs_diff


def error_analysis_diff_10(x):

    country, year, indicator = x
    print(x, '    starts')
    code, CODE = get_country_alpha3_code(country)

    indic=indicator[4:]

    l_tot = []

    count = 0
    for n in range(10):
        path = result_root + country + '/' + year + '/kfold_valid/'+ code + '_' + year + '_idw_' + indic +'_'+str(n)+'.csv'
        if os.path.exists(path):
            dfn = pd.read_csv(path)
            ln=dfn[str(n)].tolist()
            l_tot.append(ln)
            count += 1


    l_ave = []
    if count == 10 :
        l_ave = [np.mean([l_tot[n][i] for n in range(10)]) for i in range(len(l_tot[0]))]


    l,num_px = [], []
    path100 =  result_root + country + '/' + year + '/kfold_valid/'+ code + '_' + year + '_idw_' + indic +'_'+str(100)+'.csv'
    if os.path.exists(path100):
        df = pd.read_csv(path100)
        l=df[str(100)].tolist()
        num_px = df['NUM_PIXELS'].tolist()

    return  l_ave, l, num_px























###################################################################################################








































###################################################################################################

def peak_locations(x, half_window = 5, threshold=1000):
    """
    Finds peak locations in a population raster based on given threshold.

    Args:
    - x (tuple): A tuple containing country and year.
    - threshold (int, optional): Population density threshold. Defaults to 1000.

    Returns:
    - list: List of peak locations as (x, y) coordinates.
    """

    # Extract country and year from input tuple
    country, year = x

    # Get input file path using population_raster function
    input_file = population_raster(country, year)

    # Define window size for neighborhood analysis
    w = half_window

    # Read raster data using rasterio
    with rasterio.open(input_file) as src:
        data = src.read(1)

        # Initialize temporary list to store peak values
        temp =[]

        # Iterate over the raster data to find peak values
        for j in range(1, src.height - w):
            for i in range(1, src.width - w):
                # Extract neighborhood around each pixel
                neighborhood = data[j - w:j + w + 1, i - w:i + w + 1]
                # Check if the pixel value is greater than or equal to its neighborhood and neighborhood has non-zero values
                if np.all(data[j, i] >= neighborhood) and np.prod(neighborhood) > 0:
                    temp.append(data[j, i])

        # Calculate population density threshold as the maximum of threshold and the 95th percentile of temporary peak values
        population_density_threshold = max(threshold, np.percentile(temp, 95))

        # Initialize list to store peak locations
        peak_locations = []

        # Iterate over the raster data again to find peak locations
        for j in range(1, src.height - w):
            for i in range(1, src.width - w):
                # Extract neighborhood around each pixel
                neighborhood = data[j - w:j + w + 1, i - w:i + w + 1]

                # Check if the pixel value is greater than or equal to its neighborhood and greater than or equal to population density threshold
                if np.all(data[j, i] >= neighborhood) and data[j, i] >= population_density_threshold:
                    # Append peak location to the list
                    peak_locations.append(src.xy(j, i))
    return peak_locations


def polygon_coords(geom):
    """
    Extracts exterior and interior coordinates of a polygon geometry.

    Args:
    - geom: Polygon geometry object.

    Returns:
    - tuple: A tuple containing lists of exterior and interior coordinates.
    """

    # Extract exterior coordinates
    exterior_coords = geom.exterior.coords[:]

    # Initialize list to store interior coordinates
    interior_coords = []

    # Iterate over interior rings of the polygon
    for interior in geom.interiors:
        # Append interior coordinates to the list
        interior_coords += [interior.coords[:]]

    return exterior_coords, interior_coords

def plot_shapes1(shapes):
    """
    Plots shapes represented as Polygon or MultiPolygon geometries.

    Args:
    - shapes: List of Polygon or MultiPolygon geometries.

    Returns:
    - None
    """

    # Iterate over each shape in the list of shapes
    for shapei in shapes:
        # Check if the shape is a Polygon
        if shapei.type == 'Polygon':
            # Extract exterior and interior coordinates of the polygon
            extr, intr = polygon_coords(shapei)
            # Extract X and Y coordinates of the exterior ring
            X = [e[0] for e in extr]
            Y = [e[1] for e in extr]

            # Plot the exterior ring
            plt.plot(X, Y, color='k', lw=0.3)
            plt.fill(X, Y, alpha=0.3)

            # Plot and fill the interior rings
            for a in intr:
                XX = [e[0] for e in a]
                YY = [e[1] for e in a]
                plt.plot(XX, YY, color='k', lw=0.2)
                plt.fill(XX, YY, color='w', alpha = 0.3)

        # Check if the shape is a MultiPolygon
        elif shapei.type == 'MultiPolygon':
            # Iterate over each part of the MultiPolygon
            for part in shapei.geoms:
                # Extract exterior and interior coordinates of the part
                extr, intr = polygon_coords(part)
                # Extract X and Y coordinates of the exterior ring
                X = [e[0] for e in extr]
                Y = [e[1] for e in extr]

                # Plot the exterior ring
                plt.plot(X, Y, color='k', lw=0.3)
                plt.fill(X, Y, alpha=0.3)

                # Plot and fill the interior rings
                for a in intr:
                    XX = [e[0] for e in a]
                    YY = [e[1] for e in a]
                    plt.plot(XX, YY, color='k', lw=0.2)
                    plt.fill(XX, YY, color='w', alpha = 0.3)

def settlement_modification(x, half_window = 5, threshold=1000):
    """
    Modifies settlement shapes based on peak locations.

    Args:
    - x (tuple): A tuple containing country and year.
    - threshold (int, optional): Population density threshold. Defaults to 1000.

    Returns:
    - list: List of modified settlement shapes.
    """

    # Extract country and year from input tuple
    country, year = x

    # Get country alpha-3 code
    code, CODE = get_country_alpha3_code(country)

    # Find peak locations
    peaks = peak_locations(x, half_window = half_window, threshold=threshold)

    # Get path to settlement shapefile
    path_to_settlement_shapefile = settlements_shapefile(country, year)

    # Open settlement shapefile using Fiona
    with fiona.open(path_to_settlement_shapefile, "r") as shapefile:

        # Extract shapes from shapefile
        shapes = [shape(feature["geometry"]) for feature in shapefile]

        # Initialize lists to store old and new shapes
        old_shapes = []
        new_shapes = []

        # Initialize list to store peak locations for each shape
        settl_peak = [[] for _ in shapes]

        # Iterate over each shape in the shapefile
        for i, shapei in enumerate(shapes):
            # Iterate over each peak location
            for j, p in enumerate(peaks):
                # Create a point object from peak location
                point = Point(p)
                # Check if the point is within the shape
                if point.within(shapei):
                    # Append peak location to the corresponding shape's peak locations list
                    settl_peak[i].append(p)

            # If the shape has more than one peak location
            if len(settl_peak[i]) > 1:
                # Calculate bounding box of the shape
                min_lng, min_lat, max_lng, max_lat = shapei.bounds
                locations = settl_peak[i]

                # Add four additional points to create a larger boundary
                new_locations = locations + [(max_lng+1, max_lat+1),
                                             (min_lng-1, max_lat+1),
                                             (max_lng+1, min_lat-1),
                                             (min_lng-1, min_lat-1)]

                # Create MultiPoint object from new locations
                points = MultiPoint(new_locations)

                # Compute Voronoi diagram of points
                polygons = voronoi_diagram(points)

                # Iterate over each polygon in the Voronoi diagram
                for k, polygon in enumerate(polygons.geoms):
                    # Intersect the shape with the polygon
                    intersect = shapei.intersection(polygon)

                    # If intersection is not empty, add it to the new shapes
                    if not intersect.is_empty:
                        new_shapes.append(intersect)

            # If the shape has only one or zero peak locations
            else:
                # Add the shape to the new shapes
                new_shapes.append(shapei)

    return new_shapes


def dhs_clusters_inside_settlements1(shapes, locations, urban_rural):
    """
    Identifies DHS clusters inside settlements and assigns settlements to clusters.

    Args:
    - shapes (list): List of settlement shapes.
    - locations (list): List of (longitude, latitude) coordinates of DHS clusters.
    - urban_rural (list): List indicating whether each DHS cluster is urban (1) or rural (0).

    Returns:
    - tuple: A tuple containing:
      - list: List of lists, where each inner list contains indices of DHS clusters inside corresponding settlements.
      - list: List of lists, where each inner list contains indices of settlements sharing common DHS clusters.
      - list: List of representative points for each settlement.
    """

    # Extract longitudes and latitudes from locations
    longitudes = [l[0] for l in locations]
    latitudes = [l[1] for l in locations]

    # Create buffer for each DHS cluster based on urban or rural status
    cluster_buffer = [
        point_buffer(g, t, 2000) if u == 1 else point_buffer(g, t, 5000)
        for g, t, u in zip(longitudes, latitudes, urban_rural)
    ]

    # Initialize lists to store DHS locations in each settlement,
    # representative points for settlements, and settlements sharing common clusters
    dhs_locations_in_settlement = [[] for _ in shapes]
    settlement_representative_point = [None for _ in shapes]
    settlements_with_common_cluster = [[] for _ in cluster_buffer]

    # Iterate over each settlement shape
    for i, shapei in enumerate(shapes):
        # Find representative point for the settlement
        point = shapei.representative_point()
        settlement_representative_point[i] = (point.x, point.y)

        # Check intersection of each cluster buffer with the settlement
        for j, b in enumerate(cluster_buffer):
            if b.intersects(shapei):
                # Append index of DHS cluster to list of DHS locations in the settlement
                dhs_locations_in_settlement[i].append(j)
                # Append index of settlement to list of settlements with common DHS cluster
                settlements_with_common_cluster[j].append(i)

    return dhs_locations_in_settlement, settlements_with_common_cluster, settlement_representative_point



def settlement_intersect_with_region1(shapes, regions):
    """
    Finds intersections between settlements and regions.

    Args:
    - shapes (list): List of settlement shapes.
    - regions (list): List of region shapes.

    Returns:
    - tuple: A tuple containing:
      - list: List of lists, where each inner list contains indices of regions intersecting with corresponding settlements.
      - list: List of lists, where each inner list contains indices of settlements intersecting with corresponding regions.
    """

    # Initialize lists to store intersections between settlements and regions
    settlement_intersections = [[] for _ in shapes]
    region_intersections = [[] for _ in regions]

    # Iterate over each settlement shape
    for i, settlement in enumerate(shapes):
        # Iterate over each region shape
        for j, region in enumerate(regions):
            # Extract the region geometry
            region = region[0]

            # Check intersection between settlement and region
            if settlement.intersects(region):
                # Append index of region to list of intersections for the settlement
                settlement_intersections[i].append(j)
                # Append index of settlement to list of intersections for the region
                region_intersections[j].append(i)

    return settlement_intersections, region_intersections




def dhs_settlements_weighted_networkx1(shapes, settlement_dhs, settlement_id, net, weight_function=None):
    """
    Creates a weighted networkx graph representing connections between settlements based on shared DHS clusters.

    Args:
    - shapes (list): List of settlement shapes.
    - settlement_dhs (list): List of lists, where each inner list contains indices of DHS clusters in each settlement.
    - settlement_id (list): List of settlement identifiers.
    - net (list): List representing connections between DHS clusters.
    - weight_function (function, optional): Function to compute edge weights based on settlement shapes. Defaults to None.

    Returns:
    - networkx.Graph: Weighted graph representing connections between settlements.
    """

    # Initialize a networkx graph
    G = nx.Graph()

    # Iterate over each pair of settlements
    for i in range(len(settlement_dhs)):
        A = set(settlement_dhs[i])

        for j in range(i + 1, len(settlement_dhs)):
            B = set(settlement_dhs[j])
            # Check if there are common DHS clusters between the settlements
            if len(A.intersection(B)) > 0:
                d = 1
                # Compute edge weight based on weight function if provided
                if weight_function is not None:
                    shape_i = shapes[settlement_id[i]]
                    shape_j = shapes[settlement_id[j]]

                    nps = list(nearest_points(shape_i, shape_j))
                    li = nps[0].coords[0]
                    lj = nps[1].coords[0]

                    d = weight_function(li, lj)

                # Add edge to the graph with computed weight
                G.add_edge(settlement_id[i], settlement_id[j], weight=d)

    # Iterate over each settlement
    for i in range(len(settlement_dhs)):
        neighbor = []

        # Gather neighboring DHS clusters
        for k in settlement_dhs[i]:
            neighbor += net[k]

        A = set(neighbor).difference(set(settlement_dhs[i]))

        # Check intersections with other settlements
        for j in range(i + 1, len(settlement_dhs)):
            B = set(settlement_dhs[j])

            if len(A.intersection(B)) > 0:
                d = 1

                # Compute edge weight based on weight function if provided
                if weight_function is not None:
                    shape_i = shapes[settlement_id[i]]
                    shape_j = shapes[settlement_id[j]]

                    nps = list(nearest_points(shape_i, shape_j))
                    li = nps[0].coords[0]
                    lj = nps[1].coords[0]

                    d = weight_function(li, lj)

                # Add edge to the graph with computed weight
                G.add_edge(settlement_id[i], settlement_id[j], weight=d)

    return G


def validation1_for_prediction_by_settlements_network(y):
    """
    Performs validation for prediction by settlements network.

    Args:
    - x (tuple): A tuple containing country and year.
    - folder (str): Path to the output folder.
    - threshold (int, optional): Population density threshold. Defaults to 1000.

    Returns:
    - None
    """

    x, folder, threshold = y

    country, year = x

    print(country, 'start')

    # Read list of indicators
    indicators = read_list_of_indicators(list_of_indicators)

    # Create dictionary of indicator names
    name_dictionary = dictionary_of_indicators(list_of_indicators)

    # Get names of indicators
    name = [name_dictionary[indicator] for indicator in indicators]

    # Get path to DHS survey CSV file
    path_to_dhs_survey = dhs_csv_file(country, year)

    # Read DHS survey data
    df = pd.read_csv(path_to_dhs_survey)

    # Remove spurious data from the dataframe
    df = removing_sporious_data(df)

    # Modify settlement shapes
    shapes = settlement_modification(x, threshold=threshold)

    # Get path to settlement shapefile
    path_to_settlement_shapefile = settlements_shapefile(country, year)

    # Open settlement shapefile using Fiona
    with fiona.open(path_to_settlement_shapefile, "r") as shapefile:
        shapes = [shape(feature["geometry"]) for feature in shapefile]

    # Get path to country shapefile
    path_to_country_shapefile = country_shapefile(country)

    # Read country shapefile
    country_shape = gpd.read_file(path_to_country_shapefile)

    # Initialize dataframe for results
    res = pd.DataFrame()

    # Initialize lists for metrics
    rmsd = [np.nan for indicator in indicators]
    num_locs = [np.nan for indicator in indicators]
    mad = [np.nan for indicator in indicators]
    bias = [np.nan for indicator in indicators]
    ratio = [np.nan for indicator in indicators]

    # Iterate over each indicator
    for idx, indicator in enumerate(indicators):
        indic_den = 'den' + indicator[3:]
        indic_num = 'num' + indicator[3:]
        print(x, 'Network for', indicator)

        # Extract relevant columns from the dataframe
        df_temp = df[['area', indicator, indic_num, indic_den, 'LNG', 'LAT']]

        # Drop rows with missing values
        df_temp = df_temp.dropna()

        # Compute unique values and percentages of the indicator
        unique_values = df_temp[indicator].nunique()
        indicator_percentages = df_temp[indicator].tolist()

        # Check if there are valid data points for the indicator
        if len(indicator_percentages) > 0 and unique_values != 1 :
            # Extract numerator and denominator values
            denominator = df_temp[indic_den].to_numpy()
            numerator = df_temp[indic_num].to_numpy()

            # Extract DHS cluster locations and areas types
            locations = dhs_cluster_locations(df_temp)
            num_locs[idx] = len(locations)
            areas_type = dhs_cluster_areas_type(df_temp)

            # Find DHS clusters inside settlements
            dhs_locations_in_settlement, _, settlement_representative_point = \
                dhs_clusters_inside_settlements1(shapes, locations, areas_type)

            # Get settlement clusters and their IDs
            dhs_settlement_clusters, dhs_settlement_id = dhs_settlements(dhs_locations_in_settlement)

            # Perform DHS estimation for settlements
            dhs_estimation_dict = dhs_estimation_for_settlements(numerator, denominator, dhs_settlement_clusters, dhs_settlement_id)

            # Compute Voronoi regions
            regions = voronoi_regions(locations, country_shape)

            # Find intersections between settlements and regions
            settlement_intersections, region_intersections = \
                settlement_intersect_with_region1(shapes, regions)

            # Get DHS clusters network
            net = dhs_clusters_network(regions)

            # Define weight function
            def func(x, y):
                return 1 / (1 + distance(x, y))

            # Create weighted networkx graph
            G = dhs_settlements_weighted_networkx1(shapes, dhs_settlement_clusters, dhs_settlement_id, net)

            # Compute PageRank centrality
            page_rank = nx.pagerank(G, alpha=0.85)

            # Compute settlement estimation
            settlement_estimation = {}
            for i, locs in enumerate(dhs_locations_in_settlement):
                if len(locs) > 0 and i in page_rank:
                    regs = []
                    for si in settlement_intersections[i]:
                        for reg in region_intersections[si]:
                            if reg in dhs_settlement_id:
                                regs.append(reg)
                    if len(regs) > 0:
                        settlement_estimation[i] = sum([dhs_estimation_dict[r] * page_rank[r] for r in regs]) / \
                                                   sum([page_rank[r] for r in regs])

            # Compute metrics
            rmsd[idx] = np.sqrt(np.mean([(settlement_estimation[key] - dhs_estimation_dict[key])**2 for key in settlement_estimation]))
            mad[idx] = np.mean([abs(settlement_estimation[key] - dhs_estimation_dict[key]) for key in settlement_estimation])
            bias[idx] = np.mean([settlement_estimation[key] - dhs_estimation_dict[key] for key in settlement_estimation])
            ratio[idx] = np.mean([settlement_estimation[key] for key in settlement_estimation]) / \
                         np.mean([dhs_estimation_dict[key] for key in settlement_estimation])

    # Store results in a dataframe
    res['INDICATOR'] = name
    res['NUM_CLUST'] = num_locs
    res['RMSD'] = rmsd
    res['MAD'] = mad
    res['RATIO'] = ratio

    # Get country alpha-3 code
    code, CODE = get_country_alpha3_code(country)

    # Create output folder if it doesn't exist
    if not os.path.exists(folder):
        os.makedirs(folder)

    # Output results to a CSV file
    output = folder + code + '.csv'
    res.to_csv(output)

    print(country, 'end')



def rmsd_error_analysis_settlements_network(input_folder, output_file):
    """
    Perform RMSD error analysis for settlements network.

    Args:
    - input_folder (str): Path to the input folder containing settlement results.
    - output_file (str): Path to the output CSV file to store the analysis results.

    Returns:
    - None
    """

    # Read list of indicators
    indicators = read_list_of_indicators(list_of_indicators)

    # Create dictionary of indicators
    indicator_dict = dictionary_of_indicators(list_of_indicators)

    # Read list of country years and add additional entries
    country_year = read_list_of_country_years(list_of_country_years) + [('Bangladesh', '2017'), ('Ethiopia', '2016'), ('Kenya', '2014')]

    # Initialize DataFrame for results
    result = pd.DataFrame()

    # Map indicator codes to their names
    INDICATOR = [indicator_dict[indic] for indic in indicators]
    result['INDICATOR'] = INDICATOR

    # Iterate over each country and year
    for (country, year) in country_year:

        # Get country alpha-3 code
        code, CODE = get_country_alpha3_code(country)

        # Construct path to settlement result CSV file
        path_to_settlement_result = input_folder + code + '.csv'

        # Read settlement result CSV file into DataFrame
        df = pd.read_csv(path_to_settlement_result)

        # Extract RMSD values
        rmsd = df['RMSD'].tolist()

        # Add RMSD values to the result DataFrame
        result[country + year] = rmsd

    # Write results to CSV file
    result.to_csv(output_file)











