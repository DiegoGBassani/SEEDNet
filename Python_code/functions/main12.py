
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
    
    for indicator in indicators :
    
        for country,year in country_year :
    
            inputs = inputs + [(country, year, indicator, n) for n in range(10)]
        
    pool = multiprocessing.Pool()
    pool = multiprocessing.Pool(processes=10)
    outputs=pool.map(local_inverse_distance_weighting_interpolation_10, inputs)
       
   
    
    
       
if __name__ == "__main__":
    main()
    
    
    
  
