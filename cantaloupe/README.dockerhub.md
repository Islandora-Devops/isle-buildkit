# Cantaloupe

Docker image for [Cantaloupe] version 4.1.5.

Please refer to the [Cantaloupe Documentation] for more in-depth information.

As a quick example this will bring up an instance of [Cantaloupe], and allow you
to view on <http://localhost:80/cantaloupe/>.

```bash
docker run --rm -ti -p 80:80 islandora/cantaloupe
```

## Dependencies

Requires `islandora/tomcat` docker image to build. Please refer to the
[Tomcat Image README](../tomcat/README.md) for additional information including
additional settings, volumes, ports, etc.

## Volumes

| Path  | Description          |
| :---- | :------------------- |
| /data | [Cantaloupe Caching] |

## Settings

Please see the
[documentation](https://github.com/Islandora-Devops/isle-buildkit/tree/main/cantaloupe#settings)
in Github as the settings here exceed the file length supported by Docker Hub.

## Logs

| Path                                        | Description       |
| :------------------------------------------ | :---------------- |
| /opt/tomcat/logs/cantaloupe.access.log      | [Cantaloupe Logs] |
| /opt/tomcat/logs/cantaloupe.application.log | [Cantaloupe Logs] |

[Cantaloupe Caching]: https://cantaloupe-project.github.io/manual/3.1/caching.html
[Cantaloupe Documentation]: https://cantaloupe-project.github.io/manual/3.1/getting-started.html
[Cantaloupe Logs]: https://cantaloupe-project.github.io/manual/3.1/logging.html
[Cantaloupe]: https://cantaloupe-project.github.io/
