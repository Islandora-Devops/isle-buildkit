# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
ARG alpine=3.15.0
FROM --platform=$BUILDPLATFORM ${repository}/java:${tag} AS download

ARG TOMCAT_VERSION="9.0.58"
ARG TOMCAT_FILE_SHA256="a7895a9f425dd57fba5a1e8685d43754d3ecfe05de80e93bfd245ca8313cc7c1"

RUN --mount=type=cache,id=tomcat-downloads,sharing=locked,target=/opt/downloads \
    TOMCAT_FILE="apache-tomcat-${TOMCAT_VERSION}.tar.gz" && \
    TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/${TOMCAT_FILE}" && \
    download.sh --url "${TOMCAT_URL}" --sha256 "${TOMCAT_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-apache-service.sh \
        --name tomcat \
        --file "${DOWNLOAD_CACHE_DIRECTORY}/${TOMCAT_FILE}" \
        webapps/docs webapps/examples

FROM alpine:${alpine} AS cache
FROM ${repository}/java:${tag}

EXPOSE 8080

COPY --from=download /etc/group /etc/group
COPY --from=download /etc/passwd /etc/passwd
COPY --from=download /etc/shadow /etc/shadow

ENV \
    TOMCAT_ADMIN_NAME=admin \
    TOMCAT_ADMIN_PASSWORD=password \
    TOMCAT_ADMIN_ROLES=manager-gui \
    TOMCAT_CONNECTION_TIMEOUT=20000 \
    TOMCAT_CATALINA_OPTS= \
    TOMCAT_JAVA_OPTS= \
    TOMCAT_LOG_LEVEL=INFO \
    TOMCAT_MANAGER_REMOTE_ADDRESS_VALVE=^.*$

COPY --from=download /opt /opt

COPY rootfs /
COPY --chown=tomcat:tomcat rootfs/opt/tomcat /opt/tomcat

WORKDIR /opt/tomcat