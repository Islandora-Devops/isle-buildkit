# Merge PDF

Docker image for mergepdf. Aggregate IIIF manifests for books/paged-content into a PDF.

Built from [Islandora-DevOps/isle-buildkit mergpdf](https://github.com/Islandora-DevOps/isle-buildkit/tree/main/mergepdf)

## Dependencies

Requires `islandora/scyllaridae` docker image to build. Please refer to the
[Scyllaridae Image README](../scyllaridae/README.md) for additional information including
additional settings, volumes, ports, etc.

### IIIF Manifest

The drupal site requires a route available at `/node/{node}/book-manifest`. This View is installed by default in the [views.view.iiif_manifest.yml](https://github.com/Islandora-Devops/islandora-starter-site/blob/main/config/sync/views.view.iiif_manifest.yml) config in the Islandora Starter Site.

### Taxonomy Term Name to TID

The drupal site requires a route available at `/term_from_term_name`. This View is installed by default in the [views.view.term_from_term_name.yml](https://github.com/Islandora-Devops/islandora-starter-site/blob/main/config/sync/views.view.term_from_term_name.yml) config in the Islandora Starter Site. This View **must** have `jwt_auth` enabled in the `Path settings > Authentication` at `/admin/structure/views/view/term_from_term_name`

## Settings

| Environment Variable | Default                                                   | Description                                                             |
| :------------------- | :-------------------------------------------------------- | :---------------------------------------------------------------------- |
| MAX_THREADS          | 5                                                         | How many images to download at once from a IIIF manifest                |
| MAX_WIDTH            | 2000                                                      | How many pixels wide the images in the PDFs can be                      |
| URI_SCHEME           | `private`                                                 | The Drupal URI to store the generated PDF in                            |
