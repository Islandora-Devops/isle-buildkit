# Crayfish

Docker image for [Crayfish] version 1.1.1.

Acts as base Docker image for Crayfish based micro-services. It is not meant to
be run on its own it is only used to cache the download.

## Dependencies

Requires `islandora/nginx` docker image to build. Please refer to the
[Nginx Image README](../nginx/README.md) for additional information including
additional settings, volumes, ports, etc.

## Ports

| Port | Description |
| :--- | :---------- |
| 8000 | HTTP        |

## Settings

### JWT Settings

[Crayfish] makes use of JWT for authentication. Please see the documentation in
the [base image] for more information.

[base image]: ../base/README.md
[nginx image]: ../nginx/README.md
[Crayfish]: https://github.com/Islandora/Crayfish/tree/main
