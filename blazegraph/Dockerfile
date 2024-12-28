# syntax=docker/dockerfile:1.5.1
FROM tomcat

ARG TARGETARCH
ARG BLAZEGRAPH_VERSION="CANDIDATE_2_1_5"
ARG BLAZEGRAPH_FILE="blazegraph.war"
ARG BLAZEGRAPH_URL="https://github.com/blazegraph/database/releases/download/BLAZEGRAPH_RELEASE_${BLAZEGRAPH_VERSION}/${BLAZEGRAPH_FILE}"
ARG BLAZEGRAPH_SHA256="b22f1a1aa8e536443db9a57da63720813374ef59e4021cfa9ad0e98f9a420e85"

# renovate: datasource=github-releases depName=apache-log4j packageName=apache/logging-log4j2
ARG LOG4J_VERSION=2.22.0
ARG LOG4J_FILE="apache-log4j-${LOG4J_VERSION}-bin.zip"
ARG LOG4J_URL="https://archive.apache.org/dist/logging/log4j/${LOG4J_VERSION}/${LOG4J_FILE}"
ARG LOG4J_FILE_SHA256="359ef2d7278b67a72053239c1c8cdba44a5681097835d010982470e121c2338a"
ARG OLD_LOG4J_VERSION="1.2.17"

# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=blazegraph-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${BLAZEGRAPH_URL}" \
        --sha256 "${BLAZEGRAPH_SHA256}" \
        --dest "/opt/tomcat/webapps/bigdata" \
    && \
    ## Remove the outmoded log4j-* files that come with blazegraph
    rm -f "/opt/tomcat/webapps/bigdata/WEB-INF/lib/log4j-${OLD_LOG4J_VERSION}.jar" && \
    cleanup.sh

# Now drop in newer log4j-* files
RUN --mount=type=cache,id=log4j-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${LOG4J_URL}" \
        --sha256 "${LOG4J_FILE_SHA256}" \
    && \
    ## Add new log4j-* files
    unzip -o "${DOWNLOAD_CACHE_DIRECTORY}/${LOG4J_FILE}" -d "${DOWNLOAD_CACHE_DIRECTORY}" && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/log4j-1.2-api-${LOG4J_VERSION}.jar" /opt/tomcat/webapps/bigdata/WEB-INF/lib/ && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/log4j-api-${LOG4J_VERSION}.jar" /opt/tomcat/webapps/bigdata/WEB-INF/lib/ && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/log4j-core-${LOG4J_VERSION}.jar" /opt/tomcat/webapps/bigdata/WEB-INF/lib/ && \
    cleanup.sh

COPY --link rootfs /

RUN chown -R tomcat:tomcat /opt/tomcat
