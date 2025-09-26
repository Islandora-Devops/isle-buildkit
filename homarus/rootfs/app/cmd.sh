#!/usr/bin/env bash

set -eou pipefail

SOURCE_EXT="$1"
DESTINATION_EXT="$2"
ARGS=()
if [ "$#" -eq 3 ]; then
  IFS=' ' read -r -a ARGS <<< "$3"
fi

TMP_DIR=$(mktemp -d)
INPUT_FILE="$TMP_DIR/input.$SOURCE_EXT"
OUTPUT_FILE="$TMP_DIR/output.$DESTINATION_EXT"

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT
cat > "$INPUT_FILE"

if [ "$DESTINATION_EXT" = "mp4" ]; then
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
  "${cmd[@]}" >&2
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
  "${cmd[@]}" >&2
fi

if [ ! -f "$OUTPUT_FILE" ] || [ ! -s "$OUTPUT_FILE" ]; then
  echo "No outputfile created. Command must have failed" >&2
  exit 1
fi

cat "$OUTPUT_FILE"
