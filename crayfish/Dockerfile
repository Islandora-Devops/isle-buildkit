# syntax=docker/dockerfile:1.5.1
FROM nginx

# When updating this commit also update the lock files in rootfs/var/www/crayfish.
ARG TARGETARCH
ARG COMMIT=6ba190c3ffebabb83e977c6515ecfd022692f6e5
ARG FILE=${COMMIT}.tar.gz
ARG URL=https://github.com/Islandora/Crayfish/archive/${FILE}
ARG SHA256=3fb7ae787be43a719f66a3d98efff85766056cf2d962365d9e821ff3a9f813ee

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
