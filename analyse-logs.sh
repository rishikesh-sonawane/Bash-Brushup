#!/bin/bash
PATH=/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin


Error_Patterns=("ERROR" "FATAL" "CRITICAL" "FAILURE" "EXCEPTION" "TRACEBACK" "PANIC" "ABORT" "SEGFAULT" "ASSERTION" "UNCAUGHT EXCEPTION" "UNHANDLED EXCEPTION" "UNEXPECTED ERROR" "UNEXPECTED FAILURE" "UNEXPECTED EXCEPTION" "UNEXPECTED PANIC" "UNEXPECTED ABORT" "UNEXPECTED SEGFAULT" "UNEXPECTED ASSERTION")

find_file() {
	local log_files
	log_files=$(find /Users/rishi/Code -name "*.log" -mtime -1 2>&1)
	echo "Files that are recently modified (1 day) are:"
	if [ -z "$log_files" ]; then
		echo "No recent logs files found"
	else	
		echo "$log_files"
		ACTIVE_FILES="$log_files"
	fi
}

failure() {
	find_file || return 1
	echo -e "\nDisplaying the failures and the failure count from the file:"
	echo "$ACTIVE_FILES" | xargs grep -c -i "${Error_Patterns[3]}"
} 

error() {
	find_file
	echo -e "\nDisplaying the error and error count from the file:"
	echo "$ACTIVE_FILES" | xargs grep -i "${Error_Patterns[0]}"
    echo "$ACTIVE_FILES" | xargs grep -c -i "${Error_Patterns[0]}"	
}

lets_loop() {
	for ACTIVE_FILE in $ACTIVE_FILES; do
		echo -e "\nDisplaying the ${Error_Patterns[0]} count from the file: $ACTIVE_FILE"
		grep -c -i "${Error_Patterns[0]}" "$ACTIVE_FILE"

		echo -e "\nDisplaying the ${Error_Patterns[1]} count from the file: $ACTIVE_FILE"
		grep -c -i "${Error_Patterns[1]}" "$ACTIVE_FILE"

		echo -e "\nDisplaying the ${Error_Patterns[3]} count from the file: $ACTIVE_FILE"
		grep -c -i "${Error_Patterns[3]}" "$ACTIVE_FILE"
	done
}

loop_in_loop() {
	for ACTIVE_FILE in $ACTIVE_FILES; do
		echo -e "\n"
		echo "========================================"
		echo "============="$ACTIVE_FILE"============="
		echo "========================================"
		for pattern in "${Error_Patterns[@]}"; do
			echo -e "\nDisplaying the $pattern count from the file: $ACTIVE_FILE"
			error_count=$(grep -c -i "$pattern" "$ACTIVE_FILE")
			echo "Count: $error_count"

			if [ $error_count -gt 10 ]; then
				echo " :alert: Alert: The count of $pattern in $ACTIVE_FILE is greater than 10. Please check the error_report file for details."
			fi

		done
	done
}

menu() {
	# echo "========================================"
	# echo -e "Do you want to see 'failure' or do you want to see 'error' from the log files?"
	# echo "========================================"
	# read choice
	# echo "You chose $choice"
	
	# if [ "$choice" = "failure" ]; then
	# 	failure
	# elif [ "$choice" = "error" ]; then
	# 	error
	# else
	# 	echo "No selection"
	# 	return 1
	# fi

	find_file || return 1
	# lets_loop 
	# loop_in_loop > "error_report_$(date +%Y%m%d_%H%M%S).txt"
	local report_path="/Users/rishi/Code/error_report_$(date +%Y_%m_%d__%H_%M_%S).txt"
	loop_in_loop | tee "$report_path"
}

menu 

# date +%Y_%m_%d__%H_%m_%S - 2026_06_15__13_06_24

# 30 23 * * * /absolute/path/to/the/Code/analyse-logs.sh - 11:30 PM every day
# 0 8 * * 1 /absolute/path/to/the/Code/analyse-logs.sh - 8:00 AM every Monday
# 0 */12 * * * /absolute/path/to/the/Code/analyse-logs.sh - every 12 hours
# M H D M W - Minute, Hour, Day of Month, Month, Day of Week

# 20 14 * * 1 - /absolute/path/to/your/Code/analyse-logs.sh - every Monday at 2:20 PM 
