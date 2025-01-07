#!/usr/bin/env bash

set -eou pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <APP_ID> <INSTALL_ID> <PRIVATE_KEY_FILE_PATH>"
  echo "e.g. ./ci/fetch-app-token.sh 123 456 /path/to/priv.pem"
  exit 1
fi

APP_ID="$1"
INSTALL_ID="$2"
PRIVATE_KEY_FILE="$3"

if [[ ! -f "$PRIVATE_KEY_FILE" ]]; then
  echo "Error: Private key file not found: $PRIVATE_KEY_FILE"
  exit 1
fi

b64url_encode() {
  base64 -w 0 | tr -d '=' | tr '/+' '_-' | tr -d '\n'
}

JWT_HEADER=$(jq -n \
    '{
        "alg": "RS256",
        "typ": "JWT"
     }' | b64url_encode
)

NOW=$(date +%s)
EXPIRATION=$((NOW + 300)) # 5m
JWT_PAYLOAD=$(jq -n \
    --argjson iat "$NOW" \
    --argjson exp "$EXPIRATION" \
    --arg     iss "$APP_ID" \
    '{
        "iat": $iat,
        "exp": $exp,
        "iss": $iss
    }' | b64url_encode
)

JWT_SIGNATURE=$(echo -n "${JWT_HEADER}.${JWT_PAYLOAD}" \
  | openssl dgst -sha256 -sign "$PRIVATE_KEY_FILE" \
  | b64url_encode
)

JWT="${JWT_HEADER}.${JWT_PAYLOAD}.${JWT_SIGNATURE}"

RESPONSE=$(curl -s -X POST \
  "https://api.github.com/app/installations/${INSTALL_ID}/access_tokens" \
  -H "Authorization: Bearer $JWT" \
  -H "Accept: application/vnd.github+json")

if echo "$RESPONSE" | jq -e '.token' > /dev/null; then
  # this token has a TTL of 60m
  # see https://docs.github.com/en/apps/creating-github-apps/authenticating-with-a-github-app/generating-an-installation-access-token-for-a-github-app#generating-an-installation-access-token
  echo "$RESPONSE" | jq -r '.token'
else
  echo "Error:" >&2
  echo "$RESPONSE" | jq >&2
  exit 1
fi
