# Crayfish

Docker image for [scyllaridae] 3.1.0.

Acts as base Docker image for scyllaridae based micro-services. It is not meant to
be run on its own it is only used to cache the download.

## Dependencies

Requires `islandora/base` docker image to build. Please refer to the
[Base Image README](../base/README.md) for additional information including
additional settings, volumes, ports, etc.

## Ports

| Port | Description |
| :--- | :---------- |
| 8080 | HTTP        |

## Settings

### JWT Settings

[scyllaridae] makes use of JWT for authentication.

By default, JWT verification is skipped with `SKIP_JWT_VERIFY=true`. JWT verification can be enabled by setting `SKIP_JWT_VERIFY=false`
and setting `JWKS_URI=https://$DOMAIN/oauth/discovery/keys`. This relies on the Drupal module [drupal/islandora_jwks](https://www.drupal.org/project/islandora_jwks)

[scyllaridae]: https://github.com/lehigh-university-libraries/scyllaridae
