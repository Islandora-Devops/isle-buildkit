# Recast

Docker image for [Recast].

## Dependencies

Requires `islandora/crayfish` docker image to build. Please refer to the
[Crayfish Image README](../crayfish/README.md) for additional information including
additional settings, volumes, ports, etc.

## Settings

| Environment Variable | Default                               | Description                                                                                       |
| :------------------- | :------------------------------------ | :------------------------------------------------------------------------------------------------ |
| RECAST_DRUPAL_URL    | islandora.traefik.me                  | Drupal URL                                                                                        |
| RECAST_FCREPO_URL    | islandora.traefik.me:8081/fcrepo/rest | Fcrepo Rest API URL                                                                               |
| RECAST_LOG_LEVEL     | info                                  | Log level. Possible Values: debug, info, notice, warning, error, critical, alert, emergency, none |

[Recast]: https://github.com/Islandora/Crayfish/tree/main/Recast
