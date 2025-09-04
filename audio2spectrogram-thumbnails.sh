#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 <audio_folder> [--nfft N] [--size WxH] [--legend 0|1] [--fscale lin|log] [--wav2mp3] [--outdir PATH]"
  echo "Defaults: --nfft 4096 --size 1920x1080 --legend 1 --fscale log --outdir <audio_folder>/_with_covers"
  exit 1
}

[[ $# -lt 1 ]] && usage
IN_DIR="$1"; shift || true

# Defaults
NFFT=4096
SIZE="1920x1080"
LEGEND=1
FSCALE="log"
WAV2MP3=0
OUT_AUDIO=""

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --nfft|-n) NFFT="$2"; shift 2;;
    --size|-s) SIZE="$2"; shift 2;;
    --legend)  LEGEND="$2"; shift 2;;
    --fscale)  FSCALE="$2"; shift 2;;
    --wav2mp3) WAV2MP3=1; shift;;
    --outdir) OUT_AUDIO="$2"; shift 2;;
    *) echo "Unknown arg: $1"; usage;;
  esac
done

OUT_IMG="$IN_DIR/_spectrograms"
if [[ -z "$OUT_AUDIO" ]]; then
  OUT_AUDIO="$IN_DIR/_with_covers"
  OUT_IMG="$IN_DIR/_spectrograms"
else
  OUT_IMG="$OUT_AUDIO/_spectrograms"
fi
mkdir -p "$OUT_IMG" "$OUT_AUDIO"

shopt -s nullglob nocaseglob
for f in "$IN_DIR"/*.{mp3,wav,flac,m4a,ogg,opus,aac}; do
  [[ -f "$f" ]] || continue
  base="$(basename "$f")"
  stem="${base%.*}"
  ext="${base##*.}"
  lc_ext="$(printf '%s' "$ext" | tr '[:upper:]' '[:lower:]')"
  img="$OUT_IMG/$stem.png"
  # If wav, output as flac or mp3 depending on option
  if [[ "$lc_ext" == "wav" ]]; then
    if [[ "$WAV2MP3" == "1" ]]; then
      out="$OUT_AUDIO/$stem.mp3"
    else
      out="$OUT_AUDIO/$stem.flac"
    fi
  else
    out="$OUT_AUDIO/$base"
  fi

  echo ">> Spectrogram: $base"
  ffmpeg -hide_banner -loglevel error -y -i "$f" \
    -lavfi "showspectrumpic=s=${SIZE}:legend=${LEGEND}:fscale=${FSCALE}" \
    "$img"

  echo ">> Embedding cover: $base"
  case "$lc_ext" in
    wav)
      if [[ "$WAV2MP3" == "1" ]]; then
        # Convert WAV to MP3, embed cover
        ffmpeg -hide_banner -loglevel error -y -i "$f" -i "$img" \
          -map 0 -map 1 -c:a libmp3lame -b:a 320k -c:v:1 png \
          -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" \
          -disposition:v attached_pic \
          "$out"
      else
        # Convert WAV to FLAC, re-encode audio, embed cover
        ffmpeg -hide_banner -loglevel error -y -i "$f" -i "$img" \
          -map 0 -map 1 -c:a flac -c:v:1 png \
          -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" \
          -disposition:v attached_pic \
          "$out"
      fi
      ;;
    mp3|m4a|aac|flac|ogg)
      # Generic “attached_pic” approach works for MP3/M4A/FLAC and many OGG/Vorbis files.
      ffmpeg -hide_banner -loglevel error -y -i "$f" -i "$img" \
        -map 0 -map 1 -c copy \
        -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" \
        -disposition:v attached_pic \
        "$out"
      ;;
    opus)
      # Opus cover embedding can be finicky in ffmpeg; many use opustags (if available).
      # Try with ffmpeg first; if your player doesn’t show covers, install opustags and run:
      #   opustags --set-cover "$img" "$out" -i
      ffmpeg -hide_banner -loglevel error -y -i "$f" -i "$img" \
        -map 0 -map 1 -c copy \
        -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" \
        -disposition:v attached_pic \
        "$out" || {
          cp -f "$f" "$out"
          echo "   (Opus cover via ffmpeg may not be supported by your tools; consider 'opustags'.)"
        }
      ;;
    *)
      # Fallback: just copy original if type not handled
      cp -f "$f" "$out"
      ;;
  esac
done

echo "Done."
echo "Images in:   $OUT_IMG"
echo "Audio in:    $OUT_AUDIO"
