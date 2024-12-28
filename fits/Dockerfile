# syntax=docker/dockerfile:1.5.1
FROM tomcat

ARG TARGETARCH

# renovate: datasource=github-releases depName=fits-servlet packageName=harvard-lts/FITSservlet
ARG FITSSERVLET_VERSION="2.1.0"
ARG FITSSERVLET_FILE="fits-service-${FITSSERVLET_VERSION}.war"
ARG FITSSERVLET_URL="https://github.com/harvard-lts/FITSservlet/releases/download/${FITSSERVLET_VERSION}/${FITSSERVLET_FILE}"
ARG FITSSERVLET_SHA256="ba3c4d5af4dfbe42a32b4321eb96fad8db1379c8b00cd2bc7b7b0e4f59cb7e67"

# renovate: datasource=github-releases depName=fits packageName=harvard-lts/fits
ARG FITS_VERSION="1.6.0"
ARG FITS_FILE="fits-${FITS_VERSION}.zip"
ARG FITS_URL="https://github.com/harvard-lts/fits/releases/download/${FITS_VERSION}/${FITS_FILE}"
ARG FITS_SHA256="32e436effe7251c5b067ec3f02321d5baf4944b3f0d1010fb8ec42039d9e3b73"

# renovate: datasource=github-releases depName=apache-log4j packageName=apache/logging-log4j2
ARG LOG4J_VERSION="2.23.1"
ARG LOG4J_FILE="apache-log4j-${LOG4J_VERSION}-bin.zip"
ARG LOG4J_URL="https://archive.apache.org/dist/logging/log4j/${LOG4J_VERSION}/${LOG4J_FILE}"
ARG LOG4J_FILE_SHA256="c53645414ce68f21dd347439df5852ad16b38cd7227a9d417ebaf411a1c09501"
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

# Replace linux shared libraries with ones that target muslibc and are platform specific.
# Also add perl for exiftool, and platform specific jna so native libs can be loaded.
#
# Additionally, Python and Jpylyzer are included for analyzing JP2 files
#
# Platform specific does require arch specific identifier.
RUN --mount=type=cache,id=fits-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
        file \
        java-jna \
        libmediainfo \
        libzen \
        perl \
        py3-pip \
        python3 \
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
