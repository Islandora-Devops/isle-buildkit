#!/usr/bin/with-contenv bash
set -e


# Copy the solr config
cp /solr_config/* /opt/solr/server/solr/ISLANDORA/conf/

# When bind mounting we need to ensure that we
# actually can write to the folder.
chown -R solr:solr /opt/solr/server/solr
