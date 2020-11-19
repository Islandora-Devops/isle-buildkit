#!/usr/bin/with-contenv bash
set -e

IPS=$(getent hosts traefik | awk '{ print $1 }')
[[ ! -z "$IPS" ]] && s6-env -i DRUPAL_REVERSE_PROXY_IPS="$IPS" s6-dumpenv -- /var/run/s6/container_environment

