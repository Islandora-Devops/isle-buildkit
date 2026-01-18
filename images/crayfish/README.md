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
COMMIT=$(cat crayfish/Dockerfile | grep -o 'COMMIT=.*' | cut -f2 -d=)
FILE=$(cat crayfish/Dockerfile | grep -o 'FILE=.*' | cut -f2 -d=)
URL=$(cat crayfish/Dockerfile | grep -o 'URL=.*' | cut -f2 -d=)
FILE=$(eval "echo $FILE")
URL=$(eval "echo $URL")
wget --quiet "${URL}"
shasum -a 256 "${FILE}" | cut -f1 -d' '
rm "${FILE}"
```

When changing the `COMMIT` and `SHA256` be sure to also update the composer lock files, this
can be done with the following commands:

```bash
make bake TARGET=crayfish

docker run --rm -ti \
  -v $(pwd)/crayfish/rootfs/var/www/crayfish/Recast/composer.lock:/var/www/crayfish/Recast/composer.lock \
  --entrypoint ash islandora/crayfish:local -c \
    "cd /var/www/crayfish/Recast && composer update"

docker run --rm -ti \
  -v $(pwd)/crayfish/rootfs/var/www/crayfish/Homarus/composer.lock:/var/www/crayfish/Homarus/composer.lock \
  --entrypoint ash islandora/crayfish:local -c \
    "cd /var/www/crayfish/Homarus && composer update"

docker run --rm -ti \
  -v $(pwd)/crayfish/rootfs/var/www/crayfish/Hypercube/composer.lock:/var/www/crayfish/Hypercube/composer.lock \
  --entrypoint ash islandora/crayfish:local -c \
    "cd /var/www/crayfish/Hypercube && composer update"

docker run --rm -ti \
  -v $(pwd)/crayfish/rootfs/var/www/crayfish/Houdini/composer.lock:/var/www/crayfish/Houdini/composer.lock \
  --entrypoint ash islandora/crayfish:local -c \
    "cd /var/www/crayfish/Houdini && composer update"

docker run --rm -ti \
  -v $(pwd)/crayfish/rootfs/var/www/crayfish/Milliner/composer.lock:/var/www/crayfish/Milliner/composer.lock \
  --entrypoint ash islandora/crayfish:local -c \
    "cd /var/www/crayfish/Milliner && composer update"

docker run --rm -ti \
  -v $(pwd)/crayfish/rootfs/var/www/crayfish/CrayFits/composer.lock:/var/www/crayfish/CrayFits/composer.lock \
  --entrypoint ash islandora/crayfish:local -c \
    "cd /var/www/crayfish/CrayFits && composer update"
```

[base image]: ../base/README.md
[nginx image]: ../nginx/README.md
[Crayfish]: https://github.com/Islandora/Crayfish/tree/4.x
