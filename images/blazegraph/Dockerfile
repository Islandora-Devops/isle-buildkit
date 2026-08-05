# syntax=docker/dockerfile:1.20.0
FROM tomcat

ARG TARGETARCH
ARG SOURCE_DATE_EPOCH=0
ARG \
    # renovate: datasource=repology depName=alpine_3_24/strip-nondeterminism
    STRIP_NONDETERMINISM_VERSION=1.15.0-r0
ARG BLAZEGRAPH_VERSION="CANDIDATE_2_1_5"
ARG BLAZEGRAPH_FILE="blazegraph.war"
ARG BLAZEGRAPH_URL="https://github.com/blazegraph/database/releases/download/BLAZEGRAPH_RELEASE_${BLAZEGRAPH_VERSION}/${BLAZEGRAPH_FILE}"
ARG BLAZEGRAPH_SHA256="b22f1a1aa8e536443db9a57da63720813374ef59e4021cfa9ad0e98f9a420e85"

# renovate: datasource=custom.apache-downloads depName=apache-log4j packageName=logging/log4j
ARG LOG4J_VERSION=2.26.0
ARG LOG4J_FILE="apache-log4j-${LOG4J_VERSION}-bin.zip"
ARG LOG4J_URL="https://archive.apache.org/dist/logging/log4j/${LOG4J_VERSION}/${LOG4J_FILE}"
ARG LOG4J_FILE_SHA256="6735d0f8f10c858aa0499aac5500d75fc32464baeb1667e73cdb00562ad20fa6"
ARG OLD_LOG4J_VERSION="1.2.17"

# Blazegraph still targets the Java EE javax namespace, so migrate it for
# Tomcat 11's Jakarta APIs before deployment.
# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=blazegraph-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    --mount=type=cache,id=blazegraph-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add --virtual .jakarta-migration-deps \
        strip-nondeterminism=="${STRIP_NONDETERMINISM_VERSION}" \
    && \
    download.sh \
        --url "${BLAZEGRAPH_URL}" \
        --sha256 "${BLAZEGRAPH_SHA256}" \
        --dest "/opt/tomcat/webapps-javaee/bigdata" \
    && \
    /opt/tomcat/bin/migrate.sh \
        /opt/tomcat/webapps-javaee/bigdata \
        /opt/tomcat/webapps/bigdata \
    && \
    NORMALIZED_TIMESTAMP="$((SOURCE_DATE_EPOCH > 315576060 ? SOURCE_DATE_EPOCH : 315576060))" && \
    find /opt/tomcat/webapps/bigdata -type f -name "*.jar" \
        -exec strip-nondeterminism \
            --type jar \
            --timestamp "${NORMALIZED_TIMESTAMP}" \
            {} + \
        >/dev/null \
    && \
    find /opt/tomcat/webapps/bigdata \
        -exec touch -h -d "@${NORMALIZED_TIMESTAMP}" {} + \
    && \
    apk del .jakarta-migration-deps \
    && \
    rm -rf /opt/tomcat/webapps-javaee \
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
