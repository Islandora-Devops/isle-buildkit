FROM ghcr.io/jhu-sheridan-libraries/idc-isle-dc/base as base

FROM unicon/shibboleth-idp@sha256:397941df7098b44c939b6d7e0a94afde627a79c27863e0a99f4ae8d8ec069134

COPY common/shibboleth-idp/ /opt/shibboleth-idp/
COPY common/shib-jetty-base/ /opt/shib-jetty-base/

COPY run-jetty.sh /usr/local/bin

RUN chmod 750 /usr/local/bin/run-jetty.sh

RUN yum -y install gettext && \
    rm -rf /var/cache/yum

RUN wget -O /usr/local/bin/yq https://github.com/mikefarah/yq/releases/download/v4.6.3/yq_linux_amd64 && \
    chmod 755 /usr/local/bin/yq && \
    echo "c4343783c3361495c0d6d1eb742bba7432aa65e13e9fb8d7e201d544bcf14246  /usr/local/bin/yq" | sha256sum -c

COPY --from=base /usr/local/bin/confd /usr/local/bin

COPY rootfs/ /
