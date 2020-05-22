# Recast

Docker image for [Recast].

## Dependencies

Requires `islandora/crayfish` docker image to build. Please refer to the
[Crayfish Image README](../crayfish/README.md) for additional information including
additional settings, volumes, ports, etc.

## Settings

| Environment Variable | Etcd Key           | Default                 | Description                            |
| :------------------- | :----------------- | :---------------------- | :------------------------------------- |
| RECAST_DRUPAL_URL    | /recast/drupal/url | drupal:80               | Drupal URL                             |
| RECAST_FCREPO_URL    | /recast/fcrepo/url | fcrepo/fcrepo/rest | Fcrepo Rest API URL                    |
| RECAST_GEMINI_URL    | /recast/gemini/url | gemini:8000             | Gemini URL                             |
| RECAST_LOG_LEVEL     | /recast/log/level  | WARNING                 | The log level for Recast micro-service |

## Logs

| Path                          | Description |
| :---------------------------- | :---------- |
| /var/log/islandora/recast.log | Recast Log  |

[Recast]: https://github.com/Islandora/Crayfish/tree/master/Recast
