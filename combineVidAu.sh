#!/usr/bin/env bash
# usage: v2p.sh INFILEPATH OUTFILEPATH -r CONVERTED_FPS
## without -r argument

if [ -z $1 ]
then
	echo 'combineVidAu_wav.sh [videoFile_path] [acousticFile_path] [output_newVideoFile_path]'
	exit 0
fi


while getopts ":n" opt; do
  case $opt in
    n)
    echo "normalized!"
    shift 1
    ffmpeg -i "$1" -i "$2" -map 0:v -map 1:a -vcodec copy -af loudnorm=I=-16:LRA=11:TP=-1.5 -f matroska "$3_normalized-audio.mkv"
    exit 0
    ;;
  esac
done

ffmpeg -i "$1" -i "$2" -map 0:v -map 1:a -vcodec copy -acodec copy -f matroska "$3.mkv"
