
import pandas as pd


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
    
    COUNTRY, YEAR, INDICATOR, BIAS , MAD, RMSE = [], [], [], [], [] , []
    
    for country,year in country_year :
    
        for indicator in indicators :
    
            x = (country, year, indicator)
        
            bias, rmse, mad = error_analysis_10(x)
        
            COUNTRY.append(country)
            YEAR.append(year)
            INDICATOR.append(dic_indic[indicator])
            BIAS.append("{:.6f}".format(bias))
            RMSE.append("{:.4f}".format(rmse))
            MAD.append("{:.4f}".format(mad))
        
    res['COUNTRY']=COUNTRY
    res['YEAR']=YEAR
    res['INDICATOR']=INDICATOR
    res['BIAS']=BIAS
    res['RMSE']=RMSE
    res['MAD']=MAD
    
    res.to_csv(result_root+'kfold_validation.csv')    
        
    
    
        
    
    
    
       
if __name__ == "__main__":
    main()
    
    
    
  
