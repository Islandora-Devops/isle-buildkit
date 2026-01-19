# syntax=docker/dockerfile:1.20.0
FROM base

ARG TARGETARCH

ARG \
  # renovate: datasource=repology depName=alpine_3_22/openjdk17
  OPENJDK_VERSION=17.0.17_p10-r0 \
  # renovate: datasource=repology depName=alpine_3_22/maven
  MAVEN_VERSION=3.9.9-r0

# Install packages and tools required by all downstream images.
#
# Platform specific does require arch specific identifier.
RUN --mount=type=cache,id=java-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
        openjdk17=="${OPENJDK_VERSION}" \
        maven=="${MAVEN_VERSION}" \
    && \
    cleanup.sh

ENV JAVA_HOME=/usr/lib/jvm/default-jvm
