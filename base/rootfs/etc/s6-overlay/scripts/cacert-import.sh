#!/command/with-contenv bash
# shellcheck shell=bash

set -e

# Install the bind-mounted certificate if present.
if [[ -s "/usr/local/share/ca-certificates/cert.pem" ]]; then
    update-ca-certificates
fi

# Import into the java certificate store if java is installed.
# And the CA pem file exists.
if [[ -s "/usr/local/share/ca-certificates/rootCA.pem" ]]; then
    if hash keytool &>/dev/null; then
        keytool \
            -importcert \
            -noprompt \
            -cacerts \
            -storepass changeit \
            -file "/usr/local/share/ca-certificates/rootCA.pem" \
            -alias rootCA.pem
    fi
fi
