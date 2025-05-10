#!/usr/bin/env bash

set -eou pipefail

# shellcheck disable=SC1091
source /usr/local/share/isle/utilities.sh

wait_20x "http://localhost:8182"

apk update && apk add perl-uri imagemagick

for IMG_PATH in /images/*; do
  IMG=$(basename "$IMG_PATH")
  ENCODED=$(perl -MURI::Escape -e 'print uri_escape($ARGV[0])' "$IMG")
  echo "Checking $IMG => $ENCODED"
  curl -sf http://localhost:8182/iiif/2/http%3A%2F%2Fnginx%2f$ENCODED/info.json | jq -e .width
  curl -sf \
    -o default.jpg \
    http://localhost:8182/iiif/2/http%3A%2F%2Fnginx%2f$ENCODED/full/1,/0/default.jpg
  identify default.jpg | grep JPEG
done

exit 0
