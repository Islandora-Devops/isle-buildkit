#!/usr/bin/with-contenv bash
set -e

# Renders the SAML secrets from the file backend
confd -onetime -backend file -file /run/secrets/saml_secrets -sync-only -confdir /etc/confd-saml-secrets  -config-file /etc/confd-saml-secrets/confd.toml