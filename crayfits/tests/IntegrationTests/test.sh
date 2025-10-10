#!/usr/bin/env bash

set -eou pipefail

# shellcheck disable=SC1091
source /usr/local/share/isle/utilities.sh

# The URL of the crayfits service
URL="http://localhost:8080"

# Wait for Houdini service to be ready
wait_20x "$URL/healthcheck"

# Install file utility for checking file type
apk update && apk add file

# Test: Generate PNG thumbnail from PDF served by nginx
echo "Testing PNG thumbnail generation from PDF..."

curl -s -o fits.xml \
    --header "Accept: application/xml" \
    --header "Content-Type: application/pdf" \
    --header "Apix-Ldp-Resource: http://nginx/test.pdf" \
    "$URL"

# check the md5 of that file exists in the FITS XML
grep c4b7c84671428767e3b0d9193c9c444b fits.xml | grep -q md5checksum && echo "FITS ran successfully"

rm fits.xml

echo "All tests passed!"
exit 0
