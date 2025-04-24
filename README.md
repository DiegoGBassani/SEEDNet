
<img width="1000" alt="SEEDNet_logo" src="https://github.com/user-attachments/assets/a6b4f431-f1fe-4925-bdd0-2fbba50b5e59" />


Repository containing code and data for replication of the manuscript: "Darooneh et. al. SEEDNet: Covariate-free multi-country settlement-level datasets of epidemiological estimates for network analysis"

## Overview:

There are two sets of instructions contained in this repository. 

A. Replication of the manuscript results and technical validation. It is restricted to 15 indicator and 10 countries included in the manuscript. 

B. Estimation of the 15 indicators for the most recent georeferenced DHS survey available for any country. It reproduces the results found in the library presented with this paper. 

The processed files are available on Borealis: ([https://borealisdata.ca/dataverse/SEEDNet](https://borealisdata.ca/dataverse/SEEDNet))

## A. For replication of the manuscript estimates and technical validation:

### Where to start: 

#### 1 - Select indicators and create the survey cluster DHS files with the scripts available with the accompanying detailed instructions in the [R_code](https://github.com/DiegoGBassani/SEEDNet/tree/main/R_code) folder.




#### 2 - Save the resulting csv file, it should look like this one ([dataset_cluster.csv](https://github.com/DiegoGBassani/SEEDNet/tree/main/Python_code/Data/Globe/dataset_cluster.csv)) if you are replicating our findings. It will be larger if you include other countries or indicators.



#### 3 - To replicate the estimation and validation steps, follow the [Instructions](https://github.com/DiegoGBassani/SEEDNet/blob/main/Python_code/ReadMe_SDManuscript.md) within the [Python_code](https://github.com/DiegoGBassani/SEEDNet/tree/main/Python_code) folder: 

#### 4 - To produce the tables and graphs shown in the manuscript follow the instructions in the [Stata_code] (https://github.com/DiegoGBassani/SD_2024_Code/tree/main/Stata_code) folder. The 5 files found in the input_files folder are produced after running the [Python_code](https://github.com/DiegoGBassani/SEEDNet/tree/main/Python_code) and will be found in the Results folder. The 6th file [summary_validation_data.csv](https://github.com/DiegoGBassani/SEEDNet/blob/main/Stata_code/input_files/summary_validation_data.csv) is one of the outputs of the [R_code](https://github.com/DiegoGBassani/SEEDNet/tree/main/R_code).


## B. For estimation of the 15 indicators for the most recent georeferenced DHS survey available among all DHS countries, or to add indicators and countries for your own project:

### Where to start: 

#### 1 - Select indicators and create the survey cluster DHS files with the scripts available with the accompanying detailed instructions in the [R_code](https://github.com/DiegoGBassani/SEEDNet/tree/main/R_code) folder.

   1.1. - Obtain a list of the most recent surveys from the DHS API (see links below), save it as a .csv file with 2 entries, country and year, as in this [example](https://github.com/DiegoGBassani/SEEDNet/blob/main/Python_code/Data/Globe/list_of_countries.csv) from the replication instructions (above).

A current list of the completed georeferenced surveys can be viewed and downloaded using the DHS API: 

[All completed georeferenced surveys from DHS API as html](https://api.dhsprogram.com/rest/dhs/surveys?surveyCharacteristicIds=26&surveyStatus=completed&surveytype=DHS&f=html) 

The data can be dowloaded as a csv here:

[All completed georeferenced surveys from DHS API as csv](https://api.dhsprogram.com/rest/dhs/surveys?surveyCharacteristicIds=26&surveyStatus=completed&surveytype=DHS&f=csv)


   1.2 - Follow the instructions in the [R_code](https://github.com/DiegoGBassani/SEEDNet/tree/main/R_code) folder to produce the dataset_cluster.csv file.
  

#### 2 - Save the resulting csv file, it should have a similar structure as this one ([dataset_cluster.csv](https://github.com/DiegoGBassani/SEEDNet/tree/main/Python_code/Data/Globe/dataset_cluster.csv)) but with your selection of countries and indicators.


#### 3 - To generate your own estimates of indicators by settlement follow the [Instructions](https://github.com/DiegoGBassani/SEEDNet/blob/main/Python_code/ReadMe_SDManuscript.md) within the [Python_code](https://github.com/DiegoGBassani/SEEDNet/tree/main/Python_code) folder

## The complete library can be accessed at the [SEEDNet](https://borealisdata.ca/dataverse/SEEDNet) dataverse hosted by Borealis Canada.

### About the SEEDNet Library:
SEEDNet (Settlement-level Epidemiological Estimates Database for Network Analysis) is an open-source data library of multi-country representations of population health across human settlements. The methods for generating the settlement-level health indicators from national surveys for each country are described in the manuscript "SEEDNet: Covariate-free multi-country settlement-level datasets of epidemiological estimates for network analysis" (2024-08-02)

Other countries and indicators will be added as new surveys become available. 

Currently, the 98 surveys covering 52 countries included in this library are: 


Albania-2017, Angola-2015, Armenia-2010, Armenia-2015, Bangladesh-2011, Bangladesh-2014, Bangladesh-2017, Bangladesh-2022, Benin-2011, Benin-2017, Burkina Faso-2010, Burkina Faso-2021, Burundi-2010, Burundi-2016, Cambodia-2010, Cambodia-2014, Cambodia-2021, Cameroon-2011, Cameroon-2018, Chad-2014, Colombia-2009, Comoros-2012, Congo, Democratic Republic-2013, Coted'Ivoire-2011, Cote d'Ivoire-2021, Dominican Republic-2013, Egypt-2014, Ethiopia-2011, Ethiopia-2016, Ethiopia-2019, Gabon-2012, Gabon-2019, Gambia-2019, Ghana-2014, Ghana-2022, Guatemala-2014, Guinea-2012, Guinea-2018, Haiti-2012, Haiti-2016, Honduras-2011, Jordan-2012, Jordan-2017, Jordan-2023, Kenya-2014, Kenya-2022, Kyrgyz Republic-2012, Lesotho-2014, Lesotho-2023, Liberia-2013, Liberia-2019, Madagascar-2021, Malawi-2010, Malawi-2015, Mali-2012, Mali-2018, Mauritania-2019, Mozambique-2011, Mozambique-2022, Myanmar-2015, Namibia-2013, Nepal-2011, Nepal-2016, Nepal-2022, Niger-2012, Nigeria-2013, Nigeria-2018, Pakistan-2017, Philippines-2017, Philippines-2022, Rwanda-2010, Rwanda-2014, Rwanda-2019, Senegal-2010, Senegal-2012, Senegal-2014, Senegal-2015, Senegal-2016, Senegal-2017, Senegal-2018, Senegal-2019, Senegal-2023, Sierra Leone-2013, Sierra Leone-2019, South Africa-2016, Tajikistan-2012, Tajikistan-2017, Tanzania-2009, Tanzania-2015, Tanzania-2022, Timor-Leste-2016, Togo-2013, Uganda-2011, Uganda-2016, Zambia-2013, Zambia-2018, Zimbabwe-2010, Zimbabwe-2015.

## Please cite this work as: 
Darooneh, A.H. et al. (2024) ‘SEEDNet: Covariate-free multi-country settlement-level datasets of epidemiological estimates for network analysis.’ Available at: https://borealisdata.ca/dataverse/SEEDNet.

## Citation

## Manuscript (Peer-reviewed)
	@article{darooneh_seednet_2025_SD,
	title = {{SEEDNet}: {Covariate}-free multi-country settlement-level epidemiological estimates datasets for network analysis},
	url = {TBC},
	doi = {TBC},
	journal = {Scientific Data},
	author = {Darooneh, Amir Hossein and Kortenaar, Jean-Luc and Goulart, Céline M. and McLaughlin, Katie and Cornelius, Sean P. and Bassani, Diego G.},
	year = {2025},
	annote = {Publisher: Nature},
	}

## Manuscript (Pre-print)
	@article{darooneh_seednet_2025_MedRxiv,
	title = {{SEEDNet}: {Covariate}-free multi-country settlement-level epidemiological estimates datasets for network analysis},
	url = {https://www.medrxiv.org/content/early/2025/02/27/2025.02.26.25322963},
	doi = {10.1101/2025.02.26.25322963},
	journal = {medRxiv},
	author = {Darooneh, Amir Hossein and Kortenaar, Jean-Luc and Goulart, Céline M. and McLaughlin, Katie and Cornelius, Sean P. and Bassani, Diego G.},
	year = {2025},
	annote = {Publisher: Cold Spring Harbor Laboratory Press \_eprint: https://www.medrxiv.org/content/early/2025/02/27/2025.02.26.25322963.full.pdf},
	}

## SEEDNet library
	@data{SP3/ZF6X3F_2024,
	author = {Bassani, Diego G and Darooneh, Amir Hossein and Kortenaar, Jean-Luc and McLaughlin, Katie and Cornelius, Sean P},
	publisher = {Borealis},
	title = {{SEEDNet Library}},
	UNF = {UNF:6:A5MTuQbclK+0u0g25d2k8Q==},
	year = {2024},
	version = {V3},
	doi = {10.5683/SP3/ZF6X3F},
	url = {https://doi.org/10.5683/SP3/ZF6X3F}
	}

## Replication data and code
	@data{SP3/XBGKZN_2024,
	author = {Darooneh, Amir Hossein and Kortenaar, Jean-Luc and Goulart, Celine M and McLaughlin, Katie and Cornelius, Sean P and Bassani, Diego G},
	publisher = {Borealis},
	title = {{Replication Data for: SEEDNet: Covariate-free multi-country settlement-level datasets of epidemiological estimates for network analysis}},
	UNF = {UNF:6:txboxi3HSCkxPNQ5HaCzcQ==},
	year = {2024},
	version = {V2},
	doi = {10.5683/SP3/XBGKZN},
	url = {https://doi.org/10.5683/SP3/XBGKZN}
	}

### https://creativecommons.org/licenses/by/4.0/
