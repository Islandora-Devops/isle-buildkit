# syntax=docker/dockerfile:1.5.1
FROM java

ARG TARGETARCH
ARG ALPACA_VERSION="2.2.0"
ARG ALPACA_FILE="islandora-alpaca-app-${ALPACA_VERSION}-all.jar"
ARG ALPACA_URL="https://repo1.maven.org/maven2/ca/islandora/alpaca/islandora-alpaca-app/${ALPACA_VERSION}/${ALPACA_FILE}"
ARG ALPACA_FILE_SHA256="5722306dd78f9fdc3d7a4248a527c439143a3472e5b2d4ea10601b0038b43923"

# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=alpaca-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${ALPACA_URL}" \
        --sha256 "${ALPACA_FILE_SHA256}" \
    && \
    mkdir -p /opt/alpaca && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/${ALPACA_FILE}" "/opt/alpaca/alpaca.jar" && \
    cleanup.sh

RUN create-service-user.sh --name alpaca && \
    cleanup.sh

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

COPY --link rootfs /

WORKDIR /opt/alpaca