
import multiprocessing


import warnings
warnings.filterwarnings('ignore')

from lidw_functions import *

        
###################################################################################################
###################################################################################################

def main():

    indicators = read_list_of_indicators()


    country_year = read_list_of_country_years()
    
    inputs = []

    for indicator in indicators:

        for country,year in country_year :

            inputs.append( (country, year, indicator))
        
    pool = multiprocessing.Pool()
    pool = multiprocessing.Pool(processes=40)
    outputs=pool.map(loocv_settlements, inputs)  
        
        
        
    
    
        
    
    
    
       
if __name__ == "__main__":
    main()
    
    
    
  
