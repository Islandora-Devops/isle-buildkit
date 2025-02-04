# Hypercube

Docker image for [Hypercube].

Built from [Islandora-DevOps/isle-buildkit hypercube](https://github.com/Islandora-DevOps/isle-buildkit/tree/main/hypercube)

## Dependencies

Requires `islandora/crayfish` docker image to build. Please refer to the
[Crayfish Image README](../crayfish/README.md) for additional information including
additional settings, volumes, ports, etc.

## Settings

| Environment Variable | Default                        | Description                                                                                       |
| :------------------- | :----------------------------- | :------------------------------------------------------------------------------------------------ |
| HYPERCUBE_FCREPO_URL | http://fcrepo:8080/fcrepo/rest | Fcrepo Rest API URL                                                                               |
| HYPERCUBE_LOG_LEVEL  | info                           | Log level. Possible Values: debug, info, notice, warning, error, critical, alert, emergency, none |

[Hypercube]: https://github.com/Islandora/Crayfish/tree/4.x/Hypercube
