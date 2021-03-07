# syntax=docker/dockerfile:1.2.1
FROM alpine:3.13.2 AS cache
FROM alpine:3.13.2

RUN --mount=type=cache,id=abuild-apk,sharing=locked,from=cache,target=/var/cache/apk \
    ln -s /var/cache/apk /etc/apk/cache && \
    apk add \
        alpine-sdk \
        sudo \
    && \
    adduser -G abuild -g "Alpine Package Builder" -s /bin/ash -D builder && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
