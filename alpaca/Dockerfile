# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
ARG alpine=3.15.0
FROM --platform=$BUILDPLATFORM ${repository}/download:${tag} AS download

RUN --mount=type=cache,id=alpaca-downloads,sharing=locked,target=/opt/downloads \
    ALPACA_VERSION="2.2.0" && \
    ALPACA_FILE="islandora-alpaca-app-${ALPACA_VERSION}-all.jar" && \
    ALPACA_URL="https://repo1.maven.org/maven2/ca/islandora/alpaca/islandora-alpaca-app/${ALPACA_VERSION}/${ALPACA_FILE}" && \
    ALPACA_FILE_SHA256="5722306dd78f9fdc3d7a4248a527c439143a3472e5b2d4ea10601b0038b43923" && \
    download.sh --url "${ALPACA_URL}" --sha256 "${ALPACA_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-service.sh \
        --name alpaca \
        --file "${DOWNLOAD_CACHE_DIRECTORY}/${ALPACA_FILE}" && \
    mv "/opt/alpaca/${ALPACA_FILE}" "/opt/alpaca/alpaca.jar"

FROM alpine:${alpine} AS cache
FROM ${repository}/java:${tag}

ENV \
    ALPACA_CLIENT_ADDITIONAL_OPTIONS= \
    ALPACA_CLIENT_CONFIGURER=true \
    ALPACA_CLIENT_CONNECTION_TIMEOUT=-1 \
    ALPACA_CLIENT_REQUEST_TIMEOUT=-1 \
    ALPACA_CLIENT_SOCKET_TIMEOUT=-1 \
    ALPACA_DERIVATIVE_FITS_ASYNC_CONSUMER=true \
    ALPACA_DERIVATIVE_FITS_CONSUMERS=-1 \
    ALPACA_DERIVATIVE_FITS_ENABLED=true \
    ALPACA_DERIVATIVE_FITS_MAX_CONSUMERS=-1 \
    ALPACA_DERIVATIVE_FITS_QUEUE=queue:islandora-connector-fits \
    ALPACA_DERIVATIVE_FITS_URL=http://crayfits:8000 \
    ALPACA_DERIVATIVE_HOMARUS_ASYNC_CONSUMER=true \
    ALPACA_DERIVATIVE_HOMARUS_CONSUMERS=-1 \
    ALPACA_DERIVATIVE_HOMARUS_ENABLED=true \
    ALPACA_DERIVATIVE_HOMARUS_MAX_CONSUMERS=-1 \
    ALPACA_DERIVATIVE_HOMARUS_QUEUE=queue:islandora-connector-homarus \
    ALPACA_DERIVATIVE_HOMARUS_URL=http://homarus:8000/convert \
    ALPACA_DERIVATIVE_HOUDINI_ASYNC_CONSUMER=true \
    ALPACA_DERIVATIVE_HOUDINI_CONSUMERS=-1 \
    ALPACA_DERIVATIVE_HOUDINI_ENABLED=true \
    ALPACA_DERIVATIVE_HOUDINI_MAX_CONSUMERS=-1 \
    ALPACA_DERIVATIVE_HOUDINI_QUEUE=queue:islandora-connector-houdini \
    ALPACA_DERIVATIVE_HOUDINI_URL=http://houdini:8000/convert \
    ALPACA_DERIVATIVE_OCR_ASYNC_CONSUMER=true \
    ALPACA_DERIVATIVE_OCR_CONSUMERS=-1 \
    ALPACA_DERIVATIVE_OCR_ENABLED=true \
    ALPACA_DERIVATIVE_OCR_MAX_CONSUMERS=-1 \
    ALPACA_DERIVATIVE_OCR_QUEUE=queue:islandora-connector-ocr \
    ALPACA_DERIVATIVE_OCR_URL=http://hypercube:8000 \
    ALPACA_DERIVATIVE_SYSTEMS=fits,homarus,houdini,ocr \
    ALPACA_FCREPO_INDEXER_ASYNC_CONSUMER=true \
    ALPACA_FCREPO_INDEXER_CONSUMERS=-1 \
    ALPACA_FCREPO_INDEXER_ENABLE=true \
    ALPACA_FCREPO_INDEXER_MAX_CONSUMERS=-1 \
    ALPACA_FCREPO_INDEXER_MILLINER_URL=http://milliner:8000 \
    ALPACA_FCREPO_INDEXER_QUEUE_DELETE=queue:islandora-indexing-fcrepo-delete \
    ALPACA_FCREPO_INDEXER_QUEUE_EXTERNAL=queue:islandora-indexing-fcrepo-file-external \
    ALPACA_FCREPO_INDEXER_QUEUE_MEDIA=queue:islandora-indexing-fcrepo-media \
    ALPACA_FCREPO_INDEXER_QUEUE_NODE=queue:islandora-indexing-fcrepo-content \
    ALPACA_JAVA_OPTS= \
    ALPACA_JMS_CONNECTIONS=10 \
    ALPACA_JMS_CONSUMERS=1 \
    ALPACA_JMS_PASSWORD=password \
    ALPACA_JMS_URL=tcp://activemq:61616 \
    ALPACA_JMS_USER=admin \
    ALPACA_MAX_REDELIVERIES=5 \
    ALPACA_TRIPLESTORE_INDEXER_ASYNC_CONSUMER=true \
    ALPACA_TRIPLESTORE_INDEXER_CONSUMERS=-1 \
    ALPACA_TRIPLESTORE_INDEXER_ENABLED=true \
    ALPACA_TRIPLESTORE_INDEXER_MAX_CONSUMERS=-1 \
    ALPACA_TRIPLESTORE_INDEXER_QUEUE_DELETE=queue:islandora-indexing-triplestore-delete \
    ALPACA_TRIPLESTORE_INDEXER_QUEUE_INDEX=queue:islandora-indexing-triplestore-index \
    ALPACA_TRIPLESTORE_INDEXER_URL=http://blazegraph:8080/bigdata/namespace/islandora/sparql

WORKDIR /opt/alpaca

COPY --link --from=download /etc/group /etc/group
COPY --link --from=download /etc/passwd /etc/passwd
COPY --link --from=download /etc/shadow /etc/shadow
COPY --link --from=download /opt/alpaca /opt/alpaca

COPY --link rootfs /

RUN chown -R alpaca:alpaca /opt/alpaca
