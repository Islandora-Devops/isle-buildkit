# Fcrepo

Docker image for [fcrepo] version 6.5.0

Please refer to the [Fcrepo Documentation] for more in-depth information.

As a quick example this will bring up an instance of [fcrepo], and allow you
to view on <http://localhost:80/fcrepo/>.

```bash
docker run --rm -ti -p 80:80 islandora/fcrepo
```

## Dependencies

Requires `islandora/tomcat` docker image to build. Please refer to the
[Tomcat Image README](../tomcat/README.md) for additional information including
additional settings, volumes, ports, etc.

## Volumes

| Path  | Description     |
| :---- | :-------------- |
| /data | OCFL Filesystem |

> N.B. Volumes are not created automatically. It is up to the user to either bind
> mount or attach a volume at the paths specified above.

## Settings

### Confd Settings

| Environment Variable         | Default              | Description                                                                          |
| :--------------------------- | :------------------- | :----------------------------------------------------------------------------------- |
| FCREPO_ACTIVEMQ_BROKER       | tcp://activemq:61616 | The location of the ActiveMQ Broker in which to publish JMS messages to              |
| FCREPO_ACTIVEMQ_QUEUE        | fedora               | The ActiveMQ Queue in which to publish JMS messages                                  |
| FCREPO_ACTIVEMQ_QUEUE_ENABLE | false                | If `true` publish JMS messages on the queue `FCREPO_ACTIVEMQ_QUEUE`                  |
| FCREPO_ACTIVEMQ_TOPIC        | fedora               | The ActiveMQ Topic in which to publish JMS messages                                  |
| FCREPO_ACTIVEMQ_TOPIC_ENABLE | true                 | If `true` publish JMS messages on the topic `FCREPO_ACTIVEMQ_TOPIC`                  |
| FCREPO_BINARYSTORAGE_TYPE    | file                 | The binary storage type. Only `file` and `s3` are supported at this time             |
| FCREPO_AWS_REGION            | us-east-1            | AWS Region for S3 Bucket                                                             |
| FCREPO_S3_BUCKET             |                      | Bucket to use for S3 Storage                                                         |
| FCREPO_S3_USER               |                      | AWS User for S3 Storage                                                              |
| FCREPO_S3_PASSWORD           |                      | AWS Secret Token for S3 Storage                                                      |
| FCREPO_S3_PREFIX             |                      | AWS Prefix for S3 Storage                                                            |
| FCREPO_PERSISTENCE_TYPE      | file                 | The object store type. Only `file`, `mysql`, `postgresql` are supported at this time |
| FCREPO_DISABLE_SYN           | false                | Enable or disable authentication via [Syn](https://github.com/Islandora/Syn)         |

To allow [external content] provide sites as key pairs. Wherein multiple values
is the url and the 'name' is a key that replaces the '*' symbol below.

| Environment Variable    |
| :---------------------- |
| FCREPO_ALLOW_EXTERNAL_* |

### JWT Settings

[fcrepo] makes use of JWT for authentication. Please see the documentation in
the [base image] for more information.

### Database Settings

[fcrepo] can optionally make use of a database for object storage. Please see
the documentation in the [base image] for more information about the default
database connection configuration.

The following settings are only used if `FCREPO_PERSISTENCE_TYPE` is set to
`mysql` or `postgresql`.

| Environment Variable | Default  | Description                                              |
| :------------------- | :------- | :------------------------------------------------------- |
| FCREPO_DB_NAME       | fedora   | The name of the database                                 |
| FCREPO_DB_USER       | fedora   | The user to connect to the database                      |
| FCREPO_DB_PASSWORD   | password | The password of the user used to connect to the database |

Additionally the `DB_DRIVER` variable is derived from the
`FCREPO_PERSISTENCE_TYPE` so users do not need to specify it separately.

### Tomcat Settings

Fcrepo is deployed in as a servlet in Tomcat. Please see the documentation in
the [tomcat image] for more information.


## Updating

You can change the version used for [fcrepo] by modifying the build argument
`FCREPO_VERSION` and `FCREPO_SHA256` in the `Dockerfile`.

Change `FCREPO_VERSION` and then generate the `FCREPO_SHA256` with the following
commands:

```bash
FCREPO_VERSION=$(cat fcrepo6/Dockerfile | grep -o 'FCREPO_VERSION=.*' | cut -f2 -d=)
FCREPO_FILE=$(cat fcrepo6/Dockerfile | grep -o 'FCREPO_FILE=.*' | cut -f2 -d=)
FCREPO_URL=$(cat fcrepo6/Dockerfile | grep -o 'FCREPO_URL=.*' | cut -f2 -d=)
FCREPO_FILE=$(eval "echo $FCREPO_FILE")
FCREPO_URL=$(eval "echo $FCREPO_URL")
wget --quiet "${FCREPO_URL}"
shasum -a 256 "${FCREPO_FILE}" | cut -f1 -d' '
rm "${FCREPO_FILE}"
```

You can change the version used for [syn] by modifying the build argument
`SYN_VERSION` and `SYN_SHA256` in the `Dockerfile`.

Change `SYN_VERSION` and then generate the `SYN_SHA256` with the following
commands:

```bash
SYN_VERSION=$(cat fcrepo6/Dockerfile | grep -o 'SYN_VERSION=.*' | cut -f2 -d=)
SYN_FILE=$(cat fcrepo6/Dockerfile | grep -o 'SYN_FILE=.*' | cut -f2 -d=)
SYN_URL=$(cat fcrepo6/Dockerfile | grep -o 'SYN_URL=.*' | cut -f2 -d=)
SYN_FILE=$(eval "echo $SYN_FILE")
SYN_URL=$(eval "echo $SYN_URL")
wget --quiet "${SYN_URL}"
shasum -a 256 "${SYN_FILE}" | cut -f1 -d' '
rm "${SYN_FILE}"
```

You can change the version used for [fcrepo-import-export] by modifying the
build argument `IMPORT_EXPORT_VERSION` and `IMPORT_EXPORT_SHA256` in the
`Dockerfile`.

Change `IMPORT_EXPORT_VERSION` and then generate the `IMPORT_EXPORT_SHA256` with
the following commands:

```bash
IMPORT_EXPORT_VERSION=$(cat fcrepo6/Dockerfile | grep -o 'IMPORT_EXPORT_VERSION=.*' | cut -f2 -d=)
IMPORT_EXPORT_FILE=$(cat fcrepo6/Dockerfile | grep -o 'IMPORT_EXPORT_FILE=.*' | cut -f2 -d=)
IMPORT_EXPORT_URL=$(cat fcrepo6/Dockerfile | grep -o 'IMPORT_EXPORT_URL=.*' | cut -f2 -d=)
IMPORT_EXPORT_FILE=$(eval "echo $IMPORT_EXPORT_FILE")
IMPORT_EXPORT_URL=$(eval "echo $IMPORT_EXPORT_URL")
wget --quiet "${IMPORT_EXPORT_URL}"
shasum -a 256 "${IMPORT_EXPORT_FILE}" | cut -f1 -d' '
rm "${IMPORT_EXPORT_FILE}"
```

You can change the version used for [fcrepo-upgrade-utils] by modifying the
build argument `UPGRADE_UTILS_VERSION` and `UPGRADE_UTILS_SHA256` in the
`Dockerfile`.

Change `UPGRADE_UTILS_VERSION` and then generate the `UPGRADE_UTILS_SHA256` with
the following commands:

```bash
UPGRADE_UTILS_VERSION=$(cat fcrepo6/Dockerfile | grep -o 'UPGRADE_UTILS_VERSION=.*' | cut -f2 -d=)
UPGRADE_UTILS_FILE=$(cat fcrepo6/Dockerfile | grep -o 'UPGRADE_UTILS_FILE=.*' | cut -f2 -d=)
UPGRADE_UTILS_URL=$(cat fcrepo6/Dockerfile | grep -o 'UPGRADE_UTILS_URL=.*' | cut -f2 -d=)
UPGRADE_UTILS_FILE=$(eval "echo $UPGRADE_UTILS_FILE")
UPGRADE_UTILS_URL=$(eval "echo $UPGRADE_UTILS_URL")
wget --quiet "${UPGRADE_UTILS_URL}"
shasum -a 256 "${UPGRADE_UTILS_FILE}" | cut -f1 -d' '
rm "${UPGRADE_UTILS_FILE}"
```

[base image]: ../base/README.md
[external content]: https://wiki.lyrasis.org/display/FEDORA6x/External+Content
[Fcrepo Documentation]: https://wiki.lyrasis.org/display/FF
[fcrepo-import-export]: https://github.com/fcrepo-exts/fcrepo-import-export
[fcrepo-upgrade-utils]: https://github.com/fcrepo-exts/fcrepo-upgrade-utils
[fcrepo]: https://github.com/fcrepo/fcrepo
[s3]: https://aws.amazon.com/s3/
[syn]: https://github.com/Islandora-CLAW/Syn
[tomcat image]: ../tomcat/README.md
