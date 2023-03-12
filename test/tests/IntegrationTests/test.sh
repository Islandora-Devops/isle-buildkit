#!/command/with-contenv bash
# shellcheck shell=bash

set -xeuo pipefail

# To pause cause Fedora can't shutdown successfully.
readonly QUEUES=(
  islandora-indexing-fcrepo-delete
  islandora-indexing-fcrepo-file-external
  islandora-indexing-fcrepo-media
  islandora-indexing-fcrepo-content
)

function jolokia {
    local type="${1}"
    local queue="${2}"
    local action="${3}"
    local url="http://${DRUPAL_DEFAULT_BROKER_HOST}:8161/api/jolokia/${type}/org.apache.activemq:type=Broker,brokerName=localhost,destinationType=Queue,destinationName=${queue}"
    if [ "$action" != "" ]; then
        url="${url}/$action"
    fi
    curl -s -u "admin:password" "${url}"
    printf "\n"
}

function pause_queues {
  for queue in "${QUEUES[@]}"; do
    jolokia "exec" "${queue}" "pause" &
  done
  wait
}

function node_count() {
  local count="${1}"
  test "$(drush sql-query 'select count(*) from node;')" -eq "${count}"
}

function media_use_count() {
  local name="${1}"
  local count="${2}"
  TID=$(drush sql-query "select tid from taxonomy_term_field_data where name = '${name}';")
  test "$(drush sql-query "select count(*) from media__field_media_use where field_media_use_target_id = $TID;")" -eq "${count}"
}

function solr_document_count() {
  local count="${1}"
  test "$(curl -sL 'solr:8983/solr/default/select?q=*:*&rows=0' | jq '.response.numFound')" -eq "${count}"
}

function main() {
  # Tests
  echo "Perform Tests"

  sleep 30

  echo "Confirm default Nodes were created."
  node_count 4

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
  solr_document_count 4

  # Fcrepo will not shut down gracefully if still recieving requests, so pause
  # all ActiveMQ queues first and sleep.
  pause_queues
  sleep 30
}
main
