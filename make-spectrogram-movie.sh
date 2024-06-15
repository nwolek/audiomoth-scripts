#!/bin/bash

# Copyright (c) 2020, lowkey digital studio
# Author: Nathan Wolek
# Usage of this file and its contents is governed by the MIT License

# BEGUN - 30 April 2020
# GOAL - generate movies that pair audio with spectrograms of their content
# expected input .wav files (lower case extension) from rename-by-date.sh script
# expected output single .mp4 for entire .wav file

# variables for setting output options quickly
# for complete list, visit this page - https://ffmpeg.org/ffmpeg-filters.html#showspectrum-1
# dynamic range in dBFS, values can be between 10 to 200
dynamic_range=72
# highest frequency in Hertz
highest_freq=10000
# lowest frequency in Hertz
lowest_freq=0
# gain scale, typically switch between linear "lin" or logarithmic "log"
gain_scale="log"
# frequency scale, switch between linear "lin" or logarithmic "log"
freq_scale="lin"
# color scheme, personal favorite options are cool, fruit, fiery, green
color_choice="cool"
# sliding behavior, switch between "scroll" & other options like "replace"
slide_choice="scroll"

# set variables used when generating text
location_text="Purchase Knob, NC USA"
gps_text="35.5858847,-83.0735405"

# iterate through all arguments 
for file in $@
do
	
	# strip out the filename without extension
	without_path="${file##*/}"
	without_extension="${without_path%.wav}"
	
	# interpret the filename as a timestamp 
	timestamp_at_recording=$(date -j -f "%Y%m%d_%H%M%S" "$without_extension" +%s)
	date_text=$(date -j -f "%s" $timestamp_at_recording +"%d %B %Y")
	time_text=$(date -j -f "%s" $timestamp_at_recording +"%H\:%M\:%S")
	
	echo ""
	echo "Creating spectrogram movie for $without_path"
	echo "	Timestamp at start is $timestamp_at_recording"
	echo "	Date at start is $date_text"
	echo "	Time at start is $time_text"
	
	# generates spectrogram video using original .wav audio to create .mp4 movie
	echo "	Creating full length movie at $without_extension.mp4..."
	full_header_text="$location_text ($gps_text)"
	full_date_text="$date_text at $time_text"
	ffmpeg -i $without_extension.wav -filter_complex \
		"[0:a]showspectrum=s=996x592:legend=enable:start="$lowest_freq":stop="$highest_freq":scale="$freq_scale":color="$color_choice":drange="$dynamic_range":scale="$gain_scale":slide="$slide_choice",
		drawtext=text='$full_header_text':x=25:y=25:fontsize=24:fontcolor=white,
		drawtext=text='$full_date_text':x=W-tw-25:y=25:fontsize=24:fontcolor=white,
		format=yuv420p[v]" \
		-map "[v]" -map 0:a -v verbose $without_extension.mp4
	echo "	Done!"
		
	# adds location text to newly generated .mp4 movie 
	#echo "adding text to movie..."
	#
	#ffmpeg -i $without_extension-no-text.mp4 -vf "drawtext=text='$full_header_text':x=25:y=25:fontsize=24:fontcolor=white" -c:a copy $without_extension.mp4
		
done
