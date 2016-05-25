# convert-music

Task
------------
Create script to convert music (.mp3 files) bitrates to 192 kbit/s. And recursively change file names and folder names (names of albums). Artist folders will change manually.

I should do that for old music automobile player, it can't support Cyrillic letters in file names (and folder names) and only play files with bitrate 192 kbit/s.

Requirements
------------
- pwgen
- ffmpeg (https://trac.ffmpeg.org/wiki/CompilationGuide/Ubuntu)

Distros tested
------------

Currently, this is only tested on ubuntu 14.04. It should theoretically work on older versions of Ubuntu or Debian based systems.

Usage
------------
Just change variable in your copy of script SOURCE_FOLDER="/home/sergiy/Desktop/test-music-folder" and сheck it out that there is enough free space on your PC in /tmp folder. After that run script.

Source folder with Artist folders - "/home/sergiy/Desktop/test-music-folder".
We copy all folders to "/tmp/music_output and perform some operations".

Also we create log files - "/tmp/convert_music.log" and "/tmp/cm_ffmpeg.log".

recode - first function that convert all mp3 files in every folders and change file names.
recursion - second function recursively change folder names.
