# Crayfish

Docker image for [scyllaridae] 4.1.0.

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


| Environment Variable | Default                                    | Description                                                       |
| :------------------- | :----------------------------------------- | :---------------------------------------------------------------- |
| LOG_LEVEL            | info                                       | Log level. Possible Values: debug, info, notice, warning, error   |
| SKIP_JWT_VERIFY      | "true"                                     | Set to `"false"` to force JWT verification on event messages      |
| JWKS_URI             | https://islandora.dev/oauth/discovery/keys | URL to JSON Web Key Set for JWT verification                      |

### JWT Settings

[scyllaridae] makes use of JWT for authentication.

By default, JWT verification is skipped with `SKIP_JWT_VERIFY=true`. JWT verification can be enabled by setting `SKIP_JWT_VERIFY=false`
and setting `JWKS_URI=https://$DOMAIN/oauth/discovery/keys`. This relies on the Drupal module [drupal/islandora_jwks](https://www.drupal.org/project/islandora_jwks)
being installed on your Islandora Drupal site.

[scyllaridae]: https://github.com/lehigh-university-libraries/scyllaridae
