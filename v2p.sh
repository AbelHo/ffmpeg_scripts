#!/usr/bin/env bash
# usage: v2p.sh INFILEPATH OUTFILEPATH -r CONVERTED_FPS
## without -r argument

if [ -z $1 ]
then
	echo usage: v2p.sh INFILEPATH OUTFILEPATH -r CONVERTED_FPS
	exit 0
fi

infile=$1
outfol=$2
if [ -z "$outfol" ]
then
  outfol=$1_pics
fi
mkdir $outfol

shift 2

while getopts ":r" opt; do
  case $opt in
    r)
    ffmpeg -i "$infile" -r $2 -f image2 "$outfol/image-%06d.png"
    exit 0
    ;;
  esac
done

ffmpeg -i "$infile" -f image2 "$outfol/image-%06d.png"