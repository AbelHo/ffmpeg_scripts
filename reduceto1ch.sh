#!/bin/bash
# Usage: ./to_mono.sh input_folder output_folder

in_dir="$1"
out_dir="$2"

if [ -z "$in_dir" ] || [ -z "$out_dir" ]; then
  echo "Usage: $0 input_folder output_folder"
  exit 1
fi

mkdir -p "$out_dir"

for f in "$in_dir"/*; do
  [ -f "$f" ] || continue
  ext="${f##*.}"
  base="$(basename "$f")"
  out="$out_dir/$base"
  codec=$(ffprobe -v error -select_streams a:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$f")
  channels=$(ffprobe -v error -select_streams a:0 -show_entries stream=channels -of default=noprint_wrappers=1:nokey=1 "$f")
  if [ "$channels" -eq 1 ]; then
    ffmpeg -y -i "$f" -c:a copy "$out"
  else
    ffmpeg -y -i "$f" -ac 1 -c:a "$codec" "$out"
  fi
done