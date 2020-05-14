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

| Path  | Description                  |
| :---- | :--------------------------- |
| /data | Fcrepo Object / Binary Store |

## Settings

| Environment Variable           | Etcd Key                        | Default                           | Description |
| :----------------------------- | :------------------------------ | :-------------------------------- | :---------- |
| FCREPO_ACTIVEMQ_QUEUE          | /fcrepo/activemq/queue          | fedora                            |             |
| FCREPO_ACTIVEMQ_TOPIC          | /fcrepo/activemq/topic          | fedora                            |             |
| FCREPO_BINARYSTORAGE_TYPE      | /fcrepo/binarystorage/type      | file                              |             |
| FCREPO_BROKER                  | /fcrepo/broker                  | tcp://activemq:61616              |             |
| FCREPO_CATALINA_OPTS           | /fcrepo/catalina/opts           |                                   |             |
| FCREPO_DB_NAME                 | /fcrepo/db/name                 | fcrepo                            |             |
| FCREPO_DB_PASSWORD             | /fcrepo/db/password             | password                          |             |
| FCREPO_DB_USER                 | /fcrepo/db/user                 | admin                             |             |
| FCREPO_JAVA_OPTS               | /fcrepo/java/opts               |                                   |             |
| FCREPO_JWT_ADMIN_TOKEN         | /fcrepo/jwt/admin/token         | islandora                         |             |
| FCREPO_MODESHAPE_CONFIGURATION | /fcrepo/modeshape/configuration | classpath:/config/repository.json |             |
| FCREPO_PERSISTENCE_TYPE        | /fcrepo/persistence/type        | file                              |             |
| FCREPO_QUEUE                   | /fcrepo/queue                   | fedora                            |             |
| FCREPO_S3_BUCKET               | /fcrepo/s3/bucket               |                                   |             |
| FCREPO_S3_PASSWORD             | /fcrepo/s3/password             |                                   |             |
| FCREPO_S3_USER                 | /fcrepo/s3/user                 |                                   |             |
| FCREPO_TOPIC                   | /fcrepo/topic                   | fedora                            |             |

## Logs

| Path                                        | Description   |
| :------------------------------------------ | :------------ |
| /opt/tomcat/logs/cantaloupe.access.log      | [Fcrepo Logs] |
| /opt/tomcat/logs/cantaloupe.application.log | [Fcrepo Logs] |

[Fcrepo Documentation]: https://wiki.lyrasis.org/display/FF
[Fcrepo]: https://github.com/fcrepo4/fcrepo4
