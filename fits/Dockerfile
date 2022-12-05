# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
ARG alpine=3.16.2
FROM --platform=$BUILDPLATFORM ${repository}/download:${tag} AS download

ARG FITSSERVLET_VERSION="1.2.3"
ARG FITSSERVLET_SHA256="e98450a1617c491976966a307da8b9c783c83e9e1a79bca9dbd9bc6c9a7226cd"
ARG FITS_VERSION="1.5.5"
ARG FITS_SHA256="48be7ad9f27d9cc0b52c63f1aea1a3814e1b6996ca4e8467e77772c187ac955c"

RUN --mount=type=cache,id=fits-downloads,sharing=locked,target=/opt/downloads \
    FITSSERVLET_FILE="fits-service-${FITSSERVLET_VERSION}.war" && \
    FITSSERVLET_URL="https://github.com/harvard-lts/FITSservlet/releases/download/${FITSSERVLET_VERSION}/${FITSSERVLET_FILE}" && \
    download.sh --url "${FITSSERVLET_URL}" --sha256 "${FITSSERVLET_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-war-into-tomcat.sh --name "fits" --file "${DOWNLOAD_CACHE_DIRECTORY}/${FITSSERVLET_FILE}" && \
    FITS_FILE="fits-${FITS_VERSION}.zip" && \
    FITS_URL="https://github.com/harvard-lts/fits/releases/download/${FITS_VERSION}/${FITS_FILE}" && \
    mkdir /opt/fits && \
    download.sh --url "${FITS_URL}" --sha256 "${FITS_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    unzip "${DOWNLOAD_CACHE_DIRECTORY}/${FITS_FILE}" -d /opt/fits && \
    rm -fr \
        /opt/fits/lib/jna-* \
        /opt/fits/tools/exiftool/perl/html \
        /opt/fits/tools/exiftool/windows \
        /opt/fits/tools/file_utility_windows \
        /opt/fits/tools/mediainfo

# Onces this https://gitlab.alpinelinux.org/alpine/aports/-/issues/13495 is resolved we can remove this build step.
FROM ${repository}/abuild:${tag} AS build

RUN --mount=type=cache,id=imagemagick-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk add \
        apache-ant \
        autoconf \
        automake \
        libffi-dev \
        libtool \
        openjdk8

COPY --link /build /build

WORKDIR /build

RUN chown -R builder /build

USER builder

RUN export PACKAGER="Nigel Banks <nigel.g.banks@gmail.com>" && \
    abuild-keygen -ain && \
    abuild-apk update && \
    abuild

USER root

RUN cp -r /home/builder/packages/* /packages

FROM alpine:${alpine} AS cache
FROM ${repository}/tomcat:${tag}

RUN --mount=type=bind,from=build,source=/packages,target=/packages \
    --mount=type=bind,from=build,source=/etc/apk/keys,target=/etc/apk/keys \
    apk add /packages/java-jna-*.apk && \
    cleanup.sh

COPY --link --from=download /opt/tomcat /opt/tomcat
COPY --link --from=download /opt/fits /opt/fits

# Replace linux shared libraries with ones that target muslibc and are platform specific.
# Also add perl for exiftool, and platform specific jna so native libs can be loaded.
RUN --mount=type=cache,id=fits-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk add \
        file \
        libmediainfo \
        libzen \
        perl \
    && \
    cp $(realpath /usr/share/java/jna.jar) /opt/fits/lib && \
    cleanup.sh

ENV \
    FITS_MAX_IN_MEMORY_FILE_SIZE=4 \
    FITS_MAX_OBJECTS_IN_POOL=5 \
    FITS_MAX_REQUEST_SIZE=2000 \
    FITS_MAX_UPLOAD_FILE_SIZE=2000 \
    FITS_SERVICE_LOG_LEVEL=INFO

COPY --link rootfs /

RUN chown -R tomcat:tomcat /opt/tomcat /opt/fits
