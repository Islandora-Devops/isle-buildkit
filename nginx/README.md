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
> `PHP_LOG_LEVEL` would become `HOUDINI_PHP_LOG_LEVEL` this is to allow for
> different settings on a per-service basis.

### Nginx Settings

| Environment Variable          | Confd Key                      | Default | Description                                                                           |
| :---------------------------- | :----------------------------- | :------ | :------------------------------------------------------------------------------------ |
| NGINX_CLIENT_BODY_TIMEOUT     | /nginx/client/body/timeout     | 60s     | Timeout for reading client request body                                               |
| NGINX_CLIENT_MAX_BODY_SIZE    | /nginx/client/max/body/size    | 1m      | Specifies the maximum accepted body size of a client request                          |
| NGINX_ERROR_LOG_LEVEL         | /nginx/error/log/level         | warn    | Log Level of Error log                                                                |
| NGINX_FASTCGI_CONNECT_TIMEOUT | /nginx/fastcgi/connect/timeout | 60s     | Timeout for establishing a connection with a FastCGI server                           |
| NGINX_FASTCGI_READ_TIMEOUT    | /nginx/fastcgi/read/timeout    | 60s     | Timeout for reading a response from the FastCGI server                                |
| NGINX_FASTCGI_SEND_TIMEOUT    | /nginx/fastcgi/send/timeout    | 60s     | Timeout for transmitting a request to the FastCGI server.                             |
| NGINX_KEEPALIVE_TIMEOUT       | /nginx/keepalive/timeout       | 75s     | Timeout for keep-alive connections                                                    |
| NGINX_LINGERING_TIMEOUT       | /nginx/lingering/timeout       | 5s      | The maximum waiting time for more client data to arrive                               |
| NGINX_PROXY_CONNECT_TIMEOUT   | /nginx/proxy/connect/timeout   | 60s     | Timeout for establishing a connection with a proxied server                           |
| NGINX_PROXY_READ_TIMEOUT      | /nginx/proxy/read/timeout      | 60s     | Timeout for reading a response from the proxied server                                |
| NGINX_PROXY_SEND_TIMEOUT      | /nginx/proxy/send/timeout      | 60s     | Timeout for transmitting a request to the proxied server                              |
| NGINX_SEND_TIMEOUT            | /nginx/send/timeout            | 60s     | Timeout for transmitting a response to the client                                     |
| NGINX_WORKER_CONNECTIONS      | /nginx/worker/connections      | 1024    | The maximum number of simultaneous connections that can be opened by a worker process |
| NGINX_WORKER_PROCESSES        | /nginx/worker/processes        | auto    | Set number of worker processes automatically based on number of CPU cores             |

### PHP Settings

| Environment Variable          | Confd Key                      | Default | Description                                                                        |
| :---------------------------- | :----------------------------- | :------ | :--------------------------------------------------------------------------------- |
| PHP_DEFAULT_SOCKET_TIMEOUT    | /php/default/socket/timeout    | 60      | Default timeout for socket based streams (seconds)                                 |
| PHP_LOG_LEVEL                 | /php/log/level                 | notice  | Log level. Possible Values: alert, error, warning, notice, debug                   |
| PHP_LOG_LIMIT                 | /php/log/limit                 | 16384   | Log limit on number of characters in the single line                               |
| PHP_MAX_EXECUTION_TIME        | /php/max/execution/time        | 30      | Maximum execution time of each script, in seconds                                  |
| PHP_MAX_FILE_UPLOADS          | /php/max/file/uploads          | 20      | Maximum number of files that can be uploaded via a single request                  |
| PHP_MAX_INPUT_TIME            | /php/max/input/time            | 60      | Maximum amount of time each script may spend parsing request data                  |
| PHP_MEMORY_LIMIT              | /php/memory/limit              | 128M    | Maximum amount of memory a script may consume                                      |
| PHP_POST_MAX_SIZE             | /php/post/max/size             | 128M    | Maximum size of POST data that PHP will accept                                     |
| PHP_PROCESS_CONTROL_TIMEOUT   | /php/process/control/timeout   | 60      | Timeout for child processes to wait for a reaction on signals from master          |
| PHP_REQUEST_TERMINATE_TIMEOUT | /php/request/terminate/timeout | 60      | Timeout for serving a single request after which the worker process will be killed |
| PHP_UPLOAD_MAX_FILESIZE       | /php/upload/max/filesize       | 128M    | Maximum allowed size for uploaded files                                            |

[FPM Documentation]: https://www.php.net/manual/en/install.fpm.configuration.php
[FPM Logging]: https://www.php.net/manual/en/install.fpm.configuration.php
[FPM]: https://www.php.net/manual/en/install.fpm.php
[Nginx Documentation]: https://nginx.org/en/docs/
[Nginx Logging]: https://docs.nginx.com/nginx/admin-guide/monitoring/logging/
[Nginx]: https://www.nginx.com/
