# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
ARG alpine=3.16.2
FROM --platform=$BUILDPLATFORM ${repository}/java:${tag} AS download

ARG TOMCAT_VERSION="9.0.69"
ARG TOMCAT_FILE_SHA256="ef6564505f43f8f50afc25b7aa3b1ee4bae8c937f1d93131007f179fab92805a"

RUN --mount=type=cache,id=tomcat-downloads,sharing=locked,target=/opt/downloads \
    TOMCAT_FILE="apache-tomcat-${TOMCAT_VERSION}.tar.gz" && \
    TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/${TOMCAT_FILE}" && \
    download.sh --url "${TOMCAT_URL}" --sha256 "${TOMCAT_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-apache-service.sh \
        --name tomcat \
        --file "${DOWNLOAD_CACHE_DIRECTORY}/${TOMCAT_FILE}" \
        webapps/docs webapps/examples \
    && \
    mkdir /data && \
    chown tomcat:tomcat /data

FROM alpine:${alpine} AS cache
FROM ${repository}/java:${tag}

EXPOSE 8080

ENV \
    TOMCAT_ADMIN_NAME=admin \
    TOMCAT_ADMIN_PASSWORD=password \
    TOMCAT_ADMIN_ROLES=manager-gui \
    TOMCAT_CONNECTION_TIMEOUT=20000 \
    TOMCAT_CATALINA_OPTS= \
    TOMCAT_JAVA_OPTS= \
    TOMCAT_LOG_LEVEL=INFO \
    TOMCAT_MANAGER_REMOTE_ADDRESS_VALVE=^.*$

WORKDIR /opt/tomcat

COPY --link --from=download /etc/group /etc/group
COPY --link --from=download /etc/passwd /etc/passwd
COPY --link --from=download /etc/shadow /etc/shadow
COPY --link --from=download /data /data
COPY --link --from=download /opt/tomcat /opt/tomcat

COPY --link rootfs /

RUN chown -R tomcat:tomcat /opt/tomcat
