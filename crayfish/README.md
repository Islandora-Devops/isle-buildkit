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

## Updating

You can change the commit used for crayfish by modifying the build argument
`COMMIT` in the `Dockerfile` shown as `XXXXXXXXXXXX` in the following snippet:

```Dockerfile
#...
# When updating this commit also update the lock files in rootfs/var/www/crayfish.
ARG COMMIT=XXXXXXXXXXXX

RUN --mount=type=cache,id=crayfish-downloads,sharing=locked,target=/opt/downloads \
    git-clone-cached.sh \
        --url https://github.com/Islandora/Crayfish.git \
        --cache-dir "${DOWNLOAD_CACHE_DIRECTORY}" \
        --commit "${COMMIT}" \
        --worktree /var/www/crayfish
#...
```

When changing the `COMMIT` be sure to also update the composer lock files, this
can be done with the following commands:

```bash
./gradlew crayfish:build

docker run --rm -ti \
  -v $(pwd)/crayfish/rootfs/var/www/crayfish/Recast/composer.lock:/var/www/crayfish/Recast/composer.lock \
  --entrypoint ash islandora.dev/crayfish:latest -c \
    "cd /var/www/crayfish/Recast && composer update"

docker run --rm -ti \
  -v $(pwd)/crayfish/rootfs/var/www/crayfish/Homarus/composer.lock:/var/www/crayfish/Homarus/composer.lock \
  --entrypoint ash islandora.dev/crayfish:latest -c \
    "cd /var/www/crayfish/Homarus && composer update"

docker run --rm -ti \
  -v $(pwd)/crayfish/rootfs/var/www/crayfish/Hypercube/composer.lock:/var/www/crayfish/Hypercube/composer.lock \
  --entrypoint ash islandora.dev/crayfish:latest -c \
    "cd /var/www/crayfish/Hypercube && composer update"

docker run --rm -ti \
  -v $(pwd)/crayfish/rootfs/var/www/crayfish/Houdini/composer.lock:/var/www/crayfish/Houdini/composer.lock \
  --entrypoint ash islandora.dev/crayfish:latest -c \
    "cd /var/www/crayfish/Houdini && composer update"

docker run --rm -ti \
  -v $(pwd)/crayfish/rootfs/var/www/crayfish/Milliner/composer.lock:/var/www/crayfish/Milliner/composer.lock \
  --entrypoint ash islandora.dev/crayfish:latest -c \
    "cd /var/www/crayfish/Milliner && composer update"
```

[base image]: ../base/README.md
[nginx image]: ../nginx/README.md
[Crayfish]: https://github.com/Islandora/Crayfish/tree/main
