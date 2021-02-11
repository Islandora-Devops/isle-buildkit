#!/usr/bin/env bash
set -e

# Sets container enviroment variables in order of precedence depending on the
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
/bin/exec -c \
    s6-envdir -fn -- /etc/defaults \
    s6-envdir -fn -- /var/run/s6/container_environment \
    s6-envdir -fn -- /run/secrets \
    s6-dumpenv -- /var/run/s6/container_environment

# Temporary directory to deposit generated confd configuration templates and
# output, etc.
mkdir -p /tmp/confd/conf.d /tmp/confd/templates /tmp/confd/out

# Temporary confd template config.
cat << EOF > /tmp/confd/conf.d/import.sh.toml
[template]
src = "import.sh.tmpl"
dest = "/tmp/confd/out/import.sh"
keys = ["/"]
EOF

# Generate template script that will update the container environment with
# values provided by the confd backend. execline is used rather than bash 
# to avoid issues with whitespace newlines and string interpolation.
{
    echo 's6-env -i'
    for file in /var/run/s6/container_environment/*
    do
        VAR=$(basename "${file}")
        KEY=$(echo "${VAR}" | tr '[:upper:]' '[:lower:]' | tr '_' '/')
        echo "${VAR}=\"{{ getv \"/${KEY}\" (getenv \"${VAR}\") }}\""
    done
    echo 's6-dumpenv -- /var/run/s6/container_environment'
} > /tmp/confd/templates/import.sh.tmpl

# Allow the choosen confd backend to update the container environment.
# If the backend is 'env' this effectively does nothing, this allows 
# scripts to use variables defined by the confd backend.
CONFD_LOG_LEVEL=$(</var/run/s6/container_environment/CONFD_LOG_LEVEL)
CONFD_BACKEND=$(</var/run/s6/container_environment/CONFD_BACKEND)
with-contenv wait-for-confd-backend.sh
with-contenv confd -prefix '/' -onetime -sync-only -confdir /tmp/confd -log-level ${CONFD_LOG_LEVEL} -backend ${CONFD_BACKEND}
execlineb -P /tmp/confd/out/import.sh 

# Remove temporary files.
rm -fr /tmp/confd