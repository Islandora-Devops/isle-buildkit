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

elif [ "$DEP" = "alpine-pkg-glibc" ]; then
  URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${VERSION}/glibc-${VERSION}.apk"
  ARG="GLIBC_SHA256"
  DOCKERFILE="code-server/Dockerfile"

elif [ "$DEP" = "fcrepo" ]; then
  URL="https://github.com/fcrepo/fcrepo/releases/download/fcrepo-${VERSION}/fcrepo-webapp-${VERSION}.war"
  ARG="FCREPO_SHA256"
  DOCKERFILE="fcrepo6/Dockerfile"

elif [ "$DEP" = "islandora-syn" ]; then
  URL="https://github.com/Islandora/Syn/releases/download/v${VERSION}/islandora-syn-${VERSION}-all.jar"
  ARG="SYN_SHA256"
  DOCKERFILE="fcrepo6/Dockerfile"

elif [ "$DEP" = "fcrepo-import-export" ]; then
  URL="https://github.com/fcrepo-exts/fcrepo-import-export/releases/download/fcrepo-import-export-${VERSION}/fcrepo-import-export-${VERSION}.jar"
  ARG="IMPORT_EXPORT_SHA256"
  DOCKERFILE="fcrepo6/Dockerfile"

elif [ "$DEP" = "fcrepo-upgrade-utils" ]; then
  URL="https://github.com/fcrepo-exts/fcrepo-upgrade-utils/releases/download/fcrepo-upgrade-utils-${VERSION}/fcrepo-upgrade-utils-${UPGRADE_UTILS_VERSION}.jar"
  ARG="UPGRADE_UTILS_SHA256"
  DOCKERFILE="fcrepo6/Dockerfile"

elif [ "$DEP" = "cantaloupe" ]; then
  URL="https://github.com/cantaloupe-project/cantaloupe/releases/download/v${VERSION}/cantaloupe-${VERSION}.zip"
  ARG="CANTALOUPE_SHA256"
  DOCKERFILE="cantaloupe/Dockerfile"

elif [ "$DEP" = "fits-servlet" ]; then
  URL="https://github.com/harvard-lts/FITSservlet/releases/download/${VERSION}/fits-service-${VERSION}.war"
  ARG="FITSSERVLET_SHA256"
  DOCKERFILE="cantaloupe/Dockerfile"

elif [ "$DEP" = "fits" ]; then
  URL="https://github.com/harvard-lts/fits/releases/download/${VERSION}/fits-${VERSION}.zip"
  ARG="FITS_SHA256"
  DOCKERFILE="cantaloupe/Dockerfile"

elif [ "$DEP" = "apache-log4j" ]; then
  URL="https://archive.apache.org/dist/logging/log4j/${VERSION}/apache-log4j-${VERSION}-bin.zip"
  ARG="LOG4J_FILE_SHA256"
  DOCKERFILE="cantaloupe/Dockerfile"

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
