# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/java:${tag} AS download

RUN --mount=type=cache,id=tomcat-downloads,sharing=locked,target=/opt/downloads \
    TOMCAT_VERSION="9.0.34" && \
    TOMCAT_FILE="apache-tomcat-${TOMCAT_VERSION}.tar.gz" && \
    TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/${TOMCAT_FILE}" && \
    TOMCAT_FILE_SHA256="321de5b18a48ec09d2963d9faba4bfeafc7dd2203d80a2ef7e7a20b159e2120a" && \
    TOMCAT_SIG_SHA256="40cdb1433a3e080b26a9e791409fb3840364150b2f4594e19b3f7d0c97f7c736" && \
    download.sh --url "${TOMCAT_URL}" --sha256 "${TOMCAT_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    download.sh --url "${TOMCAT_URL}.asc" --sha256 "${TOMCAT_SIG_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-apache-service.sh \
        --name tomcat \
        --key "A9C5DF4D22E99998D9875A5110C01C5A2F6059E7" \
        --file "${DOWNLOAD_CACHE_DIRECTORY}/${TOMCAT_FILE}" \
        webapps/docs webapps/examples

FROM alpine:3.13.2 AS cache
FROM ${repository}/java:${tag}

COPY --from=download /etc/group /etc/group
COPY --from=download /etc/passwd /etc/passwd
COPY --from=download /etc/shadow /etc/shadow
COPY --from=download /opt /opt

# Install reverse proxy to redirect from 80 to 8080.
RUN --mount=type=cache,id=tomcat-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk add nginx && \
    cleanup.sh

WORKDIR /opt/tomcat

EXPOSE 8080

ENV \
    TOMCAT_ADMIN_NAME=admin \
    TOMCAT_ADMIN_PASSWORD=password \
    TOMCAT_ADMIN_ROLES=manager-gui \
    TOMCAT_CATALINA_OPTS= \
    TOMCAT_JAVA_OPTS=${JAVA_OPTS} \
    TOMCAT_LOG_LEVEL=ALL \
    TOMCAT_MANAGER_REMOTE_ADDRESS_VALVE=^.*$ \
    TOMCAT_NGINX_CLIENT_MAX_BODY_SIZE=0

COPY rootfs /