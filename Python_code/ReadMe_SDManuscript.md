# Instructions:

The code below should be executed after obtaining the files with the indicator values for each country and by survey cluster from the DHS surveys (See instructions in R-Code folder):

For replication of the manuscript estimation and analysis without replicating the extraction of the summary data from the DHS surveys directly please use the 'dataset_cluster.csv' file that can be found in the Data/Globe folder

Path to the file can be found here:
https://github.com/DiegoGBassani/SEEDNet/blob/main/Python_code/Data/Globe/dataset_cluster.csv


## 1 - Create a virtual environment that includes the packages listed in the 'clean_environment.yml' file inside the 'requirements' folder.
## from terminal window

        $ conda update -n base -c conda-forge conda

### To create a virtual environment for project using this file, do the following. Environment will take date of creation as its name.
### Run this Python script to create and activate the environment

### From within the python console

        import subprocess
        from datetime import datetime

        date_str = datetime.now().strftime("%Y%m%d")
        env_name = f"env_{date_str}"

### To create the virtual environment

        subprocess.run(["conda", "env", "create", "--file", "requirements/clean_environment.yml", "--name", env_name])
        print(f"Activate the environment with: conda activate {env_name}")

### To update the virtual environment

        subprocess.run(["conda", "env", "update", "--file", "requirements/clean_environment.yml", "--name", env_name])

### To activate the virtual environment

        conda activate env_name

### To deactivate the virtual environment

        conda deactivate

## 2 - Create directories named 'Data' and 'Results'.

### 2.1 - Open a terminal or command prompt.
### 2.2 - Navigate to your project folder:

        cd path/to/your/project_folder

### 2.3 - Create the required directories:

        mkdir Data
        mkdir Results

### 2.4 - Create a subdirectory named 'Globe' inside the 'Data' directory.

        mkdir Data/Globe

## 3 - Place the files 'list_of_indicators', 'list_of_countries', and 'dataset_cluster' in the 'Globe' directory ('Data/Globe/').
### Files used in the technical validation can be downloaded from here:

        https://github.com/DiegoGBassani/SEEDNet/blob/main/Python_code/Data/Globe/list_of_indicators.csv
        https://github.com/DiegoGBassani/SEEDNet/blob/main/Python_code/Data/Globe/dataset_cluster.csv
        https://github.com/DiegoGBassani/SEEDNet/blob/main/Python_code/Data/Globe/list_of_countries.csv

### As mentioned above, for the replication of the manuscript estimation and analysis without replicating the extraction of the summary data from the DHS surveys use the 'dataset_cluster.csv' file that can be found in the path below:

        https://github.com/DiegoGBassani/SEEDNet/blob/main/Python_code/Data/Globe/dataset_cluster.csv

## 4 - The following steps involve executing a series of Python scripts that will process the data, generate additional files, and prepare them for your main analysis. Each script builds upon the previous one, so it's important to run them in order:

### 4.1 - The scripts prep0.py to prep7.py will:

4.1.0 - [file prep0.py] Download, extract, and reproject the GHS_SMOD datasets - the years can be modified from within the prep0.py.

These are currently set to 1995-2025 and therefore download all years covered by geo-referenced DHS surveys.

For the technical validation only the years 2010 and 2015 are necessary.

4.1.1 - [file prep1.py] Read the list of countries and years from the 'Globe' directory to define years to generate other subdirectories.

4.1.2 - [file prep2.py] Download the GADM dataset (administrative boundaries) for countries.

4.1.3 - [file prep3.py] Extract population rasters from GHSL Population datasets.

4.1.4 - [file prep4.py] Construct the settlements shapefile for countries; polygonize settlements.


The scripts prep5.py to prep7.py are necessary to replicate the validation results included in the accompanying manuscript:

4.1.5 - [file prep5.py] Create a country file with the survey information (to replicate manuscript analysis; optional).

4.1.6 - [file prep6.py] Download the GHSL UCDB file for settlement validation step (to replicate manuscript analysis; optional).

4.1.7 - [file prep7.py] Download Measles immunization maps from WorlPop (to replicate manuscript analysis; optional).


For convenience, we've created a script that runs all preparation steps in sequence. To use it:

Ensure you're in the project directory.

Run the following command:

        python run_settlement_sequence.py

This script will execute all preparation files (prep0.py through prep7.py) in order. Each step will print a completion message when finished.

Note: This process may take some time depending on your system and internet connection. Ensure you have a stable connection before starting.

## 5  - The following steps involve running a series of Python scripts that will conduct the main analysis, including predictions, simulations.

### Each script builds upon the previous one, so it's important to run them in order:

Estimation: Estimates settlement values (from survey data) using the prepared datasets

5.1 - The Scripts for Estimation should be executed in this order, after prep0-4.py or prep0-7.py (datasets are prepared (0-4) or prepared and settlement validation has been assessed(0-7))

        program_list = ['main1.py', 'main1_1.py', 'main23.py', 'main24.py']

5.1.1 - [file main1.py]   Performs Local Inverse Distance Interpolation of values from geo-referenced DHS surveys to settlement polygons.

5.1.2 - (to replicate manuscript analysis; optional)
        [file main1_1.py] Performs Local Inverse Distance Interpolation for Benchmark comparison with Utazi, 2018 Measles immunization coverage in Cambodia, Nigeria and Mozambique.
        
5.1.3 - [file main23.py]  Exports settlement indicator values to .csv file.

5.1.4 - [file main24.py]  Exports settlement indicator values to shape file.


For convenience, we've created a script that executes all Estimation steps in sequence. To use it:

Ensure you're in the project directory. Open the run_sequence_timer.py file and uncomment the line

        program_list = ['main1.py', 'main1_1.py', 'main23.py', 'main24.py']

Run the following command:

        python run_sequence_timer.py

This script will execute all estimation files (main1.py, main1_1.py, main23.py, main24.py) in order. Each step will print a completion message when finished.

## 6 - The following scripts perform the validation of LIDW predictions and the analysis of the validation output

6.1 The Scripts for Validation of LIDW and analysis of the validation output should be executed after scripts described in 5.1 have been executed. They are necessary to replicate the validation results included in the accompanying manuscript:

        program_list = ['main3.py', 'main4.py', 'main5.py', 'main6.py', 'main7.py', 'main8.py', 'main9.py', 'main10.py', 'main11.py', 'main12.py', 'main13.py', 'main14.py', 'main15.py', 'main20.py', 'main21.py', 'main22.py', 'main28.py', 'main29.py', 'main3_1.py', 'main4_1.py']

6.1.1 - [file main3.py] - Validation results at the survey cluster network level.

6.1.2 - [file main4.py] - Summarizes validation results at the survey cluster network level.

6.1.3 - [file main5.py] - Validation results at the settlement level.

6.1.4 - [file main6.py] - Summarizes validation results at the settlement level.

6.1.5 - [file main7.py] - Validation results at the administrative level 1.

6.1.6 - [file main8.py] - Summarizes validation results at the administrative level 1.

6.1.7 - [file main9.py] - Validation results at the administrative level 2.

6.1.8 - [file main10.py] - Summarizes validation results at the administrative level 2.


6.1.9 - [file main11.py] - Aggregates summary results from settlement level, administrative level 1 and administrative level 2.


6.1.10 - [file main20.py] - Validation results for out-of-sample leave-one-out cross validation (extensive computation time depending on system, number of countries and indicators).

6.1.11 - [file main21.py] - Summarizes results from out-of-sample leave-one-out cross validation.

6.1.12 - [file main22.py] - Generates summary file including predicted and direct estimates for each settlement in addition to information about the settlement such as area, number of overlapping survey clusters.

6.1.13 - [file main28.py] - Benchmark comparison of the out-of-sample predictions with Utazi, 2018 Measles immunization coverage in Cambodia, Nigeria and Mozambique.

6.1.14 - [file main29.py] - Summarizes benchmark comparison of the out-of-sample predictions with Utazi, 2018 Measles immunization coverage in Cambodia, Nigeria and Mozambique.


6.1.15 - [file main3_1.py] - Comparison to GLM-based estimates - Utazi, 2018.

6.1.16 - [file main4_1.py] - Comparison to GLM-based estimates - Utazi, 2018.


6.1.16 - [file main12.py] - K-fold validation - LIDW estimates.

6.1.17 - [file main13.py] - K-fold validation - settlement level estimates.

6.1.18 - [file main14.py] - K-fold validation - summary statistics for validation estimates.

6.1.19 - [file main15.py] - K-fold validation - outputs summary statistics for validation estimates.



We've created a script that allows users to execute all Validation steps in sequence. To use it ensure you're in the project directory. Open the run_sequence_timer.py file and uncomment the following line

        program_list = ['main3.py', 'main4.py', 'main5.py', 'main6.py', 'main7.py', 'main8.py', 'main9.py', 'main10.py', 'main11.py','main12.py', 'main13.py', 'main14.py', 'main15.py', 'main20.py', 'main21.py', 'main22.py', 'main28.py', 'main29.py', 'main3_1.py', 'main4_1.py']

Run the following command:

        python run_sequence_timer.py

This script will execute all estimation files (main3.py, main4.py, main5.py, main6.py, main7.py, main8.py, main9.py, main10.py, main11.py, main20.py, main21.py, main22.py, main28.py, main29.py) in order. Each step will print a completion message when finished.

# 7 - The following scripts serve other purposes related to the manuscript and should be executed after scripts described in 5.1 and 6.1 have been executed.

7.1 The Scripts for Other purposes should be executed after scripts described in 5.1 and 6.1 have been executed.
They are necessary to replicate the validation results included in the accompanying manuscript and generate plots:

        program_list = ['main2.py', 'main25.py', 'main26.py', 'main27.py', 'main30.py']

7.1.1 - [file main2.py] - Plots the indicator rasters with the national borders.

7.1.2 - [file main25.py] - Computes the population of the settlements for the year of the survey, in addition to the fraction of the national population in each settlement.

7.1.3 - [file main26.py] - Extracts the UCDB population settlements (entities) from the UCDB database for validation of the settlement identification process.

7.1.4 - [file main27.py] - Identifies the overlaps between polygons from our settlement identification method and UCDB settlement polygons.

7.1.5 - [file main30.py] - Exports settlement polygons as .png files with random colors assigned to each settlement (Optional).

For convenience, we've created a script that allows users to execute all these additional steps in sequence. To use it:

Ensure you're in the project directory. Open the run_sequence_timer.py file and uncomment the line

        program_list = ['main2.py', 'main25.py', 'main26.py', 'main27.py', 'main30.py']

Run the following command:

        python run_sequence_timer.py

This script will execute all estimation files (main2.py, main25.py, main26.py, main27.py, main30.py) in order. Each step will print a completion message when finished.

The dependencies of the scripts above are shown in the schematic below:
![dependencies](https://github.com/user-attachments/assets/4b1eff9e-8e76-446f-9b94-b569d6e4bae3)

And the pdf can be downloaded here:
[dependencies1.pdf](https://github.com/user-attachments/files/16360142/dependencies1.pdf)


