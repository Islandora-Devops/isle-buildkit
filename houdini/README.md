# Houdini

Docker image for [Houdini].

## Dependencies

Requires `islandora/crayfish` docker image to build. Please refer to the
[Crayfish Image README](../crayfish/README.md) for additional information including
additional settings, volumes, ports, etc.

## Settings

| Environment Variable | Etcd Key           | Default | Description                             |
| :------------------- | :----------------- | :------ | :-------------------------------------- |
| HOUDINI_LOG_LEVEL    | /houdini/log/level | WARNING | The log level for Houdini micro-service |

## Logs

| Path                           | Description |
| :----------------------------- | :---------- |
| /var/log/islandora/houdini.log | Houdini Log |

[Houdini]: https://github.com/Islandora/Crayfish/tree/master/Houdini
