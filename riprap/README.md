# Riprap

Docker image for [Riprap] (**unreleased version**) micro-service.

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

| Environment Variable        | Confd Key                    | Default                          | Description                                                                                                                           |
| :-------------------------- | :--------------------------- | :------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------ |
| RIPRAP_APP_ENV              | /riprap/app/env              | dev                              | Only 'dev' is supported at this time                                                                                                  |
| RIPRAP_APP_SECRET           | /riprap/app/secret           | f58c87e1d737c4422b45ba4310abede6 | This is a string that should be unique to your application and it's commonly used to add more entropy to security related operations. |
| RIPRAP_CROND_ENABLE_SERVICE | /riprap/crond/enable/service | true                             | Enable / disable crond service                                                                                                        |
| RIPRAP_CROND_LOG_LEVEL      | /riprap/crond/log/level      | 8                                | The log level for crond                                                                                                               |
| RIPRAP_CROND_SCHEDULE       | /riprap/crond/schedule       | 0 0 1 * *                        | The schedule for running check_fixity command, default is once a month                                                                |
| RIPRAP_LOG_LEVEL            | /riprap/log/level            | debug                            | Log level. Possible Values: debug, info, notice, warning, error, critical, alert, emergency, none                                     |
| RIPRAP_MAILER_URL           | /riprap/mailer/url           | null://localhost                 |                                                                                                                                       |
| RIPRAP_TRUSTED_HOSTS        | /riprap/trusted/hosts        |                                  |                                                                                                                                       |
| RIPRAP_TRUSTED_PROXIES      | /riprap/trusted/proxies      |                                  |                                                                                                                                       |

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

| Environment Variable                                 | Confd Key                                             | Default                                                                                                                               | Description                                                                                                                                                  |
| :--------------------------------------------------- | :---------------------------------------------------- | :------------------------------------------------------------------------------------------------------------------------------------ | :----------------------------------------------------------------------------------------------------------------------------------------------------------- |
| RIPRAP_CONFIG_DIGEST_COMMAND                         | /riprap/config/digest/command                         | /usr/bin/sha1sum                                                                                                                      |                                                                                                                                                              |
| RIPRAP_CONFIG_DRUPAL_BASEURL                         | /riprap/config/drupal/baseurl                         | https://islandora.traefik.me                                                                                                          |                                                                                                                                                              |
| RIPRAP_CONFIG_DRUPAL_CONTENT_TYPES                   | /riprap/config/drupal/content/types                   | ['islandora_object']                                                                                                                  |                                                                                                                                                              |
| RIPRAP_CONFIG_DRUPAL_FILE_FIELDNAMES                 | /riprap/config/drupal/file/fieldnames                 | ['field_media_audio', 'field_media_document', 'field_edited_text', 'field_media_file', 'field_media_image', 'field_media_video_file'] |                                                                                                                                                              |
| RIPRAP_CONFIG_DRUPAL_MEDIA_AUTH                      | /riprap/config/drupal/media/auth                      | ['admin', 'islandora']                                                                                                                |                                                                                                                                                              |
| RIPRAP_CONFIG_DRUPAL_MEDIA_TAGS                      | /riprap/config/drupal/media/tags                      | []                                                                                                                                    | e.g. ['/taxonomy/term/15']                                                                                                                                   |
| RIPRAP_CONFIG_DRUPAL_PASSWORD                        | /riprap/config/drupal/password                        | password                                                                                                                              |                                                                                                                                                              |
| RIPRAP_CONFIG_DRUPAL_USER                            | /riprap/config/drupal/user                            | admin                                                                                                                                 |                                                                                                                                                              |
| RIPRAP_CONFIG_EMAIL_FROM                             | /riprap/config/email/from                             |                                                                                                                                       |                                                                                                                                                              |
| RIPRAP_CONFIG_EMAIL_TO                               | /riprap/config/email/to                               |                                                                                                                                       |                                                                                                                                                              |
| RIPRAP_CONFIG_FAILURES_LOG_PATH                      | /riprap/config/failures/log/path                      | var/riprap_failed_events.log                                                                                                          | Absolute or relative to the Riprap application directory                                                                                                     |
| RIPRAP_CONFIG_FEDORAAPI_DIGEST_HEADER_LEADER_PATTERN | /riprap/config/fedoraapi/digest/header/leader/pattern | "^.+="                                                                                                                                | var/riprap_failed_events.log                                                                                                                                 |
| RIPRAP_CONFIG_FEDORAAPI_METHOD                       | /riprap/config/fedoraapi/method                       | HEAD                                                                                                                                  |                                                                                                                                                              |
| RIPRAP_CONFIG_FIXITY_ALGORITHM                       | /riprap/config/fixity/algorithm                       | sha1                                                                                                                                  | One of 'md5', 'sha1', or 'sha256'                                                                                                                            |
| RIPRAP_CONFIG_GEMINI_AUTH_HEADER                     | /riprap/config/gemini/auth/header                     | "Bearer islandora"                                                                                                                    |                                                                                                                                                              |
| RIPRAP_CONFIG_GEMINI_ENDPOINT                        | /riprap/config/gemini/endpoint                        | http://gemini:8000                                                                                                                    |                                                                                                                                                              |
| RIPRAP_CONFIG_JSONAPI_AUTHORIZATION_HEADERS          | /riprap/config/jsonapi/authorization/headers          |                                                                                                                                       | e.g. ['Authorization: Basic YWRtaW46aXNsYW5kb3Jh']                                                                                                           |
| RIPRAP_CONFIG_JSONAPI_PAGER_DATA_FILE_PATH           | /riprap/config/jsonapi/pager/data/file/path           | var/fetchresourcelist.from.drupal.pager.txt                                                                                           | Absolute or relative to the Riprap application directory                                                                                                     |
| RIPRAP_CONFIG_JSONAPI_PAGE_SIZE                      | /riprap/config/jsonapi/page/size                      | 50                                                                                                                                    |                                                                                                                                                              |
| RIPRAP_CONFIG_MAX_RESOURCES                          | /riprap/config/max/resources                          | 1000                                                                                                                                  | Must be a multiple of RIPRAP_CONFIG_JSONAPI_PAGE_SIZE                                                                                                        |
| RIPRAP_CONFIG_OUTPUT_CSV_PATH                        | /riprap/config/output/csv/path                        | var/riprap_events.csv                                                                                                                 |                                                                                                                                                              |
| RIPRAP_CONFIG_PLUGINS_FETCHDIGEST                    | /riprap/config/plugins/fetchdigest                    | PluginFetchDigestFromShell                                                                                                            | Either "PluginFetchDigestFromDrupal", "PluginFetchDigestFromFedoraAPI", or "PluginFetchDigestFromShell"                                                      |
| RIPRAP_CONFIG_PLUGINS_FETCHRESOURCELIST              | /riprap/config/plugins/fetchresourcelist              | ['PluginFetchResourceListFromFile']                                                                                                   | Either "PluginFetchResourceListFromDrupal", "PluginFetchResourceListFromDrupalView", "PluginFetchResourceListFromFile", or "PluginFetchResourceListFromGlob" |
| RIPRAP_CONFIG_PLUGINS_PERSIST                        | /riprap/config/plugins/persist                        | PluginPersistToDatabase                                                                                                               | Either "PluginPersistToCsv" or "PluginPersistToDatabase"                                                                                                     |
| RIPRAP_CONFIG_PLUGINS_POSTCHECK                      | /riprap/config/plugins/postcheck                      | ['PluginPostCheckCopyFailures']                                                                                                       | Either "PluginPostCheckCopyFailures", "PluginPostCheckMailFailures", "PluginPostCheckMigrateFedora3AuditLog", "PluginPostCheckSayHello", or unspecified      |
| RIPRAP_CONFIG_RESOURCE_DIR_PATHS                     | /riprap/config/resource/dir/paths                     |                                                                                                                                       | e.g. ['resources/filesystemexample/resourcefiles']                                                                                                           |
| RIPRAP_CONFIG_RESOURCE_LIST_PATH                     | /riprap/config/resource/list/path                     | ['resources/csv_file_list.csv']                                                                                                       |                                                                                                                                                              |
| RIPRAP_CONFIG_THIN                                   | /riprap/config/thin                                   | false                                                                                                                                 |                                                                                                                                                              |
| RIPRAP_CONFIG_USE_FEDORA_URLS                        | /riprap/config/use/fedora/urls                        | true                                                                                                                                  |                                                                                                                                                              |
| RIPRAP_CONFIG_VIEWS_PAGER_DATA_FILE_PATH             | /riprap/config/views/pager/data/file/path             | var/fetchresourcelist.from.drupal.pager.txt                                                                                           |                                                                                                                                                              |

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

| Environment Variable | Confd Key           | Default  | Description                                                   |
| :------------------- | :------------------ | :------- | :------------------------------------------------------------ |
| RIPRAP_DB_DRIVER     | /riprap/db/driver   | sqlite   | The database driver either 'sqlite', 'mysql', or 'postgresql' |
| RIPRAP_DB_NAME       | /riprap/db/name     | riprap   | The name of the database                                      |
| RIPRAP_DB_PASSWORD   | /riprap/db/password | password | The database users password                                   |
| RIPRAP_DB_USER       | /riprap/db/user     | riprap   | The database user                                             |

[base image]: ../base/README.md
[Riprap Documentation]: https://github.com/mjordan/riprap#riprap
[Riprap Plugin Documentation]: https://github.com/mjordan/riprap/blob/master/docs/plugins.md
[Riprap Plugin Overview]: https://github.com/mjordan/riprap#plugins
[Riprap Plugins]: https://github.com/mjordan/riprap/tree/master/src/Plugin
[Riprap]: https://github.com/mjordan/riprap
