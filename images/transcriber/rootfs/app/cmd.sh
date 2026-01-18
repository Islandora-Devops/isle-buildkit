#!/usr/bin/env bash

set -eou pipefail

INPUT_URL="$1"
EXT="${INPUT_URL##*.}"
BASE_URL=$(dirname "$INPUT_URL")

input_temp=$(mktemp /tmp/whisper-input-XXXXXX)
output_file="${input_temp}_16khz.wav"

cleanup() {
  rm -f "$input_temp" "$input_temp.vtt" "$output_file"
}

trap cleanup EXIT

# all A/V files need to be 16-bit Little-Endian PCM
if [[ "$EXT" == "m3u8" ]]; then
  # For m3u8, replace relative *.ts URLs with absolute URL and stream with HLS demuxer
  cat | sed 's|^\([^#].*\)|'"$BASE_URL"'/\1|' | \
    ffmpeg -hide_banner -loglevel error \
    -protocol_whitelist https,fd,tls,tcp,pipe \
    -f hls -i - -vn -acodec pcm_s16le \
    -ar 16000 -ac 2 "$output_file" > /dev/null 2>&1
else
  # For other formats, pass input URL directly to ffmpeg to convert to wav
  ffmpeg -hide_banner -loglevel error \
    -i "$INPUT_URL" -vn -acodec pcm_s16le \
    -ar 16000 -ac 2 "$output_file" > /dev/null 2>&1
fi

if [ -n "${CUDA_VISIBLE_DEVICES:-}" ]; then
  best_gpu=$(nvidia-smi --query-gpu=memory.free --format=csv,noheader,nounits | \
    awk '{print $1}' | nl -v 0 | sort -k2 -nr | head -n"$WHISPER_PROCESSORS" | awk '{print $1}' | tr '\n' ',' | sed 's/,$/\n/')
  export CUDA_VISIBLE_DEVICES=$best_gpu
fi

/app/whisper-cli \
  -t "$WHISPER_THREADS" \
  -p "$WHISPER_PROCESSORS" \
  -m /app/models/ggml-medium.en.bin \
  --output-vtt \
  -f "$output_file" \
  --output-file "$input_temp" > /dev/null 2>&1 || true

STATUS=$(grep -q WEBVTT "$input_temp.vtt" || echo "FAIL")
if [ "$STATUS" != "FAIL" ]; then
  cat "$input_temp.vtt"
else
  exit 1
fi
