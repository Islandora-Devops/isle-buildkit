# syntax=docker/dockerfile:1.5.1
FROM alpine AS builder

ARG TARGETARCH

ENV PACKAGER="Islandora <community@islandora.ca>"

# Platform specific does require arch specific identifier.
RUN --mount=type=cache,id=nodejs-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
        alpine-sdk \
        sccache \
        sudo \
    && \
    adduser -G abuild -g "Alpine Package Builder" -s /bin/ash -D builder && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    su - builder -c "abuild-keygen -ain" && \
    su - builder -c "abuild-apk update"

USER builder

WORKDIR /build

# Provides a clean build environment for building.
FROM builder AS package

RUN --mount=type=cache,id=nodejs-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    --mount=type=cache,id=nodejs-distfiles,sharing=locked,target=/var/cache/distfiles,uid=1000,gid=300 \
    --mount=type=cache,id=nodejs-sccache-${TARGETARCH},sharing=locked,target=/home/builder/.cache/sccache,uid=1000,gid=300 \
    --mount=type=bind,source=build/APKBUILD,target=/build/APKBUILD \
    --mount=type=bind,source=build/ada.gyp,target=/build/ada.gyp\
    --mount=type=bind,source=build/base64.gyp,target=/build/base64.gyp\
    --mount=type=bind,source=build/disable-running-gyp-on-shared-deps.patch,target=/build/disable-running-gyp-on-shared-deps.patch \
    --mount=type=bind,source=build/dynamic-linking.patch,target=/build/dynamic-linking.patch \
    --mount=type=bind,source=build/nodejs.pc.in,target=/build/nodejs.pc.in \
    --mount=type=bind,source=build/nodejs.post-upgrade,target=/build/nodejs.post-upgrade \
    abuild deps && \
    CC="sccache gcc" CXX="sccache g++" CCACHE=1 abuild -r

FROM alpine

COPY --from=package /home/builder/packages/* /packages
COPY --from=package /etc/apk/keys/builder-* /etc/apk/keys
