#!/bin/bash

# Copyright (c) 2020, lowkey digital studio
# Author: Nathan Wolek
# Usage of this file and its contents is governed by the MIT License

# BEGUN - 5 June 2020
# GOAL - generate HTML table of spectrograms, allowing for better comparison between dates and times
# expected input .wav files (lower case extension) from rename-by-date.sh script
# expected output index.html file with table of spectrogram thumbnail images
# index.html uses the generate-table.css file in this repo to support fixed header and left column

# because filenames are based on the date, we can grab the first and last
first_time="${1%.wav}"
last_time="${BASH_ARGV%.wav}"

# setup var to collect all times in HH-MM format
all_hh_mm=""

# setup var to collect all dates in YYYY-MM-DD format
all_dates=""

for file in $@
do
	# get hours & minutes from each filename in HH-MM format
	new_time=${file:11:5}
	
	# add to the end of list
	all_hh_mm="$all_hh_mm $new_time"
	
	# get calendar date from each filename in YYYY-MM-DD format
	new_date=${file:0:10}
	
	# add to the end of list
	all_dates="$all_dates $new_date"
	
done

# these echo statements were used for testing
##echo "The complete list of dates:"
##echo $all_dates

##echo "The complete list of times:"
##echo $all_hh_mm

# filter repetitions so that only unique values remain
unique_dates=$(echo $all_dates | tr ' ' '\n' | sort -u)
unique_hh_mm=$(echo $all_hh_mm | tr ' ' '\n' | sort -u)

# these echo statements were used for testing
##echo "The unique dates are:"
##echo $unique_dates

##echo "The unique times are:"
##echo $unique_hh_mm

# delete old version if it exists
if [[ -f "index.html" ]]; then
	rm index.html
fi

# start the html document
echo \<!DOCTYPE html\> >> index.html
echo \<html\> >> index.html
echo \<head\> >> index.html
echo \<link rel=\"stylesheet\" type=\"text/css\" href=\"spectrogram-table.css\"\> >> index.html
echo \<\/head\> >> index.html
echo \<body\> >> index.html

# start the table
echo \<div id=\"table-scroll\" class=\"table-scroll\"\> >> index.html
echo \<table id=\"main-table\" class=\"main-table\"\> >> index.html

# create the header row
echo \<thead\> >> index.html
echo \<tr\> >> index.html

# first table cell in header contains the "Time" label
echo \<th\>Time\<\/th\> >> index.html

for each_date in $unique_dates; do
	
	# other table cells in header contains the date
	# reformat the date to look like this: Mon 01 Jun 2020
	each_date_reformat=$(date -j -f "%Y-%m-%d" "+%a %d %b %Y" $each_date)

	echo \<th\>"$each_date_reformat"\<\/th\> >> index.html
done

echo \<\/tr\> >> index.html
echo \<\/thead\> >> index.html

# create the other rows
echo \<tbody\> >> index.html

for each_hh_mm in $unique_hh_mm; do
	
	echo \<tr\> >> index.html
	
	# first table cell in row contains the time
	# mark 00 minute as start of hour
	if [[ ${each_hh_mm:3:2} = "00" ]]; then
		echo -n \<th class=\"start-of-hour\"\> >> index.html
	else
		echo -n \<th\> >> index.html
	fi
	echo ${each_hh_mm:0:2}:${each_hh_mm:3:2} UTC\<\/th\> >> index.html

	# other table cells in row contain thumbnail spectrogram images
	for each_date in $unique_dates; do
	
		# assemble the timestamp from $each_date & $each_hh_mm
		each_timestamp_assembled="$each_date-$each_hh_mm-00-UTC"
		
		# which day of the week?
		day_of_week=$(date -j -f "%Y-%m-%d-%H-%M-%S-UTC" "+%a" $each_timestamp_assembled)
		
		# make sure the thumbnail image exists
		if [[ -f "$each_timestamp_assembled"-thumbnail.png ]]; then
			
			# mark sunday columns as start of week
			if [[ $day_of_week = "Sun" ]]; then
				echo -n \<td class=\"start-of-week\"\>  >> index.html
			else
				echo -n \<td\>  >> index.html
			fi
			echo \<img src=\"$each_timestamp_assembled\-thumbnail.png\" width=\"128\" height=\"72\"\>\<\/td\> >> index.html
		else 
			echo \<td\>\&nbsp\;\<\/td\> >> index.html
		fi
	done
	
	echo \<\/tr\> >> index.html
	
done

# close the table
echo \<\/tbody\> >> index.html
echo \<\/table\> >> index.html
echo \<\/div\> >> index.html

# close the html document
echo \<\/body\> >> index.html
echo \<\/html\> >> index.html

# copy the CSS file if it's missing
css_file="spectrogram-table.css"
if [[ ! -f "$css_file" ]]; then

	# where is this bash script source located?
	directory_audiomoth_scripts="$( dirname "${BASH_SOURCE[0]}" )"
	
	# where is the bash script running?
	directory_current=$(pwd)
	
	# if the file exists in the script source location, then copy it
	if [[ -f "$directory_audiomoth_scripts/$css_file" ]]; then
		cp "$directory_audiomoth_scripts/$css_file" "$directory_current/$css_file"
	else
		echo "Could not copy spectrogram-table.css - HTML formatting will not match expectations"
	fi
fi
