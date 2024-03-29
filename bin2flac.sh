#!/usr/bin/env bash

# Convert binary file to flac file

## $1 folder name
## $2 sampling rate
## $3 number of channels
### default 16 bit little endian

## -r to delete bin file after conversion
## -q -loglevel quiet
## -y overwrites flac file if already exist
## -f float encoding instead of int16
## -d .dat instead of .bin

if [ $# -eq 0 ]
then
  echo 'bin2flac.sh [folder_path] [fs] [number_of_channels] [outfolder(optional)] [options: -r(delete after convert), -q(quiet logs), -y(overwrite flac if exist), -f(float encoding), -d(.dat file), -w(create .wav file), -h(hide ffmpeg banner)]'
  exit 1
fi


folder="$1"
fs=$2
ch=$3
var_4="$4"

# [outfolder(optional)] [metadata config file]
if (( $# > 3 )) && [[ ${var_4:0:1} != "-" ]]
then
  outfol="$4"
  mkdir $outfol
  shift 1
else
  outfol="$1_flac"
  mkdir $outfol
fi

shift 3

r=""
loglevel=""
y=""
ENCODING=s16le
filetype=bin
out_type=flac
hide_banner= 
while getopts ":rqyfdwh" opt; do
  case $opt in
    r)
      r="remove"
      ;;
    q)
      loglevel="-loglevel quiet"
      ;;
    y)
      y="-y"
      ;;
    f)
      ENCODING=f32be
      ;;
    d)
      filetype=dat
      echo "---look for .dat file instead"
      ;;
    w)
      out_type=wav
      echo "---convert to wav file instead"
      ;;
    h)
      hide_banner=-hide_banner
      echo "---hide banner"
      ;;
    *)
      ;;
  esac
done

if [ "$r" = remove ]; then
  for f in ls "$folder"/*.$filetype; 
    do 
    outfile="$outfol/${f%%.$filetype}.$out_type"
    outfile=${outfile##*/}
    ffmpeg -f $ENCODING -ar $fs -ac $ch -i "$f" -f $out_type -c:a pcm_${ENCODING:0:3}le "$outfol/$outfile" $y $loglevel $hide_banner && rm "$f"
  done
else
  for f in ls "$folder"/*.$filetype; 
    do
    outfile="$outfol/${f%%.$filetype}.$out_type"
    outfile=${outfile##*/}
    ffmpeg -f $ENCODING -ar $fs -ac $ch -i "$f" -f $out_type -c:a pcm_${ENCODING:0:3}le "$outfol/$outfile" $y $loglevel $hide_banner
  done
fi

exit 0
