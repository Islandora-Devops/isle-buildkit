# syntax=docker/dockerfile:experimental
FROM islandora/java:latest

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    SOLR_VERSION="7.1.0" && \
    install-apache-service.sh \
        --name solr \
        --version "${SOLR_VERSION}" \
        --key "38D2EA16DDF5FC722EBC433FDC92616F177050F6" \
        --mirror "https://archive.apache.org/dist/lucene/solr/${SOLR_VERSION}" \
        --file "solr-${SOLR_VERSION}.tgz" \ 
        docs example licenses server/solr/configsets

WORKDIR /opt/solr

EXPOSE 8983

VOLUME [ "/opt/solr/server/solr" ]

COPY rootfs /
