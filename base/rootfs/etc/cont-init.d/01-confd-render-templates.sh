#!/usr/bin/with-contenv bash
set -e 

# Renders confd templates once.
confd-render-templates.sh -- -onetime -sync-only
