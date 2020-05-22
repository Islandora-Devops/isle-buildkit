# MariaDB

Docker image for [MariaDB] version 10.4.12

Please refer to the [MariaDB Documentation] for more in-depth information.

As a quick example this will bring up an instance of MariaDB, and allow you to
log in with client as the user `root` with the password `password`.

```bash
docker run --rm -d -name mariadb islandora/mariadb
docker exec -ti mariadb mysql -u root --password='password'
```

## Dependencies

Requires `islandora/base` docker image to build. Please refer to the
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

| Environment Variable | Etcd Key             | Default  | Description                            |
| :------------------- | :------------------- | :------- | :------------------------------------- |
| MYSQL_ROOT_PASSWORD  | /mysql/root/password | password | The password for the root user account |

## Logs

| Path   | Description   |
| :----- | :------------ |
| STDOUT | [MariaDB Log] |

[MariaDB Documentation]: https://mariadb.org/documentation/
[MariaDB]: https://mariadb.org/
