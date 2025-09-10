#!/usr/bin/env bash
# audio2spectrogram-thumbnails.sh
#
# This script processes audio files in a specified folder, generating spectrogram images
# and embedding them as album covers into the audio files. It supports various audio formats
# and allows customization of spectrogram parameters.
#
# Usage:
#   ./audio2spectrogram-thumbnails.sh <audio_folder> [options]
#
# Arguments:
#   <audio_folder>  Path to the directory containing audio files (required).
#
# Options:
#   --nfft N        FFT size for spectrogram (default: 4096). #BUG
#   --size WxH      Output image size (default: 1920x1080).
#   --legend 0|1    Show legend on spectrogram (default: 1).
#   --fscale lin|log Frequency scale (default: log).
#   --wav2mp3       Convert WAV files to MP3 instead of FLAC (default: FLAC).
#   --outdir PATH   Output directory for processed audio (default: <audio_folder>/_with_covers).
#   --wavespic      Generate time series image instead of spectrogram.
#   --timeseries    Same as --wavespic; generate time series image.
# Output:
#   - Spectrogram images are saved in <audio_folder>/_spectrograms or <outdir>/_spectrograms.
#   - Processed audio files with embedded covers are saved in <audio_folder>/_with_covers or <outdir>.
#
# Supported formats: MP3, WAV, FLAC, M4A, OGG, OPUS, AAC.
# Requires: ffmpeg (and optionally opustags for OPUS cover embedding).
#
# Examples:
#   ./audio2spectrogram-thumbnails.sh /path/to/audio --size 1280x720 --fscale lin
#   ./audio2spectrogram-thumbnails.sh /path/to/audio --wav2mp3 --outdir /path/to/output
#
# Notes:
#   - The script uses ffmpeg's showspectrumpic filter for spectrograms.
#   - For OPUS files, ffmpeg embedding may not work in all players; consider using opustags.
#   - Original files are not modified; copies are created in the output directory.
set -euo pipefail

usage() {
  echo "Usage: $0 <audio_folder> [--nfft N] [--size WxH] [--legend 0|1] [--fscale lin|log] [--wav2mp3] [--outdir PATH] [--wavespic|--timeseries]"
  echo "Defaults: --nfft 4096 --size 1920x1080 --legend 1 --fscale log --outdir <audio_folder>/_with_covers"
  echo "  --wavespic      Plot time series image using showwavespic instead of spectrogram."
  echo "  --timeseries    Same as --wavespic; plot time series image."
  exit 1
}

[[ $# -lt 1 ]] && usage
IN_DIR="$1"; shift || true

# Defaults
NFFT=4096 #BUG
SIZE="1920x1080"
LEGEND=1
FSCALE="log"
WAV2MP3=0
OUT_AUDIO=""
WAVESPIC=0

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --nfft|-n) NFFT="$2"; shift 2;;
    --size|-s) SIZE="$2"; shift 2;;
    --legend)  LEGEND="$2"; shift 2;;
    --fscale)  FSCALE="$2"; shift 2;;
    --wav2mp3) WAV2MP3=1; shift;;
    --outdir) OUT_AUDIO="$2"; shift 2;;
  --wavespic|--timeseries) WAVESPIC=1; shift;;
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

  if [[ "$WAVESPIC" == "1" ]]; then
    echo ">> Time series image: $base"
    if ! ffmpeg -hide_banner -loglevel error -y -i "$f" \
      -lavfi "showwavespic=s=${SIZE}:split_channels=0" \
      "$img"; then
      echo "[ERROR] ffmpeg failed for: $base"
      continue
    fi
  else
    echo ">> Spectrogram: $base"
    if ! ffmpeg -hide_banner -loglevel error -y -i "$f" \
      -lavfi "showspectrumpic=s=${SIZE}:legend=${LEGEND}:fscale=${FSCALE}" \
      "$img"; then
      echo "[ERROR] ffmpeg failed for: $base"
      continue
    fi
  fi

  echo ">> Embedding cover: $base"
  case "$lc_ext" in
    wav)
      if [[ "$WAV2MP3" == "1" ]]; then
        # Convert WAV to MP3, embed cover
        if ! ffmpeg -hide_banner -loglevel error -y -i "$f" -i "$img" \
          -map 0 -map 1 -c:a libmp3lame -b:a 320k -c:v:1 png \
          -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" \
          -disposition:v attached_pic \
          "$out"; then
          echo "[ERROR] ffmpeg failed for: $base (WAV->MP3 with cover)"
          # Try conversion without cover
          if ! ffmpeg -hide_banner -loglevel error -y -i "$f" -c:a libmp3lame -b:a 320k "$out"; then
            echo "[ERROR] ffmpeg failed for: $base (WAV->MP3 without cover)"
            continue
          fi
        fi
      else
        # Convert WAV to FLAC, re-encode audio, embed cover
        if ! ffmpeg -hide_banner -loglevel error -y -i "$f" -i "$img" \
          -map 0 -map 1 -c:a flac -c:v:1 png \
          -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" \
          -disposition:v attached_pic \
          "$out"; then
          echo "[ERROR] ffmpeg failed for: $base (WAV->FLAC with cover)"
          # Try conversion without cover
          if ! ffmpeg -hide_banner -loglevel error -y -i "$f" -c:a flac "$out"; then
            echo "[ERROR] ffmpeg failed for: $base (WAV->FLAC without cover)"
            continue
          fi
        fi
      fi
      ;;
    mp3|m4a|aac|flac|ogg)
      # Generic “attached_pic” approach works for MP3/M4A/FLAC and many OGG/Vorbis files.
      if ! ffmpeg -hide_banner -loglevel error -y -i "$f" -i "$img" \
        -map 0 -map 1 -c copy \
        -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" \
        -disposition:v attached_pic \
        "$out"; then
        echo "[ERROR] ffmpeg failed for: $base ($lc_ext with cover)"
        # Try conversion without cover
        if ! ffmpeg -hide_banner -loglevel error -y -i "$f" -c copy "$out"; then
          echo "[ERROR] ffmpeg failed for: $base ($lc_ext without cover)"
          continue
        fi
      fi
      ;;
    opus)
      # Opus cover embedding can be finicky in ffmpeg; many use opustags (if available).
      # Try with ffmpeg first; if your player doesn’t show covers, install opustags and run:
      #   opustags --set-cover "$img" "$out" -i
      if ! ffmpeg -hide_banner -loglevel error -y -i "$f" -i "$img" \
        -map 0 -map 1 -c copy \
        -metadata:s:v title="Album cover" -metadata:s:v comment="Cover (front)" \
        -disposition:v attached_pic \
        "$out"; then
        echo "[ERROR] ffmpeg failed for: $base (opus with cover)"
        # Try conversion without cover
        if ! ffmpeg -hide_banner -loglevel error -y -i "$f" -c copy "$out"; then
          echo "[ERROR] ffmpeg failed for: $base (opus without cover)"
          cp -f "$f" "$out"
          echo "   (Opus cover via ffmpeg may not be supported by your tools; consider 'opustags'.)"
          continue
        fi
        echo "   (Opus cover via ffmpeg may not be supported by your tools; consider 'opustags'.)"
        continue
      fi
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
