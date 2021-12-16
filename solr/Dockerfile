# syntax=docker/dockerfile:experimental
FROM local/java:latest

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    SOLR_VERSION="8.11.1" && \
    SOLR_FILE="solr-${SOLR_VERSION}.tgz" && \
    SOLR_URL="https://dlcdn.apache.org/lucene/solr/${SOLR_VERSION}/${SOLR_FILE}" && \
    SOLR_FILE_SHA256="9ec540cbd8e45f3d15a6b615a22939f5e6242ca81099951a47d3c082c79866a9" && \
    SOLR_SIG_SHA256="6a1eca93d0d0a80647cb60063f5e46347350b03a0f75b6a662d1b0a4746dabba" && \
    download.sh --url "${SOLR_URL}" --sha256 "${SOLR_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    download.sh --url "${SOLR_URL}.asc" --sha256 "${SOLR_SIG_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-apache-service.sh \
        --name solr \
        --key "CFCE5FBB920C3C745CEEE084C38FF5EC3FCFDB3E" \
        --file "${DOWNLOAD_CACHE_DIRECTORY}/${SOLR_FILE}" \ 
        docs example licenses server/solr/configsets

WORKDIR /opt/solr

EXPOSE 8983

COPY rootfs /
