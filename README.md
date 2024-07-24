# SD_2024: Darooneh et. al. Multi-country settlement level database of health indicators and covariate-free estimation method. 

Repository containing code and data for replication of the manuscript: "Multi-country settlement level database of health indicators and covariate-free estimation method"

# Overview:

There are two sets of instructions contained in this repository. 

A. Replication of the manuscript results and technical validation. It is restricted to 15 indicator and 10 countries included in the manuscript. 

B. Estimation of the 15 indicators for the most recent georeferenced DHS survey available for any country. It reproduces the results found in the library presented with this paper. 

The processed files are available on Borealis: (Add url)

# A. For replication of the manuscript estimates and technical validation:

## Where to start: 

### 1 - Select indicators and create the survey cluster DHS files with the scripts available with the accompanying detailed instructions in the [R_code](https://github.com/DiegoGBassani/SD_2024_Code/tree/main/R_code) folder.




### 2 - Save the resulting csv file, it should look like this one ([dataset_cluster.csv](https://github.com/DiegoGBassani/SD_2024_Code/tree/main/Python_code/Data/Globe/dataset_cluster.csv)) if you are replicating our findings. It will be larger if you include other countries or indicators.



### 3 - To replicate the estimation and validation steps, follow the [Instructions](https://github.com/DiegoGBassani/SD_2024_Code/blob/main/Python_code/ReadMe_SDManuscript.md) within the [Python_code](https://github.com/DiegoGBassani/SD_2024_Code/tree/main/Python_code) folder: 

### 4 - To produce the tables and graphs shown in the manuscript follow the instructions in the [Stata_code] (https://github.com/DiegoGBassani/SD_2024_Code/tree/main/Stata_code) folder. The 5 files found in the input_files folder are produced after running the [Python_code](https://github.com/DiegoGBassani/SD_2024_Code/tree/main/Python_code) and will be found in the Results folder. The 6th file [summary_validation_data.csv](https://github.com/DiegoGBassani/SD_2024_Code/blob/main/Stata_code/input_files/summary_validation_data.csv) is one of the outputs of the [R_code](https://github.com/DiegoGBassani/SD_2024_Code/tree/main/R_code).


# B. For estimation of the 15 indicators for the most recent georeferenced DHS survey available among all DHS countries, or to add indicators and countries for your own project:

## Where to start: 

### 1 - Select indicators and create the survey cluster DHS files with the scripts available with the accompanying detailed instructions in the [R_code](https://github.com/DiegoGBassani/SD_2024_Code/tree/main/R_code) folder.

1.1. - Obtain a list of the most recent surveys from the DHS API (see links below), save it as a .csv file with 2 entries, country and year, as in this [example](https://github.com/DiegoGBassani/SD_2024_Code/blob/main/Python_code/Data/Globe/list_of_countries.csv) from the replication instructions (above).

A current list of the completed georeferenced surveys can be viewed and downloaded using the DHS API: 

[All completed georeferenced surveys from DHS API as html](https://api.dhsprogram.com/rest/dhs/surveys?surveyCharacteristicIds=26&surveyStatus=completed&surveytype=DHS&f=html) 

The data can be dowloaded as a csv here:

[All completed georeferenced surveys from DHS API as csv](https://api.dhsprogram.com/rest/dhs/surveys?surveyCharacteristicIds=26&surveyStatus=completed&surveytype=DHS&f=csv)


1.2 - Follow the instructions in the [R_code](https://github.com/DiegoGBassani/SD_2024_Code/tree/main/R_code) folder to produce the dataset_cluster.csv file.
  

### 2 - Save the resulting csv file, it should have a similar structure as this one ([dataset_cluster.csv](https://github.com/DiegoGBassani/SD_2024_Code/tree/main/Python_code/Data/Globe/dataset_cluster.csv)) but with your selection of countries and indicators.


### 3 - To generate your own estimates of indicators by settlement follow the [Instructions](https://github.com/DiegoGBassani/SD_2024_Code/blob/main/Python_code/ReadMe_SDManuscript.md) within the [Python_code](https://github.com/DiegoGBassani/SD_2024_Code/tree/main/Python_code) folder



# Please cite this work as: 
Darooneh, A.H. et al. (2024) ‘Multi-country settlement level database of health indicators and a covariate-free estimation method.’ Available at: https://doi.org/TBC.

# citation
@misc{darooneh_2024,
	title = {Multi-country settlement level database of health indicators and a covariate-free estimation method.},
	doi = {TBC},
	number = {{SDATA}-24-01804},
  year = {2024},
	author = {Darooneh, Amir Hossein and Kortenaar, Jean-Luc and Goulart, Céline M. and {McLaughlin}, Katie and Cornelius, Sean P. and Bassani, Diego G.},
	note = {Pre-print of article submitted to Scientific Data},
}


