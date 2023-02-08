# syntax=docker/dockerfile:1.5.1
FROM nginx

# When updating this commit also update the lock files in rootfs/var/www/crayfish.
ARG TARGETARCH
ARG COMMIT=3dee7c65ef8a43dabd886511bc1b10513454d3b5
ARG FILE=${COMMIT}.tar.gz
ARG URL=https://github.com/nigelgbanks/Crayfish/archive/${FILE}
ARG SHA256=1f1cb77637c252cb1da03e54b3e74e4b426223e38c8ebfa2bff312deb9428123

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
