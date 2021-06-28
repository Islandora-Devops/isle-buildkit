# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM --platform=$BUILDPLATFORM ${repository}/download:${tag} AS download

RUN --mount=type=cache,id=karaf-downloads,sharing=locked,target=/opt/downloads \
    KARAF_VERSION="4.0.8" && \
    KARAF_FILE="apache-karaf-${KARAF_VERSION}.tar.gz" && \
    KARAF_URL="https://archive.apache.org/dist/karaf/${KARAF_VERSION}/${KARAF_FILE}" && \
    KARAF_FILE_SHA256="67e555e3896fbe87d23ceec008898bb33133f36b48d7e5ede363c214a54e7d2a" && \
    download.sh --url "${KARAF_URL}" --sha256 "${KARAF_FILE_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    install-apache-service.sh -e \
        --name karaf \
        --file "${DOWNLOAD_CACHE_DIRECTORY}/${KARAF_FILE}" \
        demos \
    && \
    sed -i 's@http://repo1@https://repo1@' /opt/karaf/etc/org.ops4j.pax.url.mvn.cfg && \
    mkdir /opt/karaf/data/log && \
    rm -rf /opt/karaf/instances/* && \
    chown -R karaf:karaf /opt/karaf

FROM ${repository}/java:${tag}

EXPOSE 8101 1099 44444 8181

ENV \
    KARAF_ADMIN_NAME=admin \
    KARAF_ADMIN_PASSWORD=password

COPY --from=download /etc/group /etc/group
COPY --from=download /etc/passwd /etc/passwd
COPY --from=download /etc/shadow /etc/shadow
COPY --from=download --chown=karaf:karaf /opt/karaf /opt/karaf

COPY rootfs /

WORKDIR /opt/karaf