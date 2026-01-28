# syntax=docker/dockerfile:1.20.0
FROM java

ARG TARGETARCH
# renovate: datasource=custom.apache-downloads depName=apache-tomcat packageName=tomcat/tomcat-9
ARG TOMCAT_VERSION=9.0.115
ARG TOMCAT_FILE_SHA256="5a165bb121a69e69bfa3c50c4f999a7d1e48120d625b6f5df8383b90a7bbbb98"

EXPOSE 8080

WORKDIR /opt/tomcat

RUN --mount=type=cache,id=tomcat-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    TOMCAT_FILE="apache-tomcat-${TOMCAT_VERSION}.tar.gz" && \
    TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/${TOMCAT_FILE}" && \
    download.sh --url "${TOMCAT_URL}" --sha256 "${TOMCAT_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    download.sh \
        --url "${TOMCAT_URL}" \
        --sha256 "${TOMCAT_FILE_SHA256}" \
        --dest "/opt/tomcat" \
        --strip \
        webapps/docs webapps/examples \
    && \
    cleanup.sh

RUN create-service-user.sh \
        --name tomcat \
        --group jwt \
        /data \
    && \
    cleanup.sh

ENV \
    TOMCAT_ADMIN_NAME=admin \
    TOMCAT_ADMIN_PASSWORD=password \
    TOMCAT_ADMIN_ROLES=manager-gui \
    TOMCAT_CONNECTION_TIMEOUT=20000 \
    TOMCAT_CATALINA_OPTS= \
    TOMCAT_JAVA_OPTS= \
    TOMCAT_LOG_LEVEL=INFO \
    TOMCAT_MANAGER_REMOTE_ADDRESS_VALVE=^.*$

COPY --link rootfs /
