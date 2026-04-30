#!/usr/bin/env bash

set -eou pipefail

URL="$1/book-manifest"
TMP_DIR=$(mktemp -d)
I=0
MAX_THREADS=${MAX_THREADS:-5}
MAX_WIDTH=${MAX_WIDTH:-2000}
PIDS=()
RETRIES=3

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

download_and_process() {
  local img_url="$1"
  local width="$2"
  local output_file="$3"
  local attempt=0
  local download_url

  if (( width > MAX_WIDTH )); then
    download_url="${img_url}/full/${MAX_WIDTH},/0/default.jpg"
  elif [[ "$img_url" == *"/iiif/3/"* ]]; then
    download_url="${img_url}/full/max/0/default.jpg"
  else
    download_url="${img_url}/full/full/0/default.jpg"
  fi

  while (( attempt < RETRIES )); do
    if curl -sf "$download_url" -o "$output_file"; then
      return 0
    fi
    attempt=$(( attempt + 1 ))
    echo "Retrying ($attempt/$RETRIES) for $download_url..." >&2
    sleep 1
  done

  echo "Failed to process $download_url after $RETRIES attempts." >&2
  return 1
}

mapfile -t ENTRIES < <(curl -sf "$URL" | \
  jq -r '.sequences[0].canvases[] |
    (.images[0].resource.service["@id"]) + " " + (.width | tostring)')

for ENTRY in "${ENTRIES[@]}"; do
  IMG_URL=$(echo "$ENTRY" | cut -d' ' -f1)
  WIDTH=$(echo "$ENTRY" | cut -d' ' -f2)

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

  (
    local_img="$TMP_DIR/img_$I.jpg"

    if ! download_and_process "$IMG_URL" "$WIDTH" "$local_img"; then
      exit 1
    fi

    tesseract "$local_img" "$TMP_DIR/img_$I" pdf > /dev/null 2>&1
    rm "$local_img"
  ) &
  PIDS+=("$!")
  I="$(( I + 1))"
done

FILES=()
for index in $(seq 0 $((I - 1))); do
  FILES+=("$TMP_DIR/img_${index}.pdf")
done

wait

TITLE=$(curl -L "$1?_format=json" | jq -r '.title[0].value' | sed 's/(/\\(/g; s/)/\\)/g')
echo "[ /Title ($TITLE)/DOCINFO pdfmark" > "$TMP_DIR/metadata.txt"

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

NID=$(basename "$1")
BASE_URL=$(dirname "$1" | xargs dirname)
TID=$(curl -sf \
  -H "Authorization: $SCYLLARIDAE_AUTH" \
  "$BASE_URL/term_from_term_name?vocab=islandora_media_use&name=Original+File&_format=json" \
  | jq '.[0].tid[0].value')

YEAR=$(date +"%Y")
MONTH=$(date +"%m")
curl \
  -H "Authorization: $SCYLLARIDAE_AUTH" \
  -H "Content-Type: application/pdf" \
  -H "Content-Location: ${URI_SCHEME}://derivatives/$YEAR/$MONTH/pc/$NID.pdf" \
  -T "$TMP_DIR/ocr.pdf" \
  "$1/media/document/$TID"

echo "OK"
