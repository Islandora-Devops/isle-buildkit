#!/usr/bin/env bash

set -eou pipefail

# shellcheck disable=SC1091
source /usr/local/share/isle/utilities.sh

# The URL of the homarus service
URL="http://localhost:8080"

# Wait for Homarus service to be ready
wait_20x "$URL/healthcheck"

# Install file utility for checking file type
apk update && apk add file

# Test video thumbnail generation from local test video
echo "Testing video thumbnail generation..."

curl -s -o image.jpg \
    --header "X-Islandora-Args: -ss 00:00:01.000 -frames 1 -vf scale=240:-2" \
    --header "Accept: image/jpeg" \
    --header "Apix-Ldp-Resource: http://nginx/test-video.mp4" \
    "$URL"

# Verify the output is a JPEG image
if file image.jpg | grep -q JPEG; then
    echo "✓ Thumbnail created successfully"
else
    echo "✗ Failed to create JPEG thumbnail"
    file image.jpg
    exit 1
fi

# Clean up
rm image.jpg

echo "All tests passed!"
exit 0
