# syntax=docker/dockerfile:1.20.0
FROM java

ARG TARGETARCH
# renovate: datasource=custom.apache-downloads depName=apache-solr packageName=solr/solr
ARG SOLR_VERSION=10.1.0
ARG SOLR_FILE=solr-${SOLR_VERSION}.tgz
ARG SOLR_URL=https://downloads.apache.org/solr/solr/${SOLR_VERSION}/solr-${SOLR_VERSION}.tgz
ARG SOLR_FILE_SHA256="67c2303404fbce6ca12e82b1f88bde74359b0068a0c882b1046dfb06f9671c38"
# renovate: datasource=github-releases depName=solr-ocrhighlighting packageName=dbmdz/solr-ocrhighlighting
ARG OCRHIGHLIGHT_VERSION=0.11.0
ARG OCRHIGHLIGHT_FILE=solr-ocrhighlighting-${OCRHIGHLIGHT_VERSION}.jar
ARG OCRHIGHLIGHT_URL=https://github.com/dbmdz/solr-ocrhighlighting/releases/download/${OCRHIGHLIGHT_VERSION}/solr-ocrhighlighting-${OCRHIGHLIGHT_VERSION}.jar
ARG OCRHIGHLIGHT_FILE_SHA256="0193f431616738e8ebd8cd221f1167c0826c66a39b27ba3442e59c6a614d345f"
ARG OCRHIGHLIGHT_DEST=/opt/solr/lib

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
    mkdir -p /opt/solr/server/solr/contrib/ocrhighlighting/lib && \
    # v9 support to avoid breaking <lib> directives in solr XML
    ln -s "${OCRHIGHLIGHT_DEST}/solr-ocrhighlighting-${OCRHIGHLIGHT_VERSION}.jar" /opt/solr/server/solr/contrib/ocrhighlighting/lib/ocrhighlighting.jar && \
    cleanup.sh

RUN create-service-user.sh --name solr /data && \
    cleanup.sh

# Defaults environment variables to be overloaded.
ENV \
    SOLR_JAVA_OPTS= \
    SOLR_JETTY_OPTS="-Dsolr.host.bind=0.0.0.0" \
    SOLR_LOG_LEVEL=INFO \
    SOLR_MEMORY=512m \
    SOLR_MODULES=analysis-extras,extraction,langid,ltr

COPY --link rootfs /

HEALTHCHECK CMD curl -s http://localhost:8983/solr/admin/info/system?wt=json | jq -r .responseHeader.status | grep -q 0
