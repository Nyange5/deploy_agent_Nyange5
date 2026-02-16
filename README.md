Automated Project Bootstrapping & Process Management


A shell-based automation project that shows the IaC (Infrastructure as Code) principles by creating and managing a Student Attendance Tracker application automatically. 

This method only requires a single shell script to generate the required structure, update configuration values and handle unexpected interruptions.

Overview

This project contains one main script that when run, it sets up the Student Attendance Tracker system:
setup_project.sh

Scripts

setup_project.sh
This is the master shell script that’s responsible for setting up the Student Attendance Tracker system.

What it does

1. Prompts the user for a project name, in order to create a directory named:

attendance_tracker_<input>

2. Creates the directory structure:

attendance_tracker_<input>/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
    └── reports.log

3. Prompts the user to update attendance thresholds (optionally):
Warning threshold (default: 75%)
Failure threshold (default: 50%)

4. Uses sed to perform in-place editing of config.json

5. Performs an environment health check that verifies python3 anddisplays a success or warning message accordingly.

6. Implementing a signal trap which archives the current project state into attendance_tracker_<input>_archive when there’s anycancelation of the script mid-execution. Then deletes the incomplete directory.


Usage

1. Running the Script

chmod +x setup_project.sh
./setup_project.sh

2. Example run

$ ./setup_project.sh
Enter project name: demo
Do you want to update attendance thresholds? (y/n): y
Enter warning threshold (default 75): 80
Enter failure threshold (default 50): 40
python3 is installed 
Project setup completed successfully


Triggering the Archive Feature (Signal Trap)

* Run the script

* Press Ctrl + C during execution

* The script will:
Create an archive named:
attendance_tracker_<input>_archive
Remove the partially created directory


Project structure

The directory structure should look like this:

attendance_tracker_<input>/
├── attendance_checker.py     # Main Python application logic
├── Helpers/
│   ├── assets.csv            # Attendance data
│   └── config.json           # Configurable thresholds
└── reports/
    └── reports.log           # Application logs

How It Works

1. User Input – The script collects a project name and configuration preferences

2. Directory Architecture – Required folders and files are created automatically

3. Dynamic Configuration – read command enables the capture of new threshold values. sed command updates threshold values without manual editing in Helpers/config.json

4. Environment Validation – Ensures Python is available before completion

5. Process Management – A signal trap safely handles interruptions

6. Cleanup & Archiving – Prevents incomplete setups from polluting the workspace


Requirements

* Bash shell (Linux, macOS, or WSL)
* Bash Unix utilities (sed, tar, chmod)
* Python 3 (validated at runtime)

