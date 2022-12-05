# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
ARG alpine=3.15.0
FROM --platform=$BUILDPLATFORM ${repository}/download:${tag} AS download

ARG SOLR_VERSION="8.11.2"
ARG SOLR_FILE_SHA256="54d6ebd392942f0798a60d50a910e26794b2c344ee97c2d9b50e678a7066d3a6"

RUN --mount=type=cache,id=solr-downloads,sharing=locked,target=/opt/downloads \
    SOLR_FILE="solr-${SOLR_VERSION}.tgz" && \
    SOLR_URL="https://archive.apache.org/dist/lucene/solr/${SOLR_VERSION}/${SOLR_FILE}" && \
    download.sh --url "${SOLR_URL}" --sha256 "${SOLR_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-apache-service.sh \
        --name solr \
        --file "${DOWNLOAD_CACHE_DIRECTORY}/${SOLR_FILE}" \
        docs example licenses server/solr/configsets

FROM alpine:${alpine} AS cache
FROM ${repository}/java:${tag}

EXPOSE 8983

# Defaults environment variables to be overloaded.
ENV \
    SOLR_JAVA_OPTS= \
    SOLR_JETTY_OPTS= \
    SOLR_LOG_LEVEL=INFO \
    SOLR_MEMORY=512m

WORKDIR /opt/solr

COPY --link --from=download /etc/group /etc/group
COPY --link --from=download /etc/passwd /etc/passwd
COPY --link --from=download /etc/shadow /etc/shadow
COPY --link --from=download /opt/solr /opt/solr

COPY --link rootfs /

RUN mkdir /opt/data && \
    chown -R solr:solr /opt/solr /opt/data
