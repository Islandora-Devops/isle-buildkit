# syntax=docker/dockerfile:1.5.1
FROM java

ARG TARGETARCH
# renovate: datasource=github-tags depName=apache-solr packageName=apache/solr
ARG SOLR_VERSION=9.5.0
ARG SOLR_FILE=solr-${SOLR_VERSION}.tgz
ARG SOLR_URL=https://archive.apache.org/dist/solr/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.tgz
ARG SOLR_FILE_SHA256=d8538502019af1945e0b124a4613b46ca43aedcf3f20e9912c482c080407ea21
# renovate: datasource=github-releases depName=solr-ocrhighlighting packageName=dbmdz/solr-ocrhighlighting
ARG OCRHIGHLIGHT_VERSION=0.9.0
ARG OCRHIGHLIGHT_FILE=solr-ocrhighlighting-${OCRHIGHLIGHT_VERSION}.jar
ARG OCRHIGHLIGHT_URL=https://github.com/dbmdz/solr-ocrhighlighting/releases/download/${OCRHIGHLIGHT_VERSION}/solr-ocrhighlighting-${OCRHIGHLIGHT_VERSION}.jar
ARG OCRHIGHLIGHT_FILE_SHA256=79eb7374989359c74903daefbe61f7feb9aeb7367ee6f7e1361fe8b911d2fa82
ARG OCRHIGHLIGHT_DEST=/opt/solr/server/solr/contrib/ocrhighlighting/lib

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

RUN --mount=type=cache,id=solr-ocrhighlight-downloads,sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${OCRHIGHLIGHT_URL}" \
        --sha256 "${OCRHIGHLIGHT_FILE_SHA256}" \
        --dest ${OCRHIGHLIGHT_DEST} \
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
