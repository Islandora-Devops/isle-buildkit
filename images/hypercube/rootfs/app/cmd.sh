#!/usr/bin/env bash

set -eou pipefail

SOURCE_EXT="$1"
ARGS=()
if [ "$#" -gt 1 ]; then
  ARGS=("${@:2}")
fi

MAX_SIZE="${HYPERCUBE_MAX_SIZE:-8000}"

TMP_DIR=$(mktemp -d)

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

INPUT="$TMP_DIR/input.$SOURCE_EXT"
cat > "$INPUT"

# Convert each page to 8-bit greyscale with libvips, since leptonica can not
# read tiled TIFF, 16-bit JP2, float TIFF or HEIF
PAGES=$(vipsheader -f n-pages "$INPUT" 2>/dev/null || echo 1)
PREV_WIDTH=0
for ((i = 0; i < PAGES; i++)); do
  PAGE="${INPUT}[page=$i]"
  if [ "$PAGES" = 1 ]; then
    PAGE="$INPUT"
  fi

  # Stop at the reduced levels of a pyramid TIFF
  WIDTH=$(vipsheader -f width "$PAGE" 2>/dev/null || echo 0)
  if [ "$i" -gt 0 ] && [ "$WIDTH" -le $((PREV_WIDTH / 2 + 1)) ]; then
    break
  fi
  PREV_WIDTH="$WIDTH"

  vips thumbnail "$PAGE" "$TMP_DIR/thumb.v" "$MAX_SIZE" --height "$MAX_SIZE" --size down || break
  vips colourspace "$TMP_DIR/thumb.v" "$TMP_DIR/grey.v" b-w || break
  vips flatten "$TMP_DIR/grey.v" "$TMP_DIR/page-$i.pgm" --background 255 || break
  echo "$TMP_DIR/page-$i.pgm" >> "$TMP_DIR/pages.txt"
done

# tesseract treats a text file as a list of images
if [ -f "$TMP_DIR/pages.txt" ]; then
  INPUT="$TMP_DIR/pages.txt"
else
  echo "libvips could not read input, passing it to tesseract as is" 1>&2
fi

tesseract "$INPUT" stdout "${ARGS[@]}"
