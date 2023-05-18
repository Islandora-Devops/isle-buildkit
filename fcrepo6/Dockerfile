# syntax=docker/dockerfile:1.5.1
FROM tomcat

ARG TARGETARCH
ARG FCREPO_VERSION="6.3.0"
ARG FCREPO_FILE="fcrepo-webapp-${FCREPO_VERSION}.war"
ARG FCREPO_URL="https://github.com/fcrepo/fcrepo/releases/download/fcrepo-${FCREPO_VERSION}/${FCREPO_FILE}"
ARG FCREPO_SHA256="e7589081b6c747f1e06f46b78d568bb1a3a6853106b884f6f9b1fce4e41d673f"

ARG SYN_VERSION="1.1.0"
ARG SYN_FILE="islandora-syn-${SYN_VERSION}-all.jar"
ARG SYN_URL="https://github.com/Islandora-CLAW/Syn/releases/download/v${SYN_VERSION}/${SYN_FILE}"
ARG SYN_SHA256="bcad5f872930b1bcc9ea4a176c60e22683297121357336769a21ead9fadcbbd5"

ARG IMPORT_EXPORT_VERSION="1.0.1"
ARG IMPORT_EXPORT_FILE="fcrepo-import-export-${IMPORT_EXPORT_VERSION}.jar"
ARG IMPORT_EXPORT_URL="https://github.com/fcrepo-exts/fcrepo-import-export/releases/download/fcrepo-import-export-${IMPORT_EXPORT_VERSION}/${IMPORT_EXPORT_FILE}"
ARG IMPORT_EXPORT_SHA256="89c579d1223c8f3c0da60c4309a06e47f5919c51929d976e60ea525c60cb33d1"

ARG UPGRADE_UTILS_VERSION="6.0.0-beta-1"
ARG UPGRADE_UTILS_FILE="fcrepo-upgrade-utils-${UPGRADE_UTILS_VERSION}.jar"
ARG UPGRADE_UTILS_URL="https://github.com/fcrepo-exts/fcrepo-upgrade-utils/releases/download/fcrepo-upgrade-utils-${UPGRADE_UTILS_VERSION}/${UPGRADE_UTILS_FILE}"
ARG UPGRADE_UTILS_SHA256="e8a0bbbabca45ff95b2ffb5c62cad49e02548bc116b80f2747d5215f80d02a0a"

# Platform agnostic does not require arch specific identifier.
RUN --mount=type=cache,id=fcrepo6-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${FCREPO_URL}" \
        --sha256 "${FCREPO_SHA256}" \
        --dest "/opt/tomcat/webapps/fcrepo" \
    && \
    download.sh \
        --url "${SYN_URL}" \
        --sha256 "${SYN_SHA256}" \
        --dest "/opt/tomcat/lib" \
    && \
    download.sh \
        --url "${IMPORT_EXPORT_URL}" \
        --sha256 "${IMPORT_EXPORT_SHA256}" \
        --dest "/opt/tomcat" \
    && \
    download.sh \
        --url "${UPGRADE_UTILS_URL}" \
        --sha256 "${UPGRADE_UTILS_SHA256}" \
        --dest "/opt/tomcat" \
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
