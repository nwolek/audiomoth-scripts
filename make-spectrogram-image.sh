#!/bin/bash

# Copyright (c) 2020, lowkey digital studio
# Author: Nathan Wolek
# Usage of this file and its contents is governed by the MIT License

# BEGUN - 16 April 2020
# GOAL - generate spectrogram image of entire .WAV file
# expected input .wav files (upper or lower case extension) produced by the AudioMoth
# expected output .png files visualizing entire .WAV file

# iterate through all arguments
for file in $@
do

	# strip out the filename without path
	without_path="${file##*/}"
	
	# use conditionals to make wav extension case insensitive
	if [[ $without_path == *.wav ]] || [[ $without_path == *.WAV ]]; then
	
		# strip the extension
		without_extension="${without_path%.*}"
	
		total_duration=$(soxi -D "$without_path") # get the duration in seconds
		total_duration=${total_duration%.*} # convert to integer

		# generate the initial .png spectrogram output from sox
		# dimension here are for spectrogram only, extra padding will result in 1280 x 720 image
		echo "making spectrogram for $without_path..."
		sox "$file" -n trim 0 $total_duration spectrogram -x 1136 -y 642 -z 96 -w hann -a -o "$without_extension".png
	
	else
		echo "skipped $without_path - not a wav file!"
	fi
	
done