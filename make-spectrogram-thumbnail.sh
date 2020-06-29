#!/bin/bash

# Copyright (c) 2020, lowkey digital studio
# Author: Nathan Wolek
# Usage of this file and its contents is governed by the MIT License

# BEGUN - 23 June 2020
# GOAL - generate spectrogram thumbnail image of entire .WAV file
# expected input .wav files (upper or lower case extension) produced by the AudioMoth
# expected output 2 .png files (fullsize & thumbnail) visualizing entire .WAV file

# iterate through all arguments
for file in $@
do

	# strip out the filename without path
	without_path="${file##*/}"
	
	# use conditionals to make wav extension case insensitive
	if [[ $without_path == *.wav ]] || [[ $without_path == *.WAV ]]; then
		
		# strip the extension
		without_extension="${without_path%.*}"
	
		total_duration=$(soxi -D "$file") # get the duration in seconds
		total_duration=${total_duration%.*} # convert to integer
		
		# since thumbnail images are small, we don't want more than 30 seconds represented
		if (( total_duration > 30 )); then
			total_duration=30
		fi

		# generate the initial .png spectrogram output from sox
		# dimension here are for spectrogram only, extra padding will result in 1280 x 720 image
		echo "making fullsize spectrogram for $without_path..."
		sox "$file"  -n rate 24k trim 0 $total_duration spectrogram -x 1136 -y 642  -z 96 -w hann -a -o "$without_extension"-fullsize.png

		# resize to thumbnail dimensions 128 x 72
		echo "making thumbnail spectrogram for $without_path..."
		convert "$without_extension"-fullsize.png -resize 128x72 "$without_extension"-thumbnail.png
		
		# to delete the fullsize version, uncomment the next two lines
		echo "deleting fullsize spectrogram for $without_path..."
		rm "$without_extension"-fullsize.png
	
	else
		echo "skipped $without_path - not a wav file!"
	fi
	
done