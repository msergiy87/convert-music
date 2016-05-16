#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:$PATH

#set -x

SOURCE_FOLDER="/home/sergiy/Desktop/test-music-folder"
MAIN_FOLDER="/tmp/music_output"
LOG_FILE="/tmp/convert_music.log"

# Install pwgen
if [ ! -f /usr/bin/pwgen ]
then
	echo "Please install pwgen and run againe (apt-get install pwgen). EXIT"
	exit 113
fi

mkdir "$MAIN_FOLDER"
cp -r "$SOURCE_FOLDER"/* "$MAIN_FOLDER"
rm "$LOG_FILE" > /dev/null 2>&1
rm /tmp/cm_ffmpeg.log > /dev/null 2>&1

##############################################
### FIRST PART - RECODE FILES IN EVERY DIR ###
##############################################

recode () {
	INPUT_DIR="$1"

	echo "-------------------------" >> "$LOG_FILE"
	echo "START PROCESS DIRECTORY" >> "$LOG_FILE"
	echo "$INPUT_DIR" >> "$LOG_FILE"

	# Create list of files that should process
	find "$INPUT_DIR"/*.mp3 -maxdepth 0 -type f > /tmp/cm_processing_list_files

	if [ -s /tmp/cm_processing_list_files ]		# True if FILE exists and has a size greater than zero
	then
		echo "FILES IN DIR:" >> "$LOG_FILE"
		cat /tmp/cm_processing_list_files >> "$LOG_FILE"

		ORDER_NUM="1"

		while read -r MUSIC_FILE
		do
			echo "Start change BITRATE and NAME" >> "$LOG_FILE"
			echo "$MUSIC_FILE" >> "$LOG_FILE"
			echo "$INPUT_DIR"/"$ORDER_NUM".mp3 >> "$LOG_FILE"

			ffmpeg -i "$MUSIC_FILE" -ab 192k "$INPUT_DIR"/"$ORDER_NUM".mp3 < /dev/null > /tmp/cm_ffmpeg.log 2>&1
			rm "$MUSIC_FILE"
			ORDER_NUM=$(( ORDER_NUM + 1 ))

		done < /tmp/cm_processing_list_files

	elif [ ! -s /tmp/cm_processing_list_files ]
	then
		echo "There are no any files .mp3 in folder $INPUT_DIR" >> "$LOG_FILE"
	else
		echo "ERROR. File not exist /tmp/cm_processing_list_files or another problem" >> "$LOG_FILE"
		exit 113
	fi
}

# Find all nesting album dirs and process it (including artist dirs)
find "$MAIN_FOLDER" -mindepth 1 -type d > /tmp/cm_list_all_albums

while read -r ALB_DIR
do
	recode "$ALB_DIR"

done < /tmp/cm_list_all_albums

######################################
### SECOND PART - CHANGE DIR NAMES ###
######################################

# Function for create nesting albums dirs
recursion () {
	INPUT_DIR="$1"
	RND="$RANDOM-$RANDOM"

	find "$INPUT_DIR" -maxdepth "$LEVEL" -mindepth "$LEVEL" -type d > /tmp/cm_nested_dirs_with_music_$RND

	if [ -s /tmp/cm_nested_dirs_with_music_$RND ]		# True if FILE exists and has a size greater than zero
	then
		while read -r NEST_DIR
		do
			NEW_DIR_NAME=$(pwgen --no-numerals --no-capitalize 10 1)
			OUT_DIR=$(dirname "$NEST_DIR")
			mv "$NEST_DIR" "$OUT_DIR"/"$NEW_DIR_NAME"

			echo "=========================" >> "$LOG_FILE"
			echo "Rename dir" >> "$LOG_FILE"
			echo "$NEST_DIR" >> "$LOG_FILE"
			echo "$OUT_DIR"/"$NEW_DIR_NAME" >> "$LOG_FILE"

			LEVEL=$(( LEVEL + 1 ))
			recursion "$INPUT_DIR"

		done < /tmp/cm_nested_dirs_with_music_"$RND"

		stat -t /tmp/cm_nested_dirs_with_music_* > /dev/null 2>&1
		if [ 0 -eq $? ]
		then
			rm /tmp/cm_nested_dirs_with_music_*
		fi
	fi
}

# Find only artist dirs (parent)
find "$MAIN_FOLDER" -maxdepth 1 -mindepth 1 -type d > /tmp/cm_main_dirs_with_music

# Create artist dirs (or parent)
while read -r ART_DIR
do
	LEVEL="1"
	recursion "$ART_DIR"

done < /tmp/cm_main_dirs_with_music
