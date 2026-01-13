# Base

Base Docker image from which almost all others are derived. It is not meant to
be run on its own.

Built from [Islandora-DevOps/isle-buildkit base](https://github.com/Islandora-DevOps/isle-buildkit/tree/main/base)

It's based off off [Alpine Linux], and includes [s6 overlay] and [confd].

## Dependencies

Requires `alpine` version is set in [docker-bake.hcl](../docker-bake.hcl).

## Settings

### Confd Settings

The following environment variables cannot be provided by [confd] as they drive
it's configuration, they must be set on each container as environment variables.

| Environment Variable    | Default | Description                                                                       |
| :---------------------- | :------ | :-------------------------------------------------------------------------------- |
| CONFD_BACKEND           | env     | The backend to use for `confd` only `env`, and `etcd` are supported at the moment |
| CONFD_ENABLE_SERVICE    | false   | If `true` confd will run continuously rather than just on startup.                |
| CONFD_LOG_LEVEL         | error   | The log level to use when executing `confd`                                       |
| CONFD_POLLING_INTERVAL  | 30      | Time in seconds between runs of `confd` when enabled as a service                 |
| ETCD_CONNECTION_TIMEOUT | 0       | Timeout to wait for a connection to etcd                                          |
| ETCD_HOST               | etcd    | The host where etcd, can be found                                                 |
| ETCD_PORT               | 2379    | The port where etcd can be accessed                                               |

Users do not require [etcd] to run the containers, environment variables can be
used instead for simplicity.

### Certificate Settings

If using development certificates for local development, they can be made
available within the containers using the following environment variables.

| Environment Variable | Default | Description                                                                                                                                                  |
| :------------------- | :------ | :----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CERT_PUBLIC_KEY      |         | Primarily used for development. If provided the certificate will be registered inside of the container such that curl, etc accepts the certificate as valid. |
| CERT_AUTHORITY       |         | Primarily used for development. If provided the authority is registered with the java, so that requests originating from Java accept the public certificate. |

For example if generating certificates locally with [mkcert] for local
development, and using `islandora.dev` as the primary domain.

> N.B `islandora.dev` just redirects back to `127.0.0.1`.

```bash
mkcert -install
mkcert \
  -cert-file cert.pem \
  -key-file privkey.pem \
  "*.islandora.dev" \
  "islandora.dev" \
  "localhost" \
  "127.0.0.1" \
  "::1"
```

This will generate `cert.pem` which can be use as `CERT_PUBLIC_KEY` and
`rootCA.pem` can be used for `CERT_AUTHORITY`. `rootCA.pem` can be found at the
path printed by using the command `mkcert -CAROOT`.

Now requests originating within the container will accept the development
certificate as genuine.

> N.B. This is not required for production sites or certificates that are
> publically available.

### JWT Settings

Many services that connect to Drupal / Fedora authenticate via JWT. Please see
the Islandora documentation for [JWT Authentication], and the [Syn] project for
more details. The base image includes these environment variables to reduce
duplication.

| Environment Variable | Default                                       | Description                                                                                                  |
| :------------------- | :-------------------------------------------- | :----------------------------------------------------------------------------------------------------------- |
| JWT_ADMIN_TOKEN      | islandora                                     | Used for [bearer authentication] (Only use with HTTPS or over private networks)                              |
| JWT_PRIVATE_KEY      | @see base/rootfs/etc/defaults/JWT_PRIVATE_KEY | Private key for JWT authentication, RSA PEM Format is expected (should only be used in the Drupal container) |
| JWT_PUBLIC_KEY       | @see base/rootfs/etc/defaults/JWT_PUBLIC_KEY  | Public key for JWT authentication                                                                            |

To generate a private public / private key pair use the following.

```bash
ssh-keygen -q -t rsa -m pem -f /tmp/JWT -N ""
```

This produces two files `/tmp/JWT` and `/tmp/JWT.pub`. Which can be used for
`JWT_PRIVATE_KEY` and `JWT_PUBLIC_KEY` respectively. The format is RSA PEM,
*without a password*. **Do not share these files** keep their contents hidden.

The public/private key pair and [Syn] configuration are placed in `/opt/keys`
and are only readable by the `jwt` group, if your service needs to read these files
add `jwt` as a secondary group to your service user.

### Database Settings

Many services can work with multiple backends, to this end the `DB_DRIVER`
setting is used to determine which of the backend specific environment variables
to use. For example if `DB_DRIVER` is equal to `mysql` then the `DB_MYSQL_HOST`
and `DB_MYSQL_PORT` variables will be used when connecting to the backend.

| Environment Variable | Default    | Description                                                                                     |
| :------------------- | :--------- | :---------------------------------------------------------------------------------------------- |
| DB_DRIVER            | mysql      | The database driver to use by default, only `mysql` and `postgresql` are supported at this time |
| DB_HOST              |            | The database host to use. The default value is derived from `DB_DRIVER` if not specified        |
| DB_MYSQL_HOST        | mariadb    | The default database host if `DB_DRIVER` is `mysql`                                             |
| DB_MYSQL_PORT        | 3306       | The default database port if `DB_DRIVER` is `mysql`                                             |
| DB_NAME              | default    | The name of the default database if no other is specified                                       |
| DB_PASSWORD          | password   | The password of the user used by the service (e.g. Drupal) to connect to the database           |
| DB_PORT              |            | The database port to use. The default value is derived from `DB_DRIVER` if not specified        |
| DB_POSTGRESQL_HOST   | postgresql | The default database host if `DB_DRIVER` is `postgresql`                                        |
| DB_POSTGRESQL_PORT   | 5432       | The default database port if `DB_DRIVER` is `postgresql`                                        |
| DB_ROOT_PASSWORD     | password   | The root user password                                                                          |
| DB_ROOT_USER         | root       | The root user, which is used only on startup to create database / user in the chosen backend    |
| DB_USER              | default    | The user used by the service (e.g. Drupal) to connect to the database                           |

> N.B. For all of the settings above, images that descend from this image can
> apply a prefix to every setting. So for example `DB_NAME` would become
> `FCREPO_DB_NAME`. This is to allow for different settings on a per-service
> basis when sharing the same confd backend.


[Alpine Linux]: https://alpinelinux.org
[bearer authentication]: https://tools.ietf.org/html/rfc6750
[confd]: https://github.com/kelseyhightower/confd
[etcd]: https://github.com/etcd-io/etcd
[JWT Authentication]: https://islandora.github.io/documentation/technical-documentation/jwt/
[mkcert]: https://github.com/FiloSottile/mkcert
[s6 overlay]: https://github.com/just-containers/s6-overlay
[Syn]: https://github.com/Islandora/Syn
