# syntax=docker/dockerfile:1.5.1
FROM nginx

# When updating this commit also update the lock files in rootfs/var/www/crayfish.
ARG TARGETARCH
ARG COMMIT=d4bc375c6dd9c6df6bb4fa088629a2f8b7cf5cce
ARG FILE=${COMMIT}.tar.gz
ARG URL=https://github.com/Islandora/Crayfish/archive/${FILE}
ARG SHA256=3b4c144a98b4ed4d1fd9a6395a4e3484ecbb89cac144142d3fc187bc0e5c130a

# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=crayfish-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${URL}" \
        --sha256 "${SHA256}" \
        --strip \
        --dest "/var/www/crayfish" \
    && \
    cleanup.sh

COPY --link rootfs /
