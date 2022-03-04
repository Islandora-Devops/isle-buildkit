# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/karaf:${tag} AS download

# Install common features and repos
RUN bin/start && \
    ALPACA_VERSION=1.0.5 && \
    ACTIVEMQ_VERSION=5.15.0 && \
    CAMEL_VERSION=2.20.4 && \
    bin/client -r 10 -d 5  "feature:repo-add mvn:ca.islandora.alpaca/islandora-karaf/${ALPACA_VERSION}/xml/features" && \
    bin/client -r 10 -d 5  "feature:repo-add mvn:org.apache.activemq/activemq-karaf/${ACTIVEMQ_VERSION}/xml/features" && \
    bin/client -r 10 -d 5  "feature:repo-add mvn:org.apache.camel.karaf/apache-camel/${CAMEL_VERSION}/xml/features" && \
    bin/client -r 10 -d 5  "feature:install -v fcrepo-service-activemq" && \
    bin/client -r 10 -d 5  "feature:install -v fcrepo-service-camel" && \
    bin/client -r 10 -d 5  "feature:install -v islandora-http-client" && \
    bin/stop && \
    rm -rf instances/*

# Derivative connector
RUN bin/start && \
    bin/client -r 10 -d 5  "feature:install -v islandora-connector-derivative" && \
    bin/stop && \
    rm -rf instances/*

# Fcrepo indexing
RUN bin/start && \
    bin/client -r 10 -d 5  "feature:install -v islandora-indexing-fcrepo" && \
    bin/stop && \
    rm -rf instances/*

# Triple indexing
RUN bin/start && \
    bin/client -r 10 -d 5  "feature:install islandora-indexing-triplestore" && \
    bin/stop && \
    rm -rf instances/*

# Fix up ownership.
RUN chown -R karaf:karaf /opt/karaf

FROM ${repository}/karaf:${tag}

ENV \
    ALPACA_ACTIVEMQ_PASSWORD=password \
    ALPACA_ACTIVEMQ_URL=tcp://activemq:61616 \
    ALPACA_ACTIVEMQ_USER=admin \
    ALPACA_FCREPO_AUTH_HOST= \
    ALPACA_FCREPO_AUTH_PASSWORD= \
    ALPACA_FCREPO_AUTH_USER= \
    ALPACA_FCREPO_URL=http://fcrepo/fcrepo/rest \
    ALPACA_FITS_QUEUE=broker:queue:islandora-connector-fits \
    ALPACA_FITS_REDELIVERIES=10 \
    ALPACA_FITS_SERVICE=http://crayfits:8000 \
    ALPACA_FITS_TIMEOUT=10000 \
    ALPACA_HOMARUS_QUEUE=broker:queue:islandora-connector-homarus \
    ALPACA_HOMARUS_REDELIVERIES=10 \
    ALPACA_HOMARUS_SERVICE=http://homarus:8000/convert \
    ALPACA_HOMARUS_TIMEOUT=10000 \
    ALPACA_HOUDINI_QUEUE=broker:queue:islandora-connector-houdini \
    ALPACA_HOUDINI_REDELIVERIES=10 \
    ALPACA_HOUDINI_SERVICE=http://houdini:8000/convert \
    ALPACA_HOUDINI_TIMEOUT=10000 \
    ALPACA_HTTP_TOKEN=islandora \
    ALPACA_INDEXING_MILLINER_URL=http://milliner:8000 \
    ALPACA_INDEXING_REDELIVERIES=10 \
    ALPACA_INDEXING_STREAM_FILE_DELETE=broker:queue:islandora-indexing-fcrepo-file-delete \
    ALPACA_INDEXING_STREAM_FILE_EXTERNAL=broker:queue:islandora-indexing-fcrepo-file-external \
    ALPACA_INDEXING_STREAM_INPUT=broker:topic:fedora \
    ALPACA_INDEXING_STREAM_MEDIA_INDEX=broker:queue:islandora-indexing-fcrepo-media \
    ALPACA_INDEXING_STREAM_NODE_DELETE=broker:queue:islandora-indexing-fcrepo-delete \
    ALPACA_INDEXING_STREAM_NODE_INDEX=broker:queue:islandora-indexing-fcrepo-content \
    ALPACA_INDEXING_STREAM_TRIPLESTORE_DELETE=broker:queue:islandora-indexing-triplestore-delete \
    ALPACA_INDEXING_STREAM_TRIPLESTORE_INDEX=broker:queue:islandora-indexing-triplestore-index \
    ALPACA_INDEXING_STREAM_TRIPLESTORE_REINDEX=broker:queue:triplestore.reindex \
    ALPACA_INDEXING_URL=http://blazegraph:8080/bigdata/namespace/islandora/sparql \
    ALPACA_LOGGER_CAMEL_LEVEL=WARN \
    ALPACA_LOGGER_ISLANDORA_LEVEL=WARN \
    ALPACA_LOGGER_ROOT_LEVEL=WARN \
    ALPACA_OCR_QUEUE=broker:queue:islandora-connector-ocr \
    ALPACA_OCR_REDELIVERIES=10 \
    ALPACA_OCR_SERVICE=http://hypercube:8000 \
    ALPACA_OCR_TIMEOUT=10000 \
    JAVA_OPTS="-Dfile.encoding=UTF-8 -Dnet.sf.ehcache.skipUpdateCheck=true -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:+UseParNewGC -XX:MaxPermSize=128m -Xms512m -Xmx8g"

COPY --from=download --chown=karaf:karaf /opt/karaf /opt/karaf
COPY --from=download /root/.m2 /root/.m2

COPY rootfs /
