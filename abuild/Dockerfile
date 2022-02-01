# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM ${repository}/download:${tag} AS download
FROM alpine:3.15.0 AS cache
FROM alpine:3.15.0

RUN --mount=type=cache,id=abuild-apk,sharing=locked,from=cache,target=/var/cache/apk \
    ln -s /var/cache/apk /etc/apk/cache && \
    apk add \
        alpine-sdk \
        sudo \
    && \
    adduser -G abuild -g "Alpine Package Builder" -s /bin/ash -D builder && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

COPY --from=download /usr/local/bin/*.sh /usr/local/bin