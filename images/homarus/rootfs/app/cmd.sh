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
  # shellcheck disable=SC2046
  tar -czf "$TMP_DIR/hls.tar.gz" -C "$TMP_DIR" $(cd "$TMP_DIR" ; echo ./*.ts)

  BASE_URL=$(dirname "$NODE_URL" | xargs dirname)
  TID=$(curl -sf \
             -H "Authorization: $SCYLLARIDAE_AUTH" \
             "$BASE_URL/term_from_term_name?vocab=islandora_media_use&name=Intermediate+File&_format=json" | \
        jq -e '.[0].tid[0].value')
  curl -s \
    -H "Authorization: $SCYLLARIDAE_AUTH" \
    -H "Content-Type: application/gzip" \
    -H "Content-Location: private://derivatives/hls/$NID/hls.tar.gz" \
    -T "$TMP_DIR/hls.tar.gz" \
    "$NODE_URL/media/file/$TID"
fi

cat "$OUTPUT_FILE"
