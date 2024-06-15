#!/bin/bash

# Copyright (c) 2020, lowkey digital studio
# Author: Nathan Wolek
# Usage of this file and its contents is governed by the MIT License

# BEGUN - 30 April 2020
# GOAL - generate movies that pair audio with spectrograms of their content
# expected input .wav files (lower case extension) from rename-by-date.sh script
# expected output multiple .png files, each visualizing 30 second segments of .wav file
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
location_text="Canaveral National Seashore, Florida"
gps_text="28.909534, -80.820955"

# iterate through all arguments 
for file in $@
do
	
	# strip out the filename without extension
	without_path="${file##*/}"
	without_extension="${without_path%.wav}"
	
	# interpret the filename as a timestamp 
	# timestamp_at_recording=$(TZ=UTC date -j -f "%Y%m%d-%H%M%S-UTC" "$without_extension" +%s)
	
	echo ""
	echo "Starting movie for $without_path..."

	# total_duration=$(soxi -D "$without_path") # get the duration in seconds
	# total_duration=${total_duration%.*} # convert to integer
	# let total_duration=$total_duration-30 # subtract the last 30 seconds
	# png_suffix=0 # set the suffix to initial value
	
	# create individual spectrogram for each 30 second segment of the .wav file
	# for current_file_time in $(seq 0 30 $total_duration); 
	# do
	# 	echo "making spectrogram from $current_file_time to $(( $current_file_time + 30 )) seconds..."
		
		# generate the initial .png spectrogram output from sox
	# 	sox "$file" -n rate 24k trim $current_file_time 30 spectrogram -x 1136 -y 542 -z 96 -w hann -o "$without_extension$png_suffix".png
		
		# extend the .png canvas size to match 720p dimensions and make room for text 
	# 	convert "$without_extension$png_suffix".png -background black -gravity north -extent 1280x720 "$without_extension$png_suffix".png
		
		# add text to the bottom of the .png image
	# 	date_text=$(date -j -f "%s" $timestamp_at_recording)
	# 	convert "$without_extension$png_suffix".png -gravity south -fill white -pointsize 36 -annotate +0+10 "$location_text ($gps_text)\n$date_text" "$without_extension-slide$png_suffix".png
		
		# update variables for next 30 second segment
	# 	let png_suffix++
	# 	timestamp_at_recording=$(( $timestamp_at_recording + 30 ))
	
	# done
	
	# combines original .wav audio with .png spectrograms to create .mp4 movie
	echo "creating full length movie..."
	ffmpeg -i $without_extension.wav -filter_complex \
		"[0:a]showspectrum=s=996x592:legend=enable:start="$lowest_freq":stop="$highest_freq":scale="$freq_scale":color="$color_choice":drange="$dynamic_range":scale="$gain_scale":slide="$slide_choice",format=yuv420p[v]" \
		-map "[v]" -map 0:a -v verbose $without_extension-no-text.mp4
	# if a shortened copy of .mp4 movie is needed for something like social media, use something like the following 
	##echo "creating 60-sec edit of movie..."
	##ffmpeg -loglevel panic -framerate 1/30 -i "$without_extension"%d.png -i "$without_extension".wav -c:v libx264 -pix_fmt yuv420p -t 60 "$without_extension"-60sec.mp4
		
done