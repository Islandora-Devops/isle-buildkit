# Nginx

Docker image for [Nginx] version 1.16.1 and [FPM] version 7.3.17.

Please refer to the [Nginx Documentation] and [FPM Documentation] for more
in-depth information.

Acts as base Docker image for all PHP based services, such as Crayfish, Docker
etc. It can be used on it's own as well.

## Dependencies

Requires `islandora/base` docker image to build. Please refer to the
[Base Image README](../base/README.md) for additional information.

## Settings

> N.B. For all of the settings below images that descend from
> ``islandora/nginx`` will apply prefix to every setting. So for example
> `JWT_ADMIN_TOKEN` would become `GEMINI_JWT_ADMIN_TOKEN` this is to allow for
> different settings on a per-service basis.

### Nginx Settings

| Environment Variable       | Etcd Key                    | Default | Description                                                                           |
| :------------------------- | :-------------------------- | :------ | :------------------------------------------------------------------------------------ |
| NGINX_CLIENT_MAX_BODY_SIZE | /nginx/client/max/body/size | 1m      | Specifies the maximum accepted body size of a client request                          |
| NGINX_ERROR_LOG_LEVEL      | /nginx/error/log/level      | warn    | Log Level of Error log                                                                |
| NGINX_KEEPALIVE_TIMEOUT    | /nginx/keepalive/timeout    | 65      | Timeout for keep-alive connections                                                    |
| NGINX_WORKER_CONNECTIONS   | /nginx/worker/connections   | 1024    | The maximum number of simultaneous connections that can be opened by a worker process |
| NGINX_WORKER_PROCESSES     | /nginx/worker/processes     | auto    | Set number of worker processes automatically based on number of CPU cores             |

### PHP Settings

| Environment Variable       | Etcd Key                    | Default | Description                                                       |
| :------------------------- | :-------------------------- | :------ | :---------------------------------------------------------------- |
| PHP_DEFAULT_SOCKET_TIMEOUT | /php/default/socket/timeout | 60      | Default timeout for socket based streams (seconds)                |
| PHP_LOG_LEVEL              | /php/log/level              | notice  | Log level. Possible Values: alert, error, warning, notice, debug  |
| PHP_LOG_LIMIT              | /php/log/limit              | 16384   | Log limit on number of characters in the single line              |
| PHP_MAX_EXECUTION_TIME     | -                           | 30      | Maximum execution time of each script, in seconds.  The value of this is aligned with the Nginx fastcgi parameter `fastcgi_read_timeout` and the PHP parameter `request_terminate_timeout`.  That is, setting  `/php/max/execution/time` will set `fastcgi_read_timeout` and `request_terminate_timeout` to the same values.|
| PHP_MAX_FILE_UPLOADS       | /php/max/file/uploads       | 20      | Maximum number of files that can be uploaded via a single request |
| PHP_MAX_INPUT_TIME         | /php/max/input/time         | 60      | Maximum amount of time each script may spend parsing request data |
| PHP_MEMORY_LIMIT           | /php/memory/limit           | 128M    | Maximum amount of memory a script may consume                     |
| PHP_POST_MAX_SIZE          | /php/post/max/size          | 8M      | Maximum size of POST data that PHP will accept                    |
| PHP_UPLOAD_MAX_FILESIZE    | /php/upload/max/filesize    | 2M      | Maximum allowed size for uploaded files                           |
| PHP_FPM_MAX_CHILDREN       | -                           | 5       | Maximum number of child processes (when using 'dynamic' pm)       |
| PHP_FPM_START_SERVERS      | -                           | 2       | The number of child processes created on startup (when using 'dynamic' pm) |
| PHP_FPM_MIN_SPARE_SERVERS  | -                           | 1       | The desired minimum number of idle server processes (when using 'dynamic' pm) |
| PHP_FPM_MAX_SPARE_SERVERS  | -                           | 3       | The desired maximum number of idle server processes (when using 'dynamic' pm) |

[FPM Documentation]: https://www.php.net/manual/en/install.fpm.configuration.php
[FPM Logging]: https://www.php.net/manual/en/install.fpm.configuration.php
[FPM]: https://www.php.net/manual/en/install.fpm.php
[Nginx Documentation]: https://nginx.org/en/docs/
[Nginx Logging]: https://docs.nginx.com/nginx/admin-guide/monitoring/logging/
[Nginx]: https://www.nginx.com/
