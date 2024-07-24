

import multiprocessing

import warnings
warnings.filterwarnings('ignore')

from lidw_functions import *





   
###################################################################################################
###################################################################################################

def main():

    indicators=read_list_of_indicators()

    country_year = read_list_of_country_years()
    
    inputs = []
    
    for indicator in indicators : 
    
        inputs += [(country,year,indicator) for country,year in country_year ]
    
    pool = multiprocessing.Pool()
    pool = multiprocessing.Pool(processes=40)
    outputs=pool.map(validation_network_level, inputs)
    
    
    
    
       
if __name__ == "__main__":
    main()
    
    
    
  
