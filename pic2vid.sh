#!/usr/bin/env bash

if [ -z $1 ]
then
	echo usage: pic2vid.sh INFILEPATH OUTFILEPATH -r CONVERTED_FPS
	exit 0
fi

in_folder=$1
out_video=$2
fps=4

shift 2
while getopts ":r" opt; do
  case $opt in
    r)
    fps=$2
    #ffmpeg -i "$infile" -r $2 -f image2 "$outfol/image-%06d.png"
    ;;
  esac
done

ffmpeg -framerate $fps -i $in_folder/image-%06d.png -vcodec libx264 -b 5m -vf format=yuv420p $out_video

