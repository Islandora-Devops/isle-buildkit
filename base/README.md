# Base

Base Docker image from which almost all others are derived. It is not meant to
be run on its own.

It's based off off [Alpine Linux], and includes [s6 overlay] and [confd].

## Dependencies

Requires `alpine:3.11.6`

## Settings

| Environment Variable    | Default | Description                              |
| :---------------------- | :------ | :--------------------------------------- |
| ETCD_HOST               | etcd    | The host where etcd, can be found        |
| ETCD_HOST_PORT          | 2379    | The port where etcd can be accessed      |
| ETCD_CONNECTION_TIMEOUT | 0       | Timeout to wait for a connection to etcd |

If [etcd] cannot be reached the container will use environment variables as a
[backend] for [confd]. The timeout is set to `0` by default to ensure containers
start quickly in a development environment where etcd is not running.

Users do not require [etcd] to run the containers, environment variables can be
used instead for simplicity.

[Alpine Linux]: https://alpinelinux.org
[backend]: https://github.com/kelseyhightower/confd/blob/34a6ce8897ab3bde10f49c30c815fe496d592860/docs/configuration-guide.md
[confd]: https://github.com/kelseyhightower/confd
[etcd]: https://github.com/etcd-io/etcd
[s6 overlay]: https://github.com/just-containers/s6-overlay
