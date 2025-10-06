#!/usr/bin/env bash

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "usage: pic2vid.sh INFILEPATH OUTFILEPATH [COUNTER_PATTERN] [-r CONVERTED_FPS] [--auto]"
  echo "  INFILEPATH         Path to input image folder"
  echo "  OUTFILEPATH        Output video file path"
  echo "  COUNTER_PATTERN    (optional) printf-style pattern for image numbering, e.g. %06d (default: %d)"
  echo "  -r CONVERTED_FPS   (optional) set output frame rate"
  echo "  --auto             (optional) automatically process all image files in folder, sorted by name"
  echo "                    ignores COUNTER_PATTERN and uses all supported image types"
  exit 0
fi

in_folder=$1
out_video=$2
fps=4
counter="%d"

# Check for optional counter argument (3rd positional argument)
if [ ! -z "$3" ]; then
  counter="$3"
fi

shift 2
while getopts ":rc" opt; do
  case $opt in
    r)
    fps=$2
    #ffmpeg -i "$infile" -r $2 -f image2 "$outfol/image-%06d.png"
    ;;
  esac
done


# If --auto is provided, generate a sorted list of image files and use ffmpeg concat
auto_mode=false
for arg in "$@"; do
  if [ "$arg" = "--auto" ]; then
    auto_mode=true
    break
  fi
done

if [ "$auto_mode" = true ]; then
  listfile="${in_folder}/list.txt"
  # Find image files, sort by name, and create ffmpeg list file
  find "$in_folder" -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.bmp' -o -iname '*.gif' \) | sort | awk -F/ '{print "file "$(NF)""}' > "$listfile"
  ffmpeg -r $fps -f concat -safe 0 -i "$listfile" -vcodec libx264 -b 5m -vf format=yuv420p "$out_video" && rm "$listfile"
else
  ffmpeg -framerate $fps -i $in_folder/$counter.png -vcodec libx264 -b 5m -vf format=yuv420p $out_video
fi
