# Homarus

Docker image for [Homarus].

## Dependencies

Requires `islandora/crayfish` docker image to build. Please refer to the
[Crayfish Image README](../crayfish/README.md) for additional information including
additional settings, volumes, ports, etc.

## Settings

| Environment Variable | Etcd Key           | Default | Description                                                                                       |
| :------------------- | :----------------- | :------ | :------------------------------------------------------------------------------------------------ |
| HOMARUS_LOG_LEVEL    | /homarus/log/level | debug   | Log level. Possible Values: debug, info, notice, warning, error, critical, alert, emergency, none |

[Homarus]: https://github.com/Islandora/Crayfish/tree/master/Homarus
