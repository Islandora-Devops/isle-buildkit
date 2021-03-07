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

# Import sites/subsites environment var so we can generate defaults for each site.
cat << EOF | /usr/local/bin/confd-import-environment.sh
DRUPAL_SUBSITES="{{ toUpper (join (lsdir "/drupal/site") " ") }}"
DRUPAL_SITES="DEFAULT {{ toUpper (join (lsdir "/drupal/site") " ") }}"
EOF

# Populate container environment variables for each of the DRUPAL_SUBSITES.
DRUPAL_SUBSITES=$(</var/run/s6/container_environment/DRUPAL_SUBSITES)
{
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
} | /usr/local/bin/confd-import-environment.sh
