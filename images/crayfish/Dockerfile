# syntax=docker/dockerfile:1.20.0
FROM nginx

# Keep this immutable source pin and checksum in sync with the Crayfish 5.x release line.
ARG TARGETARCH
ARG COMMIT=ef30f09e9a17bffc1148facdf785b6b6f9312acb
ARG FILE=${COMMIT}.tar.gz
ARG URL=https://github.com/Islandora/Crayfish/archive/${FILE}
ARG SHA256=2e27caac6ec5b10d6d4a62257d8a69b874c62c020e2c64bfc1ba249b6d527ef8

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
