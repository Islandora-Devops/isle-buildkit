# syntax=docker/dockerfile:experimental
FROM local/java:latest

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    KARAF_VERSION="4.0.8" && \
    install-apache-service.sh \
        --name karaf \
        --version "${KARAF_VERSION}" \
        --key "BFF2EE42C8282E76" \
        --mirror "https://archive.apache.org/dist/karaf/${KARAF_VERSION}" \
        --file "apache-karaf-${KARAF_VERSION}.tar.gz" \ 
        demos \
    && \
    sed -i 's@http://repo1@https://repo1@' /opt/karaf/etc/org.ops4j.pax.url.mvn.cfg && \
    chown -R karaf:karaf /opt/karaf && \
    rm -rf /opt/karaf/instances/* && \
    cleanup.sh

WORKDIR /opt/karaf

EXPOSE 8101 1099 44444 8181

COPY rootfs /
