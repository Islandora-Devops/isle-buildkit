# Drupal

Docker image for [Drupal].

Built from [Islandora-DevOps/isle-buildkit drupal](https://github.com/Islandora-DevOps/isle-buildkit/tree/main/images/drupal)

Acts as base Docker image for Drupal based projects, it doesn't install Drupal
as consumers of this image are expected to provide their own composer file.
Instead it provides startup scripts that allow Drupal to be installed when the
image is first run.

## Dependencies

Requires `islandora/nginx` Docker image to build. Please refer to the
[Nginx Image README](../nginx/README.md) for additional information including
additional settings, volumes, ports, etc.

## Ports

| Port | Description |
| :--- | :---------- |
| 80   | HTTP        |

## Settings

### Network Settings

| Environment Variable     | Default | Description                                                                        |
| :----------------------- | :------ | :--------------------------------------------------------------------------------- |
| DRUPAL_ENABLE_HTTPS      | true    | Inform PHP that `https` should be used.                                            |
| DRUPAL_REVERSE_PROXY_IPS |         | Use the IP address for the host 'traefik' if found otherwise default to `0.0.0.0`. |

### Symfony Messenger Worker Settings

This image can manage Islandora Events Messenger workers directly with
`s6-overlay`. That is intended for single-container or small deployment
topologies where worker processes should live beside PHP-FPM.

Set `DRUPAL_SM_WORKERS_MODE=container` to enable the built-in workers. Leave it
as `external` to run workers elsewhere.

| Environment Variable                          | Default  | Description                                                                 |
| :-------------------------------------------- | :------- | :-------------------------------------------------------------------------- |
| DRUPAL_SM_WORKERS_MODE                        | external | `container` runs local `drush sm:consume` services, `external` disables them |
| DRUPAL_SM_WORKERS_DERIVATIVES_ENABLED         | true     | Enable the derivative transport worker when local workers are enabled       |
| DRUPAL_SM_WORKERS_INDEX_FEDORA_ENABLED        | true     | Enable the Fedora indexing worker when local workers are enabled            |
| DRUPAL_SM_WORKERS_INDEX_BLAZEGRAPH_ENABLED    | true     | Enable the Blazegraph indexing worker when local workers are enabled        |
| DRUPAL_SM_WORKERS_TIME_LIMIT                  | 3600     | `drush sm:consume --time-limit` value used before the worker is restarted   |
| DRUPAL_SM_WORKERS_FETCH_SIZE                  |          | Optional `drush sm:consume --fetch-size` value for Symfony 8.1+             |
| DRUPAL_SM_WORKERS_NO_RESET                    |          | Set to `true` to pass `drush sm:consume --no-reset` on Symfony 8.1+         |
| DRUPAL_SM_WORKERS_RETRY_DELAY                 | 30       | Seconds to wait before retrying when Drupal is not ready or a worker exits  |

`DRUPAL_SM_WORKERS_FETCH_SIZE` and `DRUPAL_SM_WORKERS_NO_RESET` are opt-in so
the image remains safe on current Drupal and Symfony releases. Only set them
when the target `sm:consume` command supports those options.

Worker bootstrap uses this URI precedence:

- `DRUSH_OPTIONS_URI`
- `DRUPAL_DEFAULT_SITE_URL`

The built-in worker services are:

- `islandora_derivatives`
- `islandora_index_fedora`
- `islandora_index_blazegraph`

`external` mode does not use a worker URL. Distributed workers are simply the
same `drush sm:consume` commands running in another container, pod, or host
against the same Drupal site and queue backend.

### Derivative Command Settings

Islandora Events derivative queues default to local `command` execution for the
bundled Scyllaridae-backed connectors. The Drupal image writes the matching
`settings.php` policy during startup so those queues can run without a manual
settings override.

| Environment Variable                                      | Default             | Description |
| :-------------------------------------------------------- | :------------------ | :---------- |
| DRUPAL_ISLANDORA_EVENTS_DERIVATIVE_COMMAND_ENABLED        | true                | Enables privileged local derivative command execution in `settings.php` |
| DRUPAL_ISLANDORA_EVENTS_DERIVATIVE_COMMAND_ALLOWED_BINARIES | /usr/bin/scyllaridae | Comma-separated allowlist written to `settings.php` for derivative command execution |

### Database Settings

[Drupal] can make use of different database backends for storage. Please see the
documentation in the [base image] for more information about the default
database connection configuration.

| Environment Variable            | Default | Description                                                                           |
| :------------------------------ | :------ | :------------------------------------------------------------------------------------ |
| DRUPAL_DEFAULT_DB_DRIVER        |         | The database driver. Defaults to `DB_DRIVER`                                          |
| DRUPAL_DEFAULT_DB_HOST          |         | The database host. Defaults to `DB_HOST`                                              |
| DRUPAL_DEFAULT_DB_PORT          |         | The database port. Defaults to `DB_PORT`                                              |
| DRUPAL_DEFAULT_DB_ROOT_PASSWORD |         | The database root user password. Defaults to `DB_ROOT_PASSWORD`                       |
| DRUPAL_DEFAULT_DB_ROOT_USER     |         | The database root user (used to create the site database). Defaults to `DB_ROOT_USER` |

These variables also provide the default for their site specific variants such
as `DRUPAL_SITE_{SITE}_DB_HOST` are defined.

### JWT Settings

[Drupal] is expected to make use of JWT for authentication. Please see the
documentation in the [base image] for more information.

The public/private key pair used here should be the same key as is used in the
`crayfish` and `fcrepo` based containers.

### Default Site

| Environment Variable            | Default                 | Description                                        |
| :------------------------------ | :---------------------- | :------------------------------------------------- |
| DRUPAL_DEFAULT_ACCOUNT_EMAIL    | webmaster@localhost.com | The email to use for the admin account             |
| DRUPAL_DEFAULT_ACCOUNT_NAME     | admin                   | The Drupal administrator user                      |
| DRUPAL_DEFAULT_ACCOUNT_PASSWORD | password                | The Drupal administrator user password             |
| DRUPAL_DEFAULT_DB_NAME          | drupal_default          | The name of the sites database                     |
| DRUPAL_DEFAULT_DB_PASSWORD      | password                | The database users password                        |
| DRUPAL_DEFAULT_DB_USER          | drupal_default          | The database user used by the site                 |
| DRUPAL_DEFAULT_EMAIL            | webmaster@localhost.com | The Drupal administrators email                    |
| DRUPAL_DEFAULT_LOCALE           | en                      | The Drupal sites locale                            |
| DRUPAL_DEFAULT_NAME             | default                 | The Drupal sites name                              |
| DRUPAL_DEFAULT_PROFILE          | standard                | The installation profile to use                    |
| DRUPAL_DEFAULT_SUBDIR           | default                 | The installation profile to use                    |
| DRUPAL_DEFAULT_CONFIGDIR        |                         | Install using existing config files from directory |
| DRUPAL_DEFAULT_INSTALL          | true                    | Perform install if not already installed           |

Of the above you should provide at a minium your own passwords when running in
production.

### Multi-site

Additional multi-sites can be defined by adding more environment variables,
following the above conventions, only the `DRUPAL_SITE_{SITE}_NAME` is required
to create an additional site:

| Environment Variable                | Default                 | Description                                        |
| :---------------------------------- | :---------------------- | :------------------------------------------------- |
| DRUPAL_SITE_{SITE}_ACCOUNT_EMAIL    | webmaster@localhost.com | The email to use for the admin account             |
| DRUPAL_SITE_{SITE}_ACCOUNT_NAME     | admin                   | The Drupal administrator user                      |
| DRUPAL_SITE_{SITE}_ACCOUNT_PASSWORD | password                | The Drupal administrator user password             |
| DRUPAL_SITE_{SITE}_DB_NAME          | drupal_{SITE}           | The name of the sites database                     |
| DRUPAL_SITE_{SITE}_DB_PASSWORD      | password                | The database users password                        |
| DRUPAL_SITE_{SITE}_DB_USER          | drupal_{SITE}           | The database user used by the site                 |
| DRUPAL_SITE_{SITE}_EMAIL            | webmaster@localhost.com | The Drupal administrators email                    |
| DRUPAL_SITE_{SITE}_LOCALE           | en                      | The Drupal sites locale                            |
| DRUPAL_SITE_{SITE}_NAME             |                         | The Drupal sites name                              |
| DRUPAL_SITE_{SITE}_PROFILE          | standard                | The installation profile to use                    |
| DRUPAL_SITE_{SITE}_SUBDIR           | {SITE}                  | The subdirectory to install the sub-site into      |
| DRUPAL_SITE_{SITE}_CONFIGDIR        |                         | Install using existing config files from directory |
| DRUPAL_SITE_{SITE}_INSTALL          | true                    | Perform install if not already installed           |

[base image]: ../base/README.md
[Drupal]: https://www.drupal.org/
