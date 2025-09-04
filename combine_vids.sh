#!/bin/bash
# Usage: ./combine_vids.sh video1.mp4 video2.mp4 ... videoN.mp4 output.mp4
# If videos have different codecs/resolutions, ffmpeg may fail; in that case, re-encoding is required

# Get the last argument as output file name
out="${@: -1}"

# Create a temporary file list
tmpfile=$(mktemp)
for f in "${@:1:$(($#-1))}"; do
    echo "file '$PWD/$f'" >> "$tmpfile"
done

# Concatenate without re-encoding
ffmpeg -f concat -safe 0 -i "$tmpfile" -c copy "$out" || (echo -e "\033[31mFailed to concatenate without re-encoding. Trying with re-encoding...\033[0m"; ffmpeg -f concat -safe 0 -i "$tmpfile" "$out";)

# Clean up
rm "$tmpfile"