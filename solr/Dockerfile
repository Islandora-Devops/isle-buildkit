# syntax=docker/dockerfile:experimental
FROM local/java:latest

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    SOLR_VERSION="8.11.2" && \
    SOLR_FILE="solr-${SOLR_VERSION}.tgz" && \
    SOLR_URL="https://dlcdn.apache.org/lucene/solr/${SOLR_VERSION}/${SOLR_FILE}" && \
    SOLR_FILE_SHA256="b7f0dc3f1f2cc4a15d1d6e5a680b3681ea0eb5dc88295d30a97e943a94b23f8a" && \
    SOLR_SIG_SHA256="d1f50d28b71950e5f7848f28dd484b010212b28300b449225c625611e8738d2b" && \
    download.sh --url "${SOLR_URL}" --sha256 "${SOLR_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    download.sh --url "${SOLR_URL}.asc" --sha256 "${SOLR_SIG_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-apache-service.sh \
        --name solr \
        --key "86EDB9C33B8517228E88A8F93E48C0C6EF362B9E" \
        --file "${DOWNLOAD_CACHE_DIRECTORY}/${SOLR_FILE}" \ 
        docs example licenses server/solr/configsets

WORKDIR /opt/solr

EXPOSE 8983

COPY rootfs /
