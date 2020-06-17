#!/bin/bash

# Copyright (c) 2020, lowkey digital studio
# Author: Nathan Wolek
# Usage of this file and its contents is governed by the MIT License

# BEGUN - 23 April 2020
# GOAL - change the WAV filename to be based on the birthdate
# Example of desired format - 2020-04-06-04-00-00-UTC
# expected input .WAV files (upper case extension) produced by the AudioMoth
# expected output .wav files (lower case extension)

# make directory for output
if [ ! -d output ]; then
	mkdir -p output
fi

# iterate through all arguments
for file in $@
do

	# Use 'stat' to get the birthdate of the file, but switch the format
	# Example of default format from stat - Apr  6 04:00:00 2020
	# Example of desired format - 2020-04-06-04-00-00-UTC

	format='%F-%H-%M-%S-UTC'
	birthdate=$(stat -f "%SB" -t $format $file)

	# copy the original sound file and give it a new birthdate name

	cp $file output/$birthdate.wav

	# apply old attributes to the new file

	touch -r $file output/$birthdate.wav

	# touch one more time to update the modification date

	touch output/$birthdate.wav

done