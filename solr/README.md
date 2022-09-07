# Solr

Docker image for [Solr] version 8.11.2.

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

| Environment Variable | Confd Key        | Default | Description                                                                    |
| :------------------- | :--------------- | :------ | :----------------------------------------------------------------------------- |
| SOLR_JAVA_OPTS       | /solr/java/opts  |         | Additional parameters to pass to the JVM when starting Solr                    |
| SOLR_JETTY_OPTS      | /solr/jetty/opts |         | Additional parameters to pass to Jetty when starting Solr.                     |
| SOLR_LOG_LEVEL       | /solr/log/level  | INFO    | Log level. Possible Values: OFF, FATAL, ERROR, WARN, INFO, DEBUG, TRACE or ALL |
| SOLR_MEMORY          | /solr/memory     | 512m    | Sets the min (-Xms) and max (-Xmx) heap size for the JVM                       |

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

## Changing versions
There is 3 values you need to update/change the version. 
1. Solr version: found at [archive.apache.org](https://archive.apache.org/dist/lucene/solr)
1. SOLR_KEYS: Generated using GPG and the acs file
1. SOLR_FILE_SHA256: sha256sum of the tgz file

```dockerfile
ENV SOLR_VERSION="8.11.2"
ENV SOLR_KEYS="86EDB9C33B8517228E88A8F93E48C0C6EF362B9E"
ENV SOLR_FILE_SHA256="54d6ebd392942f0798a60d50a910e26794b2c344ee97c2d9b50e678a7066d3a6"
```

Go to [archive.apache.org](https://archive.apache.org/dist/lucene/solr) and find the version you want. There will be several file but the ones to use have the following naming convention.

* solr-${SOLR_VERSION}.tgz
* solr-${SOLR_VERSION}.tgz.asc

Download the two files and run and replace the _1.1.1_ with the version you have.

```bash
# This outputs the value to use for $SOLR_KEYS.
gpg solr-1.1.1.tgz.asc

# This outputs the value to use for $SOLR_FILE_SHA256.
sha256sum solr-1.1.1.tgz
```
