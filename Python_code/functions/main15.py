import pandas as pd

import multiprocessing

import warnings
warnings.filterwarnings('ignore')

from lidw_functions import *

    

        
     
###################################################################################################
###################################################################################################

def main():

    indicators = read_list_of_indicators()

    country_year = read_list_of_country_years()
    
    dic_indic = dictionary_of_indicators()
    
    res = pd.DataFrame()
    
    range10 = list(range(10))+[100]
    
    SETT_IDX, COUNTRY, YEAR, INDICATOR, NUM_PIXELS, KFOLD_EST , DIR_EST = [], [], [], [], [], [], [] 
    
    for country,year in country_year :
    
        code, CODE = get_country_alpha3_code(country)
    
        for indicator in indicators :
    
            x = (country, year, indicator)
        
            l_ave, l, num_px = error_analysis_diff_10(x)
        
            for i, (a, b, c) in enumerate(zip(l_ave,l,num_px)): 
                SETT_IDX.append(CODE+str(i).zfill(6))
                KFOLD_EST.append("{:.4f}".format(a))
                DIR_EST.append("{:.4f}".format(b))
                COUNTRY.append(country)
                YEAR.append(year)
                INDICATOR.append(dic_indic[indicator])
                NUM_PIXELS.append(c)
        
    res['COUNTRY']=COUNTRY
    res['YEAR']=YEAR
    res['INDICATOR']=INDICATOR
    res['SETT_CODE'] = SETT_IDX
    res['NUM_PIXELS'] = NUM_PIXELS
    res['KFOLD_EST'] = KFOLD_EST
    res['DIR_EST'] = DIR_EST
    
    #res.to_csv(result_root+'kfold_validation_diff.csv')    
        
    
    
        
    
    
    
       
if __name__ == "__main__":
    main()
    
    
    
  
