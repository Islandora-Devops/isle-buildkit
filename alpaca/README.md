# Alpaca

Docker image for [Alpaca] version 2.2.0.

Please refer to the [Alpaca Documentation] for more in-depth information.

## Dependencies

Requires `islandora/java` docker image to build. Please refer to the
[Java Image README](../java/README.md) for additional information including
additional settings, volumes, ports, etc.

## Settings

| Environment Variable                      | Default                                                   | Description                                                             |
| :---------------------------------------- | :-------------------------------------------------------- | :---------------------------------------------------------------------- |
| ALPACA_CLIENT_ADDITIONAL_OPTIONS          |                                                           |                                                                         |
| ALPACA_CLIENT_CONFIGURER                  | true                                                      |                                                                         |
| ALPACA_CLIENT_CONNECTION_TIMEOUT          | -1                                                        |                                                                         |
| ALPACA_CLIENT_REQUEST_TIMEOUT             | -1                                                        |                                                                         |
| ALPACA_CLIENT_SOCKET_TIMEOUT              | -1                                                        |                                                                         |
| ALPACA_DERIVATIVE_FITS_ASYNC_CONSUMER     | true                                                      |                                                                         |
| ALPACA_DERIVATIVE_FITS_CONSUMERS          | -1                                                        |                                                                         |
| ALPACA_DERIVATIVE_FITS_ENABLED            | true                                                      |                                                                         |
| ALPACA_DERIVATIVE_FITS_MAX_CONSUMERS      | -1                                                        |                                                                         |
| ALPACA_DERIVATIVE_FITS_QUEUE              | queue:islandora-connector-fits                            | ActiveMQ Queue to consume from                                          |
| ALPACA_DERIVATIVE_FITS_URL                | http://crayfits:8000                                      | Url of micro-service                                                    |
| ALPACA_DERIVATIVE_HOMARUS_ASYNC_CONSUMER  | true                                                      |                                                                         |
| ALPACA_DERIVATIVE_HOMARUS_CONSUMERS       | -1                                                        |                                                                         |
| ALPACA_DERIVATIVE_HOMARUS_ENABLED         | true                                                      |                                                                         |
| ALPACA_DERIVATIVE_HOMARUS_MAX_CONSUMERS   | -1                                                        |                                                                         |
| ALPACA_DERIVATIVE_HOMARUS_QUEUE           | queue:islandora-connector-homarus                         | ActiveMQ Queue to consume from                                          |
| ALPACA_DERIVATIVE_HOMARUS_URL             | http://homarus:8000/convert                               | Url of micro-service                                                    |
| ALPACA_DERIVATIVE_HOUDINI_ASYNC_CONSUMER  | true                                                      |                                                                         |
| ALPACA_DERIVATIVE_HOUDINI_CONSUMERS       | -1                                                        |                                                                         |
| ALPACA_DERIVATIVE_HOUDINI_ENABLED         | true                                                      |                                                                         |
| ALPACA_DERIVATIVE_HOUDINI_MAX_CONSUMERS   | -1                                                        |                                                                         |
| ALPACA_DERIVATIVE_HOUDINI_QUEUE           | queue:islandora-connector-houdini                         | ActiveMQ Queue to consume from                                          |
| ALPACA_DERIVATIVE_HOUDINI_URL             | http://houdini:8000/convert                               | Url of micro-service                                                    |
| ALPACA_DERIVATIVE_OCR_ASYNC_CONSUMER      | true                                                      |                                                                         |
| ALPACA_DERIVATIVE_OCR_CONSUMERS           | -1                                                        |                                                                         |
| ALPACA_DERIVATIVE_OCR_ENABLED             | true                                                      |                                                                         |
| ALPACA_DERIVATIVE_OCR_MAX_CONSUMERS       | -1                                                        |                                                                         |
| ALPACA_DERIVATIVE_OCR_QUEUE               | queue:islandora-connector-ocr                             | ActiveMQ Queue to consume from                                          |
| ALPACA_DERIVATIVE_OCR_URL                 | http://hypercube:8000                                     | Url of micro-service                                                    |
| ALPACA_DERIVATIVE_SYSTEMS                 | fits,homarus,houdini,ocr                                  |                                                                         |
| ALPACA_FCREPO_INDEXER_ASYNC_CONSUMER      | true                                                      |                                                                         |
| ALPACA_FCREPO_INDEXER_CONSUMERS           | -1                                                        |                                                                         |
| ALPACA_FCREPO_INDEXER_ENABLED             | true                                                      |                                                                         |
| ALPACA_FCREPO_INDEXER_MAX_CONSUMERS       | -1                                                        |                                                                         |
| ALPACA_FCREPO_INDEXER_MILLINER_URL        | http://milliner:8000                                      | Url of micro-service                                                    |
| ALPACA_FCREPO_INDEXER_QUEUE_DELETE        | queue:islandora-indexing-fcrepo-delete                    | ActiveMQ Queue to consume from                                          |
| ALPACA_FCREPO_INDEXER_QUEUE_EXTERNAL      | queue:islandora-indexing-fcrepo-file-external             | ActiveMQ Queue to consume from                                          |
| ALPACA_FCREPO_INDEXER_QUEUE_MEDIA         | queue:islandora-indexing-fcrepo-media                     | ActiveMQ Queue to consume from                                          |
| ALPACA_FCREPO_INDEXER_QUEUE_NODE          | queue:islandora-indexing-fcrepo-content                   | ActiveMQ Queue to consume from                                          |
| ALPACA_JAVA_OPTS                          |                                                           |                                                                         |
| ALPACA_JMS_CONNECTIONS                    | 10                                                        |                                                                         |
| ALPACA_JMS_CONSUMERS                      | 1                                                         |                                                                         |
| ALPACA_JMS_PASSWORD                       | password                                                  | Password to authenticate with                                           |
| ALPACA_JMS_URL                            | tcp://activemq:61616                                      | The url for connecting to the ActiveMQ broker, shared by all components |
| ALPACA_JMS_USER                           | admin                                                     | User to authenticate as                                                 |
| ALPACA_MAX_REDELIVERIES                   | 5                                                         | Number of attempts to redeliver if an exception occurs                  |
| ALPACA_TRIPLESTORE_INDEXER_ASYNC_CONSUMER | true                                                      |                                                                         |
| ALPACA_TRIPLESTORE_INDEXER_CONSUMERS      | -1                                                        |                                                                         |
| ALPACA_TRIPLESTORE_INDEXER_ENABLED        | true                                                      |                                                                         |
| ALPACA_TRIPLESTORE_INDEXER_MAX_CONSUMERS  | -1                                                        |                                                                         |
| ALPACA_TRIPLESTORE_INDEXER_QUEUE_DELETE   | queue:islandora-indexing-triplestore-delete               | ActiveMQ Queue to consume from                                          |
| ALPACA_TRIPLESTORE_INDEXER_QUEUE_INDEX    | queue:islandora-indexing-triplestore-index                | ActiveMQ Queue to consume from                                          |
| ALPACA_TRIPLESTORE_INDEXER_URL            | http://blazegraph:8080/bigdata/namespace/islandora/sparql | Url of micro-service                                                    |

[Alpaca Documentation]: https://islandora.github.io/documentation/
[Alpaca]: https://github.com/Islandora/Alpaca
