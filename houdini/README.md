# Houdini

Docker image for [Houdini].

## Dependencies

Requires `islandora/crayfish` docker image to build. Please refer to the
[Crayfish Image README](../crayfish/README.md) for additional information including
additional settings, volumes, ports, etc.

## Settings

| Environment Variable | Confd Key           | Default                        | Description                                                                                       |
| :------------------- | :------------------ | :----------------------------- | :------------------------------------------------------------------------------------------------ |
| HOUDINI_FCREPO_URL   | /houdini/fcrepo/url | http://fcrepo:8080/fcrepo/rest | Fcrepo Rest API URL                                                                               |
| HOUDINI_LOG_LEVEL    | /houdini/log/level  | info                           | Log level. Possible Values: debug, info, notice, warning, error, critical, alert, emergency, none |

[Houdini]: https://github.com/Islandora/Crayfish/tree/main/Houdini
