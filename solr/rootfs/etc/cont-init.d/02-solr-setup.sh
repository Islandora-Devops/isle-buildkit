#!/usr/bin/with-contenv bash
set -e

# When bind mounting we need to ensure that we
# actually can write to the folder.
chown -R solr:solr /opt/solr/server/solr
