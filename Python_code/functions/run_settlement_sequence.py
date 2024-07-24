import subprocess

program_list = ['prep0.py', 'prep1.py', 'prep2.py', 'prep3.py', 'prep4.py', 'prep5.py', 'prep6.py', 'prep7.py']

folder_path = '.'

for program in program_list:
    subprocess.call(['python', folder_path + '/' + program])
    print("Finished:", program)
