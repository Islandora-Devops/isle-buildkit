# syntax=docker/dockerfile:1.5.1
FROM base

LABEL org.opencontainers.image.source=https://github.com/Islandora-DevOps/isle-buildkit/tree/main/java
LABEL org.opencontainers.image.url=https://github.com/Islandora-DevOps/isle-buildkit/

ARG TARGETARCH

# Install packages and tools required by all downstream images.
#
# Platform specific does require arch specific identifier.
RUN --mount=type=cache,id=java-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
        openjdk17 \
        maven \
    && \
    cleanup.sh

ENV JAVA_HOME=/usr/lib/jvm/default-jvm
