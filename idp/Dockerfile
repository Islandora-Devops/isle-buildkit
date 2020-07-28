FROM unicon/shibboleth-idp@sha256:397941df7098b44c939b6d7e0a94afde627a79c27863e0a99f4ae8d8ec069134

ARG TENANT=jhu

COPY common/shibboleth-idp/ /opt/shibboleth-idp/
COPY common/shib-jetty-base/ /opt/shib-jetty-base/

COPY ${TENANT}/shibboleth-idp/ /opt/shibboleth-idp/
