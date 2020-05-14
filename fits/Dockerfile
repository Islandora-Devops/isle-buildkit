# syntax=docker/dockerfile:experimental
FROM islandora/tomcat:latest

RUN --mount=id=downloads,type=cache,target=/opt/downloads \
    FITSSERVLET_VERSION=1.2.1 && \
    install-war-into-tomcat.sh \
        --name "fits" \
        --url "http://projects.iq.harvard.edu/files/fits/files/fits-${FITSSERVLET_VERSION}.war" \
        --key "13cfcb910092b197757e459353f0c30381febfca6baf3031ac69ff92789b200c" && \
    FITS_VERSION="1.5.0" && \
    FITS_CHECKSUM="1378a78892db103b3a00e45c510b58c70e19a1a401b3720ff4d64a51438bfe0b" && \
    mkdir /opt/fits && \
    wget -N -P /opt/downloads "https://github.com/harvard-lts/fits/releases/download/${FITS_VERSION}/fits-${FITS_VERSION}.zip" && \
    sha256sum "/opt/downloads/fits-${FITS_VERSION}.zip" | cut -f1 -d' ' | xargs test "${FITS_CHECKSUM}" ==  && \
    unzip /opt/downloads/fits-${FITS_VERSION}.zip -d /opt/fits

COPY rootfs /
