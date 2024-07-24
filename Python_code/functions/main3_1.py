
import multiprocessing

import warnings
warnings.filterwarnings('ignore')

from lidw_functions import *





   
###################################################################################################
###################################################################################################

def main():

    inputs = [ ('Cambodia','2014','cov_ch_meas_either_u5'),
    
               ('Mozambique','2011','cov_ch_meas_either_u5'),
    
               ('Nigeria','2013','cov_ch_meas_either_u5')]
    
    
    pool = multiprocessing.Pool()
    pool = multiprocessing.Pool(processes=3)
    outputs=pool.map(validation_network_level, inputs)
    
    
    
    
       
if __name__ == "__main__":
    main()
    
    
    
  
