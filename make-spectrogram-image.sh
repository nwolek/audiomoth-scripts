#!/bin/bash

# Copyright (c) 2020, lowkey digital studio
# Author: Nathan Wolek
# Usage of this file and its contents is governed by the MIT License

# BEGUN - 16 April 2020
# GOAL - generate spectrogram image of entire .WAV file
# expected input .wav files (upper or lower case extension) produced by the AudioMoth
# expected output .png files visualizing entire .WAV file

# variables for setting output options quickly
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
color_choice="fruit"

# iterate through all arguments
for file in $@
do

	# strip out the filename without path
	without_path="${file##*/}"
	
	# use conditionals to make wav extension case insensitive
	if [[ $without_path == *.wav ]] || [[ $without_path == *.WAV ]]; then
	
		# strip the extension
		without_extension="${without_path%.*}"
	
		# generate the initial .png spectrogram output from ffmpeg
		# dimension here are for spectrogram only, extra padding will result in 1280 x 720 image
		echo "making spectrogram for $without_path..."
		ffmpeg -i $without_path -lavfi showspectrumpic=s=996x592:legend=enable:start=$lowest_freq:stop=$highest_freq:fscale=$freq_scale:color=$color_choice:drange=$dynamic_range:scale=$gain_scale -v quiet "$without_extension".png
	
	else
		echo "skipped $without_path - not a wav file!"
	fi
	
done