

import warnings
warnings.filterwarnings('ignore')

from lidw_functions import *




   
###################################################################################################
###################################################################################################

def main():
    
    download_ghs_pop_file()
    
    
    country_year = read_list_of_country_years()
    
    for x in country_year :
    
        extract_ghs_country_population_raster(x)
    
    
       
if __name__ == "__main__":
    main()
    
    
    
  
