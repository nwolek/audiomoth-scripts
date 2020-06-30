#!/bin/bash

# Copyright (c) 2020, lowkey digital studio
# Author: Nathan Wolek
# Usage of this file and its contents is governed by the MIT License

# BEGUN - 30 April 2020
# GOAL - generate movies that pair audio with spectrograms of their content
# expected input .wav files (lower case extension) from rename-by-date.sh script
# expected output multiple .png files, each visualizing 30 second segments of .wav file
# expected output single .mp4 for entire .wav file

# some examples of text for locations and gps coordinates I have been using
beresfordtext="Lake Beresford, Florida"
canaveraltext="Canaveral National Seashore, Florida"
gpsdock="29.001019, -81.355588"
gpswood="29.000200, -81.354673"
gpspost14="28.894215, -80.808166"
gpspost10="28.895521, -80.806730"

# set variables used when generating text
location_text=$canaveraltext
gps_text=$gpspost14

# iterate through all arguments 
for file in $@
do
	
	# strip out the filename without extension
	without_path="${file##*/}"
	without_extension="${without_path%.wav}"
	
	# interpret the filename as a timestamp 
	timestamp_at_recording=$(TZ=UTC date -j -f "%Y-%m-%d-%H-%M-%S-UTC" "$without_extension" +%s)
	
	echo ""
	echo "Starting movie for $without_path..."

	total_duration=$(soxi -D "$without_path") # get the duration in seconds
	total_duration=${total_duration%.*} # convert to integer
	let total_duration=$total_duration-30 # subtract the last 30 seconds
	png_suffix=0 # set the suffix to initial value
	
	# create individual spectrogram for each 30 second segment of the .wav file
	for current_file_time in $(seq 0 30 $total_duration); 
	do
		echo "making spectrogram from $current_file_time to $(( $current_file_time + 30 )) seconds..."
		
		# generate the initial .png spectrogram output from sox
		sox "$file" -n rate 24k trim $current_file_time 30 spectrogram -x 1136 -y 542 -z 96 -w hann -o "$without_extension$png_suffix".png
		
		# extend the .png canvas size to match 720p dimensions and make room for text 
		convert "$without_extension$png_suffix".png -background black -gravity north -extent 1280x720 "$without_extension$png_suffix".png
		
		# add text to the bottom of the .png image
		date_text=$(date -j -f "%s" $timestamp_at_recording)
		convert "$without_extension$png_suffix".png -gravity south -fill white -pointsize 36 -annotate +0+10 "$location_text ($gps_text)\n$date_text" "$without_extension-slide$png_suffix".png
		
		# update variables for next 30 second segment
		let png_suffix++
		timestamp_at_recording=$(( $timestamp_at_recording + 30 ))
	
	done
	
	# combines original .wav audio with .png spectrograms to create .mp4 movie
	echo "creating full length movie..."
	ffmpeg -loglevel panic -framerate 1/30 -i "$without_extension"%d.png -i "$without_extension".wav -c:v libx264 -pix_fmt yuv420p "$without_extension".mp4
	
	# if a shortened copy of .mp4 movie is needed for something like social media, use something like the following 
	##echo "creating 60-sec edit of movie..."
	##ffmpeg -loglevel panic -framerate 1/30 -i "$without_extension"%d.png -i "$without_extension".wav -c:v libx264 -pix_fmt yuv420p -t 60 "$without_extension"-60sec.mp4
		
done