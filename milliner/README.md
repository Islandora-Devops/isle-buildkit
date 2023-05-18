# Milliner

Docker image for [Milliner].

## Dependencies

Requires `islandora/crayfish` docker image to build. Please refer to the
[Crayfish Image README](../crayfish/README.md) for additional information including
additional settings, volumes, ports, etc.

## Settings

| Environment Variable | Default                        | Description                                                                                       |
| :------------------- | :----------------------------- | :------------------------------------------------------------------------------------------------ |
| MILLINER_FCREPO_URL  | http://fcrepo:8080/fcrepo/rest | Fcrepo Rest API URL                                                                               |
| MILLINER_FCREPO6     | false                          | Set to "true" if using Fedora 6 and set to "false" if using  Fedora 4 or 5                        |
| MILLINER_LOG_LEVEL   | info                           | Log level. Possible Values: debug, info, notice, warning, error, critical, alert, emergency, none |

[Milliner]: https://github.com/Islandora/Crayfish/tree/main/Milliner
