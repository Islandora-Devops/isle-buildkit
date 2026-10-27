#!/usr/bin/env bash

set -eou pipefail

# shellcheck disable=SC1091
source /usr/local/share/isle/utilities.sh

# The URL of the houdini service
URL="http://localhost:8080"

# Wait for Houdini service to be ready
wait_20x "$URL/healthcheck"

# Install file utility for checking file type
apk update && apk add file

# Test: Generate PNG thumbnail from PDF served by nginx
echo "Testing PNG thumbnail generation from PDF..."

curl -s -o image.png \
    --header "Accept: image/png" \
    --header "Content-Type: application/pdf" \
    --header "Apix-Ldp-Resource: http://nginx/test.pdf" \
    "$URL"

if file image.png | grep -q PNG; then
    echo "✓ PNG thumbnail created from PDF"
else
    echo "✗ Failed to create PNG thumbnail"
    file image.png
    exit 1
fi

# Clean up
rm image.png

# Test: Generate JPEG from an animated GIF served by nginx
echo "Testing JPEG generation from animated GIF..."

curl -s -o image.jpg \
    --header "Accept: image/jpeg" \
    --header "Content-Type: image/gif" \
    --header "Apix-Ldp-Resource: http://nginx/animated.gif" \
    "$URL"

if file image.jpg | grep -q JPEG; then
    echo "✓ JPEG created from animated GIF"
else
    echo "✗ Failed to create JPEG from animated GIF"
    file image.jpg
    exit 1
fi

rm image.jpg

echo "All tests passed!"
exit 0
