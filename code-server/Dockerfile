# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
ARG alpine=3.16.2
FROM alpine:${alpine} AS cache
#FROM ${repository}/abuild:${tag} AS build
FROM ${repository}/download:${tag} AS download

ARG TARGETARCH

ARG CODE_SERVER_VERSION="4.8.3"
ARG CODE_SERVER_AMD64_SHA256="16e8b600d03eec710a7b4d6380986ba3414e7e3aa503da90b518d4fd066e220a"
ARG CODE_SERVER_ARM64_SHA256="b7b4cd77c992ea3e982d399f0e40b98707ceaf7e0960eeb84ba674f54315c595"

# Install code-server
RUN --mount=type=cache,id=code-server-downloads,sharing=locked,target=/opt/downloads \
    if [ "${TARGETARCH}" = "arm64" ]; then \
        CODE_SERVER_FILE="code-server-${CODE_SERVER_VERSION}-linux-arm64.tar.gz"; \
        CODE_SERVER_SHA256="${CODE_SERVER_ARM64_SHA256}"; \
    fi; \
    if [ "${TARGETARCH}" = "amd64" ]; then \
        CODE_SERVER_FILE="code-server-${CODE_SERVER_VERSION}-linux-amd64.tar.gz"; \
        CODE_SERVER_SHA256="${CODE_SERVER_AMD64_SHA256}"; \
    fi; \
    CODE_SERVER_URL="https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/${CODE_SERVER_FILE}" && \
    download.sh --url "${CODE_SERVER_URL}" --sha256 "${CODE_SERVER_SHA256}" "${DOWNLOAD_CACHE_DIRECTORY}" && \
    mkdir -p /opt/code-server && \
    tar -xzf "${DOWNLOAD_CACHE_DIRECTORY}/${CODE_SERVER_FILE}" -C /opt/code-server --strip-components=1 && \
    echo '' > /root/.ash_history

SHELL ["/bin/bash", "-c"]

RUN --mount=type=cache,id=code-server-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk --update add \
        gcompat \
        nodejs

# Install Editor plugins from bind mounted folder (Not available on online marketplace).
RUN --mount=type=bind,source=/extensions,target=/extensions \
    for extension in /extensions/*.vsix; \
    do \
        /opt/code-server/bin/code-server \
            --config /opt/code-server/config.yaml \
            --user-data-dir /opt/code-server/data \
            --extensions-dir /opt/code-server/extensions \
            --install-extension="${extension}" & \
    done; \
    wait

# Install Editor plugins from internet (saves downloading when installing).
RUN \
    EXTENSIONS=(\
        bmewburn.vscode-intelephense-client \
        felixfbecker.php-debug \
        streetsidesoftware.code-spell-checker \
        mblode.twig-language-2 \
    ) && \
    for extension in "${EXTENSIONS[@]}"; \
    do \
        /opt/code-server/bin/code-server \
            --config /opt/code-server/config.yaml \
            --user-data-dir /opt/code-server/data \
            --extensions-dir /opt/code-server/extensions \
            --install-extension="${extension}" & \
    done; \
    wait

FROM --platform=$BUILDPLATFORM ${repository}/composer:${tag} AS composer

COPY --link rootfs/root/.composer /root/.composer

RUN --mount=type=cache,id=code-server-composer,sharing=locked,target=/root/.composer/cache \
    cd /root/.composer && \
    composer install -n

FROM ${repository}/drupal:${tag}

EXPOSE 8443 \
       9003

# Include commonly used tools and xdebug.
RUN --mount=type=cache,id=code-server-drupal-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk --update add \
        bash \
        docker-cli \
        gcompat \
        htop \
        jq \
        nodejs \
        openssh \
        parallel \
        php81-pecl-xdebug \
        shadow \
        spdlog \
        sudo \
        unison \
        yq \
    && \
    cleanup.sh

## PHPStorm remote requries Glibc.
#RUN --mount=type=cache,id=custom-ide,sharing=locked,target=/var/cache/apk \
#  GLIBC_VERSION=2.35-r0 && \
#  GLIBC_URL=https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION} && \
#  wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub && \
#  wget ${GLIBC_URL}/glibc-${GLIBC_VERSION}.apk && \
#  apk add glibc-${GLIBC_VERSION}.apk && \
#  ln -s /lib/ld-linux-x86-64.so.2 /lib64/ld-linux-x86-64.so.2

# Drush requires HOME to be set as such.
ENV \
    HOME="/var/lib/nginx" \
    PATH=$PATH:/var/lib/nginx/.composer/vendor/bin:/var/www/drupal/vendor/bin

# Code server / xdebug settings.
ENV \
    CODE_SERVER_AUTHENTICATION=password \
    CODE_SERVER_PASSWORD=password \
    XDEBUG_FLAGS="-d xdebug.mode=develop,debug"

COPY --link --from=composer /root/.composer /var/lib/nginx/.composer
COPY --link --from=download /opt/code-server /opt/code-server
COPY --link rootfs /

# Code server should be on the path.
# Set a default shell so it can be used via code-server.
# Additionally https://github.com/sudo-project/sudo/issues/42
RUN sed -i "/nginx:x:100:101:nginx:\/var\/lib\/nginx:\/sbin\/nologin/cnginx:x:100:101:nginx:/var/lib/nginx:/bin/bash" /etc/passwd && \
    mkdir /var/lib/nginx/.local && \
    chown -R nginx:nginx /opt/code-server /var/lib/nginx/.composer /var/lib/nginx/.local && \
    ln -fs "/opt/code-server/bin/code-server" "/usr/local/bin/code-server" && \
    chmod a=r,u+w /etc/sudo.conf
