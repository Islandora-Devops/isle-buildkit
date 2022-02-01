# syntax=docker/dockerfile:1.2.1
ARG repository=local
ARG tag=latest
FROM alpine:3.15.0 AS cache
FROM ${repository}/base:${tag}

# Install packages and tools required by all downstream images.
RUN --mount=type=cache,id=java-apk,sharing=locked,from=cache,target=/var/cache/apk \
    apk add \
        openjdk8 \
        maven \
    && \
    cleanup.sh

ENV JAVA_HOME=/usr/lib/jvm/default-jvm
