# Gemini

Docker image for [Gemini].

## Dependencies

Requires `islandora/crayfish` docker image to build. Please refer to the
[Crayfish Image README](../crayfish/README.md) for additional information including
additional settings, volumes, ports, etc.

## Settings

| Environment Variable    | Etcd Key                 | Default                 | Description                                                 |
| :---------------------- | :----------------------- | :---------------------- | :---------------------------------------------------------- |
| GEMINI_DB_DRIVER        | /gemini/db/driver        | pdo_mysql               | The database driver to use                                  |
| GEMINI_DB_HOST          | /gemini/db/host          | database                | The database host                                           |
| GEMINI_DB_NAME          | /gemini/db/name          | gemini                  | The database name                                           |
| GEMINI_DB_PASSWORD      | /gemini/db/password      | password                | The database user password                                  |
| GEMINI_DB_PORT          | /gemini/db/port          | 3306                    | The database port                                           |
| GEMINI_DB_ROOT_PASSWORD | /gemini/db/root/password | password                | The root user password (used to create the database / user) |
| GEMINI_DB_ROOT_USER     | /gemini/db/root/user     | root                    | The root user (used to create the database / user)          |
| GEMINI_DB_USER          | /gemini/db/user          | gemini                  | The user to create / use when interacting with the database |
| GEMINI_FCREPO_URL       | /gemini/fcrepo/url       | fcrepo/fcrepo/rest | Fcrepo Rest API URL                                         |
| GEMINI_LOG_LEVEL        | /gemini/log/level        | WARNING                 | The log level for Gemini micro-service                      |

## Logs

| Path                          | Description |
| :---------------------------- | :---------- |
| /var/log/islandora/gemini.log | Gemini Log  |

[Gemini]: https://github.com/Islandora/Crayfish/tree/master/Gemini
