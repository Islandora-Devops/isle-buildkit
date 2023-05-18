# Cantaloupe

Docker image for [Cantaloupe] version 5.0.5.

Please refer to the [Cantaloupe Documentation] for more in-depth information.

As a quick example this will bring up an instance of [Cantaloupe], and allow you
to view on <http://localhost:8182/cantaloupe/>.

```bash
docker run --rm -ti -p 8182:8182 islandora/cantaloupe
```

## Dependencies

Requires `islandora/java` docker image to build. Please refer to the
[Java Image README](../java/README.md) for additional information including
additional settings, volumes, ports, etc.

## Volumes

| Path  | Description          |
| :---- | :------------------- |
| /data | [Cantaloupe Caching] |

## Settings

Please see the
[documentation](https://github.com/Islandora-Devops/isle-buildkit/tree/main/cantaloupe#settings)
in Github as the settings here exceed the file length supported by Docker Hub.

[Cantaloupe Caching]: https://cantaloupe-project.github.io/manual/3.1/caching.html
[Cantaloupe Documentation]: https://cantaloupe-project.github.io/manual/3.1/getting-started.html
[Cantaloupe Logs]: https://cantaloupe-project.github.io/manual/3.1/logging.html
[Cantaloupe]: https://cantaloupe-project.github.io/
