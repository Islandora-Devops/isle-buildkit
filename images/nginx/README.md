# Nginx

Docker image for [Nginx] version 1.24.0 and [FPM] version 8.3.8.

Built from [Islandora-DevOps/isle-buildkit nginx](https://github.com/Islandora-DevOps/isle-buildkit/tree/main/images/nginx)

Please refer to the [Nginx Documentation] and [FPM Documentation] for more
in-depth information.

Acts as base Docker image for all PHP based services, such as nginx, Docker
etc. It can be used on it's own as well.

## Dependencies

Requires `islandora/base` Docker image to build. Please refer to the
[Base Image README](../base/README.md) for additional information.

## Settings

> N.B. For all of the settings below images that descend from
> ``islandora/nginx`` will apply prefix to every setting. So for example
> `PHP_LOG_LEVEL` would become `HOUDINI_PHP_LOG_LEVEL` this is to allow for
> different settings on a per-service basis.

### Nginx Settings

| Environment Variable          | Default         | Description                                                                           |
| :---------------------------- | :-------------- | :------------------------------------------------------------------------------------ |
| NGINX_CLIENT_BODY_TIMEOUT     | 60s             | Timeout for reading client request body                                               |
| NGINX_CLIENT_MAX_BODY_SIZE    | 1m              | Specifies the maximum accepted body size of a client request                          |
| NGINX_ERROR_LOG_LEVEL         | warn            | Log Level of Error log                                                                |
| NGINX_FASTCGI_CONNECT_TIMEOUT | 60s             | Timeout for establishing a connection with a FastCGI server                           |
| NGINX_FASTCGI_READ_TIMEOUT    | 60s             | Timeout for reading a response from the FastCGI server                                |
| NGINX_FASTCGI_SEND_TIMEOUT    | 60s             | Timeout for transmitting a request to the FastCGI server.                             |
| NGINX_KEEPALIVE_TIMEOUT       | 75s             | Timeout for keep-alive connections                                                    |
| NGINX_LINGERING_TIMEOUT       | 5s              | The maximum waiting time for more client data to arrive                               |
| NGINX_PROXY_CONNECT_TIMEOUT   | 60s             | Timeout for establishing a connection with a proxied server                           |
| NGINX_PROXY_READ_TIMEOUT      | 60s             | Timeout for reading a response from the proxied server                                |
| NGINX_PROXY_SEND_TIMEOUT      | 60s             | Timeout for transmitting a request to the proxied server                              |
| NGINX_REAL_IP_HEADER          | X-Forwarded-For | Request header field whose value will be used to replace the client address.          |
| NGINX_REAL_IP_RECURSIVE       | off             | See https://nginx.org/en/docs/http/ngx_http_realip_module.html         |
| NGINX_SEND_TIMEOUT            | 60s             | Timeout for transmitting a response to the client                                     |
| NGINX_SET_REAL_IP_FROM        | 172.0.0.0/8     | Trusted addresses that are known to send correct replacement addresses                |
| NGINX_SET_REAL_IP_FROM2       | 172.0.0.0/8     | Trusted addresses that are known to send correct replacement addresses                |
| NGINX_SET_REAL_IP_FROM3       | 172.0.0.0/8     | Trusted addresses that are known to send correct replacement addresses                |
| NGINX_WORKER_CONNECTIONS      | 1024            | The maximum number of simultaneous connections that can be opened by a worker process |
| NGINX_WORKER_PROCESSES        | auto            | Set number of worker processes automatically based on number of CPU cores             |

### PHP Settings

| Environment Variable          | Default  | Description                                                                        |
| :---------------------------- | :------- | :--------------------------------------------------------------------------------- |
| PHP_DEFAULT_SOCKET_TIMEOUT    | 60       | Default timeout for socket based streams (seconds)                                 |
| PHP_LOG_LEVEL                 | notice   | Log level. Possible Values: alert, error, warning, notice, debug                   |
| PHP_LOG_LIMIT                 | 16384    | Log limit on number of characters in the single line                               |
| PHP_MAX_EXECUTION_TIME        | 30       | Maximum execution time of each script, in seconds                                  |
| PHP_MAX_FILE_UPLOADS          | 20       | Maximum number of files that can be uploaded via a single request                  |
| PHP_MAX_INPUT_TIME            | 60       | Maximum amount of time each script may spend parsing request data                  |
| PHP_MEMORY_LIMIT              | 128M     | Maximum amount of memory a script may consume                                      |
| PHP_PM                        | dynamic  | static, dynamic, or ondemand                                                       |
| PHP_PM_MAX_CHILDREN           | 5        | The number of simultaneous requests that will be served                            |
| PHP_PM_START_SERVERS          | 2        | The number of child processes created on startup                                   |
| PHP_PM_MIN_SPARE_SERVERS      | 1        | The desired minimum number of idle server processes (dynamic only)                 |
| PHP_PM_MAX_SPARE_SERVERS      | 3        | The desired maximum number of idle server processes (dynamic only)                 |
| PHP_PM_IDLE_TIMEOUT           | 10s      | The number of seconds after which an idle process will be killed (ondemand only)   |
| PHP_PM_MAX_REQUESTS           | 0        | The number of requests each child process should execute before respawning         |
| PHP_POST_MAX_SIZE             | 128M     | Maximum size of POST data that PHP will accept                                     |
| PHP_PROCESS_CONTROL_TIMEOUT   | 60       | Timeout for child processes to wait for a reaction on signals from master          |
| PHP_REQUEST_TERMINATE_TIMEOUT | 60       | Timeout for serving a single request after which the worker process will be killed |
| PHP_UPLOAD_MAX_FILESIZE       | 128M     | Maximum allowed size for uploaded files                                            |

## Updating

You can change the release used for `composer` by modifying the build argument
`COMPOSER_VERSION` and `COMPOSER_SHA256` in the `Dockerfile` shown as `XXXXXXXXXXXX` in the
following snippet:

```Dockerfile
ARG COMPOSER_VERSION=XXXXXXXXXXXX
#...
ARG COMPOSER_SHA256=XXXXXXXXXXXX
```

You can generate the `SHA256` with the following commands:

```bash
COMPOSER_VERSION=$(cat nginx/Dockerfile | grep -o 'COMPOSER_VERSION=.*' | cut -f2 -d=)
COMPOSER_FILE=$(cat nginx/Dockerfile | grep -o 'COMPOSER_FILE=.*' | cut -f2 -d=)
COMPOSER_URL=$(cat nginx/Dockerfile | grep -o 'COMPOSER_URL=.*' | cut -f2 -d=)
FILE=$(eval "echo $COMPOSER_FILE")
URL=$(eval "echo $COMPOSER_URL")
wget --quiet "${URL}"
shasum -a 256 "${FILE}" | cut -f1 -d' '
rm "${FILE}"
```

[FPM Documentation]: https://www.php.net/manual/en/install.fpm.configuration.php
[FPM Logging]: https://www.php.net/manual/en/install.fpm.configuration.php
[FPM]: https://www.php.net/manual/en/install.fpm.php
[Nginx Documentation]: https://nginx.org/en/docs/
[Nginx Logging]: https://docs.nginx.com/nginx/admin-guide/monitoring/logging/
[Nginx]: https://www.nginx.com/
