#!/command/with-contenv bash
# shellcheck shell=bash

# shellcheck disable=SC1091
source /usr/local/share/isle/utilities.sh

# Wait for service to start.
wait_20x http://localhost:8983/solr

# The OCR highlighting plugin should be installed as a plain Solr lib so it
# remains available after Solr 10 removes <lib .../> loading.
find /opt/solr/lib -maxdepth 1 -type f -name 'solr-ocrhighlighting-*.jar' | grep -q .

# Service must start for us to get to this point.
exit 0
