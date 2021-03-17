# Recast

Docker image for [Recast].

## Dependencies

Requires `islandora/crayfish` docker image to build. Please refer to the
[Crayfish Image README](../crayfish/README.md) for additional information including
additional settings, volumes, ports, etc.

## Settings

| Environment Variable | Confd Key           | Default            | Description                                                                                       |
| :------------------- | :----------------- | :----------------- | :------------------------------------------------------------------------------------------------ |
| RECAST_DRUPAL_URL    | /recast/drupal/url | drupal:80          | Drupal URL                                                                                        |
| RECAST_FCREPO_URL    | /recast/fcrepo/url | fcrepo/fcrepo/rest | Fcrepo Rest API URL                                                                               |
| RECAST_LOG_LEVEL     | /recast/log/level  | debug              | Log level. Possible Values: debug, info, notice, warning, error, critical, alert, emergency, none |

[Recast]: https://github.com/Islandora/Crayfish/tree/main/Recast
