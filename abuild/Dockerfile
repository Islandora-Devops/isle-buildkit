# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
ARG alpine=3.16.2
FROM ${repository}/download:${tag} AS download
FROM alpine:${alpine} AS cache
FROM alpine:${alpine}

RUN --mount=type=cache,id=abuild-apk,sharing=locked,from=cache,target=/var/cache/apk \
    ln -s /var/cache/apk /etc/apk/cache && \
    apk add \
        alpine-sdk \
        sudo \
    && \
    adduser -G abuild -g "Alpine Package Builder" -s /bin/ash -D builder && \
    echo "builder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

COPY --link --from=download /usr/local/bin/*.sh /usr/local/bin/
