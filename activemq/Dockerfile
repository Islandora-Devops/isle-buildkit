# syntax=docker/dockerfile:1.5.1
FROM java

ARG TARGETARCH
ARG ACTIVEMQ_VERSION="5.17.3"
ARG ACTIVEMQ_FILE="apache-activemq-${ACTIVEMQ_VERSION}-bin.tar.gz"
ARG ACTIVEMQ_URL="https://archive.apache.org/dist/activemq/${ACTIVEMQ_VERSION}/${ACTIVEMQ_FILE}"
ARG ACTIVEMQ_FILE_SHA256="a4cc4c3a2f136707c2c696f3bb3ee2a86dbeff1b9eb5e237b14edc0c5e5a328f"

EXPOSE 61616 5672 61613 1883 61614 8161

WORKDIR /opt/activemq

RUN --mount=type=cache,id=activemq-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    download.sh \
        --url "${ACTIVEMQ_URL}" \
        --sha256 "${ACTIVEMQ_FILE_SHA256}" \
        --dest /opt/activemq \
        --strip \
        examples webapps-demo docs \
    && \
    cleanup.sh

# Defaults environment variables to be overloaded.
ENV \
    ACTIVEMQ_AUDIT_LOG_LEVEL=INFO \
    ACTIVEMQ_LOG_LEVEL=INFO \
    ACTIVEMQ_PASSWORD=password \
    ACTIVEMQ_USER=admin \
    ACTIVEMQ_WEB_ADMIN_NAME=admin \
    ACTIVEMQ_WEB_ADMIN_PASSWORD=password \
    ACTIVEMQ_WEB_ADMIN_ROLES=admin

COPY --link rootfs /

RUN create-service-user.sh --name activemq && \
    cleanup.sh
