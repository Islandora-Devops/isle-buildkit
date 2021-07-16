# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/java:${tag} AS download

RUN --mount=type=cache,id=tomcat-downloads,sharing=locked,target=/opt/downloads \
    TOMCAT_VERSION="9.0.34" && \
    TOMCAT_FILE="apache-tomcat-${TOMCAT_VERSION}.tar.gz" && \
    TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/${TOMCAT_FILE}" && \
    TOMCAT_FILE_SHA256="321de5b18a48ec09d2963d9faba4bfeafc7dd2203d80a2ef7e7a20b159e2120a" && \
    download.sh --url "${TOMCAT_URL}" --sha256 "${TOMCAT_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-apache-service.sh \
        --name tomcat \
        --file "${DOWNLOAD_CACHE_DIRECTORY}/${TOMCAT_FILE}" \
        webapps/docs webapps/examples

FROM alpine:3.13.2 AS cache
FROM ${repository}/java:${tag}

EXPOSE 8080

COPY --from=download /etc/group /etc/group
COPY --from=download /etc/passwd /etc/passwd
COPY --from=download /etc/shadow /etc/shadow

# Install reverse proxy to redirect from 80 to 8080.
RUN --mount=type=cache,id=tomcat-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk add nginx && \
    cleanup.sh

ENV \
    TOMCAT_ADMIN_NAME=admin \
    TOMCAT_ADMIN_PASSWORD=password \
    TOMCAT_ADMIN_ROLES=manager-gui \
    TOMCAT_CATALINA_OPTS= \
    TOMCAT_JAVA_OPTS= \
    TOMCAT_LOG_LEVEL=ALL \
    TOMCAT_MANAGER_REMOTE_ADDRESS_VALVE=^.*$ \
    TOMCAT_NGINX_CLIENT_MAX_BODY_SIZE=0

COPY --from=download /opt /opt

COPY rootfs /
COPY --chown=tomcat:tomcat rootfs/opt/tomcat /opt/tomcat

WORKDIR /opt/tomcat