# syntax=docker/dockerfile:experimental
FROM local/karaf:latest

# Install common features and repos
RUN bin/start && \
    ALPACA_VERSION=1.0.3 && \
    ACTIVEMQ_VERSION=5.15.0 && \
    CAMEL_VERSION=2.20.4 && \
    bin/client -r 10 -d 5  "feature:repo-add mvn:ca.islandora.alpaca/islandora-karaf/${ALPACA_VERSION}/xml/features" && \
    bin/client -r 10 -d 5  "feature:repo-add mvn:org.apache.activemq/activemq-karaf/${ACTIVEMQ_VERSION}/xml/features" && \
    bin/client -r 10 -d 5  "feature:repo-add mvn:org.apache.camel.karaf/apache-camel/${CAMEL_VERSION}/xml/features" && \
    bin/client -r 10 -d 5  "feature:install fcrepo-service-activemq" && \
    bin/client -r 10 -d 5  "feature:install fcrepo-service-camel" && \
    bin/client -r 10 -d 5  "feature:install islandora-http-client" && \
    bin/stop && \
    rm -rf instances/*

# Derivative connector
RUN bin/start && \
    bin/client -r 10 -d 5  "feature:install islandora-connector-derivative" && \
    bin/stop && \
    rm -rf instances/*

# Fcrepo indexing THIS IS THE PROBLEM
RUN bin/start && \
    bin/client -r 10 -d 5  "feature:install islandora-indexing-fcrepo" && \
    bin/stop && \
    rm -rf instances/*

# Triple indexing
RUN bin/start && \
    bin/client -r 10 -d 5  "feature:install fcrepo-indexing-triplestore" && \
    bin/client -r 10 -d 5  "feature:install islandora-indexing-triplestore" && \
    bin/stop && \
    rm -rf instances/*

RUN chown -R karaf:karaf /opt/karaf

COPY rootfs /

ENV JAVA_OPTS="-Dfile.encoding=UTF-8 -Dnet.sf.ehcache.skipUpdateCheck=true -XX:+UseConcMarkSweepGC -XX:+CMSClassUnloadingEnabled -XX:+UseParNewGC -XX:MaxPermSize=128m -Xms512m -Xmx8g"