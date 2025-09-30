#!/bin/bash
# Usage: ./audio2flac_changefs.sh input_folder output_folder new_rate

in_dir="$1"
out_dir="$2"
new_rate="$3"

if [ -z "$in_dir" ] || [ -z "$out_dir" ] || [ -z "$new_rate" ]; then
  echo "Usage: $0 input_folder output_folder new_rate"
  exit 1
fi

mkdir -p "$out_dir"

for f in "$in_dir"/*; do
  [ -f "$f" ] || continue
  ext="${f##*.}"
  case "${ext,,}" in
    wav|flac|mp3|aac|ogg|m4a|wma|alac|aiff|opus)
  base="$(basename "$f")"
  name_noext="${base%.*}"
  out="$out_dir/$name_noext.flac"
  ffmpeg -y -i "$f" -af "asetrate=$new_rate" "$out"
      ;;
    *)
      echo "Skipping non-audio file: $f"
      ;;
  esac
done