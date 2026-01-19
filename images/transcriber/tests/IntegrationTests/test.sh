#!/usr/bin/env bash

set -eou pipefail

cleanup() {
  if [ -f transcription.vtt ]; then
    rm -rf transcription.vtt
  fi
}
trap cleanup EXIT

# shellcheck disable=SC1091
source /usr/local/share/isle/utilities.sh

URL="http://localhost:8080"
wait_20x "$URL/healthcheck"

echo "Testing audio transcription..."
curl -s -o transcription.vtt \
    --header "Accept: text/vtt" \
    --header "Apix-Ldp-Resource: http://nginx/jfk.mp3" \
    "$URL"

if grep -i "ask not what your country can do for you, ask what you can do for your country" transcription.vtt; then
    echo "✓ Transcription created successfully"
else
    echo "✗ Failed to create transcription thumbnail"
    cat transcription.vtt
    exit 1
fi

echo "All tests passed!"
exit 0
