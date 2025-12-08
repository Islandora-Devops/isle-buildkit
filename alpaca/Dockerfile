# syntax=docker/dockerfile:1.5.1
FROM gradle:6.9.4-jdk11@sha256:a21f8e1124fefb9b2affc85b7fa3bc856297056678b5cc882a61a8d6249da3a2 AS builder

ARG ALPACA_BRANCH="x-islandora-event-header"
ARG ALPACA_REPO="https://github.com/Islandora/Alpaca"

WORKDIR /build

RUN --mount=type=cache,id=alpaca-gradle,sharing=locked,target=/root/.gradle \
    git clone "${ALPACA_REPO}" . && \
    git checkout "${ALPACA_BRANCH}" && \
    ./gradlew --stacktrace clean build shadowJar --no-daemon

FROM java

ARG TARGETARCH

RUN mkdir -p /opt/alpaca

COPY --from=builder /build/islandora-alpaca-app/build/libs/islandora-alpaca-app-*-all.jar /opt/alpaca/alpaca.jar

RUN test -f /opt/alpaca/alpaca.jar && \
    create-service-user.sh --name alpaca && \
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
    ALPACA_DERIVATIVE_FITS_URL=http://crayfits:8080/ \
    ALPACA_DERIVATIVE_HOMARUS_ASYNC_CONSUMER=true \
    ALPACA_DERIVATIVE_HOMARUS_CONSUMERS=-1 \
    ALPACA_DERIVATIVE_HOMARUS_ENABLED=true \
    ALPACA_DERIVATIVE_HOMARUS_MAX_CONSUMERS=-1 \
    ALPACA_DERIVATIVE_HOMARUS_QUEUE=queue:islandora-connector-homarus \
    ALPACA_DERIVATIVE_HOMARUS_URL=http://homarus:8080/ \
    ALPACA_DERIVATIVE_HOUDINI_ASYNC_CONSUMER=true \
    ALPACA_DERIVATIVE_HOUDINI_CONSUMERS=-1 \
    ALPACA_DERIVATIVE_HOUDINI_ENABLED=true \
    ALPACA_DERIVATIVE_HOUDINI_MAX_CONSUMERS=-1 \
    ALPACA_DERIVATIVE_HOUDINI_QUEUE=queue:islandora-connector-houdini \
    ALPACA_DERIVATIVE_HOUDINI_URL=http://houdini:8080/ \
    ALPACA_DERIVATIVE_OCR_ASYNC_CONSUMER=true \
    ALPACA_DERIVATIVE_OCR_CONSUMERS=-1 \
    ALPACA_DERIVATIVE_OCR_ENABLED=true \
    ALPACA_DERIVATIVE_OCR_MAX_CONSUMERS=-1 \
    ALPACA_DERIVATIVE_OCR_QUEUE=queue:islandora-connector-ocr \
    ALPACA_DERIVATIVE_OCR_URL=http://hypercube:8080/ \
    ALPACA_DERIVATIVE_SYSTEMS=fits,homarus,houdini,ocr,transkribus,mergepdf \
    ALPACA_DERIVATIVE_TRANSKRIBUS_ASYNC_CONSUMER=true \
    ALPACA_DERIVATIVE_TRANSKRIBUS_CONSUMERS=-1 \
    ALPACA_DERIVATIVE_TRANSKRIBUS_ENABLED=false \
    ALPACA_DERIVATIVE_TRANSKRIBUS_MAX_CONSUMERS=-1 \
    ALPACA_DERIVATIVE_TRANSKRIBUS_QUEUE=queue:islandora-connector-transkribus \
    ALPACA_DERIVATIVE_TRANSKRIBUS_URL=http://transkribus:5000/ \
    ALPACA_DERIVATIVE_MERGEPDF_ASYNC_CONSUMER=true \
    ALPACA_DERIVATIVE_MERGEPDF_CONSUMERS=-1 \
    ALPACA_DERIVATIVE_MERGEPDF_ENABLED=true \
    ALPACA_DERIVATIVE_MERGEPDF_MAX_CONSUMERS=-1 \
    ALPACA_DERIVATIVE_MERGEPDF_QUEUE=queue:islandora-connector-mergepdf \
    ALPACA_DERIVATIVE_MERGEPDF_URL=http://mergepdf:8080/ \
    ALPACA_FCREPO_INDEXER_ASYNC_CONSUMER=true \
    ALPACA_FCREPO_INDEXER_CONSUMERS=-1 \
    ALPACA_FCREPO_INDEXER_ENABLED=true \
    ALPACA_FCREPO_INDEXER_MAX_CONSUMERS=-1 \
    ALPACA_FCREPO_INDEXER_MILLINER_URL=http://milliner:8000/ \
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
