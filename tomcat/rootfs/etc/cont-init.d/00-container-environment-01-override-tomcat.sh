#!/usr/bin/env bash
set -e

# Allow TOMCAT_LOG_LEVEL to be overriden by FEDORA_TOMCAT_LOG_LEVEL, etc.
/usr/local/bin/confd-override-environment.sh --prefix TOMCAT
