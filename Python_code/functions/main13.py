
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
    
    range10 = list(range(10))+[100]
    
    for country,year in country_year :
        
        for indicator in indicators :
    
            inputs = inputs + [(country, year, indicator, n) for n in range10]
        
    
    pool = multiprocessing.Pool()
    pool = multiprocessing.Pool(processes=10)
    outputs=pool.map(validation_settlement_level_10, inputs)
    
    #[plot_indicator_raster_with_border_10(('Senegal', '2019', 'cov_exclusivelybf',n))  for n in range(10)]
    
       
if __name__ == "__main__":
    main()
    
    
    
  
