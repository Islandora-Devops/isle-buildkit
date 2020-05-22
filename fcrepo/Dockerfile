# syntax=docker/dockerfile:experimental
FROM local/tomcat:latest

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    FCREPO_VERSION="5.1.0" && \
    install-war-into-tomcat.sh \
        --name "fcrepo" \
        --url "https://github.com/fcrepo4/fcrepo4/releases/download/fcrepo-${FCREPO_VERSION}/fcrepo-webapp-${FCREPO_VERSION}.war" \
        --key "fdcb43cfd1468a84ddb89c20e4f4c7f54476ab9a24f69beb335d26f2b58ecec5"

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    SYN_VERSION="1.1.0" && \
    wget -N -P /opt/downloads https://github.com/Islandora-CLAW/Syn/releases/download/v${SYN_VERSION}/islandora-syn-${SYN_VERSION}-all.jar && \
    cp /opt/downloads/islandora-syn-${SYN_VERSION}-all.jar /opt/tomcat/lib && \
    cleanup.sh

COPY rootfs /

RUN mkdir /data && \
    chown tomcat:tomcat /data && \
    chown -R tomcat:tomcat /opt/tomcat

VOLUME [ "/data" ]
