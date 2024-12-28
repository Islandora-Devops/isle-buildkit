#!/usr/bin/env bash

set -eou pipefail

DEP=$1
VERSION=$2

echo "Updating SHA for $DEP"

if [ "$DEP" = "apache-tomcat" ]; then
  SHA=$(curl -s "https://downloads.apache.org/tomcat/tomcat-9/v$VERSION/bin/apache-tomcat-$VERSION.tar.gz" \
    | shasum -a 256 \
    | awk '{print $1}')
  echo "$SHA"

  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's|^ARG TOMCAT_FILE_SHA256=".*"|ARG TOMCAT_FILE_SHA256="'"$SHA"'"|g' tomcat/Dockerfile
  else
    sed -i 's|^ARG TOMCAT_FILE_SHA256=".*"|ARG TOMCAT_FILE_SHA256="'"$SHA"'"|g' tomcat/Dockerfile
  fi
fi

if [ "$DEP" = "apache-activemq" ]; then
  SHA=$(curl -s "https://downloads.apache.org/activemq/$VERSION/apache-activemq-$VERSION-bin.tar.gz" \
    | shasum -a 256 \
    | awk '{print $1}')
  echo "$SHA"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's|^ARG ACTIVEMQ_FILE_SHA256=".*"|ARG ACTIVEMQ_FILE_SHA256="'"$SHA"'"|g' activemq/Dockerfile
  else
    sed -i 's|^ARG ACTIVEMQ_FILE_SHA256=".*"|ARG ACTIVEMQ_FILE_SHA256="'"$SHA"'"|g' activemq/Dockerfile
  fi
fi

if [ "$DEP" = "apache-solr" ]; then
  SHA=$(curl -s "https://downloads.apache.org/solr/solr/$VERSION/solr-$VERSION.tgz" \
    | shasum -a 256 \
    | awk '{print $1}')
  echo "$SHA"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's|^ARG SOLR_FILE_SHA256=".*"|ARG SOLR_FILE_SHA256="'"$SHA"'"|g' solr/Dockerfile
  else
    sed -i 's|^ARG SOLR_FILE_SHA256=".*"|ARG SOLR_FILE_SHA256="'"$SHA"'"|g' solr/Dockerfile
  fi
fi
