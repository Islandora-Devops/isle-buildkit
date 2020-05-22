#!/usr/bin/with-contenv bash
set -e 

readonly ETCD_HOST=${ETCD_HOST:-etcd}
readonly ETCD_HOST_PORT=${ETCD_HOST_PORT:-2379}
readonly ETCD_CONNECTION_TIMEOUT=${ETCD_CONNECTION_TIMEOUT:-0}
readonly CONFD_LOG_LEVEL=${CONFD_LOG_LEVEL:-error}
readonly CONFD_POLLING_INTERVAL=${CONFD_POLLING_INTERVAL:-30}

echo "Looking for etcd server... http://${ETCD_HOST}:${ETCD_HOST_PORT}"
if timeout ${ETCD_CONNECTION_TIMEOUT} wait-for-open-port.sh ${ETCD_HOST} ${ETCD_HOST_PORT} &> /dev/null; then
    echo "Found etcd server..."
    confd -onetime -sync-only -log-level ${CONFD_LOG_LEVEL} -backend etcdv3 -node ${ETCD_HOST}:${ETCD_HOST_PORT}
else 
  echo "Timeout exceeded using env backend..."
  confd -onetime -sync-only -log-level ${CONFD_LOG_LEVEL} -backend env 
fi
