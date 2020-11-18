FROM golang:buster as gobuild

RUN mkdir -p $GOPATH/src/github.com/kelseyhightower && \
    git clone https://github.com/kelseyhightower/confd.git $GOPATH/src/github.com/kelseyhightower/confd && \
    cd $GOPATH/src/github.com/kelseyhightower/confd && \
    make

FROM unicon/shibboleth-idp@sha256:397941df7098b44c939b6d7e0a94afde627a79c27863e0a99f4ae8d8ec069134

COPY common/shibboleth-idp/ /opt/shibboleth-idp/
COPY common/shib-jetty-base/ /opt/shib-jetty-base/

COPY run-jetty.sh /usr/local/bin

RUN chmod 750 /usr/local/bin/run-jetty.sh

RUN yum -y install gettext && \
    rm -rf /var/cache/yum

COPY --from=gobuild /go/src/github.com/kelseyhightower/confd/bin/confd /usr/local/bin

COPY rootfs/ /