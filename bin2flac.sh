#!/usr/bin/env bash

# Convert binary file to flac file

## $1 folder name
## $2 sampling rate
## $3 number of channels
### default 16 bit little endian

## -r to delete bin file after conversion
## -q -loglevel quiet
## -y overwrites flac file if already exist

if [ $# -eq 0 ]
then
  echo 'bin2flac.sh [folder_path] [fs] [number_of_channels] [options: -r(delete after convert), -q(quiet logs), -y(overwrite flac if exist)]'
  exit 1
fi


folder="$1"
fs=$2
ch=$3

shift 3

r=""
loglevel=""
y=""
while getopts ":rqy" opt; do
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
    *)
      ;;
  esac
done

if [ "$r" = remove ]; then
  for f in `ls "$folder*.bin"`; 
    do 
    ffmpeg -f s16le -ar $fs -ac $ch -i "$f" -c:a flac ${f%%.bin}.flac $y $loglevel && rm "$f"
  done
else
  for f in `ls "$folder*.bin"`; 
    do 
    ffmpeg -f s16le -ar $fs -ac $ch -i "$f" -c:a flac "${f%%.bin}.flac" $y $loglevel
  done
fi

exit 0