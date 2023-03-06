#!/command/with-contenv bash
# shellcheck shell=bash
set -e

function main {
    local tcp="${ALPACA_JMS_URL%:*}"
    local host="${tcp##*/}"
    local port="${ALPACA_JMS_URL##*:}"

    if timeout 300 wait-for-open-port.sh "${host}" "${port}"; then
        echo "Broker found at ${host}:${port}"
        return 0
    else
        echo "Could not connect to broker at ${host}:${port}"
        exit 1
    fi
}
main
