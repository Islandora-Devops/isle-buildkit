#!/usr/bin/with-contenv bash

set -e

# Install the bind-mounted certificate if present.
if [[ -s "/usr/local/share/ca-certificates/cert.pem" ]]; then
  update-ca-certificates
fi

# Import into the java certificate store if java is installed.
# And the CA pem file exists.
if [[ -s "/usr/local/share/ca-certificates/rootCA.pem" ]]; then
  if hash keytool; then
    keytool \
      -importcert \
      -noprompt \
      -keystore /usr/lib/jvm/default-jvm/jre/lib/security/cacerts \
      -storepass changeit \
      -file "/usr/local/share/ca-certificates/rootCA.pem" \
      -alias islandora
  fi
fi
