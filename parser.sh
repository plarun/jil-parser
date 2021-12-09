#!/bin/sh
# Autosys JIL parser
# It parses the output of "autorep -q -J *" into '~' seperated file.

jil_file=$1
parsed_file=$2

# Check arguments
if [[ $# -ne 2 ]]; then
	echo "arguments: <JIL input filename> <Parsed output filename>"
	exit 1
fi

# Checks the availability of input file
if [[ ! -f "$jil_file" ]]; then
	echo "file: $jil_file is not found"
	exit 1
fi

# Move job_type: attribute in jil_file to new line
sed -i 's/job_type:/\njob_type:/g' "$jil_file"

# Trim trailing whitespaces
sed -i 's/^[ \t]*//' "$jil_file"

awk '
BEGIN {
	# List of attributes need to be available in parsed output file
	attributes = "insert_job~box_name~job_type~alarm_if_fail~alarm_if_terminated~command~condition~machine~owner~permission~date_conditions~days_of_week~run_window~start_mins~start_times~timezone~max_run_alarm~min_run_alarm~run_calendar~exclude_calendar~std_out_file~std_err_file~profile"

	has_attr = 0
	split(attributes, keys, "~")
	for (key in keys) {
		map[key] = ""
	}

	# Add header to output file
	print attributes
}
{
	if ($0 == "") {
		# Empty line

		if (has_attr == 1) {
			# End of the job definition

			# Writes parsed data of a Job to output file
			for (i=1; i<=length(keys); i++) {
				if (keys[i] == "insert_job") {
					printf "%s", map[keys[i]]
				} else {
					printf "~%s", map[keys[i]]
				}
			}
			printf "\n"

			# Reset the array to store data for next job
			for (attr in map) {
				map[attr] = ""
			}
			has_attr = 0
		}
	} else if ($0 ~ /^\/\*/) {
		# Commented line

		has_attr = 0
	} else {
		# Job data

		has_attr = 1
		idx = index($0, ":")
		attr = substr($0, 0, idx-1)
		data = substr($0, idx+1)
		gsub(/^[ \t]+|[ \t]+$/, "", data)
		map[attr] = data
	}
}
' "$jil_file" > "$parsed_file"
