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

| Path  | Description                                                                                             |
| :---- | :------------------------------------------------------------------------------------------------------ |
| /data | Fcrepo Object / Binary Store if `FCREPO_BINARYSTORAGE_TYPE` or `FCREPO_PERSISTENCE_TYPE` is set to file |

> N.B. Volumes are not created automatically. It is up to the user to either bind
> mount or attach a volume at the paths specified above.

## Settings

<<<<<<< HEAD
| Environment Variable           | Confd Key                       | Default                                        | Description                                                           |
| :----------------------------- | :------------------------------ | :--------------------------------------------- | :-------------------------------------------------------------------- |
| FCREPO_ACTIVEMQ_BROKER         | /fcrepo/activemq/broker         | tcp://activemq:61616                           |                                                                       |
| FCREPO_ACTIVEMQ_QUEUE          | /fcrepo/activemq/queue          | fedora                                         |                                                                       |
| FCREPO_ACTIVEMQ_TOPIC          | /fcrepo/activemq/topic          | fedora                                         |                                                                       |
| FCREPO_BINARYSTORAGE_TYPE      | /fcrepo/binarystorage/type      | file                                           |                                                                       |
| FCREPO_CATALINA_OPTS           | /fcrepo/catalina/opts           |                                                |                                                                       |
| FCREPO_DB_MYSQL_HOST           | /fcrepo/db/mysql/host           | mariadb                                        |                                                                       |
| FCREPO_DB_MYSQL_PORT           | /fcrepo/db/mysql/port           | 3306                                           |                                                                       |
| FCREPO_DB_NAME                 | /fcrepo/db/name                 | fcrepo                                         |                                                                       |
| FCREPO_DB_PASSWORD             | /fcrepo/db/password             | password                                       |                                                                       |
| FCREPO_DB_POSTGRESQL_HOST      | /fcrepo/db/postgresql/host      | mariadb                                        |                                                                       |
| FCREPO_DB_POSTGRESQL_PORT      | /fcrepo/db/postgresql/port      | 3306                                           |                                                                       |
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

| Environment Variable    | Confd Key                 |
=======
### Confd Settings

| Environment Variable           | Confd Key                       | Default                           | Description                                                                                       |
| :----------------------------- | :------------------------------ | :-------------------------------- | :------------------------------------------------------------------------------------------------ |
| FCREPO_ACTIVEMQ_BROKER         | /fcrepo/activemq/broker         | tcp://activemq:61616              | The location of the ActiveMQ Broker in which to publish JMS messages to                           |
| FCREPO_ACTIVEMQ_QUEUE          | /fcrepo/activemq/queue          | fedora                            | The ActiveMQ Queue in which to publish JMS messages                                               |
| FCREPO_ACTIVEMQ_QUEUE_ENABLE   | /fcrepo/activemq/queue          | false                             | If `true` publish JMS messages on the queue `FCREPO_ACTIVEMQ_QUEUE`                               |
| FCREPO_ACTIVEMQ_TOPIC          | /fcrepo/activemq/topic          | fedora                            | The ActiveMQ Topic in which to publish JMS messages                                               |
| FCREPO_ACTIVEMQ_TOPIC_ENABLE   | /fcrepo/activemq/topic          | true                              | If `true` publish JMS messages on the topic `FCREPO_ACTIVEMQ_TOPIC`                               |
| FCREPO_BINARYSTORAGE_TYPE      | /fcrepo/binarystorage/type      | file                              | The binary storage type. Only `file` and `s3` are supported at this time                          |
| FCREPO_MODESHAPE_CONFIGURATION | /fcrepo/modeshape/configuration | classpath:/config/repository.json | The repository configuration to use. The default is generated dynamically from the other settings |
| FCREPO_PERSISTENCE_TYPE        | /fcrepo/persistence/type        | file                              | The object store type. Only `file`, `mysql`, `postgresql` are supported at this time              |
| FCREPO_S3_BUCKET               | /fcrepo/s3/bucket               |                                   | The [s3] bucket to store content. Only used if `FCREPO_BINARYSTORAGE_TYPE` is `s3`                |
| FCREPO_S3_PASSWORD             | /fcrepo/s3/password             |                                   | The [s3] user. Only used if `FCREPO_BINARYSTORAGE_TYPE` is `s3`                                   |
| FCREPO_S3_USER                 | /fcrepo/s3/user                 |                                   | The [s3] user password. Only used if `FCREPO_BINARYSTORAGE_TYPE` is `s3`                          |

To allow [external content] provide sites as key pairs. Wherein multiple values
is the url and the 'name' is a key that replaces the '*' symbol below.

| Environment Variable    | Confd Key                |
>>>>>>> Added automated tests and documentation.
| :---------------------- | :----------------------- |
| FCREPO_ALLOW_EXTERNAL_* | /fcrepo/allow/external/* |

### JWT Settings

[Fcrepo] makes use of JWT for authentication. Please see the documentation in
the [base image] for more information.

### Database Settings

[Fcrepo] can optionally make use of a database for object storage. Please see
the documentation in the [base image] for more information about the default
database connection configuration.

The following settings are only used if `FCREPO_PERSISTENCE_TYPE` is set to
`mysql` or `postgresql`.

| Environment Variable | Confd Key           | Default  | Description                                              |
| :------------------- | :------------------ | :------- | :------------------------------------------------------- |
| FCREPO_DB_NAME       | /fcrepo/db/name     | fedora   | The name of the database                                 |
| FCREPO_DB_USER       | /fcrepo/db/user     | fedora   | The user to connect to the database                      |
| FCREPO_DB_PASSWORD   | /fcrepo/db/password | password | The password of the user used to connect to the database |

Additionally the `DB_DRIVER` variable is derived from the
`FCREPO_PERSISTENCE_TYPE` so users do not need to specify it separately.

### Tomcat Settings

Fcrepo is deployed in as a servlet in Tomcat. Please see the documentation in
the [tomcat image] for more information.

[base image]: ../base/README.md
[external content]: (https://wiki.lyrasis.org/display/FEDORA51/External+Content)
[Fcrepo Documentation]: https://wiki.lyrasis.org/display/FF
[Fcrepo]: https://github.com/fcrepo4/fcrepo4
[s3]: https://aws.amazon.com/s3/
[tomcat image]: ../tomcat/README.md
