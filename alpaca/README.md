# Alpaca

Docker image for [Alpaca] version 1.0.3.

Please refer to the [Alpaca Documentation] for more in-depth information.

As a quick example this will bring up an instance of Alpaca, and allow you to
log view the [WebConsole] on <http://localhost:8181/system/console/> as the user `admin` with
the password `password`.

```bash
docker run --rm -ti -p 8181:8181 \
    -e "KARAF_ADMIN_NAME=admin" \
    -e "KARAF_ADMIN_PASSWORD=password" \
    islandora/alpaca
```

## Dependencies

Requires `islandora/karaf` docker image to build. Please refer to the
[Karaf Image README](../karaf/README.md) for additional information including
additional settings, volumes, ports, etc.

## Settings

| Environment Variable                       | Etcd Key                                   | Default                                                   | Description                                                                                                                                                 |
| :----------------------------------------- | :----------------------------------------- | :-------------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ALPACA_ACTIVEMQ_PASSWORD                   | /alpaca/activemq/password                  | password                                                  | Password to authenticate with                                                                                                                               |
| ALPACA_ACTIVEMQ_URL                        | /alpaca/activemq/url                       | tcp://broker:61616                                        | The url for connecting to the ActiveMQ broker, shared by all components                                                                                     |
| ALPACA_ACTIVEMQ_USER                       | /alpaca/activemq/user                      | admin                                                     | User to authenticate as                                                                                                                                     |
| ALPACA_FCREPO_AUTH_HOST                    | /alpaca/fcrepo/auth/host                   |                                                           | User to authenticate as                                                                                                                                     |
| ALPACA_FCREPO_AUTH_PASSWORD                | /alpaca/fcrepo/auth/password               |                                                           | Password to authenticate with                                                                                                                               |
| ALPACA_FCREPO_AUTH_USER                    | /alpaca/fcrepo/auth/user                   |                                                           | URL to authenticate against                                                                                                                                 |
| ALPACA_FCREPO_URL                          | /alpaca/fcrepo/url                         | http://fcrepo/fcrepo/rest                            | The url of fcrepo rest API                                                                                                                                  |
| ALPACA_FITS_QUEUE                          | /alpaca/fits/queue                         | broker:queue:islandora-connector-fits                     | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_FITS_REDELIVERIES                   | /alpaca/fits/redeliveries                  | 10                                                        | Number of attempts to redeliver if an exception occurs                                                                                                      |
| ALPACA_FITS_SERVICE                        | /alpaca/fits/service                       | http://crayfits:8000                                      | Url of micro-service                                                                                                                                        |
| ALPACA_HOMARUS_QUEUE                       | /alpaca/homarus/queue                      | broker:queue:islandora-connector-homarus                  | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_HOMARUS_REDELIVERIES                | /alpaca/homarus/redeliveries               | 10                                                        | Number of attempts to redeliver if an exception occurs                                                                                                      |
| ALPACA_HOMARUS_SERVICE                     | /alpaca/homarus/service                    | http://homarus:8000/convert                               | Url of micro-service                                                                                                                                        |
| ALPACA_HOUDINI_QUEUE                       | /alpaca/houdini/queue                      | broker:queue:islandora-connector-houdini                  | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_HOUDINI_REDELIVERIES                | /alpaca/houdini/redeliveries               | 10                                                        | Number of attempts to redeliver if an exception occurs                                                                                                      |
| ALPACA_HOUDINI_SERVICE                     | /alpaca/houdini/service                    | http://houdini:8000/convert                               | Url of micro-service                                                                                                                                        |
| ALPACA_HTTP_TOKEN                          | /alpaca/http/token                         | islandora                                                 | The static token value to be used for authentication by the HttpClient available as an OSGi service for other services to use against the Fedora repository |
| ALPACA_INDEXING_GEMINI_URL                 | /alpaca/indexing/gemini/url                | http://gemini:8000                                        | Url of micro-service                                                                                                                                        |
| ALPACA_INDEXING_MILLINER_URL               | /alpaca/indexing/milliner/url              | http://milliner:8000                                      | Url of micro-service                                                                                                                                        |
| ALPACA_INDEXING_REDELIVERIES               | /alpaca/indexing/redeliveries              | 10                                                        | Number of attempts to redeliver if an exception occurs                                                                                                      |
| ALPACA_INDEXING_STREAM_FILE_DELETE         | /alpaca/indexing/stream/file/delete        | broker:queue:islandora-indexing-fcrepo-file-delete        | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_INDEXING_STREAM_FILE_INDEX          | /alpaca/indexing/stream/file/index         | broker:queue:islandora-indexing-fcrepo-file               | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_INDEXING_STREAM_INPUT               | /alpaca/indexing/stream/input              | broker:topic:fedora                                       | ActiveMQ Topic to consume                                                                                                                                   |
| ALPACA_INDEXING_STREAM_MEDIA_INDEX         | /alpaca/indexing/stream/media/index        | broker:queue:islandora-indexing-fcrepo-media              | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_INDEXING_STREAM_NODE_DELETE         | /alpaca/indexing/stream/node/delete        | broker:queue:islandora-indexing-fcrepo-delete             | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_INDEXING_STREAM_NODE_INDEX          | /alpaca/indexing/stream/node/index         | broker:queue:islandora-indexing-fcrepo-content            | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_INDEXING_STREAM_TRIPLESTORE_DELETE  | /alpaca/indexing/stream/triplestore/delete | broker:queue:islandora-indexing-triplestore-delete        | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_INDEXING_STREAM_TRIPLESTORE_INDEX   | /alpaca/indexing/stream/triplestore/index  | broker:queue:islandora-indexing-triplestore-index         | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_INDEXING_STREAM_TRIPLESTORE_REINDEX | /alpaca/indexing/stream/reindex            | broker:queue:triplestore.reindex                          | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_INDEXING_URL                        | /alpaca/indexing/url                       | http://blazegraph/bigdata/namespace/islandora/sparql | Url to triple store indexer                                                                                                                                 |
| ALPACA_LOGGER_CAMEL_LEVEL                  | /alpaca/logger/camel/level                 | WARN                                                      | Camel [Log Level]                                                                                                                                           |
| ALPACA_LOGGER_ISLANDORA_LEVEL              | /alpaca/logger/islandora/level             | WARN                                                      | Islandora [Log Level]                                                                                                                                       |
| ALPACA_LOGGER_ROOT_LEVEL                   | /alpaca/logger/root/level                  | WARN                                                      | Root [Log Level]                                                                                                                                            |
| ALPACA_OCR_QUEUE                           | /alpaca/ocr/queue                          | broker:queue:islandora-connector-ocr                      | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_OCR_REDELIVERIES                    | /alpaca/ocr/redeliveries                   | 10                                                        | Number of attempts to redeliver if an exception occurs                                                                                                      |
| ALPACA_OCR_SERVICE                         | /alpaca/ocr/service                        | http://hypercube:8000                                     | Url of micro-service                                                                                                                                        |

## Logs

| Path                              | Description      |
| :-------------------------------- | :--------------- |
| /opt/karaf/data/log/camel.log     | Camel Log        |
| /opt/karaf/data/log/islandora.log | Islandora Log    |

[Alpaca Documentation]: https://islandora.github.io/documentation/
[Alpaca]: https://github.com/Islandora/Alpaca
[JMX]: https://karaf.apache.org/manual/latest/#_monitoring_and_management_using_jmx
[Karaf Directory Structure]: https://karaf.apache.org/manual/latest/#_directory_structure
[Log Level]: https://logging.apache.org/log4j/2.x/manual/customloglevels.html
[RMI]: https://karaf.apache.org/manual/latest/monitoring
[SSH]: https://karaf.apache.org/manual/latest/remote
[WebConsole]: https://karaf.apache.org/manual/latest/webconsole
