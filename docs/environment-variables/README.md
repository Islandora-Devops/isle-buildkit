# Environment variable migration

Images now use the same setting names directly: `DB_*`, `NGINX_*`, `PHP_*`, and
`TOMCAT_*`. The automatic image-prefix override convention has been removed
([#472](https://github.com/Islandora-Devops/isle-buildkit/issues/472)).

| Previous container setting | Container setting |
| --- | --- |
| `DRUPAL_DEFAULT_DB_*` | `DB_*` |
| `FCREPO_DB_*` | `DB_*` |
| `HANDLE_DB_NAME`, `HANDLE_DB_USER`, `HANDLE_DB_PASSWORD` | `DB_NAME`, `DB_USER`, `DB_PASSWORD` |
| `MARIADB_DB_*` or another image prefix before `DB_*` | `DB_*` |
| `MYSQL_ROOT_USER`, `POSTGRESQL_ROOT_USER` | `DB_ROOT_USER` |
| `MYSQL_ROOT_PASSWORD`, `POSTGRESQL_ROOT_PASSWORD` | `DB_ROOT_PASSWORD` |
| `DRUPAL_NGINX_*`, `DRUPAL_PHP_*` | `NGINX_*`, `PHP_*` |
| `FCREPO_TOMCAT_*` or another image prefix before `TOMCAT_*` | `TOMCAT_*` |

You can retain distinct names on the host and map them in Compose:

```yaml
services:
  drupal:
    environment:
      DB_PASSWORD: ${DRUPAL_DEFAULT_DB_PASSWORD}
  fcrepo:
    secrets:
      - source: FCREPO_DB_PASSWORD
        target: DB_PASSWORD

secrets:
  FCREPO_DB_PASSWORD:
    file: ./secrets/FCREPO_DB_PASSWORD
```

Rename confd keys similarly, for example `/fcrepo/db/password` becomes
`/db/password` for that container's backend. Shared backends must provide the
appropriate canonical settings for each container.

Update downstream Drupal `settings.php` files that read environment files to
read `DB_NAME`, `DB_USER`, and `DB_PASSWORD` instead of `DRUPAL_DEFAULT_DB_*`.
Drupal multisite settings (`DRUPAL_SITE_{SITE}_*`) remain supported; these select
individual sites rather than overriding the container's default settings.
Service-specific settings such as `HANDLE_DB_READONLY` also retain their names.

fcrepo and Handle refresh database account passwords during every s6 startup.
Drupal install hooks must call `create_database` before the already-installed
check; the test image demonstrates this. Recreate the application container
after changing a password secret, retaining the database volume. The root
credentials used for setup must still permit account management.
