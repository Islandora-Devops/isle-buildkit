# syntax=docker/dockerfile:1.5.1
FROM tomcat

ARG TARGETARCH
ARG FITSSERVLET_VERSION="2.1.0"
ARG FITSSERVLET_FILE="fits-service-${FITSSERVLET_VERSION}.war"
ARG FITSSERVLET_URL="https://github.com/harvard-lts/FITSservlet/releases/download/${FITSSERVLET_VERSION}/${FITSSERVLET_FILE}"
ARG FITSSERVLET_SHA256="ba3c4d5af4dfbe42a32b4321eb96fad8db1379c8b00cd2bc7b7b0e4f59cb7e67"

ARG FITS_VERSION="1.6.0"
ARG FITS_FILE="fits-${FITS_VERSION}.zip"
ARG FITS_URL="https://github.com/harvard-lts/fits/releases/download/${FITS_VERSION}/${FITS_FILE}"
ARG FITS_SHA256="32e436effe7251c5b067ec3f02321d5baf4944b3f0d1010fb8ec42039d9e3b73"

# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=fits-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${FITSSERVLET_URL}" \
        --sha256 "${FITSSERVLET_SHA256}" \
        --dest "/opt/tomcat/webapps/fits" \
    && \
    mkdir /opt/fits && \
    download.sh \
        --url "${FITS_URL}" \
        --sha256 "${FITS_SHA256}" \
        --dest "/opt/fits" \
        tools/exiftool/perl/html \
        tools/exiftool/windows \
        tools/file_utility_windows \
        tools/mediainfo \
    && \
    rm /opt/fits/lib/jna-* && \
    cleanup.sh

# Replace linux shared libraries with ones that target muslibc and are platform specific.
# Also add perl for exiftool, and platform specific jna so native libs can be loaded.
#
# Platform specific does require arch specific identifier.
RUN --mount=type=cache,id=fits-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
        file \
        java-jna \
        libmediainfo \
        libzen \
        perl \
    && \
    cleanup.sh

ENV \
    FITS_MAX_IN_MEMORY_FILE_SIZE=4 \
    FITS_MAX_OBJECTS_IN_POOL=5 \
    FITS_MAX_REQUEST_SIZE=2000 \
    FITS_MAX_UPLOAD_FILE_SIZE=2000 \
    FITS_SERVICE_LOG_LEVEL=INFO

COPY --link rootfs /

RUN cp $(realpath /usr/share/java/jna.jar) /opt/fits/lib && \
    chown -R tomcat:tomcat /opt/tomcat /opt/fits && \
    cleanup.sh
