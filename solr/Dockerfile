# syntax=docker/dockerfile:1.5.1
FROM java

ARG TARGETARCH
# renovate: datasource=github-tags depName=apache-solr packageName=apache/solr
ARG SOLR_VERSION=9.8.0
ARG SOLR_FILE=solr-${SOLR_VERSION}.tgz
ARG SOLR_URL=https://archive.apache.org/dist/solr/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.tgz
ARG SOLR_FILE_SHA256="9948dcf798c196b834c4cbb420d1ea5995479431669d266c33d46548b67e69e1"
# renovate: datasource=github-releases depName=solr-ocrhighlighting packageName=dbmdz/solr-ocrhighlighting
ARG OCRHIGHLIGHT_VERSION=0.9.2
ARG OCRHIGHLIGHT_FILE=solr-ocrhighlighting-${OCRHIGHLIGHT_VERSION}.jar
ARG OCRHIGHLIGHT_URL=https://github.com/dbmdz/solr-ocrhighlighting/releases/download/${OCRHIGHLIGHT_VERSION}/solr-ocrhighlighting-${OCRHIGHLIGHT_VERSION}.jar
ARG OCRHIGHLIGHT_FILE_SHA256="e47ccc180fb0eecb9b68fa8506bbe0b22d416758a5277bce58073e898f9e07fb"
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
    SOLR_JETTY_OPTS="-Dsolr.jetty.host=0.0.0.0 -Dsolr.config.lib.enabled=true" \
    SOLR_LOG_LEVEL=INFO \
    SOLR_MEMORY=512m

COPY --link rootfs /

HEALTHCHECK CMD curl -s http://localhost:8983/solr/admin/info/system?wt=json | jq -r .responseHeader.status | grep -q 0
