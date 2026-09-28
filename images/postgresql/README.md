# PostgreSQL

Docker image for [PostgreSQL] version 16.3

Built from [Islandora-DevOps/isle-buildkit postgresql](https://github.com/Islandora-DevOps/isle-buildkit/tree/main/images/postgresql)

Please refer to the [PostgreSQL Documentation] for more in-depth information.

As a quick example this will bring up an instance of PostgreSQL, and allow you to
log in with client as the user `root`.

```bash
docker run --rm -d --name postgresql islandora/postgresql
docker exec -ti postgresql psql -U root postgres
```

## Dependencies

Requires `islandora/base` Docker image to build. Please refer to the
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
| DB_ROOT_USER | root | The database root user |
| DB_ROOT_PASSWORD | password | The database root user password |

[base image]: ../base/README.md
[PostgreSQL Documentation]: https://www.postgresql.org/docs/
[PostgreSQL]: https://www.postgresql.org/

Use `DB_ROOT_USER` and `DB_ROOT_PASSWORD` directly. Image-prefixed aliases
are no longer supported. See the [migration guide](../../docs/environment-variables/README.md).
