

import warnings
warnings.filterwarnings('ignore')

from lidw_functions import *





   
###################################################################################################
###################################################################################################

def main():

    error_analysis_network_level_utazi()
    
    res = pd.DataFrame()
    
    df = []
    
    for country, year in [('Cambodia','2014'),('Mozambique','2011'),('Nigeria','2013')] :
        
        code, CODE = get_country_alpha3_code(country)
        
        input_path = result_root + country + '/' + year + '/' + CODE + '_VAL2_UTAZI.csv'
    
        df.append( pd.read_csv(input_path))
        
    res = pd.concat( df , ignore_index=True)    
        
    res.to_csv(result_root + 'LOOCV_NET_UTAZI.csv')    
    
       
if __name__ == "__main__":
    main()
    
    
    
  
