# PostgreSQL

Docker image for [PostgreSQL] version 16.3

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

### Database Settings

Please see the documentation in the [base image] for more information about the
default database connection configuration.

| Environment Variable     | Default | Description                                                                           |
| :----------------------- | :------ | :------------------------------------------------------------------------------------ |
| POSTGRESQL_ROOT_USER     |         | The database root user password. Defaults to `DB_ROOT_PASSWORD`                       |
| POSTGRESQL_ROOT_PASSWORD |         | The database root user (used to create the site database). Defaults to `DB_ROOT_USER` |

[base image]: ../base/README.md
[PostgreSQL Documentation]: https://www.postgresql.org/docs/
[PostgreSQL]: https://www.postgresql.org/
