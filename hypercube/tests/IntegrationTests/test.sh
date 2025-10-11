#!/usr/bin/env bash

set -eou pipefail

# shellcheck disable=SC1091
source /usr/local/share/isle/utilities.sh

# The URL of the hypercube service
URL="http://localhost:8080"

# Wait for Hypercube service to be ready
wait_20x "$URL/healthcheck"


# Test 1: Image OCR from nginx-served file
echo "Testing image OCR..."

curl -s -o ocr.txt \
    --header "Accept: text/plain" \
    --header "Apix-Ldp-Resource: http://nginx/test-image.jpg" \
    "$URL"

if grep -q "Pyrases" ocr.txt; then
    echo "✓ Image OCR as expected"
else
    echo "✗ Failed to OCR image correctly"
    echo "Got:"
    cat ocr.txt
    exit 1
fi

# Test 2: PDF OCR from POST data
echo "Testing PDF OCR..."

curl -s -o ocr.txt \
    --header "Accept: text/plain" \
    --header "Content-Type: application/pdf" \
    --header "Apix-Ldp-Resource: http://nginx/test.pdf" \
    "$URL"

if grep -q "One time I was ridin' along on the mule" ocr.txt; then
    echo "✓ PDF OCR as expected"
else
    echo "✗ Failed to OCR PDF correctly"
    echo "Got:"
    cat ocr.txt
    exit 1
fi

# Clean up
rm ocr.txt

echo "All tests passed!"
exit 0
