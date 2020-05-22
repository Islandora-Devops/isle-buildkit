# syntax=docker/dockerfile:experimental
FROM local/java:latest

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    ACTIVEMQ_VERSION="5.14.5" && \
    install-apache-service.sh \
        --name activemq \
        --version "${ACTIVEMQ_VERSION}" \
        --key "62ED4DF0BACB8793" \
        --mirror "https://archive.apache.org/dist/activemq/${ACTIVEMQ_VERSION}" \
        --file "apache-activemq-${ACTIVEMQ_VERSION}-bin.tar.gz" \
        examples webapps-demo docs

WORKDIR /opt/activemq

EXPOSE 61616 5672 61613 1883 61614 8161

VOLUME [ "/opt/activemq/data" ]

COPY rootfs /
