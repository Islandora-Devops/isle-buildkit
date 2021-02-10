# PostgreSQL

Docker image for [PostgreSQL] version 12.2

Please refer to the [PostgreSQL Documentation] for more in-depth information.

As a quick example this will bring up an instance of PostgreSQL, and allow you to
log in with client as the user `root`.

```bash
docker run --rm -d --name postgresql islandora/postgresql
docker exec -ti postgresql psql -U root postgres
```

## Dependencies

Requires `islandora/base` docker image to build. Please refer to the
[Base Image README](../base/README.md) for additional information.

## Ports

| Port | Description            |
| :--- | :--------------------- |
| 5432 | PostgreSQL Client Port |

## Settings

| Environment Variable     | Confd Key                  | Default  | Description                            |
| :----------------------- | :------------------------ | :------- | :------------------------------------- |
| POSTGRESQL_ROOT_USER     | /postgresql/root/user     | root     | The name of root user account          |
| POSTGRESQL_ROOT_PASSWORD | /postgresql/root/password | password | The password for the root user account |

[PostgreSQL Documentation]: https://www.postgresql.org/docs/
[PostgreSQL]: https://www.postgresql.org/
