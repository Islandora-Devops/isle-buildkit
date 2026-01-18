# Crayfish

Docker image for [scyllaridae] 5.1.0.

Acts as base Docker image for scyllaridae based micro-services. It is not meant to
be run on its own it is only used to cache the download.

## Dependencies

Requires `islandora/base` Docker image to build. Please refer to the
[Base Image README](../base/README.md) for additional information including
additional settings, volumes, ports, etc.

## Ports

| Port | Description |
| :--- | :---------- |
| 8080 | HTTP        |

## Settings


| Environment Variable              | Default                                    | Description                                                       |
| :-------------------------------- | :----------------------------------------- | :---------------------------------------------------------------- |
| `SCYLLARIDAE_ALLOW_INSECURE_ARGS` |  `false`                                   | Allow insecure args to be passed to a microservice.               |
| `SCYLLARIDAE_LOG_LEVEL`           |  `INFO`                                    | Log level. Possible Values: debug, info, notice, warning, error   |
| `SCYLLARIDAE_PORT`                | `8080`                                     | What port to listen on inside the container                       |
| `SCYLLARIDAE_YML_PATH`            | `/app/scyllaridae.yml`                     | Location of the scyllaridea YML file                              |

[scyllaridae]: https://github.com/islandora/scyllaridae
