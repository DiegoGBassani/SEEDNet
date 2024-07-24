
import multiprocessing
import warnings
warnings.filterwarnings('ignore')

from lidw_functions import *


def validation_subnational_division_level2(x):
    return validation_subnational_division_level(x,level=2)


   
###################################################################################################
###################################################################################################

def main():

    country_year= read_list_of_country_years()

    inputs = country_year
    
    pool = multiprocessing.Pool()
    pool = multiprocessing.Pool(processes=40)
    outputs=pool.map(validation_subnational_division_level2, inputs)

    
    
    
    
    
       
if __name__ == "__main__":
    main()
    
    
    
  
