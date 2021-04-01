# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/download:${tag} AS download

RUN --mount=type=cache,id=blazegraph-downloads,sharing=locked,target=/opt/downloads \
    BLAZEGRAPH_VERSION="CANDIDATE_2_1_5" && \
    BLAZEGRAPH_FILE="blazegraph.war" && \
    BLAZEGRAPH_URL="https://github.com/blazegraph/database/releases/download/BLAZEGRAPH_RELEASE_${BLAZEGRAPH_VERSION}/${BLAZEGRAPH_FILE}" && \
    BLAZEGRAPH_SHA256="b22f1a1aa8e536443db9a57da63720813374ef59e4021cfa9ad0e98f9a420e85" && \
    download.sh --url "${BLAZEGRAPH_URL}" --sha256 "${BLAZEGRAPH_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-war-into-tomcat.sh --name "bigdata" --file "${DOWNLOAD_CACHE_DIRECTORY}/${BLAZEGRAPH_FILE}"

FROM ${repository}/tomcat:${tag}

RUN mkdir /data && \
    chown tomcat:tomcat /data

COPY --from=download --chown=tomcat:tomcat /opt/tomcat /opt/tomcat

COPY rootfs /
COPY --chown=tomcat:tomcat rootfs/opt/tomcat /opt/tomcat
