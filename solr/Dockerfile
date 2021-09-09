# syntax=docker/dockerfile:experimental
FROM local/java:latest

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    DOWNLOAD_CACHE_DIRECTORY="/opt/downloads" && \
    SOLR_VERSION="8.9.0" && \
    SOLR_FILE="solr-${SOLR_VERSION}.tgz" && \
    SOLR_URL="https://archive.apache.org/dist/lucene/solr/${SOLR_VERSION}/${SOLR_FILE}" && \
    SOLR_FILE_SHA256="c9c970e0603318eac1ca5bae24e9a85e917d012266159237e572e636c5a3da62" && \
    SOLR_SIG_SHA256="7edba1222681a2c9593b602f5e2d3c3b6b0a8d81f227008c55b63cc913fc3b80" && \
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
