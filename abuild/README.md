# ABuild

Docker image for `abuild` which is a tool used for create `apk` package for
consumption by other docker containers.

It is not meant to be deployed as a service, but rather as base for when
creating packages as is done in `islandora/imagemagick`.

Consumers are expected to follow this pattern:

Create a folder `/build` in the project directory where the `APKBUILD` file
resides (which describes how to compile and build the package).

Define a docker file that:

1. Installs the packages required for building (but not necessarily running) the
   package.
2. Run `abuild-keygen` to generate a private/public key pair for signing the
   package.
3. Run `abuild` to build the package using `APKBUILD`.

```dockerfile
# syntax=docker/dockerfile:experimental
FROM islandora/abuild:latest

# Include packages required for building the package (not necessarily the ones require for running).
RUN --mount=type=cache,target=/var/cache/apk \
    --mount=type=cache,target=/etc/cache/apk \
    apk --update add \
        package-require-for-building-1 \
        package-require-for-building-2 \

COPY /build /build

WORKDIR /build

RUN chown -R builder /build

ARG PACKAGER="Packer Name <packager@gmail.com>"

USER builder

RUN export PACKAGER="${PACKAGER}" && \
    abuild-keygen -ain && \
    abuild-apk update && \
    abuild
```

Subsequent images which consume the package can then bring it in via a
combination of multi-stage build, and Buildkit bind mounts like so:

```dockerfile
FROM islandora/package_image:latest as PACKAGE_IMAGE

FROM islandora/crayfish:latest

RUN --mount=type=bind,from=PACKAGE_IMAGE,source=/home/builder/packages/x86_64,target=/packages \
    --mount=type=bind,from=PACKAGE_IMAGE,source=/etc/apk/keys,target=/etc/apk/keys \
    --mount=type=cache,target=/root/.composer/cache \
    apk add /packages/PACKAGE_NAME-*.apk && \
    ... other build steps ...&& \
    cleanup.sh
```

Where the image is brought in as `PACKAGE_IMAGE` and the directory where the
generated `.pkg` resides as well as the location of `apk` key files are mounted
into the destination image.

## Dependencies

Requires `alpine:3.11.6` docker image to build.

## Reference

- <https://wiki.alpinelinux.org/wiki/Creating_an_Alpine_package>
- <https://wiki.alpinelinux.org/wiki/Abuild_and_Helpers>
