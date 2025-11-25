# Houdini

Docker image for mergepdf. Aggregate IIIF manifests into a PDF.

Built from [Islandora-DevOps/isle-buildkit houdini](https://github.com/Islandora-DevOps/isle-buildkit/tree/main/houdini)

## Dependencies

Requires `islandora/scyllaridae` docker image to build. Please refer to the
[Scyllaridae Image README](../scyllaridae/README.md) for additional information including
additional settings, volumes, ports, etc.

### https://islandora.dev/node/{node}/book-manifest

The drupal site requires a route available at `/node/{node}/book-manifest`. This View is installed by default in the [views.view.iiif_manifest.yml](https://github.com/Islandora-Devops/islandora-starter-site/blob/main/config/sync/views.view.iiif_manifest.yml) config in the Islandora Starter Site.

### https://islandora.dev/term_from_term_name

The drupal site requires a route available at `/term_from_term_name`. This View is installed by default in the [views.view.term_from_term_name.yml](https://github.com/Islandora-Devops/islandora-starter-site/blob/main/config/sync/views.view.term_from_term_name.yml) config in the Islandora Starter Site.

## Settings

| Environment Variable | Default                                                   | Description                                                             |
| :------------------- | :-------------------------------------------------------- | :---------------------------------------------------------------------- |
| MAX_THREADS          | 5                                                         | How many images to download at once from a IIIF manifest                |
