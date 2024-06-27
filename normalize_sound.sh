#!/usr/bin/env bash
# usage: normalize_sound.sh [filepath]
## produces in the same filepath another normalised audio file with _norm.xxx


# The original filename is passed as the first argument
original_filename="$1"

# Extract the file extension
extension="${original_filename##*.}"

# Extract the filename without the extension
filename_without_extension="${original_filename%.*}"

# Construct the new filename by adding "_norm" before the extension
normalized_filename="${filename_without_extension}_norm.${extension}"

# Use FFmpeg to normalize the audio and save it with the new filename
ffmpeg -i "$original_filename" -af "loudnorm" "$normalized_filename"

echo "Normalized file saved as $normalized_filename"



