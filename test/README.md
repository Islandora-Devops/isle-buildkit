# Test

This image is exclusively used for **manually testing** pull request to this
repository and is not intended for use in production environments.

## Dependencies

Requires `islandora/drupal` docker image to build. Please refer to the
[Drupal Image README](../drupal/README.md) for additional information.

## Gotchas

If updating the solr image [Solr Image](../solr/README.md) be sure to update the
configuration in
[test/rootfs/opt/solr/server/solr/default/conf](test/rootfs/opt/solr/server/solr/default/conf).
