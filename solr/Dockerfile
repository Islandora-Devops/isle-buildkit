# syntax=docker/dockerfile:1.5.1
FROM java

ARG TARGETARCH
ARG SOLR_VERSION="8.11.2"
ARG SOLR_FILE="solr-${SOLR_VERSION}.tgz"
ARG SOLR_URL="https://archive.apache.org/dist/lucene/solr/${SOLR_VERSION}/${SOLR_FILE}"
ARG SOLR_FILE_SHA256="54d6ebd392942f0798a60d50a910e26794b2c344ee97c2d9b50e678a7066d3a6"

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

RUN create-service-user.sh --name solr /data && \
    cleanup.sh && \
    ## Remove the outmoded log4j-* files that come with Solr
    rm -rf /opt/solr/server/lib/ext/log4j-*-${OLD_LOG4J_VERSION}.jar && \
    rm -rf /opt/solr/contrib/prometheus-exporter/lib/log4j-*-${OLD_LOG4J_VERSION}.jar

# Install latest log4j-* files
RUN --mount=type=cache,id=log4j-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${LOG4J_URL}" \
        --sha256 "${LOG4J_FILE_SHA256}" \
        --strip \
        --dest "/opt/solr/server/lib/ext" \
    && \
    rm -rf /opt/solr/server/lib/ext/*.adoc && \
    rm -rf /opt/solr/server/lib/ext/*.txt && \
    rm -rf /opt/solr/server/lib/ext/*cyclonedx*.* && \
    rm -rf /opt/solr/server/lib/ext/*test*.* && \
    rm -rf /opt/solr/server/lib/ext/log4j-api-test*.* && \
    rm -rf /opt/solr/server/lib/ext/log4j-appserver*.* && \
    rm -rf /opt/solr/server/lib/ext/log4j-cassandra*.* && \
    rm -rf /opt/solr/server/lib/ext/log4j-couchdb*.* && \
    rm -rf /opt/solr/server/lib/ext/log4j-docker*.* && \
    rm -rf /opt/solr/server/lib/ext/log4j-flume*.* && \
    rm -rf /opt/solr/server/lib/ext/log4j-iostreams*.* && \
    rm -rf /opt/solr/server/lib/ext/log4j-jakarta-*.* && \
    rm -rf /opt/solr/server/lib/ext/log4j-jcl-*.* && \
    rm -rf /opt/solr/server/lib/ext/log4j-jdbc-*.* && \
    rm -rf /opt/solr/server/lib/ext/log4j-jpa-*.* && \
    rm -rf /opt/solr/server/lib/ext/log4j-jpl-*.* && \
    rm -rf /opt/solr/server/lib/ext/log4j-jul-*.* && \
    rm -rf /opt/solr/server/lib/ext/log4j-kubernetes-*.* && \
    rm -rf /opt/solr/server/lib/ext/log4j-layout-template-*.* && \
    rm -rf /opt/solr/server/lib/ext/log4j-mongodb*.* && \
    rm -rf /opt/solr/server/lib/ext/log4j-slf4j2*.* && \
    rm -rf /opt/solr/server/lib/ext/log4j-spring-*.* && \
    rm -rf /opt/solr/server/lib/ext/log4j-taglib-*.* && \
    rm -rf /opt/solr/server/lib/ext/log4j-to-*.* && \
    cp /opt/solr/server/lib/ext/log4j-slf4j-impl-${LOG4J_VERSION}.jar /opt/solr/contrib/prometheus-exporter/lib/ && \
    cp /opt/solr/server/lib/ext/log4j-core-${LOG4J_VERSION}.jar /opt/solr/contrib/prometheus-exporter/lib/ && \
    cp /opt/solr/server/lib/ext/log4j-api-${LOG4J_VERSION}.jar /opt/solr/contrib/prometheus-exporter/lib/ \
    && \
    cleanup.sh && \

# Defaults environment variables to be overloaded.
ENV \
    SOLR_JAVA_OPTS= \
    SOLR_JETTY_OPTS= \
    SOLR_LOG_LEVEL=INFO \
    SOLR_MEMORY=512m

COPY --link rootfs /
