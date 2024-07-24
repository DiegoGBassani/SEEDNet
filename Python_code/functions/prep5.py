

import warnings
warnings.filterwarnings('ignore')

from lidw_functions import *





   
###################################################################################################
###################################################################################################

def main():

    country_year = read_list_of_country_years()
    
    for country,year in country_year :
    
        generate_country_dhs_csv_file(country,year)
    
    
    
    
       
if __name__ == "__main__":
    main()
    
    
    
  
