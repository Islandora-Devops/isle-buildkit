# Solr

Docker image for [Solr] version 7.1.0.

Please refer to the [Solr Documentation] for more in-depth information.

As a quick example this will bring up an instance of [Solr], and allow you
to view on <http://localhost:8983/solr/>.

```bash
docker run --rm -ti -p 8983:8983 islandora/solr
```

## Dependencies

Requires `islandora/java` docker image to build. Please refer to the
[Java Image README](../java/README.md) for additional information including
additional settings, volumes, ports, etc.

## Settings

| Environment Variable | Confd Key       | Default | Description                                                                    |
| :------------------- | :-------------- | :------ | :----------------------------------------------------------------------------- |
| SOLR_LOG_LEVEL       | /solr/log/level | INFO    | Log level. Possible Values: OFF, FATAL, ERROR, WARN, INFO, DEBUG, TRACE or ALL |

## Ports

| Port | Description |
| :--- | :---------- |
| 8983 | HTTP        |

## Volumes

| Path                  | Description                                      |
| :-------------------- | :----------------------------------------------- |
| /opt/solr/server/solr | Location of configuration and data for all cores |

## Logs

- [Solr Logging]

[Solr Documentation]: https://lucene.apache.org/solr/guide/7_1/
[Solr Logging]: https://lucene.apache.org/solr/guide/7_1/configuring-logging.html
[Solr]: https://lucene.apache.org/solr/
