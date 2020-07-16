#!/usr/bin/with-contenv bash
set -e

# Make run directory if it does not exist.
mkdir /run/postgresql &> /dev/null || true
chown postgres:postgres /run/postgresql

# If no database has been created yet.
if [[ ! -f "${PGDATA}/PG_VERSION" ]]; then
    # Make sure the ${PGDATA} directory is empty so the init can run successfully. 
    rm -fr ${PGDATA}/*
    s6-setuidgid postgres bash -c "initdb --username='${POSTGRESQL_ROOT_USER}' --pwfile=<(echo '${POSTGRESQL_ROOT_PASSWORD}')"
    # Rerun the confd to restore any files that it would have written to the ${PGDATA} directory.
    confd-render-templates.sh
fi
