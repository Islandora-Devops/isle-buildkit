# syntax=docker/dockerfile:1.5.1
FROM java

ARG TARGETARCH
ARG SOLR_VERSION=9.4.1
ARG SOLR_FILE=solr-${SOLR_VERSION}.tgz
ARG SOLR_URL=https://archive.apache.org/dist/solr/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.tgz
ARG SOLR_FILE_SHA256=41015d7a693fefa4b8a537f5d0982adae8f13f382edf39c94a3497f9b3783250

EXPOSE 8983

WORKDIR /opt/solr

# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=solr-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${SOLR_URL}" \
        --sha256 "${SOLR_FILE_SHA256}" \
        --strip \
        --dest "/opt/solr" \
        docs \
        example \
        server/solr/configsets \
    && \
    cleanup.sh

RUN create-service-user.sh --name solr /data && \
    cleanup.sh

# Defaults environment variables to be overloaded.
ENV \
    SOLR_JAVA_OPTS= \
    SOLR_JETTY_OPTS=-Dsolr.jetty.host=0.0.0.0 \
    SOLR_LOG_LEVEL=INFO \
    SOLR_MEMORY=512m

COPY --link rootfs /
