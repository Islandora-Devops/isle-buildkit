# syntax=docker/dockerfile:1.20.0
FROM java AS syn-builder

ARG TARGETARCH

ARG SYN_VERSION=fix-tomcat11-release-2x
ARG SYN_REF=refs/heads/${SYN_VERSION}
ARG SYN_REPOSITORY=https://github.com/Islandora/Syn.git
ARG SYN_FILE=islandora-syn-${SYN_VERSION}-all.jar
ARG SYN_RELEASE_URL=https://github.com/Islandora/Syn/releases/download/v${SYN_VERSION}/${SYN_FILE}
ARG SYN_SHA256=2ee12833f46aab8980e872a255612865323bf22165f86b8f5208018c1775afa5

WORKDIR /build/syn

RUN --mount=type=cache,id=fcrepo-syn-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    --mount=type=cache,id=fcrepo-syn-gradle,sharing=locked,target=/root/.gradle \
    mkdir -p /opt/syn-artifact && \
    if [[ "${SYN_REF}" == refs/tags/* ]]; then \
        download.sh \
            --url "${SYN_RELEASE_URL}" \
            --sha256 "${SYN_SHA256}" \
            --dest /opt/syn-artifact; \
        mv "/opt/syn-artifact/${SYN_FILE}" /opt/syn-artifact/islandora-syn.jar; \
    else \
        git init .; \
        git remote add origin "${SYN_REPOSITORY}"; \
        git fetch --depth 1 origin "${SYN_REF}"; \
        git checkout --detach FETCH_HEAD; \
        ./gradlew --stacktrace clean build shadowJar --no-daemon; \
        cp build/libs/islandora-syn-*-all.jar /opt/syn-artifact/islandora-syn.jar; \
    fi

FROM tomcat

ARG TARGETARCH

# renovate: datasource=github-releases depName=fcrepo packageName=fcrepo/fcrepo
ARG FCREPO_VERSION=7.0.0
ARG FCREPO_FILE=fcrepo-webapp-${FCREPO_VERSION}.war
ARG FCREPO_URL=https://github.com/fcrepo/fcrepo/releases/download/fcrepo-${FCREPO_VERSION}/${FCREPO_FILE}
ARG FCREPO_SHA256="83e19e9ccddaf74dd36f6e1164156ef8eb91262175b9456820138413f0ae2244"

# renovate: datasource=github-releases depName=fcrepo-import-export packageName=fcrepo-exts/fcrepo-import-export
ARG IMPORT_EXPORT_VERSION=1.2.0
ARG IMPORT_EXPORT_FILE=fcrepo-import-export-${IMPORT_EXPORT_VERSION}.jar
ARG IMPORT_EXPORT_URL=https://github.com/fcrepo-exts/fcrepo-import-export/releases/download/fcrepo-import-export-${IMPORT_EXPORT_VERSION}/${IMPORT_EXPORT_FILE}
ARG IMPORT_EXPORT_SHA256=e767f43b0b4f639042b0e399ebfebdf61957515d585b7f0d2d8aeb9f877b12a0

# renovate: datasource=github-releases depName=fcrepo-upgrade-utils packageName=fcrepo-exts/fcrepo-upgrade-utils
ARG UPGRADE_UTILS_VERSION=6.3.0
ARG UPGRADE_UTILS_FILE=fcrepo-upgrade-utils-${UPGRADE_UTILS_VERSION}.jar
ARG UPGRADE_UTILS_URL=https://github.com/fcrepo-exts/fcrepo-upgrade-utils/releases/download/fcrepo-upgrade-utils-${UPGRADE_UTILS_VERSION}/${UPGRADE_UTILS_FILE}
ARG UPGRADE_UTILS_SHA256=a897faeda52322ead9b619dfadab6f77d3f4b3c5baf8ab3f188e8d8769430348

# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=fcrepo-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url ${FCREPO_URL} \
        --sha256 ${FCREPO_SHA256} \
        --dest /opt/tomcat/webapps/fcrepo \
    && \
    download.sh \
        --url ${IMPORT_EXPORT_URL} \
        --sha256 ${IMPORT_EXPORT_SHA256} \
        --dest /opt/tomcat \
    && \
    download.sh \
        --url ${UPGRADE_UTILS_URL} \
        --sha256 ${UPGRADE_UTILS_SHA256} \
        --dest /opt/tomcat \
    && \
    cleanup.sh

ENV \
    FCREPO_ACTIVEMQ_BROKER=tcp://activemq:61616 \
    FCREPO_ACTIVEMQ_QUEUE=fedora \
    FCREPO_ACTIVEMQ_TOPIC=fedora \
    FCREPO_DB_NAME=fcrepo \
    FCREPO_DB_PASSWORD=password \
    FCREPO_DB_USER=fcrepo \
    FCREPO_DISABLE_SYN=false \
    FCREPO_PERSISTENCE_TYPE=file \
    FCREPO_TOMCAT_ADMIN_ROLES=manager-gui,fedoraAdmin \
    FCREPO_S3_BUCKET= \
    FCREPO_S3_PASSWORD= \
    FCREPO_S3_USER= \
    FCREPO_AWS_REGION=us-east-1 \
    FCREPO_S3_PREFIX= \
    FCREPO_SESSION_TIMEOUT=180000

COPY --from=syn-builder /opt/syn-artifact/islandora-syn.jar /opt/tomcat/lib/islandora-syn.jar

COPY --link rootfs /

RUN chown -R tomcat:tomcat /opt/tomcat

HEALTHCHECK CMD curl -s http://localhost:8080/fcrepo/rest/fcr:systeminfo | jq -e .version
