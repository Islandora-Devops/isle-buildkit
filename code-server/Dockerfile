# syntax=docker/dockerfile:1.5.1
FROM drupal

ARG TARGETARCH
ARG CODE_SERVER_VERSION="4.11.0"
ARG CODE_SERVER_BASE_URL="https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}"
ARG CODE_SERVER_AMD64_FILE="code-server-${CODE_SERVER_VERSION}-linux-amd64.tar.gz"
ARG CODE_SERVER_AMD64_SHA256="4eb233054941ec298caec6fc84dfba0a72c1bc5fadc0fe4896b10f3f4a291d51"
ARG CODE_SERVER_ARM64_FILE="code-server-${CODE_SERVER_VERSION}-linux-arm64.tar.gz"
ARG CODE_SERVER_ARM64_SHA256="81bf50ac0f4a49b8f92e3ab27816a4b25d95dcff68eb81b310090e14360cf9c4"

EXPOSE 8443 \
       9003

# Install code-server
RUN --mount=type=cache,id=code-server-downloads-${TARGETARCH},sharing=locked,target=/opt/downloads \
    if [ "${TARGETARCH}" = "amd64" ]; \
    then \
        download.sh \
            --url "${CODE_SERVER_BASE_URL}/${CODE_SERVER_AMD64_FILE}" \
            --sha256 "${CODE_SERVER_AMD64_SHA256}" \
            --strip \
            --dest "/opt/code-server" ; \
    else \
        download.sh \
            --url "${CODE_SERVER_BASE_URL}/${CODE_SERVER_ARM64_FILE}" \
            --sha256 "${CODE_SERVER_ARM64_SHA256}" \
            --strip \
            --dest "/opt/code-server" ; \
    fi && \
    rm /opt/code-server/lib/node && \
    cleanup.sh

RUN --mount=type=bind,source=rootfs/var/lib/nginx/.composer,target=/composer \
    --mount=type=cache,id=code-server-composer-${TARGETARCH},sharing=locked,target=/var/lib/nginx/.composer/cache \
    mkdir -p /var/lib/nginx/.composer && \
    cp -r /composer/* /var/lib/nginx/.composer && \
    ls -lah /var/lib/nginx/.composer && \
    composer install -n -d /var/lib/nginx/.composer && \
    cleanup.sh

# Include commonly used tools and xdebug.
RUN --mount=type=cache,id=code-server-drupal-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
        docker-cli \
        gcompat \
        htop \
        nodejs \
        openssh \
        parallel \
        php81-pecl-xdebug \
        spdlog \
        sudo \
        unison \
    && \
    ln -s /usr/bin/node /opt/code-server/lib/node && \
    cleanup.sh

# Drush requires HOME to be set as such.
ENV \
    HOME="/var/lib/nginx" \
    PATH=$PATH:/var/lib/nginx/.composer/vendor/bin:/var/www/drupal/vendor/bin

# Code server / xdebug settings.
ENV \
    CODE_SERVER_AUTHENTICATION=password \
    CODE_SERVER_PASSWORD=password \
    XDEBUG_FLAGS="-d xdebug.mode=develop,debug"

COPY --link rootfs /

# Install Editor plugins from bind mounted folder (Not available on online marketplace).
RUN --mount=type=bind,source=/extensions,target=/extensions \
    for extension in /extensions/*.vsix; \
    do \
        /opt/code-server/bin/code-server \
            --config /opt/code-server/config.yaml \
            --user-data-dir /opt/code-server/data \
            --extensions-dir /opt/code-server/extensions \
            --install-extension="${extension}"; \
    done && \
    cleanup.sh

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
            --install-extension="${extension}"; \
    done && \
    cleanup.sh

# Code server should be on the path.
# Set a default shell so it can be used via code-server.
# Additionally https://github.com/sudo-project/sudo/issues/42
RUN sed -i "/nginx:x:100:101:nginx:\/var\/lib\/nginx:\/sbin\/nologin/cnginx:x:100:101:nginx:/var/lib/nginx:/bin/bash" /etc/passwd && \
    mkdir -p /var/lib/nginx/.local && \
    chown -R nginx:nginx /opt/code-server /var/lib/nginx && \
    ln -fs "/opt/code-server/bin/code-server" "/usr/local/bin/code-server" && \
    chmod a=r,u+w /etc/sudo.conf && \
    cleanup.sh
