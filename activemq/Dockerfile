# syntax=docker/dockerfile:experimental
FROM local/java:latest as builder

COPY rootfs/heartbeat-interval.patch /

RUN ACTIVEMQ_VERSION="5.16.3" && \
    ACTIVEMQ_GIT_REPO="https://github.com/apache/activemq" && \
    ACTIVEMQ_GIT_TAG="activemq-${ACTIVEMQ_VERSION}" && \
    mkdir -p /opt/builds && \
    cd /opt/builds && \
    git clone --depth 1 -b ${ACTIVEMQ_GIT_TAG} ${ACTIVEMQ_GIT_REPO} && \
    cd activemq

WORKDIR /opt/builds/activemq

# patch activemq-stomp
RUN patch -p1 < /heartbeat-interval.patch

# build activemq-stomp so the artifact is in the local maven repository.  build activemq-web-console so the classes are
# available in activemq-web-console/target for the assembly to pick up.  the remaining artifacts will be downloaded from
# maven central during assembly
RUN cd activemq-stomp && \
    mvn install -DskipTests && \
    cd ../activemq-web-console && \
    mvn package -DskipTests

# assemble the binary; will use the locally built activemq-stomp artifact, and pick up activemq-web-console/target.
RUN cd /opt/builds/activemq/assembly && \
    mvn assembly:single@unix-bin -DskipTests

FROM local/java:latest

RUN mkdir -p /opt/downloads

COPY --from=builder /opt/builds/activemq/assembly/target/apache-activemq-5.16.3-bin.tar.gz /opt/downloads

# install-apache-service.sh modified to not require a signed artifact
RUN install-apache-service.sh \
      --name activemq \
      --file /opt/downloads/apache-activemq-5.16.3-bin.tar.gz \
    examples webapps-demo docs

WORKDIR /opt/activemq

EXPOSE 61616 5672 61613 1883 61614 8161

COPY rootfs /

RUN chown -R activemq:activemq /opt/activemq
