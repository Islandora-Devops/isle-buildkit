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

| Environment Variable                       | Etcd Key                                   | Default                                              | Description                                                                                                                                                 |
| :----------------------------------------- | :----------------------------------------- | :--------------------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ALPACA_ACTIVEMQ_PASSWORD                   | /alpaca/activemq/password                  | password                                             | Password to authenticate with                                                                                                                               |
| ALPACA_ACTIVEMQ_URL                        | /alpaca/activemq/url                       | tcp://broker:61616                                   | The url for connecting to the ActiveMQ broker, shared by all components                                                                                     |
| ALPACA_ACTIVEMQ_USER                       | /alpaca/activemq/user                      | admin                                                | User to authenticate as                                                                                                                                     |
| ALPACA_ACTIVEMQ_JMS_MAXCONNECTIONS         | -                                          | -                                                    | Maximum number of connections between a Camel Context and the ActiveMQ broker                                                                               |
| ALPACA_ACTIVEMQ_JMS_CONSUMERS              | -                                          | -                                                    | Number of consumers reading from a given ActiveMQ Destination (i.e. Topic or Queue)                                                                         |
| ALPACA_ACTIVEMQ_JMS_ACKNOWLEDGEMENT_MODE   | -                                          | -                                                    | JMS Acknowledgement Mode (one of `AUTO_ACKNOWLEDGE`, `CLIENT_ACKNOWLEDGE`, `SESSION_TRANSACTED`, `DUPS_OK_ACKNOWLEDGE`)                                     |
| ALPACA_FCREPO_AUTH_HOST                    | /alpaca/fcrepo/auth/host                   |                                                      | User to authenticate as                                                                                                                                     |
| ALPACA_FCREPO_AUTH_PASSWORD                | /alpaca/fcrepo/auth/password               |                                                      | Password to authenticate with                                                                                                                               |
| ALPACA_FCREPO_AUTH_USER                    | /alpaca/fcrepo/auth/user                   |                                                      | URL to authenticate against                                                                                                                                 |
| ALPACA_FCREPO_URL                          | /alpaca/fcrepo/url                         | http://fcrepo/fcrepo/rest                            | The url of fcrepo rest API                                                                                                                                  |
| ALPACA_FITS_QUEUE                          | /alpaca/fits/queue                         | broker:queue:islandora-connector-fits                | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_FITS_REDELIVERIES                   | /alpaca/fits/redeliveries                  | 10                                                   | Number of attempts to redeliver if an exception occurs                                                                                                      |
| ALPACA_FITS_SERVICE                        | /alpaca/fits/service                       | http://crayfits:8000                                 | Url of micro-service                                                                                                                                        |
| ALPACA_HOMARUS_QUEUE                       | /alpaca/homarus/queue                      | broker:queue:islandora-connector-homarus             | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_HOMARUS_REDELIVERIES                | /alpaca/homarus/redeliveries               | 10                                                   | Number of attempts to redeliver if an exception occurs                                                                                                      |
| ALPACA_HOMARUS_SERVICE                     | /alpaca/homarus/service                    | http://homarus:8000/convert                          | Url of micro-service                                                                                                                                        |
| ALPACA_HOUDINI_QUEUE                       | /alpaca/houdini/queue                      | broker:queue:islandora-connector-houdini             | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_HOUDINI_REDELIVERIES                | /alpaca/houdini/redeliveries               | 10                                                   | Number of attempts to redeliver if an exception occurs                                                                                                      |
| ALPACA_HOUDINI_SERVICE                     | /alpaca/houdini/service                    | http://houdini:8000/convert                          | Url of micro-service                                                                                                                                        |
| ALPACA_HTTP_TOKEN                          | /alpaca/http/token                         | islandora                                            | The static token value to be used for authentication by the HttpClient available as an OSGi service for other services to use against the Fedora repository |
| ALPACA_INDEXING_GEMINI_URL                 | /alpaca/indexing/gemini/url                | http://gemini:8000                                   | Url of micro-service                                                                                                                                        |
| ALPACA_INDEXING_MILLINER_URL               | /alpaca/indexing/milliner/url              | http://milliner:8000                                 | Url of micro-service                                                                                                                                        |
| ALPACA_INDEXING_REDELIVERIES               | /alpaca/indexing/redeliveries              | 10                                                   | Number of attempts to redeliver if an exception occurs                                                                                                      |
| ALPACA_INDEXING_STREAM_FILE_DELETE         | /alpaca/indexing/stream/file/delete        | broker:queue:islandora-indexing-fcrepo-file-delete   | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_INDEXING_STREAM_FILE_INDEX          | /alpaca/indexing/stream/file/index         | broker:queue:islandora-indexing-fcrepo-file          | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_INDEXING_STREAM_INPUT               | /alpaca/indexing/stream/input              | broker:topic:fedora                                  | ActiveMQ Topic to consume                                                                                                                                   |
| ALPACA_INDEXING_STREAM_MEDIA_INDEX         | /alpaca/indexing/stream/media/index        | broker:queue:islandora-indexing-fcrepo-media         | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_INDEXING_STREAM_NODE_DELETE         | /alpaca/indexing/stream/node/delete        | broker:queue:islandora-indexing-fcrepo-delete        | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_INDEXING_STREAM_NODE_INDEX          | /alpaca/indexing/stream/node/index         | broker:queue:islandora-indexing-fcrepo-content       | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_INDEXING_STREAM_TRIPLESTORE_DELETE  | /alpaca/indexing/stream/triplestore/delete | broker:queue:islandora-indexing-triplestore-delete   | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_INDEXING_STREAM_TRIPLESTORE_INDEX   | /alpaca/indexing/stream/triplestore/index  | broker:queue:islandora-indexing-triplestore-index    | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_INDEXING_STREAM_TRIPLESTORE_REINDEX | /alpaca/indexing/stream/reindex            | broker:queue:triplestore.reindex                     | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_INDEXING_URL                        | /alpaca/indexing/url                       | http://blazegraph/bigdata/namespace/islandora/sparql | Url to triple store indexer                                                                                                                                 |
| ALPACA_LOGGER_CAMEL_LEVEL                  | /alpaca/logger/camel/level                 | WARN                                                 | Camel [Log Level]                                                                                                                                           |
| ALPACA_LOGGER_ISLANDORA_LEVEL              | /alpaca/logger/islandora/level             | WARN                                                 | Islandora [Log Level]                                                                                                                                       |
| ALPACA_LOGGER_ROOT_LEVEL                   | /alpaca/logger/root/level                  | WARN                                                 | Root [Log Level]                                                                                                                                            |
| ALPACA_OCR_QUEUE                           | /alpaca/ocr/queue                          | broker:queue:islandora-connector-ocr                 | ActiveMQ Queue to consume from                                                                                                                              |
| ALPACA_OCR_REDELIVERIES                    | /alpaca/ocr/redeliveries                   | 10                                                   | Number of attempts to redeliver if an exception occurs                                                                                                      |
| ALPACA_OCR_SERVICE                         | /alpaca/ocr/service                        | http://hypercube:8000                                | Url of micro-service                                                                                                                                        |
## Timeout Settings

| Environment Variable                              | Etcd key | Default Value | Description |
|:---                                               |:---      |:---           |:---
| ALPACA_FITS_HTTP_CONNECTION_REQUEST_TIMEOUT_MS    | - | 10000  | Timeout for retrieving a connection from the connection pool |
| ALPACA_FITS_HTTP_CONNECT_TIMEOUT_MS               | - | 10000  | Timeout making an HTTP connection                            |
| ALPACA_FITS_HTTP_SOCKET_TIMEOUT_MS                | - | 600000 | Timeout reading data from a socket                           |
| ALPACA_HOMERUS_HTTP_CONNECTION_REQUEST_TIMEOUT_MS | - | 10000  | Timeout for retrieving a connection from the connection pool |
| ALPACA_HOMERUS_HTTP_CONNECT_TIMEOUT_MS            | - | 10000  | Timeout making an HTTP connection                            |
| ALPACA_HOMERUS_HTTP_SOCKET_TIMEOUT_MS             | - | 600000 | Timeout reading data from a socket                           |
| ALPACA_HOUDINI_HTTP_CONNECTION_REQUEST_TIMEOUT_MS | - | 10000  | Timeout for retrieving a connection from the connection pool |
| ALPACA_HOUDINI_HTTP_CONNECT_TIMEOUT_MS            | - | 10000  | Timeout making an HTTP connection                            |
| ALPACA_HOUDINI_HTTP_SOCKET_TIMEOUT_MS             | - | 600000 | Timeout reading data from a socket                           |
| ALPACA_OCR_HTTP_CONNECTION_REQUEST_TIMEOUT_MS     | - | 10000  | Timeout for retrieving a connection from the connection pool |
| ALPACA_OCR_HTTP_CONNECT_TIMEOUT_MS                | - | 10000  | Timeout making an HTTP connection                            |
| ALPACA_OCR_HTTP_SOCKET_TIMEOUT_MS                 | - | 600000 | Timeout reading data from a socket                           |

## JMS Tuning Variables

| Environment Variable                              | Etcd key                                   | Default Value                                                                        | Description |
|:---                                               |:---                                        |:---                                                                                  |:---
| ALPACA_FITS_REDELIVERYDELAY                       | /fits/redeliverydelay                      | 10000                                                                                | Number of milliseconds before attempting to redeliver a JMS message to the microservice HTTP endpoint, due to, e.g. a timeout; used by the FITS microservice |
| ALPACA_FITS_REDELIVERYBACKOFF                     | /fits/redeliverybackoff                    | 1.0                                                                                  | Backoff factor applied to the redelivery delay; used by the FITS microservice |
| ALPACA_FITS_ACTIVEMQ_URL                          | /fits/activemq/url                         | value of `ALPACA_ACTIVEMQ_URL` or `tcp://activemq:61616` if unset                   | ActiveMQ broker URL used by the FITS microservice |
| ALPACA_FITS_ACTIVEMQ_USER                         | /fits/activemq/user                        | value of `ALPACA_ACTIVEMQ_USER` or `` (the empty string) if unset                    | ActiveMQ broker username used by the FITS microservice |
| ALPACA_FITS_ACTIVEMQ_PASSWORD                     | /fits/activemq/password                    | value of `ALPACA_ACTIVEMQ_PASSWORD` or `` (the empty string) if unset                | ActiveMQ broker password used by the FITS microservice |
| ALPACA_FITS_ACTIVEMQ_JMS_MAXCONNECTIONS           | /fits/activemq/jms/maxconnections          | value of `ALPACA_ACTIVEMQ_JMS_MAXCONNECTIONS` or `10` if unset                       | Maximum number of connections between the FITS microservice and the broker |
| ALPACA_FITS_ACTIVEMQ_JMS_CONSUMERS                | /fits/activemq/jms/consumers               | value of `ALPACA_ACTIVEMQ_JMS_CONSUMERS` or `1` if unset                             | Number of consumers reading from `ALPACA_FITS_QUEUE` by the FITS microservice |
| ALPACA_FITS_ACTIVEMQ_JMS_ACKNOWLEDGEMENTMODE      | /fits/activemq/jms/acknowledgement/mode    | value of `ALPACA_ACTIVEMQ_JMS_ACKNOWLEDGEMENT_MODE` or `CLIENT_ACKNOWLEDGE` if unset | JMS acknowledgement mode used by the FITS microservice
| ALPACA_HOMARUS_REDELIVERYDELAY                    | /homarus/redeliverydelay | 10000           | Number of milliseconds before attempting to redeliver a JMS message to the microservice HTTP endpoint, due to, e.g. a timeout |
| ALPACA_HOMARUS_REDELIVERYBACKOFF                  | /homarus/redeliverybackoff | 1.0           | Backoff factor applied to the redelivery delay |
| ALPACA_HOMARUS_ACTIVEMQ_URL                       | /homarus/activemq/url                      | value of `ALPACA_ACTIVEMQ_URL` or `tcp://activemq:61616` if unset                   | ActiveMQ broker URL used by the Homarus microservice |
| ALPACA_HOMARUS_ACTIVEMQ_USER                      | /homarus/activemq/user                     | value of `ALPACA_ACTIVEMQ_USER` or `` (the empty string) if unset                    | ActiveMQ broker username used by the Homarus microservice |
| ALPACA_HOMARUS_ACTIVEMQ_PASSWORD                  | /homarus/activemq/password                 | value of `ALPACA_ACTIVEMQ_PASSWORD` or `` (the empty string) if unset                | ActiveMQ broker password used by the Homarus microservice |
| ALPACA_HOMARUS_ACTIVEMQ_JMS_MAXCONNECTIONS        | /homarus/activemq/jms/maxconnections       | value of `ALPACA_ACTIVEMQ_JMS_MAXCONNECTIONS` or `10` if unset                       | Maximum number of connections between the Homarus microservice and the broker |
| ALPACA_HOMARUS_ACTIVEMQ_JMS_CONSUMERS             | /homarus/activemq/jms/consumers            | value of `ALPACA_ACTIVEMQ_JMS_CONSUMERS` or `1` if unset                             | Number of consumers reading from `ALPACA_HOMARUS_QUEUE` by the Homarus microservice |
| ALPACA_HOMARUS_ACTIVEMQ_JMS_ACKNOWLEDGEMENTMODE   | /homarus/activemq/jms/acknowledgement/mode | value of `ALPACA_ACTIVEMQ_JMS_ACKNOWLEDGEMENT_MODE` or `CLIENT_ACKNOWLEDGE` if unset | JMS acknowledgement mode used by the Homarus microservice
| ALPACA_HOUDINI_REDELIVERYDELAY                    | /houdini/redeliverydelay                   | 10000  | Number of milliseconds before attempting to redeliver a JMS message to the microservice HTTP endpoint, due to, e.g. a timeout |
| ALPACA_HOUDINI_REDELIVERYBACKOFF                  | /houdini/redeliverybackoff                 | 1.0    | Backoff factor applied to the redelivery delay |
| ALPACA_HOUDINI_ACTIVEMQ_URL                       | /houdini/activemq/url                      | value of `ALPACA_ACTIVEMQ_URL` or `tcp://activemq:61616` if unset                   | ActiveMQ broker URL used by the houdini microservice |
| ALPACA_HOUDINI_ACTIVEMQ_USER                      | /houdini/activemq/user                     | value of `ALPACA_ACTIVEMQ_USER` or `` (the empty string) if unset                    | ActiveMQ broker username used by the houdini microservice |
| ALPACA_HOUDINI_ACTIVEMQ_PASSWORD                  | /houdini/activemq/password                 | value of `ALPACA_ACTIVEMQ_PASSWORD` or `` (the empty string) if unset                | ActiveMQ broker password used by the houdini microservice |
| ALPACA_HOUDINI_ACTIVEMQ_JMS_MAXCONNECTIONS        | /houdini/activemq/jms/maxconnections       | value of `ALPACA_ACTIVEMQ_JMS_MAXCONNECTIONS` or `10` if unset                       | Maximum number of connections between the houdini microservice and the broker |
| ALPACA_HOUDINI_ACTIVEMQ_JMS_CONSUMERS             | /houdini/activemq/jms/consumers            | value of `ALPACA_ACTIVEMQ_JMS_CONSUMERS` or `1` if unset                             | Number of consumers reading from `ALPACA_HOUDINI_QUEUE` by the houdini microservice |
| ALPACA_HOUDINI_ACTIVEMQ_JMS_ACKNOWLEDGEMENTMODE   | /houdini/activemq/jms/acknowledgement/mode | value of `ALPACA_ACTIVEMQ_JMS_ACKNOWLEDGEMENT_MODE` or `CLIENT_ACKNOWLEDGE` if unset | JMS acknowledgement mode used by the houdini microservice
| ALPACA_OCR_HTTP_REDELIVERYDELAY                   | /ocr/redeliverydelay                       | 10000  | Number of milliseconds before attempting to redeliver a JMS message to the microservice HTTP endpoint, due to, e.g. a timeout |
| ALPACA_OCR_HTTP_REDELIVERYBACKOFF                 | /ocr/redeliverybackoff                     | 1.0    | Backoff factor applied to the redelivery delay |
| ALPACA_OCR_ACTIVEMQ_URL                           | /ocr/activemq/url                          | value of `ALPACA_ACTIVEMQ_URL` or `tcp://activemq:61616` if unset                   | ActiveMQ broker URL used by the OCR microservice |
| ALPACA_OCR_ACTIVEMQ_USER                          | /ocr/activemq/user                         | value of `ALPACA_ACTIVEMQ_USER` or `` (the empty string) if unset                    | ActiveMQ broker username used by the OCR microservice |
| ALPACA_OCR_ACTIVEMQ_PASSWORD                      | /ocr/activemq/password                     | value of `ALPACA_ACTIVEMQ_PASSWORD` or `` (the empty string) if unset                | ActiveMQ broker password used by the OCR microservice |
| ALPACA_OCR_ACTIVEMQ_JMS_MAXCONNECTIONS            | /ocr/activemq/jms/maxconnections           | value of `ALPACA_ACTIVEMQ_JMS_MAXCONNECTIONS` or `10` if unset                       | Maximum number of connections between the OCR microservice and the broker |
| ALPACA_OCR_ACTIVEMQ_JMS_CONSUMERS                 | /ocr/activemq/jms/consumers                | value of `ALPACA_ACTIVEMQ_JMS_CONSUMERS` or `1` if unset                             | Number of consumers reading from `ALPACA_OCR_QUEUE` by the OCR microservice |
| ALPACA_OCR_ACTIVEMQ_JMS_ACKNOWLEDGEMENTMODE       | /ocr/activemq/jms/acknowledgement/mode     | value of `ALPACA_ACTIVEMQ_JMS_ACKNOWLEDGEMENT_MODE` or `CLIENT_ACKNOWLEDGE` if unset | JMS acknowledgement mode used by the OCR microservice |

## Logs

| Path                              | Description   |
| :-------------------------------- | :------------ |
| /opt/karaf/data/log/camel.log     | Camel Log     |
| /opt/karaf/data/log/islandora.log | Islandora Log |

[Alpaca Documentation]: https://islandora.github.io/documentation/
[Alpaca]: https://github.com/Islandora/Alpaca
[JMX]: https://karaf.apache.org/manual/latest/#_monitoring_and_management_using_jmx
[Karaf Directory Structure]: https://karaf.apache.org/manual/latest/#_directory_structure
[Log Level]: https://logging.apache.org/log4j/2.x/manual/customloglevels.html
[RMI]: https://karaf.apache.org/manual/latest/monitoring
[SSH]: https://karaf.apache.org/manual/latest/remote
[WebConsole]: https://karaf.apache.org/manual/latest/webconsole
