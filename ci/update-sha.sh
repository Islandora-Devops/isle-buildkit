#!/usr/bin/env bash

set -eou pipefail

DEP=$1
OLD_VERSION=$2
NEW_VERSION=$3
NEW_DIGEST=$4
URL=""
ARG=""
DOCKERFILES=()
README=""

# Function to update the Dockerfile(s) ARG SHA256 value
update_dockerfile_sha() {
  local URL="$1"
  local ARG="$2"
  local DOCKERFILES=("${@:3}")
  local SHA
  SHA=$(curl -Ls "$URL" | shasum -a 256 | awk '{print $1}')

  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' 's|^ARG '"$ARG"'=.*|ARG '"$ARG"'="'"$SHA"'"|g' "${DOCKERFILES[@]}"
  else
    sed -i 's|^ARG '"$ARG"'=.*|ARG '"$ARG"'="'"$SHA"'"|g' "${DOCKERFILES[@]}"
  fi
}

echo "Updating SHA for $DEP@$NEW_VERSION"

if [ "$DEP" = "apache-tomcat" ]; then
  URL="https://downloads.apache.org/tomcat/tomcat-9/v$NEW_VERSION/bin/apache-tomcat-$NEW_VERSION.tar.gz"
  ARG="TOMCAT_FILE_SHA256"
  DOCKERFILES=("tomcat/Dockerfile")
  README="tomcat/README.md"

elif [ "$DEP" = "apache-activemq" ]; then
  URL="https://downloads.apache.org/activemq/$NEW_VERSION/apache-activemq-$NEW_VERSION-bin.tar.gz"
  ARG="ACTIVEMQ_FILE_SHA256"
  DOCKERFILES=("activemq/Dockerfile")
  README="activemq/README.md"

elif [ "$DEP" = "apache-solr" ]; then
  URL="https://downloads.apache.org/solr/solr/$NEW_VERSION/solr-$NEW_VERSION.tgz"
  ARG="SOLR_FILE_SHA256"
  DOCKERFILES=("solr/Dockerfile")
  README="solr/README.md"

elif [ "$DEP" = "custom-composer" ]; then
  URL="https://getcomposer.org/download/${NEW_VERSION}/composer.phar"
  ARG="COMPOSER_SHA256"
  DOCKERFILES=("nginx/Dockerfile")

elif [ "$DEP" = "solr-ocrhighlighting" ]; then
  URL=https://github.com/dbmdz/solr-ocrhighlighting/releases/download/${NEW_VERSION}/solr-ocrhighlighting-${NEW_VERSION}.jar
  ARG="OCRHIGHLIGHT_FILE_SHA256"
  DOCKERFILES=("solr/Dockerfile")

elif [ "$DEP" = "alpine-pkg-glibc" ]; then
  URL="https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${NEW_VERSION}/glibc-${NEW_VERSION}.apk"
  ARG="GLIBC_SHA256"
  DOCKERFILES=("code-server/Dockerfile")

elif [ "$DEP" = "fcrepo" ]; then
  URL="https://github.com/fcrepo/fcrepo/releases/download/fcrepo-${NEW_VERSION}/fcrepo-webapp-${NEW_VERSION}.war"
  ARG="FCREPO_SHA256"
  DOCKERFILES=("fcrepo6/Dockerfile")
  README="fcrepo6/README.md"

elif [ "$DEP" = "islandora-syn" ]; then
  URL="https://github.com/Islandora/Syn/releases/download/v${NEW_VERSION}/islandora-syn-${NEW_VERSION}-all.jar"
  ARG="SYN_SHA256"
  DOCKERFILES=("fcrepo6/Dockerfile")

elif [ "$DEP" = "fcrepo-import-export" ]; then
  URL="https://github.com/fcrepo-exts/fcrepo-import-export/releases/download/fcrepo-import-export-${NEW_VERSION}/fcrepo-import-export-${NEW_VERSION}.jar"
  ARG="IMPORT_EXPORT_SHA256"
  DOCKERFILES=("fcrepo6/Dockerfile")

elif [ "$DEP" = "fcrepo-upgrade-utils" ]; then
  URL="https://github.com/fcrepo-exts/fcrepo-upgrade-utils/releases/download/fcrepo-upgrade-utils-${NEW_VERSION}/fcrepo-upgrade-utils-${NEW_VERSION}.jar"
  ARG="UPGRADE_UTILS_SHA256"
  DOCKERFILES=("fcrepo6/Dockerfile")

elif [ "$DEP" = "cantaloupe" ]; then
  URL="https://github.com/cantaloupe-project/cantaloupe/releases/download/v${NEW_VERSION}/cantaloupe-${NEW_VERSION}.zip"
  ARG="CANTALOUPE_SHA256"
  DOCKERFILES=("cantaloupe/Dockerfile")
  README="cantaloupe/README.md"

elif [ "$DEP" = "fits-servlet" ]; then
  URL="https://github.com/harvard-lts/FITSservlet/releases/download/${NEW_VERSION}/fits-service-${NEW_VERSION}.war"
  ARG="FITSSERVLET_SHA256"
  DOCKERFILES=("fits/Dockerfile")

elif [ "$DEP" = "fits" ]; then
  URL="https://github.com/harvard-lts/fits/releases/download/${NEW_VERSION}/fits-${NEW_VERSION}.zip"
  ARG="FITS_SHA256"
  DOCKERFILES=("fits/Dockerfile")
  README="fits/README.md"

elif [ "$DEP" = "apache-log4j" ]; then
  URL="https://archive.apache.org/dist/logging/log4j/${NEW_VERSION}/apache-log4j-${NEW_VERSION}-bin.zip"
  ARG="LOG4J_FILE_SHA256"
  DOCKERFILES=(
    "blazegraph/Dockerfile"
    "fits/Dockerfile"
  )

elif [ "$DEP" = "islandora-starter-site" ]; then
  URL=https://github.com/Islandora-Devops/islandora-starter-site/archive/${NEW_DIGEST}.tar.gz
  ARG="SHA256"
  DOCKERFILES=("test/Dockerfile")

elif [ "$DEP" = "jdbc-mysql" ]; then
  URL="https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-j-${NEW_VERSION}.tar.gz"
  ARG=MYSQL_DRIVER_FILE_SHA256
  DOCKERFILES=("handle/Dockerfile")

elif [ "$DEP" = "jdbc-postgres" ]; then
  URL="https://jdbc.postgresql.org/download/postgresql-${NEW_VERSION}.jar"
  ARG=POSTGRES_DRIVER_FILE_SHA256
  DOCKERFILES=("handle/Dockerfile")

elif [ "$DEP" = "s6-overlay" ]; then
  BASE_URL="https://github.com/just-containers/s6-overlay/releases/download/v${NEW_VERSION}"
  declare -A URLS_AND_ARGS=(
    ["S6_OVERLAY_NOARCH_SHA256"]="$BASE_URL/s6-overlay-noarch.tar.xz"
    ["S6_OVERLAY_SYMLINKS_ARCH_SHA256"]="$BASE_URL/s6-overlay-symlinks-arch.tar.xz"
    ["S6_OVERLAY_SYMLINKS_NOARCH_SHA256"]="$BASE_URL/s6-overlay-symlinks-noarch.tar.xz"
    ["S6_OVERLAY_AMD64_SHA256"]="$BASE_URL/s6-overlay-x86_64.tar.xz"
    ["S6_OVERLAY_ARM64_SHA256"]="$BASE_URL/s6-overlay-aarch64.tar.xz"
  )

  for ARG in "${!URLS_AND_ARGS[@]}"; do
    URL="${URLS_AND_ARGS[$ARG]}"
    update_dockerfile_sha "$URL" "$ARG" "base/Dockerfile"
  done

  exit 0

else
  echo "DEP not found"
  exit 0
fi

update_dockerfile_sha "$URL" "$ARG" "${DOCKERFILES[@]}"

# update the README to specify the new version
if [ "$README" != "" ]; then
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/${OLD_VERSION}\.$/${NEW_VERSION}\./" "$README"
  else
    sed -i "s/${OLD_VERSION}\.$/${NEW_VERSION}\./" "$README"
  fi
fi
