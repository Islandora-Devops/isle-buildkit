#!/command/with-contenv bash
# shellcheck shell=bash
set -e
confd-render-templates.sh -- -onetime -sync-only
