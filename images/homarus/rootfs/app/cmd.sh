#!/usr/bin/env bash

set -eou pipefail

SOURCE_EXT="$1"
DESTINATION_EXT="$2"
NODE_URL="$3"
NID=$(basename "$NODE_URL")
ARGS=()
if [[ ! $NODE_URL =~ ^http ]]; then
  # If third arg doesn't start with http
  # source URI was blank
  # so include third arg in the ARGS
  ARGS=("${@:3}")
elif [ "$#" -gt 3 ]; then
  ARGS=("${@:4}")
fi

TMP_DIR=$(mktemp -d)
INPUT_FILE="$TMP_DIR/input.$SOURCE_EXT"
OUTPUT_FILE="$TMP_DIR/output.$DESTINATION_EXT"

get_media_type() {
  local file="$1"
  if ffprobe -v error -select_streams v:0 -show_entries stream=codec_type -of default=nw=1:nk=1 "$file" 2>/dev/null | grep -q video; then
    echo "video"
  else
    echo "audio"
  fi
}

retry_until_success() {
    local command_to_run=("$@")
    local MAX_RETRIES=5
    local SLEEP_INCREMENT=10
    local RETRIES=0

    while true; do
        exit_code=0
        timeout 300 "${command_to_run[@]}" || exit_code=$?

        if [ "$exit_code" -eq 0 ]; then
            return 0
        fi

        RETRIES=$((RETRIES + 1))

        if [ "$RETRIES" -ge "$MAX_RETRIES" ]; then
            echo "FAILURE: Command '${command_to_run[*]}' failed after $MAX_RETRIES attempts (Last exit code: $exit_code)." >&2
            return 1
        fi

        local SLEEP=$(( SLEEP_INCREMENT * RETRIES ))
        echo "Command '${command_to_run[*]}' failed (Exit code: $exit_code). Retrying in $SLEEP seconds... (Attempt $RETRIES/$MAX_RETRIES)" >&2
        sleep "$SLEEP"
    done
}

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT
cat > "$INPUT_FILE"

if [ "$DESTINATION_EXT" = "m3u8" ]; then
  OUTPUT_FILE="$TMP_DIR/$NID.m3u8"
  cmd=(
    ffmpeg -loglevel error
    -f "$SOURCE_EXT"
    -i "$INPUT_FILE"
    "${ARGS[@]}"
    -profile:v baseline -level 3.0
    -s 640x360
    -start_number 0
    -hls_time 10
    -hls_list_size 0
    -hls_segment_filename "${TMP_DIR}/$NID_%d.ts"
    -b:v 800k
    -maxrate 800k
    -bufsize 1200k
    -f hls
    "$OUTPUT_FILE"
  )
  echo "${cmd[@]}" >&2
  "${cmd[@]}" > /dev/null
elif [ "$DESTINATION_EXT" = "mp4" ]; then
  cmd=(
    ffmpeg -loglevel error
    -f "$SOURCE_EXT"
    -i "$INPUT_FILE"
    "${ARGS[@]}"
    -vcodec libx264
    -preset medium
    -acodec aac
    -strict -2
    -ab 128k
    -ac 2
    -async 1
    -movflags faststart
    -y
    -f "$DESTINATION_EXT"
    "$OUTPUT_FILE"
  )
  echo "${cmd[@]}" >&2
  "${cmd[@]}" > /dev/null
elif [ "$DESTINATION_EXT" = "jpg" ] || [ "$DESTINATION_EXT" = "png" ] ; then
  cmd=(
    ffmpeg -loglevel error
    -f "$SOURCE_EXT"
    -i "$INPUT_FILE"
  )

  # Add audio visualization for image output from audio input
  if [[ "$SOURCE_EXT" =~ ^(mp3|wav|flac|aac|ogg|m4a)$ ]]; then
    cmd+=(-filter_complex "showwavespic=colors=#FFC627" -frames:v 1)
  fi

  cmd+=(
    "${ARGS[@]}"
    -f image2pipe
    -vcodec "${DESTINATION_EXT/#jpg/mjpeg}"
    "$OUTPUT_FILE"
  )
  echo "${cmd[@]}" >&2
  "${cmd[@]}" > /dev/null
else
  cmd=(
    ffmpeg -loglevel error
    -f "$SOURCE_EXT"
    -i "$INPUT_FILE"
    "${ARGS[@]}"
    -y
    -f "$DESTINATION_EXT"
    "$OUTPUT_FILE"
  )
  echo "${cmd[@]}" >&2
  "${cmd[@]}" > /dev/null
fi

if [ ! -f "$OUTPUT_FILE" ] || [ ! -s "$OUTPUT_FILE" ]; then
  exit 1
fi

if [ "$DESTINATION_EXT" = "m3u8" ]; then
  BASE_URL=$(dirname "$NODE_URL" | xargs dirname)
  pushd "$TMP_DIR"
  for file in *.ts; do
    # Check if any .ts files exist (handles case where glob doesn't match)
    [ -e "$file" ] || continue
    
    echo "Processing: $file" >&2
    
    bundle=$(get_media_type "$file")
    retry_until_success \
      curl -sf \
        -X POST \
        -H "Authorization: $SCYLLARIDAE_AUTH" \
        -H "Content-Type: application/octet-stream" \
        -H "Content-Disposition: file; filename=\"$file\"" \
        --data-binary "@$file" \
        "$BASE_URL/file/upload/media/${bundle}/field_additional_files"
  done
fi

cat "$OUTPUT_FILE"
