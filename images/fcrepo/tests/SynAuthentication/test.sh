#!/command/with-contenv bash
# shellcheck shell=bash

# shellcheck disable=SC1091
source /usr/local/share/isle/utilities.sh

base64url() {
    openssl base64 -A | tr '+/' '-_' | tr -d '='
}

create_jwt() {
    local exp header iat payload signature signing_input
    iat=$(date +%s)
    exp=$((iat + 7200))
    header='{"alg":"RS256","typ":"JWT"}'
    payload=$(printf '{"sub":"adminuser","iss":"http://localhost:8080","webid":1,"roles":["fedoraAdmin"],"iat":%s,"exp":%s}' "${iat}" "${exp}")
    signing_input="$(printf '%s' "${header}" | base64url).$(printf '%s' "${payload}" | base64url)"
    signature=$(printf '%s' "${signing_input}" | openssl dgst -sha256 -sign /opt/keys/jwt/private.key -binary | base64url)
    printf '%s.%s' "${signing_input}" "${signature}"
}

post_status() {
    local body_file token
    token=${1}
    body_file=${2}
    curl -s -o "${body_file}" -w "%{http_code}" \
        -X POST \
        -H "Authorization: Bearer ${token}" \
        -H "Content-Type:text/plain" \
        "http://localhost:8080/fcrepo/rest"
}

# Wait for fcrepo to start.
wait_20x http://localhost:8080/fcrepo/rest

valid_jwt=$(create_jwt)
valid_status=$(post_status "${valid_jwt}" /tmp/syn-valid-response.txt)
if [[ "${valid_status}" != 2* ]]; then
    echo "Valid JWT failed with HTTP ${valid_status}."
    cat /tmp/syn-valid-response.txt
    exit 1
fi
echo "Valid JWT accepted with HTTP ${valid_status}."

case "${valid_jwt: -1}" in
x) bad_jwt="${valid_jwt%?}y" ;;
*) bad_jwt="${valid_jwt%?}x" ;;
esac

bad_status=$(post_status "${bad_jwt}" /tmp/syn-bad-response.txt)
if [[ "${bad_status}" != "401" ]]; then
    echo "Bad JWT returned HTTP ${bad_status}; expected 401."
    cat /tmp/syn-bad-response.txt
    exit 1
fi
echo "Bad JWT rejected with HTTP ${bad_status}."

# All tests were successful
exit 0
