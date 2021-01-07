# Handle.net

Docker image for [Handle] version 9.3.0.

Please refer to the [Handle Documentation] for more in-depth information.

As a quick example this will bring up an instance of [Handle], and allow you
to view on <http://localhost:8000/>.

```bash
docker build -t islandora/handle .
docker run --rm -ti -p 8000:8000 islandora/handle
```

## Dependencies

Requires `islandora/java` docker image to build. Please refer to the
[Java Image README](https://github.com/Islandora-Devops/isle-buildkit/blob/main/java/README.md) for additional information.

## Volumes

| Path  | Description                                                                                         |
| :---- | :-------------------------------------------------------------------------------------------------- |
|  |       |

## Settings

| Environment Variable           | Etcd Key                        | Default                           | Description |
| :----------------------------- | :------------------------------ | :-------------------------------- | :---------- |
| HANDLE_DB_HOST                 | /handle/db/host                 | mariadb                           |             |
| HANDLE_DB_NAME                 | /handle/db/name                 | handle                            |             |
| HANDLE_DB_PASSWORD             | /handle/db/password             | password                          |             |
| HANDLE_DB_PORT                 | /handle/db/port                 | 3306                              |             |
| HANDLE_DB_ROOT_PASSWORD        | /handle/db/root/password        | password                          |             |
| HANDLE_DB_ROOT_USER            | /handle/db/root/user            | root                              |             |
| HANDLE_DB_USER                 | /handle/db/user                 | handle                            |             |
| HANDLE_DB_READONLY             | /handle/db/readonly             | no                                |             |
| HANDLE_STORAGE_TYPE            | /handle/storage/type            | bdbje                             | can be 'sql'|
| HANDLE_PERSISTENCE_TYPE        | /handle/persistence/type        | mysql                             |             |
| HANDLE_PREFIX                  | /handle/prefix                  | 200                               |             |
| HANDLE_CASESENSITIVE           | /handle/casesensitive           | no                                |             |
| HANDLE_ADMINFULLACCESS         | /handle/adminfullaccess         | yes                               |             |
| HANDLE_MAXAUTHTIME             | /handle/maxauthtime             | 60000                             |             |
| HANDLE_SERVERID                | /handle/serverid                | 1                                 |             |
| HANDLE_MAXSESSIONTIME          | /handle/maxsessiontime          | 86400000                          |             |
| HANDLE_ADMIN_PRIVATE_KEY_PEM   | /handle/admin/private/key/pem   |                                   |             | 
| HANDLE_ADMIN_PUBLIC_KEY_PEM    | /handle/admin/public/key/pem    |                                   |             | 
| HANDLE_PRIVATE_KEY_PEM         | /handle/private/key/pem         |                                   |             | 
| HANDLE_PUBLIC_KEY_PEM          | /handle/public/key/pem          |                                   |             | 


[Handle Documentation]: https://www.handle.net/tech_manual/HN_Tech_Manual_9.pdf
[Handle]: https://handle.net/
