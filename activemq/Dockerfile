# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/download:${tag} AS download

ARG ACTIVEMQ_VERSION="5.14.5"
ARG ACTIVEMQ_FILE_SHA256="a4bc310ccb3fb439d0ba159e43f0e08e8073caf050c95e5e07c1a6d5f3f9a86e"

RUN --mount=type=cache,id=activemq-downloads,sharing=locked,target=/opt/downloads \
    ACTIVEMQ_FILE="apache-activemq-${ACTIVEMQ_VERSION}-bin.tar.gz" && \
    ACTIVEMQ_URL="https://archive.apache.org/dist/activemq/${ACTIVEMQ_VERSION}/${ACTIVEMQ_FILE}" && \
    download.sh --url "${ACTIVEMQ_URL}" --sha256 "${ACTIVEMQ_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-apache-service.sh \
        --name activemq \
        --file "${DOWNLOAD_CACHE_DIRECTORY}/${ACTIVEMQ_FILE}" \
        examples webapps-demo docs

FROM ${repository}/java:${tag}

EXPOSE 61616 5672 61613 1883 61614 8161

# Defaults environment variables to be overloaded.
ENV \
    ACTIVEMQ_AUDIT_LOG_LEVEL=INFO \
    ACTIVEMQ_LOG_LEVEL=INFO \
    ACTIVEMQ_PASSWORD=password \
    ACTIVEMQ_USER=admin \
    ACTIVEMQ_WEB_ADMIN_NAME=admin \
    ACTIVEMQ_WEB_ADMIN_PASSWORD=password \
    ACTIVEMQ_WEB_ADMIN_ROLES=admin

WORKDIR /opt/activemq

COPY --link --from=download /etc/group /etc/group
COPY --link --from=download /etc/passwd /etc/passwd
COPY --link --from=download /etc/shadow /etc/shadow
COPY --link --from=download /opt/activemq /opt/activemq

COPY --link rootfs /

RUN chown -R activemq:activemq /opt/activemq
