# Solr

Docker image for [solr] version 9.7.0.

Please refer to the [Solr Documentation] for more in-depth information.

As a quick example this will bring up an instance of [solr], and allow you
to view on <http://localhost:8983/solr/>.

```bash
docker run --rm -ti -p 8983:8983 islandora/solr
```

## Dependencies

Requires `islandora/java` docker image to build. Please refer to the
[Java Image README](../java/README.md) for additional information including
additional settings, volumes, ports, etc.

## Settings

| Environment Variable | Default                     | Description                                                                    |
| :------------------- | :-------------------------- | :----------------------------------------------------------------------------- |
| SOLR_JAVA_OPTS       |                             | Additional parameters to pass to the JVM when starting Solr                    |
| SOLR_JETTY_OPTS      | `-Dsolr.jetty.host=0.0.0.0` | Additional parameters to pass to Jetty when starting Solr.                     |
| SOLR_LOG_LEVEL       | `INFO`                      | Log level. Possible Values: OFF, FATAL, ERROR, WARN, INFO, DEBUG, TRACE or ALL |
| SOLR_MEMORY          | `512m`                      | Sets the min (-Xms) and max (-Xmx) heap size for the JVM                       |

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

## Updating

You can change the version used for [solr] by modifying the build argument
`SOLR_VERSION` and `SOLR_FILE_SHA256` in the `Dockerfile`.

Change `SOLR_VERSION` and then generate the `SOLR_FILE_SHA256` with the following
commands:

```bash
SOLR_VERSION=$(cat solr/Dockerfile | grep -o 'SOLR_VERSION=.*' | cut -f2 -d=)
SOLR_FILE=$(cat solr/Dockerfile | grep -o 'SOLR_FILE=.*' | cut -f2 -d=)
SOLR_URL=$(cat solr/Dockerfile | grep -o 'SOLR_URL=.*' | cut -f2 -d=)
SOLR_FILE=$(eval "echo $SOLR_FILE")
SOLR_URL=$(eval "echo $SOLR_URL")
wget --quiet "${SOLR_URL}"
shasum -a 256 "${SOLR_FILE}" | cut -f1 -d' '
rm "${SOLR_FILE}"
```

[Solr Documentation]: https://lucene.apache.org/solr/guide/7_1/
[Solr Logging]: https://lucene.apache.org/solr/guide/7_1/configuring-logging.html
[solr]: https://lucene.apache.org/solr/
