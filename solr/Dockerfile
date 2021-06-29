# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/download:${tag} AS download

RUN --mount=type=cache,id=solr-downloads,sharing=locked,target=/opt/downloads \
    SOLR_VERSION="7.1.0" && \
    SOLR_FILE="solr-${SOLR_VERSION}.tgz" && \
    SOLR_URL="https://archive.apache.org/dist/lucene/solr/${SOLR_VERSION}/${SOLR_FILE}" && \
    SOLR_FILE_SHA256="5cd25cc2634e47efbb529658d6ddd406a7cd1b211affa26563a28db2d80b8133" && \
    download.sh --url "${SOLR_URL}" --sha256 "${SOLR_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-apache-service.sh \
        --name solr \
        --file "${DOWNLOAD_CACHE_DIRECTORY}/${SOLR_FILE}" \
        docs example licenses server/solr/configsets

FROM ${repository}/java:${tag}

EXPOSE 8983

COPY --from=download /etc/group /etc/group
COPY --from=download /etc/passwd /etc/passwd
COPY --from=download /etc/shadow /etc/shadow
COPY --from=download --chown=solr:solr /opt/solr /opt/solr

COPY rootfs /

WORKDIR /opt/solr
