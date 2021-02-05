# syntax=docker/dockerfile:experimental
FROM local/java:latest

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    SOLR_VERSION="8.8.0" && \
    SOLR_FILE="solr-${SOLR_VERSION}.tgz" && \
    SOLR_URL="https://archive.apache.org/dist/lucene/solr/${SOLR_VERSION}/${SOLR_FILE}" && \
    SOLR_FILE_SHA256="7318752d1d30fa2ef839eb3d2df0f2bdb2709d304aa4870b02b33b91e945b054" && \
    SOLR_SIG_SHA256="4577e5ac15f87a5c110471520d7b829826e95224da2648b762abbc718b3c5da6" && \
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
