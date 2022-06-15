#!/usr/bin/with-contenv bash

set -e

# Install the bind-mounted certificate if present.
if [[ -f "${CERTIFICATE}" ]]; then
  update-ca-certificates
fi

# Import into the java certificate store if java is installed.
# And the CA pem file exists.
if [[ -f "${CERTIFICATE_AUTHORITY}" ]]; then
  if hash keytool; then
    keytool \
      -importcert \
      -noprompt \
      -keystore /usr/lib/jvm/default-jvm/jre/lib/security/cacerts \
      -storepass changeit \
      -file "${CERTIFICATE_AUTHORITY}" \
      -alias islandora
  fi
fi
