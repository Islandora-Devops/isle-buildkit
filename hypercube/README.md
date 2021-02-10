# Hypercube

Docker image for [Hypercube].

## Dependencies

Requires `islandora/crayfish` docker image to build. Please refer to the
[Crayfish Image README](../crayfish/README.md) for additional information including
additional settings, volumes, ports, etc.

## Settings

| Environment Variable | Confd Key              | Default            | Description                                                                                       |
| :------------------- | :-------------------- | :----------------- | :------------------------------------------------------------------------------------------------ |
| HYPERCUBE_FCREPO_URL | /hypercube/fcrepo/url | fcrepo/fcrepo/rest | Fcrepo Rest API URL                                                                               |
| HYPERCUBE_LOG_LEVEL  | /hypercube/log/level  | debug              | Log level. Possible Values: debug, info, notice, warning, error, critical, alert, emergency, none |

[Hypercube]: https://github.com/Islandora/Crayfish/tree/main/Hypercube
