# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
ARG alpine=3.16.2
FROM alpine:${alpine} AS cache
FROM ${repository}/base:${tag}

# Install packages and tools required by all downstream images.
RUN --mount=type=cache,id=java-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk add \
        openjdk17 \
        maven \
    && \
    cleanup.sh

ENV JAVA_HOME=/usr/lib/jvm/default-jvm
