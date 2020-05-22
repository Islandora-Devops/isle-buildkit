# Blazegraph

Docker image for [Blazegraph] version 2.1.5.

Please refer to the [Blazegraph Documentation] for more in-depth information.

As a quick example this will bring up an instance of [Blazegraph], and allow you
to view on <http://localhost:80/bigdata/>.

```bash
docker run --rm -ti -p 80:80 islandora/blazegraph
```

## Dependencies

Requires `islandora/tomcat` docker image to build. Please refer to the
[Tomcat Image README](../tomcat/README.md) for additional information including
additional settings, volumes, ports, etc.

## Volumes

| Path  | Description                  |
| :---- | :--------------------------- |
| /data | Location of the backing file |

## Logs

| Path                               | Description |
| :--------------------------------- | :---------- |
| /opt/tomcat/logs/rules.log         |             |
| /opt/tomcat/logs/queryLog.csv      |             |
| /opt/tomcat/logs/queryRunState.log |             |
| /opt/tomcat/logs/solutions.csv     |             |
| /opt/tomcat/logs/sparql.txt        |             |

[Blazegraph Documentation]: https://github.com/blazegraph/database/wiki/About_Blazegraph
[Blazegraph]: https://blazegraph.com/
