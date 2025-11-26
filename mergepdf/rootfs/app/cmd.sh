#!/usr/bin/env bash

set -eou pipefail

URL="$1/book-manifest"
TMP_DIR=$(mktemp -d)
I=0
MAX_THREADS=${MAX_THREADS:-5}
PIDS=()
RETRIES=3

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

# Function to download and process the image with retries
download_and_process() {
  local url="$1"
  local output_file="$2"
  local attempt=0

  while (( attempt < RETRIES )); do
    if curl -s "$url" | magick - -resize 1000x\> "$output_file" > /dev/null 2>&1; then
      return 0
    fi
    attempt=$(( attempt + 1 ))
    echo "Retrying ($attempt/$RETRIES) for $url..."
    sleep 1
  done

  echo "Failed to process $url after $RETRIES attempts." >&2
  return 1
}

# Iterate over all images in the IIIF manifest
URLS=$(curl -sf "$URL" | jq -r '.sequences[0].canvases[].images[0].resource."@id"' | awk -F '/' '{print $7}' | sed -e 's/%2F/\//g' -e 's/%3A/:/g')
while read -r URL; do
  # If we have reached the max thread limit, wait for any one job to finish
  if [ "${#PIDS[@]}" -ge "$MAX_THREADS" ]; then
    wait -n
    NEW_PIDS=()
    for pid in "${PIDS[@]}"; do
      if kill -0 "$pid" 2>/dev/null; then
        NEW_PIDS+=("$pid")
      fi
    done
    PIDS=("${NEW_PIDS[@]}")
  fi

  # Run each job in the background
  (
    local_img="$TMP_DIR/img_$I.jpg"

    # Download and resize the image with retry logic
    if ! download_and_process "$URL" "$local_img"; then
      exit 1
    fi

    # Make an OCR'd PDF from the image
    tesseract "$local_img" "$TMP_DIR/img_$I" pdf > /dev/null 2>&1
    rm "$local_img"
  ) &
  PIDS+=("$!")
  I="$(( I + 1))"
done <<< "$URLS"

FILES=()
for index in $(seq 0 $((I - 1))); do
  FILES+=("$TMP_DIR/img_${index}.pdf")
done

wait

# Make the node title the title of the PDF
TITLE=$(curl -L "$1?_format=json" | jq -r '.title[0].value' | sed 's/(/\\(/g; s/)/\\)/g')
echo "[ /Title ($TITLE)/DOCINFO pdfmark" >  "$TMP_DIR/metadata.txt"

gs -dBATCH \
  -dNOPAUSE \
  -dQUIET \
  -sDEVICE=pdfwrite \
  -dPDFA \
  -dNOOUTERSAVE \
  -dAutoRotatePages=/None \
  -sOutputFile="$TMP_DIR/ocr.pdf" \
  "${FILES[@]}" \
  "$TMP_DIR/metadata.txt"

# Instead of printing the PDF
# PUT it to the endpoint
NID=$(basename "$1")
BASE_URL=$(dirname "$1" | xargs dirname)
TID=$(curl -sf \
  -H "Authorization: $SCYLLARIDAE_AUTH" \
  "$BASE_URL/term_from_term_name?vocab=islandora_media_use&name=Original+File&_format=json" \
  | jq '.[0].tid[0].value')
curl \
  -H "Authorization: $SCYLLARIDAE_AUTH" \
  -H "Content-Type: application/pdf" \
  -H "Content-Location: private://derivatives/pc/pdf/$NID.pdf" \
  -T "$TMP_DIR/ocr.pdf" \
  "$1/media/document/$TID"

echo "OK"
