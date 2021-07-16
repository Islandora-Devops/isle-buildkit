# syntax=docker/dockerfile:experimental
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/download:${tag} AS download

RUN --mount=type=cache,id=fcrepo6-downloads,sharing=locked,target=/opt/downloads \
    FCREPO_VERSION="6.0.0-RC-2" && \
    FCREPO_FILE="fcrepo-webapp-${FCREPO_VERSION}.war" && \
    FCREPO_URL="https://github.com/fcrepo/fcrepo/releases/download/fcrepo-${FCREPO_VERSION}/${FCREPO_FILE}" && \
    FCREPO_SHA256="26274e336f53d1c9a9f17465595bfe421ad3d0fb582f417dde687a900ddf3c79" && \
    download.sh --url "${FCREPO_URL}" --sha256 "${FCREPO_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-war-into-tomcat.sh --name "fcrepo" --file "${DOWNLOAD_CACHE_DIRECTORY}/${FCREPO_FILE}" && \
    SYN_VERSION="1.1.0" && \
    SYN_FILE="islandora-syn-${SYN_VERSION}-all.jar" && \
    SYN_URL="https://github.com/Islandora-CLAW/Syn/releases/download/v${SYN_VERSION}/${SYN_FILE}" && \
    SYN_SHA256="bcad5f872930b1bcc9ea4a176c60e22683297121357336769a21ead9fadcbbd5" && \
    download.sh --url "${SYN_URL}" --sha256 "${SYN_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    mkdir -p /opt/tomcat/lib && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/${SYN_FILE}" /opt/tomcat/lib && \
    IMPORT_EXPORT_VERSION="1.0.1" && \
    IMPORT_EXPORT_FILE="fcrepo-import-export-${IMPORT_EXPORT_VERSION}.jar" && \
    IMPORT_EXPORT_URL="https://github.com/fcrepo-exts/fcrepo-import-export/releases/download/fcrepo-import-export-${IMPORT_EXPORT_VERSION}/${IMPORT_EXPORT_FILE}" && \
    IMPORT_EXPORT_SHA256="89c579d1223c8f3c0da60c4309a06e47f5919c51929d976e60ea525c60cb33d1" && \
    download.sh --url "${IMPORT_EXPORT_URL}" --sha256 "${IMPORT_EXPORT_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/${IMPORT_EXPORT_FILE}" /opt/tomcat && \
    UPGRADE_UTILS_VERSION="6.0.0-beta-1" && \
    UPGRADE_UTILS_FILE="fcrepo-upgrade-utils-${UPGRADE_UTILS_VERSION}.jar" && \
    UPGRADE_UTILS_URL="https://github.com/fcrepo-exts/fcrepo-upgrade-utils/releases/download/fcrepo-upgrade-utils-${UPGRADE_UTILS_VERSION}/${UPGRADE_UTILS_FILE}" && \
    UPGRADE_UTILS_SHA256="e8a0bbbabca45ff95b2ffb5c62cad49e02548bc116b80f2747d5215f80d02a0a" && \
    download.sh --url "${UPGRADE_UTILS_URL}" --sha256 "${UPGRADE_UTILS_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    cp "${DOWNLOAD_CACHE_DIRECTORY}/${UPGRADE_UTILS_FILE}" /opt/tomcat

FROM alpine:3.13.2 AS cache
FROM ${repository}/tomcat:${tag}

# Install packages and tools required by all downstream images.
RUN --mount=type=cache,id=fcrepo6-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk add openjdk11 && \
    mkdir -p /data && \
    chown -R tomcat:tomcat /data && \
    addgroup tomcat jwt && \
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

COPY --from=download --chown=tomcat:tomcat /opt/tomcat /opt/tomcat
COPY rootfs /
COPY --chown=tomcat:tomcat rootfs/opt/tomcat /opt/tomcat
