#!/bin/sh

# Wait for etcd to start
while true; do
    etcdctl endpoint status >/dev/null 2>&1 
    if [ "$?" -eq "0" ]; then
        break
    fi
    sleep 1
done

etcdctl put /jwt/admin/token "JWT_ADMIN_TOKEN confd value"