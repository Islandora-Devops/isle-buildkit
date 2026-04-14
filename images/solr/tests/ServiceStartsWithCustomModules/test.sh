#!/command/with-contenv bash
# shellcheck shell=bash

set -euo pipefail

# shellcheck disable=SC1091
source /usr/local/share/isle/utilities.sh

# Wait for service to start.
wait_20x http://localhost:8983/solr

# Solr should translate SOLR_MODULES into a JVM system property for the live process.
process="$(pgrep -u solr -af -- "-Dsolr.modules=")"

IFS=',' read -r -a modules <<< "${SOLR_MODULES}"
for module in "${modules[@]}"; do
  [[ "${process}" == *"${module}"* ]]
done
