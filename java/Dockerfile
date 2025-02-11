# syntax=docker/dockerfile:1.5.1
FROM base

ARG TARGETARCH

ENV \
  # renovate: datasource=repology depName=alpine_3_20/openjdk17 versioning=loose
  OPENJDK_VERSION=17.0.14_p7-r0 \
  # renovate: datasource=repology depName=alpine_3_20/maven
  MAVEN_VERSION=3.9.6-r0

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
