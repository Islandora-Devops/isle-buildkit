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
MATOMO_SUBSITES="{{ toUpper (join (lsdir "/matomo/site") " ") }}"
MATOMO_SITES="DEFAULT {{ toUpper (join (lsdir "/matomo/site") " ") }}"
EOF

# Populate container environment variables for each of the MATOMO_SUBSITES.
MATOMO_SUBSITES=$(</var/run/s6/container_environment/MATOMO_SUBSITES)
{
    for MATOMO_SITE in ${MATOMO_SUBSITES}
    do
        for FILE in /var/run/s6/container_environment/MATOMO_DEFAULT_*
        do
            DEFAULT_VAR=$(basename "${FILE}")
            SUFFIX=${DEFAULT_VAR##MATOMO_DEFAULT_}
            VAR=MATOMO_SITE_${MATOMO_SITE}_${SUFFIX}
            SITE=$(echo "${MATOMO_SITE}" | tr '[:upper:]' '[:lower:]')
            KEY=$(echo "${VAR}" | tr '[:upper:]' '[:lower:]' | tr '_' '/')
            # Some defaults are derived from the site name all others 
            # can just use the same default values as the 'default' site.
            case ${SUFFIX} in
                NAME)
                    echo "${VAR}=\"{{ getv \"/${KEY}\" \"${SITE}\" }}\""
                ;;
                *) # Use same default value as the 'default' site.
                    echo "${VAR}=\"{{ getv \"/${KEY}\" (getenv \"${DEFAULT_VAR}\") }}\""
                ;;
            esac
        done
        for FILE in /var/run/s6/container_environment/MATOMO_USER_*
        do
            DEFAULT_VAR=$(basename "${FILE}")
            SUFFIX=${DEFAULT_VAR##MATOMO_}
            VAR=MATOMO_SITE_${MATOMO_SITE}_${SUFFIX}
            SITE=$(echo "${MATOMO_SITE}" | tr '[:upper:]' '[:lower:]')
            KEY=$(echo "${VAR}" | tr '[:upper:]' '[:lower:]' | tr '_' '/')
            # Some defaults are derived from the site name all others 
            # can just use the same default values as the 'default' site.
            case ${SUFFIX} in
                USER_NAME)
                    echo "${VAR}=\"{{ getv \"/${KEY}\" \"${SITE}_admin\" }}\""
                ;;
                *) # Use same default value as the 'default' site.
                    echo "${VAR}=\"{{ getv \"/${KEY}\" (getenv \"${DEFAULT_VAR}\") }}\""
                ;;
            esac
        done
    done
} | /usr/local/bin/confd-import-environment.sh
