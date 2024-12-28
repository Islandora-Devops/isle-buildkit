# syntax=docker/dockerfile:1.5.1
FROM tomcat

ARG TARGETARCH

# renovate: datasource=github-releases depName=fcrepo packageName=fcrepo/fcrepo
ARG FCREPO_VERSION=6.5.0
ARG FCREPO_FILE=fcrepo-webapp-${FCREPO_VERSION}.war
ARG FCREPO_URL=https://github.com/fcrepo/fcrepo/releases/download/fcrepo-${FCREPO_VERSION}/${FCREPO_FILE}
ARG FCREPO_SHA256=dd0ac889f253dbe9fb09aa3f1fe4444fd57b51af34ebaaf23daec72fbdc5cf55

# renovate: datasource=github-releases depName=islandora-syn packageName=Islandora/Syn
ARG SYN_VERSION=1.1.1
ARG SYN_FILE=islandora-syn-${SYN_VERSION}-all.jar
ARG SYN_URL=https://github.com/Islandora/Syn/releases/download/v${SYN_VERSION}/${SYN_FILE}
ARG SYN_SHA256=24c589d16d579c48361d14c346e0d633a6985642f1c116295ed91eb32b283085

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
RUN --mount=type=cache,id=fcrepo6-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url ${FCREPO_URL} \
        --sha256 ${FCREPO_SHA256} \
        --dest /opt/tomcat/webapps/fcrepo \
    && \
    download.sh \
        --url ${SYN_URL} \
        --sha256 ${SYN_SHA256} \
        --dest /opt/tomcat/lib \
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
    FCREPO_S3_PREFIX=

COPY --link rootfs /

RUN chown -R tomcat:tomcat /opt/tomcat
