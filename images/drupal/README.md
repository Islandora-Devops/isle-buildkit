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

### Database Settings

[Drupal] can make use of different database backends for storage. Please see the
documentation in the [base image] for more information about the default
database connection configuration.

Use the `DB_*` settings from the [base image] for the default site's database.
`DB_NAME` and `DB_USER` default to `drupal_default`; `DB_PASSWORD` defaults to
`password`. Use `DB_*` directly; the `DRUPAL_DEFAULT_DB_*` aliases have been
removed. `DRUPAL_SITE_{SITE}_DB_*` settings remain site-specific; connection
settings inherit from `DB_*`, while names and users default to `drupal_{SITE}`. See the [migration guide](../../docs/environment-variables/README.md).

Database setup updates existing users' passwords as well as creating missing
accounts. Downstream install hooks must call `create_database` on every startup,
before checking whether Drupal is already installed (as the test image does).
Recreate the container after changing a mounted password secret.

### JWT Settings

[Drupal] is expected to make use of JWT for authentication. Please see the
documentation in the [base image] for more information.

The public/private key pair used here should be the same key as is used in the
`milliner` and `fcrepo` containers.

### Default Site

| Environment Variable            | Default                 | Description                                        |
| :------------------------------ | :---------------------- | :------------------------------------------------- |
| DRUPAL_DEFAULT_ACCOUNT_EMAIL    | webmaster@localhost.com | The email to use for the admin account             |
| DRUPAL_DEFAULT_ACCOUNT_NAME     | admin                   | The Drupal administrator user                      |
| DRUPAL_DEFAULT_ACCOUNT_PASSWORD | password                | The Drupal administrator user password             |
| DB_NAME                          | drupal_default          | The name of the sites database                     |
| DB_PASSWORD                      | password                | The database users password                        |
| DB_USER                          | drupal_default          | The database user used by the site                 |
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
