#!/bin/bash

read -p "Enter the main directory name: " name

if [[ -z "$name" ]]; then
	echo "The project name can't be empty"
	exit 1
fi

main_dir="attendance_tracker_$name"
archive="${main_dir}_archive"

# Process management (signal trapping and creation of archive)

cleanup() {
	echo ""
	echo "The script has been interrupted. The project is archiving"

	if [[ -d "$main_dir" ]]; then
		tar -czf "$archive" "$main_dir"
		rm -rf "$main_dir"
		echo "Archive has been created and the incomplete directory has been removed."
	fi
	exit 1
}
trap cleanup SIGINT

# Creation of the directory structure

mkdir -p "$main_dir/Helpers"
mkdir -p "$main_dir/reports"

# attendance_checker.py
cat > "$main_dir/attendance_checker.py" << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    # 1. Load Config
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)
    
    # 2. Archive old reports.log if it exists
    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    # 3. Process Data
    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']
        
        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")
        
        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])
            
            # Simple Math: (Attended / Total) * 100
            attendance_pct = (attended / total_sessions) * 100
            
            message = ""
            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."
            
            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF

# assets.csv
cat > "$main_dir/Helpers/assets.csv" << 'EOF'
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF

# config.json
cat > "$main_dir/Helpers/config.json" << 'EOF'
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF

# reports.log
cat > "$main_dir/reports/reports.log" << 'EOF'
--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.
EOF

echo "The directory structure is now created"

# Dynamic configuration

echo ""
read -p "Do you want to update the attendance thresholds? (yes/no): " choice
if [[ "$choice" = "yes" ]]; then

	read -p "Enter new warning threshold: " warning
	if [[ -z "$warning" ]]; then
		warning=75
	fi

	read -p "Enter new failure threshold: " failure
	if [[ -z "$failure" ]]; then
		failure=50
	fi
	
	sed -i "s/\"warning\": [0-9]*/\"warning\": $warning/" "$main_dir/Helpers/config.json"

	sed -i "s/\"failure\": [0-9]*/\"failure\": $failure/" "$main_dir/Helpers/config.json"

	echo "Thresholds updated successfully"

else
	echo "Thresholds returned to default"

fi

# Environment validation

if python3 --version &> /dev/null; then
	echo "Python3 is installed"
else
	echo "Warning: Python3 isn't installed"
fi

# Final directory structure check

if [ -f "$main_dir/attendance_checker.py" ] &&
	[ -f "$main_dir/Helpers/assets.csv" ] &&
	 [ -f "$main_dir/Helpers/config.json" ] &&
	 [ -f "$main_dir/reports/reports.log" ]; then 
	 echo "Directory structure is correct"
else
	echo "Directory structure isn’t correct"
fi

echo "Setup complete."
