# syntax=docker/dockerfile:1.20.0
FROM java

ARG TARGETARCH
# renovate: datasource=custom.apache-downloads depName=apache-tomcat packageName=tomcat/tomcat-11
ARG TOMCAT_VERSION=11.0.24
ARG TOMCAT_FILE_SHA256="10efed90bf330114af66279e43dcf211ecfcf7b88e618757954ac88329600cba"

EXPOSE 8080

WORKDIR /opt/tomcat

RUN --mount=type=cache,id=tomcat-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    TOMCAT_FILE="apache-tomcat-${TOMCAT_VERSION}.tar.gz" && \
    TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-11/v${TOMCAT_VERSION}/bin/${TOMCAT_FILE}" && \
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
