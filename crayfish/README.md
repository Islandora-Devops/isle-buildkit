# Crayfish

Docker image for [Crayfish] version 1.1.1.

Acts as base Docker image for Crayfish based micro-services. It is not meant to
be run on its own.

## Dependencies

Requires `islandora/nginx` docker image to build. Please refer to the
[Nginx Image README](../nginx/README.md) for additional information including
additional settings, volumes, ports, etc.

## Ports

| Port | Description |
| :--- | :---------- |
| 8000 | HTTP        |

## Settings

> N.B. For all of the settings below images that descend from
> ``islandora/crayfish`` will apply prefix to every setting. So for example
> `JWT_ADMIN_TOKEN` would become `GEMINI_JWT_ADMIN_TOKEN` this is to allow for
> different settings on a per-service basis.

| Environment Variable | Etcd Key         | Default   | Description |
| :------------------- | :--------------- | :-------- | :---------- |
| JWT_ADMIN_TOKEN      | /jwt/admin/token | islandora | JWT Token   |

### Timeout configuration

| Environment Variable    | Etcd Key                 | Default           | Description                                                                                       |
| :---------------------- | :----------------------- | :---------------- | :------------------------------------------------------------------------------------------------ |
| PHP_MAX_EXECUTION_TIME  | -                        | 60                | The value of `PHP_MAX_EXECUTION_TIME` is used to set the Nginx `fastcgi_read_timeout` parameter   |

[Crayfish]: https://github.com/Islandora/Crayfish/tree/main
