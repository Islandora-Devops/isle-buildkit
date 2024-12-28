#!/usr/bin/env bash

set -eou pipefail

DEP=$1
VERSION=$2
URL=""
ARG=""
DOCKERFILE=""

echo "Updating SHA for $DEP@$VERSION"

if [ "$DEP" = "apache-tomcat" ]; then
  URL="https://downloads.apache.org/tomcat/tomcat-9/v$VERSION/bin/apache-tomcat-$VERSION.tar.gz"
  ARG="TOMCAT_FILE_SHA256"
  DOCKERFILE="tomcat/Dockerfile"
elif [ "$DEP" = "apache-activemq" ]; then
  URL="https://downloads.apache.org/activemq/$VERSION/apache-activemq-$VERSION-bin.tar.gz"
  ARG="ACTIVEMQ_FILE_SHA256"
  DOCKERFILE="activemq/Dockerfile"
elif [ "$DEP" = "apache-solr" ]; then
  URL="https://downloads.apache.org/solr/solr/$VERSION/solr-$VERSION.tgz"
  ARG="SOLR_FILE_SHA256"
  DOCKERFILE="solr/Dockerfile"
elif [ "$DEP" = "custom-composer" ]; then
  URL="https://getcomposer.org/download/${VERSION}/composer.phar"
  ARG="COMPOSER_SHA256"
  DOCKERFILE="nginx/Dockerfile"
elif [ "$DEP" = "solr-ocrhighlighting" ]; then
  URL=https://github.com/dbmdz/solr-ocrhighlighting/releases/download/${VERSION}/solr-ocrhighlighting-${VERSION}.jar
  ARG="OCRHIGHLIGHT_FILE_SHA256"
  DOCKERFILE="solr/Dockerfile"
else
  echo "DEP not found"
  exit 0
fi

SHA=$(curl -s "$URL" \
  | shasum -a 256 \
  | awk '{print $1}')
if [[ "$OSTYPE" == "darwin"* ]]; then
  sed -i '' 's|^ARG '"$ARG"'=.*|ARG '"$ARG"'="'"$SHA"'"|g' "$DOCKERFILE"
else
  sed -i 's|^ARG '"$ARG"'=.*|ARG '"$ARG"'="'"$SHA"'"|g' "$DOCKERFILE"
fi
