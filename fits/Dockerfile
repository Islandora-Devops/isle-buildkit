# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
ARG alpine=3.15.0
FROM --platform=$BUILDPLATFORM ${repository}/download:${tag} AS download

RUN --mount=type=cache,id=fits-downloads,sharing=locked,target=/opt/downloads \
    FITSSERVLET_VERSION=1.2.1 && \
    FITSSERVLET_FILE="fits-${FITSSERVLET_VERSION}.war" && \
    FITSSERVLET_URL="http://projects.iq.harvard.edu/files/fits/files/${FITSSERVLET_FILE}" && \
    FITSSERVLET_SHA256="13cfcb910092b197757e459353f0c30381febfca6baf3031ac69ff92789b200c" && \
    download.sh --url "${FITSSERVLET_URL}" --sha256 "${FITSSERVLET_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-war-into-tomcat.sh --name "fits" --file "${DOWNLOAD_CACHE_DIRECTORY}/${FITSSERVLET_FILE}" && \
    FITS_VERSION="1.5.1" && \
    FITS_FILE="fits-${FITS_VERSION}.zip" && \
    FITS_URL="https://github.com/harvard-lts/fits/releases/download/${FITS_VERSION}/${FITS_FILE}" \
    FITS_SHA256="4bf4adfedf0779221cc2f4648f5dfd3040c7a3e5daa4060c5754d73dc1964442" && \
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

COPY /build /build

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

COPY --from=download --chown=tomcat:tomcat /opt/tomcat /opt/tomcat
COPY --from=download --chown=tomcat:tomcat /opt/fits /opt/fits

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

COPY rootfs /
COPY --chown=tomcat:tomcat rootfs/opt/tomcat /opt/tomcat
COPY --chown=tomcat:tomcat rootfs/opt/fits /opt/fits