#!/usr/bin/env bash
set -e

# Sets container environment variables in order of precedence depending on the
# source:
#
#  1. Confd backend (highest)
#  2. Secrets kept in /run/secrets
#  3. Environment variables passed into the container
#  4. Environment variables defined in Dockerfile(s)
#  5. Environment variables defined in the /etc/defaults directory (lowest only used for multiline variables)
#
# If not defined in the highest level the next level applies and so forth down
# the list. /etc/defaults and the environment variables declared in the
# Dockerfile(s) used to create this image are expected to define all
# environment variables used by scripts and Confd templates.
#
# Confd templates are required to use `getenv` function for all default values.

# Load the environment variables according to the expected precedence.
# Note `exec -c` is used to empty the existing environment.
#
# Write those to the container environment if not already present. The container
# environment has already been initialized by this point and contains levels 3 and
# 4 as mentioned in the top of this file.

# Temporary conditional to prevent issues with Kubernetes as `s6-envdir` expects the
# folder to contain only files, Kubernetes mounts a folder in this location and works
# with secrets in a different way. At a later time we'll revisit our convention to
# hopefully support all that Kuberentes has to offer while not degrading the
# quality of Swarm or Docker Compose. At the moment Kubernetes users will need
# to inject the secrets as environment variables. Please see
# https://kubernetes.io/docs/concepts/configuration/secret/#using-secrets-as-environment-variables
if [[ $(find /run/secrets -mindepth 1 -maxdepth 1 -type d | wc -l) -gt 0 ]]; then
    /command/exec -c \
        s6-envdir -fn -- /etc/defaults \
        s6-envdir -fn -- /var/run/s6/container_environment \
        s6-dumpenv -- /var/run/s6/container_environment
else
    /command/exec -c \
        s6-envdir -fn -- /etc/defaults \
        s6-envdir -fn -- /var/run/s6/container_environment \
        s6-envdir -fn -- /run/secrets \
        s6-dumpenv -- /var/run/s6/container_environment
fi

# Confd backend variable needs to be normalized.
CONFD_BACKEND=$(</var/run/s6/container_environment/CONFD_BACKEND)
case "${CONFD_BACKEND}" in
etcd | etcdv3)
    CONFD_BACKEND="etcdv3"
    ;;
env)
    CONFD_BACKEND="env"
    ;;
*)
    # Unknown backend assume failure.
    exit 1
    ;;
esac
echo "CONFD_BACKEND=${CONFD_BACKEND}" | /usr/local/bin/confd-import-environment.sh

# Import environment variables from confd or default to what is currently in the
# container environment. This can only import values from confd that are already
# defined in the environment.
{
    for file in /var/run/s6/container_environment/*; do
        VAR=$(basename "${file}")
        KEY=$(echo "${VAR}" | tr '[:upper:]' '[:lower:]' | tr '_' '/')
        echo "${VAR}=\"{{ getv \"/${KEY}\" (getenv \"${VAR}\") }}\""
    done
} | /usr/local/bin/confd-import-environment.sh
