
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
    
    for country,year in country_year :
        
        inputs += [(country,year,indicator) for indicator in indicators]
    
    pool = multiprocessing.Pool()
    pool = multiprocessing.Pool(processes=40)
    outputs=pool.map(local_inverse_distance_weighting_interpolation, inputs)
    
    
    
    
       
if __name__ == "__main__":
    main()
    
    
    
  
