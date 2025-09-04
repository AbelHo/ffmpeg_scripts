#!/bin/bash
# Usage: ./add_subtitle.sh input.mp4 subtitle.srt output.mp4 [--cpu]

if [[ $# -eq 0 ]]; then
    echo "Usage: ./add_subtitle.sh input.mp4 subtitle.srt output.mp4 [--cpu]"
    echo "  input.mp4: Input video file (e.g., .mp4, .avi)"
    echo "  subtitle.srt: Subtitle file (e.g., .srt)"
    echo "  output.mp4: Output video file (e.g., .mp4)"
    echo "  --cpu: Optional flag to force CPU encoding instead of auto-detecting GPU"
    echo ""
    echo "This script adds subtitles to a video using ffmpeg."
    echo "It automatically detects and uses NVIDIA or Apple Metal encoder if available."
    echo "Otherwise, it defaults to CPU encoding."
    exit 1
fi

input="$1"
subtitle="$2"
output="$3"
force_cpu=0

if [[ "$4" == "--cpu" ]]; then
    force_cpu=1
fi

if [[ $force_cpu -eq 1 ]]; then
    encoder=""
    echo "Flag set: Forcing CPU encoder"
elif command -v nvidia-smi &>/dev/null && ffmpeg -encoders 2>/dev/null | grep -q h264_nvenc; then
    encoder="-c:v h264_nvenc -preset p6 -profile:v high -tune hq -rc vbr -cq 26 -b:v 0"
    echo "Using NVIDIA GPU encoder (h264_nvenc)"
elif [[ "$OSTYPE" == "darwin"* ]] && ffmpeg -encoders 2>/dev/null | grep -q h264_videotoolbox; then
    encoder="-c:v h264_videotoolbox"
    echo "Using Apple Metal encoder (h264_videotoolbox)"
else
    encoder=""
    echo "Using CPU encoder"
fi

ffmpeg -i "$input" -vf subtitles="$subtitle" -c:a copy $encoder "$output"