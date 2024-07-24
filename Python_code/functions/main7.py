
import multiprocessing
import warnings
warnings.filterwarnings('ignore')

from lidw_functions import *





   
###################################################################################################
###################################################################################################

def main():

    country_year= read_list_of_country_years()

    inputs = country_year
    
    pool = multiprocessing.Pool()
    pool = multiprocessing.Pool(processes=40)
    outputs=pool.map(validation_subnational_division_level, inputs)

    
    
    
    
    
       
if __name__ == "__main__":
    main()
    
    
    
  
