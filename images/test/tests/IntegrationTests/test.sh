#!/command/with-contenv bash
# shellcheck shell=bash

set -xeuo pipefail

trap 'echo "ERROR: test.sh failed at line ${LINENO}: ${BASH_COMMAND}" >&2' ERR

function fail() {
  local message="${1}"
  echo "ERROR: ${message}" >&2
  exit 1
}

function assert_eq() {
  local label="${1}"
  local expected="${2}"
  local actual="${3}"

  if [[ "${actual}" != "${expected}" ]]; then
    fail "${label} mismatch. expected=${expected} actual=${actual}"
  fi

  echo "PASS: ${label}=${actual}"
}

function node_count() {
  local count="${1}"
  local actual
  actual="$(drush sql-query 'select count(*) from node;')"
  assert_eq "node_count" "${count}" "${actual}"
}

function media_use_count() {
  local name="${1}"
  local count="${2}"
  local tid
  local actual

  tid="$(drush sql-query "select tid from taxonomy_term_field_data where name = '${name}';")"
  [[ -n "${tid}" ]] || fail "taxonomy term not found for media use '${name}'"

  actual="$(drush sql-query "select count(*) from media__field_media_use where field_media_use_target_id = ${tid};")"
  assert_eq "media_use_count[${name}]" "${count}" "${actual}"
}

function solr_document_count() {
  local count="${1}"
  local response
  local actual

  response="$(curl -fsSL 'solr:8983/solr/default/select?q=*:*&rows=0')"
  actual="$(jq -r '.response.numFound' <<< "${response}")"
  assert_eq "solr_document_count" "${count}" "${actual}"
}

function main() {
  # Tests
  echo "Perform Tests"

  sleep 30

  echo "Confirm default Nodes were created."
  node_count 5

  echo "Confirm default Media was created."
  media_use_count "Original File" 4

  # Note:
  # Test fails relatively often due to https://www.drupal.org/project/drupal/issues/2833539
  # occurring when Alpaca tries to write a derivative to Drupal
  # Route that is the culprit:
  # https://github.com/Islandora/islandora/blob/2923a1a8b9303569fdea4bdbf580c1f56e3ed033/islandora.routing.yml#L81-L89
  # Until this is resolved we can't really uncomment the checks below.

  #echo "Confirm FITS exists for each media item"
  #media_use_count "FITS File" 4

  #echo "Confirm Thumbnails were created."
  #media_use_count "Thumbnail Image" 3 # Audio does not produce a thumbnail.

  #echo "Confirm Service Files were created."
  #media_use_count "Service File" 3 # One for Image, Audio and Video.

  #echo "Confirm Extract Text was created."
  #media_use_count "Extracted Text" 1

  echo "Confirm Solr documents were created."
  solr_document_count 5
}
main
