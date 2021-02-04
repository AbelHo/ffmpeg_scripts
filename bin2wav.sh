#!/usr/bin/env bash
# usage: bin2wav.sh [folder_path] [fs] [number_of_channels] [outputfolder]

if [ $# -eq 0 ]
then
  echo 'bin2wav.sh [folder_path] [fs] [number_of_channels] [outputfolder]'
else
  cd $1
fi


if [ $# -eq 4 ]
then
  outfol=$4
else
  outfol="."
fi

mkdir $outfol || echo 'cannot create directory'

for f in `ls *.bin`; do ffmpeg -f s16le -ar $2 -ac $3 -i $f -f wav $outfol/${f%%.bin}.wav -loglevel quiet; done
