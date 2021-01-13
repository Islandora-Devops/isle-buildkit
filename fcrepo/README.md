# Fcrepo

Docker image for [Fcrepo] version 5.1.0.

Please refer to the [Fcrepo Documentation] for more in-depth information.

As a quick example this will bring up an instance of [Fcrepo], and allow you
to view on <http://localhost:80/fcrepo/>.

```bash
docker run --rm -ti -p 80:80 islandora/fcrepo
```

## Dependencies

Requires `islandora/tomcat` docker image to build. Please refer to the
[Tomcat Image README](../tomcat/README.md) for additional information including
additional settings, volumes, ports, etc.

## Volumes

| Path  | Description                                                                                         |
| :---- | :-------------------------------------------------------------------------------------------------- |
| /data | Fcrepo Object / Binary Store if FCREPO_BINARYSTORAGE_TYPE or FCREPO_PERSISTENCE_TYPE is set to file |

## Settings

| Environment Variable           | Etcd Key                        | Default                                        | Description                                                           |
| :----------------------------- | :------------------------------ | :--------------------------------------------- | :-------------------------------------------------------------------- |
| FCREPO_ACTIVEMQ_BROKER         | /fcrepo/activemq/broker         | tcp://activemq:61616                           |                                                                       |
| FCREPO_ACTIVEMQ_QUEUE          | /fcrepo/activemq/queue          | fedora                                         |                                                                       |
| FCREPO_ACTIVEMQ_TOPIC          | /fcrepo/activemq/topic          | fedora                                         |                                                                       |
| FCREPO_BINARYSTORAGE_TYPE      | /fcrepo/binarystorage/type      | file                                           |                                                                       |
| FCREPO_CATALINA_OPTS           | /fcrepo/catalina/opts           |                                                |                                                                       |
| FCREPO_DB_HOST                 | /fcrepo/db/host                 | mariadb                                        |                                                                       |
| FCREPO_DB_NAME                 | /fcrepo/db/name                 | fcrepo                                         |                                                                       |
| FCREPO_DB_PASSWORD             | /fcrepo/db/password             | password                                       |                                                                       |
| FCREPO_DB_PORT                 | /fcrepo/db/port                 | 3306                                           |                                                                       |
| FCREPO_DB_ROOT_PASSWORD        | /fcrepo/db/root/password        | password                                       |                                                                       |
| FCREPO_DB_ROOT_USER            | /fcrepo/db/root/user            | root                                           |                                                                       |
| FCREPO_DB_USER                 | /fcrepo/db/user                 | fcrepo                                         |                                                                       |
| FCREPO_JAVA_OPTS               | /fcrepo/java/opts               |                                                |                                                                       |
| FCREPO_JWT_ADMIN_TOKEN         | /fcrepo/jwt/admin/token         | islandora                                      |                                                                       |
| FCREPO_JWT_PUBLIC_KEY          | /fcrepo/jwt/public/key          | See rootfs/etc/confd/templates/public.key.tmpl | The public key must match the public key used in the Drupal container |
| FCREPO_MODESHAPE_CONFIGURATION | /fcrepo/modeshape/configuration | classpath:/config/repository.json              |                                                                       |
| FCREPO_PERSISTENCE_TYPE        | /fcrepo/persistence/type        | file                                           |                                                                       |
| FCREPO_QUEUE                   | /fcrepo/queue                   | fedora                                         |                                                                       |
| FCREPO_S3_BUCKET               | /fcrepo/s3/bucket               |                                                |                                                                       |
| FCREPO_S3_PASSWORD             | /fcrepo/s3/password             |                                                |                                                                       |
| FCREPO_S3_USER                 | /fcrepo/s3/user                 |                                                |                                                                       |
| FCREPO_TOPIC                   | /fcrepo/topic                   | fedora                                         |                                                                       |

To allow
[external content](https://wiki.lyrasis.org/display/FEDORA51/External+Content)
provide sites as key pairs. Wherein multiple values is the url and the 'name' is
a key that replaces the '*' symbol below.

| Environment Variable    | Etcd Key                 |
| :---------------------- | :----------------------- |
| FCREPO_ALLOW_EXTERNAL_* | /fcrepo/allow/external/* |

[Fcrepo Documentation]: https://wiki.lyrasis.org/display/FF
[Fcrepo]: https://github.com/fcrepo4/fcrepo4
