# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
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

FROM ${repository}/java:${tag}

EXPOSE 8983

# Defaults environment variables to be overloaded.
ENV \
    SOLR_JAVA_OPTS= \
    SOLR_JETTY_OPTS= \
    SOLR_LOG_LEVEL=INFO \
    SOLR_MEMORY=512m

COPY --from=download /etc/group /etc/group
COPY --from=download /etc/passwd /etc/passwd
COPY --from=download /etc/shadow /etc/shadow
COPY --from=download --chown=solr:solr /opt/solr /opt/solr

COPY rootfs /

WORKDIR /opt/solr
