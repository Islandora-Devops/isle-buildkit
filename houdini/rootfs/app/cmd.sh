#!/usr/bin/env bash
set -eou pipefail

SOURCE_EXT="$1"
DEST_EXT="$2"
ARGS=()
if [ "$#" -gt 2 ]; then
  ARGS=("${@:3}")
fi

OUTPUT=$(mktemp -u /tmp/output-XXXXXX)
OUTPUT="$OUTPUT.$DEST_EXT"

# shellcheck disable=SC2317
cleanup() {
  rm -rf "$OUTPUT"
}
trap cleanup EXIT

INPUT="-"
if [ "$SOURCE_EXT" = "pdf" ]; then
  INPUT="pdf:-[0]"
elif [ "$SOURCE_EXT" = "tiff" ]; then
  INPUT="-[0]"
fi

magick "$INPUT" "${ARGS[@]}" "$OUTPUT"

# make sure we have a valid image
EXIT_CODE=0
timeout 5 identify -verbose "$OUTPUT" > /dev/null 2>&1 || EXIT_CODE=$?
if [ $EXIT_CODE != 1 ]; then
  cat "$OUTPUT"
  exit 0
fi

exit "$EXIT_CODE"
