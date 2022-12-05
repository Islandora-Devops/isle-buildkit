# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/download:${tag} AS download

ARG BLAZEGRAPH_VERSION="CANDIDATE_2_1_5"
ARG BLAZEGRAPH_SHA256="b22f1a1aa8e536443db9a57da63720813374ef59e4021cfa9ad0e98f9a420e85"

RUN --mount=type=cache,id=blazegraph-downloads,sharing=locked,target=/opt/downloads \
    BLAZEGRAPH_FILE="blazegraph.war" && \
    BLAZEGRAPH_URL="https://github.com/blazegraph/database/releases/download/BLAZEGRAPH_RELEASE_${BLAZEGRAPH_VERSION}/${BLAZEGRAPH_FILE}" && \
    download.sh --url "${BLAZEGRAPH_URL}" --sha256 "${BLAZEGRAPH_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-war-into-tomcat.sh --name "bigdata" --file "${DOWNLOAD_CACHE_DIRECTORY}/${BLAZEGRAPH_FILE}"

FROM ${repository}/tomcat:${tag}

COPY --link --from=download /opt/tomcat /opt/tomcat

COPY --link rootfs /

RUN chown -R tomcat:tomcat /opt/tomcat
