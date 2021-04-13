#!/bin/sh

#set -x

export JAVA_HOME=/opt/jre-home
export PATH=$PATH:$JAVA_HOME/bin

if [ -e "/opt/shibboleth-idp/ext-conf/idp-secrets.properties" ]; then
  export JETTY_BACKCHANNEL_SSL_KEYSTORE_PASSWORD=`gawk 'match($0,/^jetty.backchannel.sslContext.keyStorePassword=\s?(.*)\s?$/, a) {print a[1]}' /opt/shibboleth-idp/ext-conf/idp-secrets.properties`
  export JETTY_BROWSER_SSL_KEYSTORE_PASSWORD=`gawk 'match($0,/^jetty\.sslContext\.keyStorePassword=\s?(.*)\s?$/, a) {print a[1]}' /opt/shibboleth-idp/ext-conf/idp-secrets.properties`
fi

export JETTY_ARGS="jetty.sslContext.keyStorePassword=$JETTY_BROWSER_SSL_KEYSTORE_PASSWORD jetty.backchannel.sslContext.keyStorePassword=$JETTY_BACKCHANNEL_SSL_KEYSTORE_PASSWORD"
sed -i "s/^-Xmx.*$/-Xmx$JETTY_MAX_HEAP/g" /opt/shib-jetty-base/start.ini

confd -onetime -backend file -file /run/secrets/saml_secrets -sync-only

export _SP_SIGNING_CERT=$(yq eval '.saml-secrets.sp.signing-cert' /run/secrets/saml_secrets | sed -e '/^-----*/d'|tr -d '\n')
export _IDP_SIGNING_CERT=$(yq eval '.saml-secrets.idp.signing-cert' /run/secrets/saml_secrets | sed -e '/^-----*/d'|tr -d '\n')
export _IDP_ENCRYPTION_CERT=$(yq eval '.saml-secrets.idp.encryption-cert' /run/secrets/saml_secrets | sed -e '/^-----*/d'|tr -d '\n')
export _IDP_BACKCHANNEL_CERT=$(yq eval '.saml-secrets.idp.backchannel-signing-cert' /run/secrets/saml_secrets | sed -e '/^-----*/d'|tr -d '\n')

envsubst < /opt/shibboleth-idp/metadata/sp-metadata.xml > /tmp/sp-metadata.xml && cp /tmp/sp-metadata.xml /opt/shibboleth-idp/metadata/sp-metadata.xml
envsubst < /opt/shibboleth-idp/metadata/idp-metadata.xml > /tmp/idp-metadata.xml && cp /tmp/idp-metadata.xml /opt/shibboleth-idp/metadata/idp-metadata.xml
envsubst < /opt/shibboleth-idp/conf/attribute-filter.xml > /tmp/attribute-filter.xml && cp /tmp/attribute-filter.xml /opt/shibboleth-idp/conf/attribute-filter.xml
envsubst < /opt/shibboleth-idp/conf/idp.properties > /tmp/idp.properties && cp /tmp/idp.properties /opt/shibboleth-idp/conf/idp.properties

exec /etc/init.d/jetty run