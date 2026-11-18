# syntax=docker/dockerfile:1.20.0
FROM alpine AS openjdk-build

RUN apk add --no-cache alpine-sdk sudo && \
    adduser -D -G abuild builder && \
    echo 'builder ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/builder
COPY --chown=builder:abuild build /home/builder/aports/openjdk21
USER builder
WORKDIR /home/builder/aports/openjdk21
RUN abuild-keygen -ain && abuild-apk update && abuild -r && \
    mkdir /home/builder/apks && \
    find /home/builder/packages -name '*.apk' -exec cp {} /home/builder/apks/ \; && \
    rm /home/builder/.abuild/*.rsa

FROM base

ARG TARGETARCH

ARG \
  # Built from the vendored aport; ci/update-openjdk.sh updates this pin.
  OPENJDK_VERSION=21.0.13.1_p2-r0 \
  # renovate: datasource=repology depName=alpine_3_24/maven
  MAVEN_VERSION=3.9.16-r0

# Install the locally built JDK and all its split runtime packages together.
RUN --mount=type=bind,from=openjdk-build,source=/home/builder/apks,target=/packages \
    --mount=type=bind,from=openjdk-build,source=/etc/apk/keys,target=/etc/apk/keys \
    --mount=type=cache,id=java-apk-${TARGETARCH},sharing=locked,target=/var/cache/apk \
    apk add \
        /packages/openjdk21-${OPENJDK_VERSION}.apk \
        /packages/openjdk21-jdk-${OPENJDK_VERSION}.apk \
        /packages/openjdk21-jmods-${OPENJDK_VERSION}.apk \
        /packages/openjdk21-jre-${OPENJDK_VERSION}.apk \
        /packages/openjdk21-jre-headless-${OPENJDK_VERSION}.apk \
        /packages/openjdk21-demos-${OPENJDK_VERSION}.apk \
        /packages/openjdk21-doc-${OPENJDK_VERSION}.apk \
        maven=="${MAVEN_VERSION}" \
    && \
    java -version && javac -version && mvn -version && \
    cleanup.sh

ENV JAVA_HOME=/usr/lib/jvm/default-jvm
