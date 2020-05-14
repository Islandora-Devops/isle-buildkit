#!/usr/bin/with-contenv bash
set -e
# Key needs to be present before startup otherwise,
# it will ignore subsequent requests even if the key has been generated.
timeout 60 bash -c 'until [[ -f /opt/keys/claw/public.key ]]; do sleep 1; done'
