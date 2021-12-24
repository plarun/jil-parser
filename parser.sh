#!/bin/sh
# Autosys JIL parser
# It parses the output of "autorep -q -J *" into '~' seperated file.

# Input file contains output data of autosys command `autorep -q -J *`
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

# JIL Data parsing
awk -f "parse.awk" "$jil_file" > "$parsed_file"
