# MariaDB

Docker image for [MariaDB] version 10.11.6

Built from [Islandora-DevOps/isle-buildkit mariadb](https://github.com/Islandora-DevOps/isle-buildkit/tree/main/images/mariadb)

Please refer to the [MariaDB Documentation] for more in-depth information.

As a quick example this will bring up an instance of MariaDB, and allow you to
log in with client as the user `root` with the password `password`.

```bash
docker run --rm -d -name mariadb islandora/mariadb
docker exec -ti mariadb mysql -u root --password='password'
```

## Dependencies

Requires `islandora/base` Docker image to build. Please refer to the
[Base Image README](../base/README.md) for additional information.

## Ports

| Port | Description       |
| :--- | :---------------- |
| 3306 | MySQL Client Port |

## Volumes

| Path                 | Description                                    |
| :------------------- | :--------------------------------------------- |
| /var/lib/mysql       | Database files                                 |
| /var/lib/mysql-files | Location to import databases via CSV/SQL files |

## Settings

### Database Settings

Please see the documentation in the [base image] for more information about the
default database connection configuration.

| Environment Variable | Default | Description                                                                           |
| :------------------- | :------ | :------------------------------------------------------------------------------------ |
| MYSQL_ROOT_PASSWORD  |         | The database root user password. Defaults to `DB_ROOT_PASSWORD`                       |
| MYSQL_ROOT_USER      |         | The database root user (used to create the site database). Defaults to `DB_ROOT_USER` |
| MYSQL_MAX_ALLOWED_PACKET | 16777216 | Max packet length to send to or receive from the server, [documentation](https://mariadb.com/docs/server/ref/mdb/system-variables/max_allowed_packet/)
| MYSQL_TRANSACTION_ISOLATION | READ-COMMITTED | The isolation level for transactions.

## Logs

| Path   | Description   |
| :----- | :------------ |
| STDOUT | [MariaDB Log] |

[base image]: ../base/README.md
[MariaDB Documentation]: https://mariadb.org/documentation/
[MariaDB]: https://mariadb.org/
