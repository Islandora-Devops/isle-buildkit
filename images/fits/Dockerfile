# syntax=docker/dockerfile:1.20.0
FROM tomcat

ARG TARGETARCH

# renovate: datasource=github-releases depName=fits-servlet packageName=harvard-lts/FITSservlet
ARG FITSSERVLET_VERSION=2.1.0
ARG FITSSERVLET_FILE="fits-service-${FITSSERVLET_VERSION}.war"
ARG FITSSERVLET_URL="https://github.com/harvard-lts/FITSservlet/releases/download/${FITSSERVLET_VERSION}/${FITSSERVLET_FILE}"
ARG FITSSERVLET_SHA256="ba3c4d5af4dfbe42a32b4321eb96fad8db1379c8b00cd2bc7b7b0e4f59cb7e67"

# renovate: datasource=github-releases depName=fits packageName=harvard-lts/fits
ARG FITS_VERSION=1.6.0
ARG FITS_FILE="fits-${FITS_VERSION}.zip"
ARG FITS_URL="https://github.com/harvard-lts/fits/releases/download/${FITS_VERSION}/${FITS_FILE}"
ARG FITS_SHA256="32e436effe7251c5b067ec3f02321d5baf4944b3f0d1010fb8ec42039d9e3b73"

# renovate: datasource=custom.apache-downloads depName=apache-log4j packageName=logging/log4j
ARG LOG4J_VERSION=2.25.3
ARG LOG4J_FILE="apache-log4j-${LOG4J_VERSION}-bin.zip"
ARG LOG4J_URL="https://archive.apache.org/dist/logging/log4j/${LOG4J_VERSION}/${LOG4J_FILE}"
ARG LOG4J_FILE_SHA256="0259555ff869522b889310a25c27859cf6dc35258251d5355a5eaaf7f4f48b40"
ARG OLD_LOG4J_VERSION="2.22.0"

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

ARG \
    # renovate: datasource=repology depName=alpine_3_22/file
    FILE_VERSION=5.46-r2 \
    # renovate: datasource=repology depName=alpine_3_22/java-jna
    JNA_VERSION=5.15.0-r0 \
    # renovate: datasource=repology depName=alpine_3_22/libmediainfo
    LIBMEDIAINFO_VERSION=25.03-r0 \
    # renovate: datasource=repology depName=alpine_3_22/libzen
    LIBZEN_VERSION=0.4.41-r0 \
    # renovate: datasource=repology depName=alpine_3_22/perl
    PERL_VERSION=5.40.3-r0 \
    # renovate: datasource=repology depName=alpine_3_22/py3-pip
    PIP_VERSION=25.1.1-r0 \
    # renovate: datasource=repology depName=alpine_3_22/python3
    PYTHON_VERSION=3.12.12-r0

# Replace linux shared libraries with ones that target muslibc and are platform specific.
# Also add perl for exiftool, and platform specific jna so native libs can be loaded.
#
# Additionally, Python and Jpylyzer are included for analyzing JP2 files
#
# Platform specific does require arch specific identifier.
RUN --mount=type=cache,id=fits-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
        file=="${FILE_VERSION}" \
        java-jna=="${JNA_VERSION}" \
        libmediainfo=="${LIBMEDIAINFO_VERSION}" \
        libzen=="${LIBZEN_VERSION}" \
        perl=="${PERL_VERSION}" \
        py3-pip=="${PIP_VERSION}" \
        python3=="${PYTHON_VERSION}" \
    && \
    pip install --break-system-packages jpylyzer && \
    cleanup.sh

# Remove old files & then install latest log4j-* files
RUN --mount=type=cache,id=log4j-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${LOG4J_URL}" \
        --sha256 "${LOG4J_FILE_SHA256}" \
    && \
    ## Remove the outmoded log4j-* files that come with fits
    rm -f /opt/fits/lib/droid/log4j-1.2.13.jar && \
    rm -f "/opt/tomcat/webapps/fits/WEB-INF/lib/log4j-api-${OLD_LOG4J_VERSION}.jar" && \
    rm -f "/opt/tomcat/webapps/fits/WEB-INF/lib/log4j-core-${OLD_LOG4J_VERSION}.jar" && \
    ## Add new log4j-* files
    unzip -o "${DOWNLOAD_CACHE_DIRECTORY}/${LOG4J_FILE}" -d "${DOWNLOAD_CACHE_DIRECTORY}" && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/log4j-1.2-api-${LOG4J_VERSION}.jar" /opt/fits/lib/droid/ && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/log4j-1.2-api-${LOG4J_VERSION}.jar" /opt/tomcat/webapps/fits/WEB-INF/lib/ && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/log4j-api-${LOG4J_VERSION}.jar" /opt/tomcat/webapps/fits/WEB-INF/lib/ && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/log4j-core-${LOG4J_VERSION}.jar" /opt/tomcat/webapps/fits/WEB-INF/lib/ && \
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
