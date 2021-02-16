#!/usr/bin/env bash
set -e

# Update container environment with site specific environment variables:
#
# 1. Get the list of subsites from confd backend.
# 2. For each subsite set container variables if not already defined.
#
# At this point the 'default' site variables have already been updated to match
# the confd backend. As such for any subsite will use those values unless the
# subsite variable is explicitly overriden.

# Temporary directory to deposit generated confd configuration templates and
# output, etc.
mkdir -p /tmp/confd/conf.d /tmp/confd/templates /tmp/confd/out

# Get backend and log level.
CONFD_LOG_LEVEL=$(</var/run/s6/container_environment/CONFD_LOG_LEVEL)
CONFD_BACKEND=$(</var/run/s6/container_environment/CONFD_BACKEND)

# Temporary confd template config.
cat << EOF > /tmp/confd/conf.d/import.sh.toml
[template]
src = "import.sh.tmpl"
dest = "/tmp/confd/out/import.sh"
keys = ["/"]
EOF

# Temporary confd template.
cat << EOF > /tmp/confd/templates/import.sh.tmpl
s6-env -i 
DRUPAL_SUBSITES="{{ toUpper (join (lsdir "/drupal/site") " ") }}"
DRUPAL_SITES="DEFAULT {{ toUpper (join (lsdir "/drupal/site") " ") }}"
s6-dumpenv -- /var/run/s6/container_environment
EOF

# Set DRUPAL_SUBSITES and DRUPAL_SITES variables by checking if any environment
# variables have been defined for them.
with-contenv wait-for-confd-backend.sh
with-contenv confd -prefix '/' -onetime -sync-only -confdir /tmp/confd -log-level ${CONFD_LOG_LEVEL} -backend ${CONFD_BACKEND}
execlineb -P /tmp/confd/out/import.sh 

# Populate container environment variables for each of the DRUPAL_SUBSITES.
DRUPAL_SUBSITES=$(</var/run/s6/container_environment/DRUPAL_SUBSITES)
{
    echo 's6-env -i'
    for DRUPAL_SITE in ${DRUPAL_SUBSITES}
    do
        for FILE in /var/run/s6/container_environment/DRUPAL_DEFAULT_*
        do
            DEFAULT_VAR=$(basename "${FILE}")
            SUFFIX=${DEFAULT_VAR##DRUPAL_DEFAULT_}
            VAR=DRUPAL_SITE_${DRUPAL_SITE}_${SUFFIX}
            SITE=$(echo "${DRUPAL_SITE}" | tr '[:upper:]' '[:lower:]')
            KEY=$(echo "${VAR}" | tr '[:upper:]' '[:lower:]' | tr '_' '/')
            # Some defaults are derived from the site name all others 
            # can just use the same default values as the 'default' site.
            case ${SUFFIX} in
                DB_NAME|DB_USER)
                    echo "${VAR}=\"{{ getv \"/${KEY}\" \"drupal_${SITE}\" }}\""
                ;;
                NAME|SUBDIR|SOLR_CORE|TRIPLESTORE_NAMESPACE)
                    echo "${VAR}=\"{{ getv \"/${KEY}\" \"${SITE}\" }}\""
                ;;
                *) # Use same default value as the 'default' site.
                    echo "${VAR}=\"{{ getv \"/${KEY}\" (getenv \"${DEFAULT_VAR}\") }}\""
                ;;
            esac
            
        done
    done
    echo 's6-dumpenv -- /var/run/s6/container_environment'
} > /tmp/confd/templates/import.sh.tmpl

# Allow the choosen confd backend to update the container environment.
# If the backend is 'env' this effectively does nothing, this allows 
# scripts to use variables defined by the confd backend.
with-contenv wait-for-confd-backend.sh
with-contenv confd -prefix '/' -onetime -sync-only -confdir /tmp/confd -log-level ${CONFD_LOG_LEVEL} -backend ${CONFD_BACKEND}
execlineb -P /tmp/confd/out/import.sh 

# Remove temporary files.
rm -fr /tmp/confd