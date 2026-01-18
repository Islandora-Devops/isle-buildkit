#!/command/with-contenv bash
# shellcheck shell=bash
set -e

# If not explicitly set by confd backend already attempt to set it from querying
# current networking environment.
if [[ -z "${DRUPAL_REVERSE_PROXY_IPS}" ]]; then
    IPS=$(getent hosts traefik | awk '{ print $1 }')
    # Use the IP address for the host 'traefik' if found otherwise default to
    # '0.0.0.0'.
    s6-env -i DRUPAL_REVERSE_PROXY_IPS="${IPS:-0.0.0.0}" s6-dumpenv -- /var/run/s6/container_environment
fi
