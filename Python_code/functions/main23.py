
import warnings
warnings.filterwarnings('ignore')

from lidw_functions import *

        
###################################################################################################
###################################################################################################

def main():
    
    
    country_year = read_list_of_country_years()
    
    for x in country_year :
        settlements_indicators_to_csv(x)
       
    
    
       
if __name__ == "__main__":
    main()
    
    
    
  
