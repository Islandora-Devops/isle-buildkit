# syntax=docker/dockerfile:1.5.1
FROM tomcat

ARG TARGETARCH
ARG BLAZEGRAPH_VERSION="CANDIDATE_2_1_5"
ARG BLAZEGRAPH_FILE="blazegraph.war"
ARG BLAZEGRAPH_URL="https://github.com/blazegraph/database/releases/download/BLAZEGRAPH_RELEASE_${BLAZEGRAPH_VERSION}/${BLAZEGRAPH_FILE}"
ARG BLAZEGRAPH_SHA256="b22f1a1aa8e536443db9a57da63720813374ef59e4021cfa9ad0e98f9a420e85"

# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=blazegraph-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${BLAZEGRAPH_URL}" \
        --sha256 "${BLAZEGRAPH_SHA256}" \
        --dest "/opt/tomcat/webapps/bigdata" \
    && \
    cleanup.sh

COPY --link rootfs /

RUN chown -R tomcat:tomcat /opt/tomcat
