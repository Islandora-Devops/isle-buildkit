# Riprap

Docker image for [Riprap] (**unreleased version**) micro-service.

Built from [Islandora-DevOps/isle-buildkit riprap](https://github.com/Islandora-DevOps/isle-buildkit/tree/main/riprap)

Please refer to the [Riprap Documentation] for more in-depth information.

## Dependencies

Requires `islandora/nginx` docker image to build. Please refer to the
[Nginx Image README](../nginx/README.md) for additional information including
additional settings, volumes, ports, etc.

Additionally you can run with different database backends, by default it will
use the bundled SQLite backend which requires no additional configuration.
However if you wish to use a MySQL or PostgreSQL backend please refer to the
[MariaDB Image README](../mariadb/README.md) and
[PostgreSQL Image README](../postgresql/README.md) respectively, and change
`RIPRAP_DB_DRIVER` to your selected backend, along with any other
relevant settings.

## Ports

| Port | Description |
| :--- | :---------- |
| 8000 | HTTP        |

## Volumes

| Path                           | Description                            |
| :----------------------------- | :------------------------------------- |
| /var/www/riprap/src/Migrations | Generated Migrations                   |
| /var/www/riprap/var            | SQLite Database / Cache files location |

## Settings

### Confd Settings

| Environment Variable        | Default                          | Description                                                                                                                           |
| :-------------------------- | :------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------ |
| RIPRAP_APP_ENV              | dev                              | Only 'dev' is supported at this time                                                                                                  |
| RIPRAP_APP_SECRET           | f58c87e1d737c4422b45ba4310abede6 | This is a string that should be unique to your application and it's commonly used to add more entropy to security related operations. |
| RIPRAP_CROND_ENABLE_SERVICE | true                             | Enable / disable crond service                                                                                                        |
| RIPRAP_CROND_LOG_LEVEL      | 8                                | The log level for crond                                                                                                               |
| RIPRAP_CROND_SCHEDULE       | 0 0 1 * *                        | The schedule for running check_fixity command, default is once a month                                                                |
| RIPRAP_LOG_LEVEL            | info                             | Log level. Possible Values: debug, info, notice, warning, error, critical, alert, emergency, none                                     |
| RIPRAP_MAILER_URL           | null://localhost                 |                                                                                                                                       |
| RIPRAP_TRUSTED_HOSTS        |                                  |                                                                                                                                       |
| RIPRAP_TRUSTED_PROXIES      |                                  |                                                                                                                                       |

You can generate your own secret using the following command:

```bash
cat /dev/urandom | base64 | head -c 32 && echo ""
```

What follows is configuration specific to the check fixity command. Not all
configurations are applicable in all situations, they are largely dependent on
which plugins you enable.

Please refer to the [Riprap Plugin Overview] and [Riprap Plugin Documentation]
for more in-depth information, as well as the [Riprap Plugins] themselves.

If starting out fresh its recommend to use
`PluginFetchResourceListFromDrupalView` rather than
`PluginFetchResourceListFromDrupal` which is currently in the process of being
deprecated.

| Environment Variable                                 | Default                                                                                                                               | Description                                                                                                                                                  |
| :--------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------ | :----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RIPRAP_CONFIG_DIGEST_COMMAND                         | /usr/bin/sha1sum                                                                                                                      |                                                                                                                                                              |
| RIPRAP_CONFIG_DRUPAL_BASEURL                         | https://islandora.traefik.me                                                                                                          |                                                                                                                                                              |
| RIPRAP_CONFIG_DRUPAL_CONTENT_TYPES                   | ['islandora_object']                                                                                                                  |                                                                                                                                                              |
| RIPRAP_CONFIG_DRUPAL_FILE_FIELDNAMES                 | ['field_media_audio', 'field_media_document', 'field_edited_text', 'field_media_file', 'field_media_image', 'field_media_video_file'] |                                                                                                                                                              |
| RIPRAP_CONFIG_DRUPAL_MEDIA_AUTH                      | ['admin', 'islandora']                                                                                                                |                                                                                                                                                              |
| RIPRAP_CONFIG_DRUPAL_MEDIA_TAGS                      | []                                                                                                                                    | e.g. ['/taxonomy/term/15']                                                                                                                                   |
| RIPRAP_CONFIG_DRUPAL_PASSWORD                        | password                                                                                                                              |                                                                                                                                                              |
| RIPRAP_CONFIG_DRUPAL_USER                            | admin                                                                                                                                 |                                                                                                                                                              |
| RIPRAP_CONFIG_EMAIL_FROM                             |                                                                                                                                       |                                                                                                                                                              |
| RIPRAP_CONFIG_EMAIL_TO                               |                                                                                                                                       |                                                                                                                                                              |
| RIPRAP_CONFIG_FAILURES_LOG_PATH                      | var/riprap_failed_events.log                                                                                                          | Absolute or relative to the Riprap application directory                                                                                                     |
| RIPRAP_CONFIG_FEDORAAPI_DIGEST_HEADER_LEADER_PATTERN | "^.+="                                                                                                                                | var/riprap_failed_events.log                                                                                                                                 |
| RIPRAP_CONFIG_FEDORAAPI_METHOD                       | HEAD                                                                                                                                  |                                                                                                                                                              |
| RIPRAP_CONFIG_FIXITY_ALGORITHM                       | sha1                                                                                                                                  | One of 'md5', 'sha1', or 'sha256'                                                                                                                            |
| RIPRAP_CONFIG_GEMINI_AUTH_HEADER                     | "Bearer islandora"                                                                                                                    |                                                                                                                                                              |
| RIPRAP_CONFIG_GEMINI_ENDPOINT                        | http://gemini:8000                                                                                                                    |                                                                                                                                                              |
| RIPRAP_CONFIG_JSONAPI_AUTHORIZATION_HEADERS          |                                                                                                                                       | e.g. ['Authorization: Basic YWRtaW46aXNsYW5kb3Jh']                                                                                                           |
| RIPRAP_CONFIG_JSONAPI_PAGER_DATA_FILE_PATH           | var/fetchresourcelist.from.drupal.pager.txt                                                                                           | Absolute or relative to the Riprap application directory                                                                                                     |
| RIPRAP_CONFIG_JSONAPI_PAGE_SIZE                      | 50                                                                                                                                    |                                                                                                                                                              |
| RIPRAP_CONFIG_MAX_RESOURCES                          | 1000                                                                                                                                  | Must be a multiple of RIPRAP_CONFIG_JSONAPI_PAGE_SIZE                                                                                                        |
| RIPRAP_CONFIG_OUTPUT_CSV_PATH                        | var/riprap_events.csv                                                                                                                 |                                                                                                                                                              |
| RIPRAP_CONFIG_PLUGINS_FETCHDIGEST                    | PluginFetchDigestFromShell                                                                                                            | Either "PluginFetchDigestFromDrupal", "PluginFetchDigestFromFedoraAPI", or "PluginFetchDigestFromShell"                                                      |
| RIPRAP_CONFIG_PLUGINS_FETCHRESOURCELIST              | ['PluginFetchResourceListFromFile']                                                                                                   | Either "PluginFetchResourceListFromDrupal", "PluginFetchResourceListFromDrupalView", "PluginFetchResourceListFromFile", or "PluginFetchResourceListFromGlob" |
| RIPRAP_CONFIG_PLUGINS_PERSIST                        | PluginPersistToDatabase                                                                                                               | Either "PluginPersistToCsv" or "PluginPersistToDatabase"                                                                                                     |
| RIPRAP_CONFIG_PLUGINS_POSTCHECK                      | ['PluginPostCheckCopyFailures']                                                                                                       | Either "PluginPostCheckCopyFailures", "PluginPostCheckMailFailures", "PluginPostCheckMigrateFedora3AuditLog", "PluginPostCheckSayHello", or unspecified      |
| RIPRAP_CONFIG_RESOURCE_DIR_PATHS                     |                                                                                                                                       | e.g. ['resources/filesystemexample/resourcefiles']                                                                                                           |
| RIPRAP_CONFIG_RESOURCE_LIST_PATH                     | ['resources/csv_file_list.csv']                                                                                                       |                                                                                                                                                              |
| RIPRAP_CONFIG_THIN                                   | false                                                                                                                                 |                                                                                                                                                              |
| RIPRAP_CONFIG_USE_FEDORA_URLS                        | true                                                                                                                                  |                                                                                                                                                              |
| RIPRAP_CONFIG_VIEWS_PAGER_DATA_FILE_PATH             | var/fetchresourcelist.from.drupal.pager.txt                                                                                           |                                                                                                                                                              |

> N.B. Configuration list was generated by searching for all instances of
> `$this->settings['some_setting']` in the riprap repository. When upgrading
> riprap commit be sure to check that the options for configuration have been
> updated appropriately along with their defaults.

### Database Settings

[Riprap] can optionally make use of different database backends. Please see
the documentation in the [base image] for more information about the default
database connection configuration.

Aside from `RIPRAP_DB_DRIVER`, the following settings are only used if
`RIPRAP_DB_DRIVER` is set to `mysql` or `postgresql`.

| Environment Variable | Default  | Description                                                   |
| :------------------- | :------- | :------------------------------------------------------------ |
| RIPRAP_DB_DRIVER     | sqlite   | The database driver either 'sqlite', 'mysql', or 'postgresql' |
| RIPRAP_DB_NAME       | riprap   | The name of the database                                      |
| RIPRAP_DB_PASSWORD   | password | The database users password                                   |
| RIPRAP_DB_USER       | riprap   | The database user                                             |

## Updating

You can change the commit used for riprap by modifying the build argument
`COMMIT` and `SHA256` in the `Dockerfile` shown as `XXXXXXXXXXXX` in the
following snippet:

```Dockerfile
ARG COMMIT=XXXXXXXXXXXX
#...
ARG SHA256=XXXXXXXXXXXX
```

You can generate the `SHA256` with the following commands:

```bash
COMMIT=$(cat riprap/Dockerfile | grep -o 'COMMIT=.*' | cut -f2 -d=)
FILE=$(cat riprap/Dockerfile | grep -o 'FILE=.*' | cut -f2 -d=)
URL=$(cat riprap/Dockerfile | grep -o 'URL=.*' | cut -f2 -d=)
FILE=$(eval "echo $FILE")
URL=$(eval "echo $URL")
wget --quiet "${URL}"
shasum -a 256 "${FILE}" | cut -f1 -d' '
rm "${FILE}"
```

When changing either the `riprap` version or when the version of `PHP` in the
`nginx` image this is based on changes you will also need to update the
`compose.lock` file.

```bash
# Build required base image.
make bake TARGET=nginx
# Build the layer before installation.
docker buildx build --target download \
  --tag islandora/riprap:download \
  --build-context nginx=docker-image://islandora/nginx:local ./riprap
# Update the lock file.
docker run --rm -ti \
  -v $(pwd)/riprap/rootfs/var/www/riprap/composer.lock:/var/www/riprap/composer.lock \
  --entrypoint ash islandora/riprap:download -c \
    "cd /var/www/riprap && composer update"
# Build the image with the updated composer.lock file.
make bake target=riprap
```

[base image]: ../base/README.md
[Riprap Documentation]: https://github.com/mjordan/riprap#riprap
[Riprap Plugin Documentation]: https://github.com/mjordan/riprap/blob/master/docs/plugins.md
[Riprap Plugin Overview]: https://github.com/mjordan/riprap#plugins
[Riprap Plugins]: https://github.com/mjordan/riprap/tree/master/src/Plugin
[Riprap]: https://github.com/mjordan/riprap
