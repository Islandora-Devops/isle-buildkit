# syntax=docker/dockerfile:experimental
FROM alpine:3.12.4

RUN --mount=type=cache,target=/var/cache/apk \ 
    --mount=type=cache,target=/etc/cache/apk \
    ln -s /var/cache/apk /etc/apk/cache && \
    apk add --update \
        alpine-sdk \
        coreutils \
    && \
    adduser -G abuild -g "Alpine Package Builder" -s /bin/ash -D builder && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
