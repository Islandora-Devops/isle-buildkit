# syntax=docker/dockerfile:experimental
FROM islandora/tomcat:latest

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    BLAZEGRAPH_VERSION=CANDIDATE_2_1_5 && \
    install-war-into-tomcat.sh \
        --name "bigdata" \
        --url "https://github.com/blazegraph/database/releases/download/BLAZEGRAPH_RELEASE_${BLAZEGRAPH_VERSION}/blazegraph.war" \
        --key "b22f1a1aa8e536443db9a57da63720813374ef59e4021cfa9ad0e98f9a420e85"

COPY rootfs /

RUN mkdir /data && \
    chown tomcat:tomcat /data && \
    chown -R tomcat:tomcat /opt/tomcat

VOLUME /data
