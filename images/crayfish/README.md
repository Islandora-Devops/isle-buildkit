# Crayfish

Docker image for [Crayfish] (**unreleased version**).

Built from [Islandora-DevOps/isle-buildkit crayfish](https://github.com/Islandora-DevOps/isle-buildkit/tree/main/images/crayfish)

Acts as base Docker image for Crayfish based micro-services. It is not meant to
be run on its own it is only used to cache the download.

## Dependencies

Requires `islandora/nginx` Docker image to build. Please refer to the
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

## Updating

You can change the commit used for crayfish by modifying the build argument
`COMMIT` and `SHA256` in the `Dockerfile` shown as `XXXXXXXXXXXX` in the
following snippet:

```Dockerfile
ARG COMMIT=XXXXXXXXXXXX
#...
ARG SHA256=XXXXXXXXXXXX
```

You can generate the `SHA256` with the following commands:

```bash
commit=$(sed -n 's/^ARG COMMIT=//p' images/crayfish/Dockerfile)
archive=$(mktemp)
curl --fail --location --silent --show-error \
  --output "${archive}" \
  "https://github.com/Islandora/Crayfish/archive/${commit}.tar.gz"
sha256sum "${archive}"
rm "${archive}"
```

Milliner's lock file is committed in the Crayfish repository and is downloaded with
the source archive. Update dependencies in Crayfish first, then update this immutable
commit and checksum pair. Do not maintain a second lock file in this image.

[base image]: ../base/README.md
[nginx image]: ../nginx/README.md
[Crayfish]: https://github.com/Islandora/Crayfish/tree/5.x
