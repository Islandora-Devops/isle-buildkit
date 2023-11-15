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

## Updating

You can change the commit used for the starter site by modifying the build
argument `COMMIT` and `SHA256` in the `Dockerfile` shown as `XXXXXXXXXXXX` in
the following snippet:

```Dockerfile
ARG COMMIT=XXXXXXXXXXXX
#...
ARG SHA256=XXXXXXXXXXXX
```

You can generate the `SHA256` with the following commands:

```bash
COMMIT=$(cat test/Dockerfile | grep -o 'COMMIT=.*' | cut -f2 -d=)
FILE=$(cat test/Dockerfile | grep -o 'FILE=.*' | cut -f2 -d=)
URL=$(cat test/Dockerfile | grep -o 'URL=.*' | cut -f2 -d=)
FILE=$(eval "echo $FILE")
URL=$(eval "echo $URL")
wget --quiet "${URL}"
shasum -a 256 "${FILE}" | cut -f1 -d' '
rm "${FILE}"
```
