

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
    
    
    
  
