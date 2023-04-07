# syntax=docker/dockerfile:1.5.1
FROM drupal

ARG TARGETARCH

EXPOSE 8443 \
       9003

RUN --mount=type=bind,source=rootfs/var/lib/nginx/.composer,target=/composer \
    --mount=type=cache,id=code-server-composer-${TARGETARCH},sharing=locked,target=/var/lib/nginx/.composer/cache \
    mkdir -p /var/lib/nginx/.composer && \
    cp -r /composer/* /var/lib/nginx/.composer && \
    ls -lah /var/lib/nginx/.composer && \
    composer install -n -d /var/lib/nginx/.composer && \
    cleanup.sh

# Include commonly used tools and xdebug.
RUN --mount=type=cache,id=code-server-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
        alpine-sdk \
        docker-cli \
        htop \
        nodejs \
        openssh \
        parallel \
        php81-pecl-xdebug \
        python3 \
        spdlog \
        sudo \
        unison \
        yarn \
    && \
    cleanup.sh

RUN --mount=type=cache,id=code-server-npm-${TARGETARCH},sharing=locked,target=/usr/local/share/.cache/yarn \
    yarn global add node-gyp@9.3.1 && \
    FORCE_NODE_VERSION=18 yarn global add --ignore-engines --unsafe-perm \
        @microsoft/1ds-core-js@3.2.9 \
        code-server@4.11.0 \
        minimist@1.2.8 \
        node-gyp@9.3.1 \
        spdlog@0.13.7 \
        yauzl@2.10.0 \
        yazl@2.5.1 \
    && \
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
    declare -a pids=(); \
    for extension in /extensions/*.vsix; \
    do \
        code-server \
            --config /opt/code-server/config.yaml \
            --user-data-dir /opt/code-server/data \
            --extensions-dir /opt/code-server/extensions \
            --install-extension="${extension}" & \
        pids+=($!); \
    done; \
    for pid in "${pids[@]}"; \
    do \
        wait "$pid"; \
    done; \
    cleanup.sh

# Install Editor plugins from internet (saves downloading when installing).
RUN \
    declare -a pids=(); \
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
    done && \
    for pid in "${pids[@]}"; \
    do \
        wait "$pid"; \
    done; \
    cleanup.sh

# Set a default shell so it can be used via code-server.
# Additionally https://github.com/sudo-project/sudo/issues/42
RUN sed -i "/nginx:x:100:101:nginx:\/var\/lib\/nginx:\/sbin\/nologin/cnginx:x:100:101:nginx:/var/lib/nginx:/bin/bash" /etc/passwd && \
    mkdir -p /var/lib/nginx/.local && \
    chown -R nginx:nginx /opt/code-server /var/lib/nginx && \
    chmod a=r,u+w /etc/sudo.conf && \
    cleanup.sh
