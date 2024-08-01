import subprocess
import time
from datetime import datetime
import traceback
import os
# User to uncomment the sequence to be computed, see instructions below regarding dependencies and requirements.
# Complete program list, including data preparation + downloads of geospatial files required:

# Data preparation, settlement identification:
# program_list = ['prep0.py', 'prep1.py', 'prep2.py', 'prep3.py', 'prep4.py', 'prep5.py', 'prep6.py', 'prep7.py']

# Estimation:
# program_list = ['main1.py', 'main1_1.py', 'main23.py', 'main24.py']


# Validation:
# program_list = ['main3.py', 'main4.py', 'main5.py', 'main6.py', 'main7.py', 'main8.py', 'main9.py', 'main10.py', 'main11.py',
#                'main12.py', 'main13.py', 'main14.py', 'main15.py',
#                'main20.py', 'main21.py', 'main22.py', 'main28.py', 'main29.py', 'main3_1.py', 'main4_1.py']

# Other purposes (plotting, etc):
# program_list = ['main2.py', 'main25.py', 'main26.py', 'main27.py', 'main30.py']

# Full execution:
# Data preparation, settlement identification, estimation and validation
# program_list = ['prep0.py', 'prep1.py', 'prep2.py', 'prep3.py', 'prep4.py', 'prep5.py', 'prep6.py', 'prep7.py']
# program_list = ['main1.py', 'main1_1.py', 'main23.py', 'main24.py']
# program_list = ['main3.py', 'main4.py', 'main5.py', 'main6.py', 'main7.py', 'main8.py', 'main9.py', 'main10.py', 'main11.py']
# retry: program_list = [ 'main12.py', 'main13.py', 'main14.py', 'main15.py']

program_list = ['main20.py', 'main21.py', 'main22.py']
program_list = ['main28.py', 'main29.py', 'main3_1.py', 'main4_1.py']

program_list = ['main2.py', 'main23.py', 'main24.py', 'main25.py', 'main26.py', 'main27.py']
program_list = ['main30.py']

## Enter your custom list of programs here:
#program_list = ['prep0.py', 'prep1.py', 'prep2.py', 'prep3.py', 'prep4.py', 'prep5.py', 'prep6.py', 'prep7.py']
#program_list = ['main1.py', 'main23.py', 'main24.py', 'main25.py', 'main30.py']
#program_list = ['prep0.py', 'prep1.py', 'prep2.py', 'prep3.py', 'prep4.py', 'prep5.py', 'prep6.py', 'prep7.py', 'main1.py', 'main23.py', 'main24.py', 'main25.py', 'main30.py']


## For partial execution, select one of the program lists below.

## Script Execution Order

# 1. Preparation of data: Prepares the initial dataset
# 2. Estimation: Estimates settlement values (from survey data) using the prepared datasets
# 3. Validation: LIDW analysis and validation output for publication
# 4. Other: creates plots and settlement identification validation

## Dependencies

# - `Preparation of data` must be run before any other scripts. Has to be repeated when adding new countries.
# - `Estimation` must be run before `Validation`
# - `Validation` must be run before `Other`
# - `Estimation` must be run before `Other`

# 1 - Scripts for Preparation of data, including download of necessary geospatial files:
# program_list = ['prep0.py', 'prep1.py', 'prep2.py', 'prep3.py', 'prep4.py', 'prep5.py', 'prep6.py', 'prep7.py']

# 2 - Scripts for Estimation - to be executed in this order, after prep0-7.py (dataset is prepared)
# program_list = ['main1.py', 'main1_1.py', 'main23.py', 'main24.py']

# 3 - Scripts for Validation of lidw and analysis the validation output:
# program_list = ['main3.py', 'main4.py', 'main5.py', 'main6.py', 'main7.py', 'main8.py', 'main9.py', 'main10.py', 'main11.py',
#                'main12.py', 'main13.py', 'main14.py', 'main15.py',
#                'main20.py', 'main21.py', 'main22.py', 'main28.py', 'main29.py', 'main3_1.py', 'main4_1.py']

# 4 - Scripts for Other purposes (plotting, etc):
# program_list = ['main2.py', 'main25.py', 'main26.py', 'main27.py', 'main30.py']

folder_path = '.'
log_file_path = os.path.join(folder_path, 'task_times.log')
error_log_path = os.path.join(folder_path, 'error_log.txt')

with open(log_file_path, 'w', buffering=1) as log_file, open(error_log_path, 'w', buffering=1) as error_log:
    log_file.write("Task, Start Time, End Time, Duration (seconds)\n")
    for program in program_list:
        try:
            print(f"Starting: {program}")
            start_time = time.time()
            start_datetime = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

            program_path = os.path.join(folder_path, program)
            subprocess.run(['python', program_path], check=True)

            end_time = time.time()
            end_datetime = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            duration = end_time - start_time

            print(f"Finished: {program}")
            print(f"Time taken: {duration:.2f} seconds")

            log_entry = f"{program}, {start_datetime}, {end_datetime}, {duration:.2f}\n"
            print(log_entry)  # Print to console
            log_file.write(log_entry)
            log_file.flush()  # Force write to disk


        except Exception as e:

            error_message = f"Error in {program}: {str(e)}\n{traceback.format_exc()}\n"

            error_log.write(error_message)

            error_log.flush()

            print(f"Error occurred in {program}. See error_log.txt for details.")

print("All tasks completed. Check task_times.log for detailed timing and error_log.txt for traceback details.")

# Print the current working directory and full path of log file

print(f"Current working directory: {os.getcwd()}")

print(f"Full path of log file: {os.path.abspath(log_file_path)}")

# Add a check to confirm the file was written

try:

    with open(log_file_path, 'r') as check_file:

        last_line = check_file.readlines()[-1]

        print(f"Last line in log file: {last_line.strip()}")

except IndexError:

    print("Log file is empty")

except FileNotFoundError:

    print(f"Log file not found at {log_file_path}")