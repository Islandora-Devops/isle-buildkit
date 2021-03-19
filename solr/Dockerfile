# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/download:${tag} AS download

RUN --mount=type=cache,id=solr-downloads,sharing=locked,target=/opt/downloads \
    SOLR_VERSION="7.1.0" && \
    SOLR_FILE="solr-${SOLR_VERSION}.tgz" && \
    SOLR_URL="https://archive.apache.org/dist/lucene/solr/${SOLR_VERSION}/${SOLR_FILE}" && \
    SOLR_FILE_SHA256="5cd25cc2634e47efbb529658d6ddd406a7cd1b211affa26563a28db2d80b8133" && \
    SOLR_SIG_SHA256="b187742e041a7315661b414bbadc69814e2a380ce49c0c2cc7c96acf0846d03b" && \
    download.sh --url "${SOLR_URL}" --sha256 "${SOLR_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    download.sh --url "${SOLR_URL}.asc" --sha256 "${SOLR_SIG_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-apache-service.sh \
        --name solr \
        --key "38D2EA16DDF5FC722EBC433FDC92616F177050F6" \
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
