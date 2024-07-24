
import warnings
warnings.filterwarnings('ignore')

from lidw_functions import *





   
###################################################################################################
###################################################################################################

def main():

    local_inverse_distance_weighting_interpolation(('Cambodia','2014','cov_ch_meas_either_u5'))
    
    local_inverse_distance_weighting_interpolation(('Mozambique','2011','cov_ch_meas_either_u5'))
    
    local_inverse_distance_weighting_interpolation(('Nigeria','2013','cov_ch_meas_either_u5'))
    
    
    
    
       
if __name__ == "__main__":
    main()
    
    
    
  
