#!/usr/bin/env bash
# usage: bin2ffplay.sh [filepath] [fs] [number_of_channels]

if [ $# -eq 0 ]
then
  echo 'bin2ffplay.sh [filepath] [fs] [number_of_channels]'
fi

if [ $# -eq 4 ]
then
  outfol=$4
else
  outfol="."
fi

ffplay -f s16le -ar $2 -ac $3 -i $1
#for f in `ls *.bin`; do ffmpeg -f s16le -ar $2 -ac $3 -i $f -f wav $outfol/${f%%.bin}.wav -loglevel quiet; done
