# syntax=docker/dockerfile:1.5.1
FROM java

ARG TARGETARCH
ARG SOLR_VERSION=9.5.0
ARG SOLR_FILE=solr-${SOLR_VERSION}.tgz
ARG SOLR_URL=https://archive.apache.org/dist/solr/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.tgz
ARG SOLR_FILE_SHA256=d8538502019af1945e0b124a4613b46ca43aedcf3f20e9912c482c080407ea21

ARG LOG4J_VERSION="2.22.0"
ARG LOG4J_FILE="apache-log4j-${LOG4J_VERSION}-bin.zip"
ARG LOG4J_URL="https://archive.apache.org/dist/logging/log4j/${LOG4J_VERSION}/${LOG4J_FILE}"
ARG LOG4J_FILE_SHA256="c6d61ecf2563b1200e02587b89b7c75b58b6e62e6a16cdb6f333c2482167c2dc"
ARG OLD_LOG4J_VERSION="2.17.1"

EXPOSE 8983

WORKDIR /opt/solr

# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=solr-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${SOLR_URL}" \
        --sha256 "${SOLR_FILE_SHA256}" \
        --strip \
        --dest "/opt/solr" \
        docs \
        example \
        server/solr/configsets \
    && \
    cleanup.sh

# Remove old files & then install latest log4j-* files
RUN --mount=type=cache,id=log4j-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${LOG4J_URL}" \
        --sha256 "${LOG4J_FILE_SHA256}" \
    && \
    ## Remove the outmoded log4j-* files that come with Solr
    rm -f "/opt/solr/contrib/prometheus-exporter/lib/log4j-api-${OLD_LOG4J_VERSION}.jar" && \
    rm -f "/opt/solr/contrib/prometheus-exporter/lib/log4j-core-${OLD_LOG4J_VERSION}.jar" && \
    rm -f "/opt/solr/contrib/prometheus-exporter/lib/log4j-slf4j-impl-${OLD_LOG4J_VERSION}.jar" && \
    rm -f "/opt/solr/licenses/log4j-1.2-api-${OLD_LOG4J_VERSION}.jar.sha1" && \
    rm -f "/opt/solr/licenses/log4j-api-${OLD_LOG4J_VERSION}.jar.sha1" && \
    rm -f "/opt/solr/licenses/log4j-core-${OLD_LOG4J_VERSION}.jar.sha1" && \
    rm -f "/opt/solr/licenses/log4j-layout-template-json-${OLD_LOG4J_VERSION}.jar.sha1" && \
    rm -f "/opt/solr/licenses/log4j-slf4j-impl-${OLD_LOG4J_VERSION}.jar.sha1" && \
    rm -f "/opt/solr/licenses/log4j-web-${OLD_LOG4J_VERSION}.jar.sha1" && \
    rm -f "/opt/solr/server/lib/ext/log4j-${OLD_LOG4J_VERSION}.jar" && \
    rm -f "/opt/solr/server/lib/ext/log4j-1.2-api-${OLD_LOG4J_VERSION}.jar" && \
    rm -f "/opt/solr/server/lib/ext/log4j-api-${OLD_LOG4J_VERSION}.jar" && \
    rm -f "/opt/solr/server/lib/ext/log4j-core-${OLD_LOG4J_VERSION}.jar" && \
    rm -f "/opt/solr/server/lib/ext/log4j-layout-template-json-${OLD_LOG4J_VERSION}.jar" && \
    rm -f "/opt/solr/server/lib/ext/log4j-slf4j-impl-${OLD_LOG4J_VERSION}.jar" && \
    rm -f "/opt/solr/server/lib/ext/log4j-web-${OLD_LOG4J_VERSION}.jar" && \
    ## Add new log4j-* files
    unzip -o "${DOWNLOAD_CACHE_DIRECTORY}/${LOG4J_FILE}" -d "${DOWNLOAD_CACHE_DIRECTORY}" && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/log4j-1.2-api-${LOG4J_VERSION}.jar" /opt/solr/server/lib/ext/ && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/log4j-api-${LOG4J_VERSION}.jar" /opt/solr/contrib/prometheus-exporter/lib/ && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/log4j-api-${LOG4J_VERSION}.jar" /opt/solr/server/lib/ext/ && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/log4j-core-${LOG4J_VERSION}.jar" /opt/solr/contrib/prometheus-exporter/lib/ && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/log4j-core-${LOG4J_VERSION}.jar" /opt/solr/server/lib/ext/ && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/log4j-layout-template-json-${LOG4J_VERSION}.jar" /opt/solr/server/lib/ext/ && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/log4j-slf4j-impl-${LOG4J_VERSION}.jar" /opt/solr/contrib/prometheus-exporter/lib/ && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/log4j-slf4j-impl-${LOG4J_VERSION}.jar" /opt/solr/server/lib/ext/ && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/log4j-web-${LOG4J_VERSION}.jar" /opt/solr/server/lib/ext/ && \
    cleanup.sh

RUN create-service-user.sh --name solr /data && \
    cleanup.sh

# Defaults environment variables to be overloaded.
ENV \
    SOLR_JAVA_OPTS= \
    SOLR_JETTY_OPTS=-Dsolr.jetty.host=0.0.0.0 \
    SOLR_LOG_LEVEL=INFO \
    SOLR_MEMORY=512m

COPY --link rootfs /
