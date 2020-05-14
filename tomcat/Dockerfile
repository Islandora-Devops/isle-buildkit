# syntax=docker/dockerfile:experimental
FROM islandora/java:latest

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    TOMCAT_VERSION="9.0.34" && \
    install-apache-service.sh \
        --name tomcat \
        --version "${TOMCAT_VERSION}" \
        --key "A9C5DF4D22E99998D9875A5110C01C5A2F6059E7" \
        --mirror "https://archive.apache.org/dist/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin" \
        --file "apache-tomcat-${TOMCAT_VERSION}.tar.gz" \ 
        webapps/docs webapps/examples

# Install reverse proxy to redirect from 80 to 8080.
RUN --mount=type=cache,target=/var/cache/apk \ 
    --mount=type=cache,target=/etc/cache/apk \ 
    apk-install.sh nginx && \
    cleanup.sh

WORKDIR /opt/tomcat

EXPOSE 8080

COPY rootfs /
