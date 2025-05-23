# Cantaloupe

Docker image for [Cantaloupe] version 5.0.6.

Built from [Islandora-DevOps/isle-buildkit cantaloupe](https://github.com/Islandora-DevOps/isle-buildkit/tree/main/cantaloupe)

Please refer to the [Cantaloupe Documentation] for more in-depth information.

As a quick example this will bring up an instance of [Cantaloupe], and allow you
to view on <http://localhost:8182/cantaloupe/>.

```bash
docker run --rm -ti -p 8182:8182 islandora/cantaloupe
```

## Dependencies

Requires `islandora/java` docker image to build. Please refer to the
[Java Image README](../java/README.md) for additional information including
additional settings, volumes, ports, etc.

## Volumes

| Path  | Description          |
| :---- | :------------------- |
| /data | [Cantaloupe Caching] |

## Settings

| Environment Variable                                                                   | Default                                                          |
| :------------------------------------------------------------------------------------- | :--------------------------------------------------------------- |
| CANTALOUPE_AZURESTORAGECACHE_ACCOUNT_KEY                                               |                                                                  |
| CANTALOUPE_AZURESTORAGECACHE_ACCOUNT_NAME                                              |                                                                  |
| CANTALOUPE_AZURESTORAGECACHE_CONTAINER_NAME                                            |                                                                  |
| CANTALOUPE_AZURESTORAGECACHE_OBJECT_KEY_PREFIX                                         |                                                                  |
| CANTALOUPE_AZURESTORAGESOURCE_ACCOUNT_KEY                                              |                                                                  |
| CANTALOUPE_AZURESTORAGESOURCE_ACCOUNT_NAME                                             |                                                                  |
| CANTALOUPE_AZURESTORAGESOURCE_CHUNKING_CACHE_ENABLED                                   | "true"                                                           |
| CANTALOUPE_AZURESTORAGESOURCE_CHUNKING_CACHE_MAX_SIZE                                  | "5M"                                                             |
| CANTALOUPE_AZURESTORAGESOURCE_CHUNKING_CHUNK_SIZE                                      | "512K"                                                           |
| CANTALOUPE_AZURESTORAGESOURCE_CHUNKING_ENABLED                                         | "true"                                                           |
| CANTALOUPE_AZURESTORAGESOURCE_CONTAINER_NAME                                           |                                                                  |
| CANTALOUPE_AZURESTORAGESOURCE_LOOKUP_STRATEGY                                          | "BasicLookupStrategy"                                            |
| CANTALOUPE_BASE_URI                                                                    |                                                                  |
| CANTALOUPE_CACHE_CLIENT_ENABLED                                                        | "true"                                                           |
| CANTALOUPE_CACHE_CLIENT_MAX_AGE                                                        | "2592000"                                                        |
| CANTALOUPE_CACHE_CLIENT_MUST_REVALIDATE                                                | "false"                                                          |
| CANTALOUPE_CACHE_CLIENT_NO_CACHE                                                       | "false"                                                          |
| CANTALOUPE_CACHE_CLIENT_NO_STORE                                                       | "false"                                                          |
| CANTALOUPE_CACHE_CLIENT_NO_TRANSFORM                                                   | "true"                                                           |
| CANTALOUPE_CACHE_CLIENT_PRIVATE                                                        | "false"                                                          |
| CANTALOUPE_CACHE_CLIENT_PROXY_REVALIDATE                                               | "false"                                                          |
| CANTALOUPE_CACHE_CLIENT_PUBLIC                                                         | "true"                                                           |
| CANTALOUPE_CACHE_CLIENT_SHARED_MAX_AGE                                                 |                                                                  |
| CANTALOUPE_CACHE_SERVER_DERIVATIVE_ENABLED                                             | "false"                                                          |
| CANTALOUPE_CACHE_SERVER_DERIVATIVE_TTL_SECONDS                                         | "2592000"                                                        |
| CANTALOUPE_CACHE_SERVER_DERIVATIVE                                                     |                                                                  |
| CANTALOUPE_CACHE_SERVER_INFO_ENABLED                                                   | "true"                                                           |
| CANTALOUPE_CACHE_SERVER_PURGE_MISSING                                                  | "false"                                                          |
| CANTALOUPE_CACHE_SERVER_RESOLVE_FIRST                                                  | "false"                                                          |
| CANTALOUPE_CACHE_SERVER_SOURCE_TTL_SECONDS                                             | "2592000"                                                        |
| CANTALOUPE_CACHE_SERVER_SOURCE                                                         | "FilesystemCache"                                                |
| CANTALOUPE_CACHE_SERVER_WORKER_ENABLED                                                 | "false"                                                          |
| CANTALOUPE_CACHE_SERVER_WORKER_INTERVAL                                                | "86400"                                                          |
| CANTALOUPE_DELEGATE_SCRIPT_ENABLED                                                     | "false"                                                          |
| CANTALOUPE_DELEGATE_SCRIPT_PATHNAME                                                    | "delegates.rb"                                                   |
| CANTALOUPE_ENDPOINT_ADMIN_ENABLED                                                      | "false"                                                          |
| CANTALOUPE_ENDPOINT_ADMIN_SECRET                                                       |                                                                  |
| CANTALOUPE_ENDPOINT_ADMIN_USERNAME                                                     | "admin"                                                          |
| CANTALOUPE_ENDPOINT_API_ENABLED                                                        | "false"                                                          |
| CANTALOUPE_ENDPOINT_API_SECRET                                                         | random 16 char string                                            |
| CANTALOUPE_ENDPOINT_API_USERNAME                                                       | "islandora"                                                      |
| CANTALOUPE_ENDPOINT_HEALTH_ENABLED                                                     | "true"                                                           |
| CANTALOUPE_ENDPOINT_HEALTH_DEPENDENCY_CHECK                                            | "false"                                                          |
| CANTALOUPE_ENDPOINT_IIIF_1_ENABLED                                                     | "false"                                                          |
| CANTALOUPE_ENDPOINT_IIIF_2_ENABLED                                                     | "true"                                                           |
| CANTALOUPE_ENDPOINT_IIIF_3_ENABLED                                                     | "true"                                                           |
| CANTALOUPE_ENDPOINT_IIIF_MIN_SIZE                                                      | "64"                                                             |
| CANTALOUPE_ENDPOINT_IIIF_MIN_TILE_SIZE                                                 | "512"                                                            |
| CANTALOUPE_ENDPOINT_IIIF_RESTRICT_TO_SIZES                                             | "false"                                                          |
| CANTALOUPE_FFMPEGPROCESSOR_PATH_TO_BINARIES                                            |                                                                  |
| CANTALOUPE_FILESYSTEMCACHE_DIR_DEPTH                                                   | "3"                                                              |
| CANTALOUPE_FILESYSTEMCACHE_DIR_NAME_LENGTH                                             | "2"                                                              |
| CANTALOUPE_FILESYSTEMCACHE_PATHNAME                                                    | "/data"                                                          |
| CANTALOUPE_FILESYSTEMSOURCE_BASICLOOKUPSTRATEGY_PATH_PREFIX                            | "/var/www/drupal/web/"                                           |
| CANTALOUPE_FILESYSTEMSOURCE_BASICLOOKUPSTRATEGY_PATH_SUFFIX                            |                                                                  |
| CANTALOUPE_FILESYSTEMSOURCE_LOOKUP_STRATEGY                                            | "BasicLookupStrategy"                                            |
| CANTALOUPE_GROKPROCESSOR_PATH_TO_BINARIES                                              |                                                                  |
| CANTALOUPE_HEAP_MIN                                                                    | "3G"                                                             |
| CANTALOUPE_HEAP_MAX                                                                    | "5G"                                                             |
| CANTALOUPE_HEAPCACHE_PERSIST_FILESYSTEM_PATHNAME                                       | "/data/heap.cache"                                               |
| CANTALOUPE_HEAPCACHE_PERSIST                                                           | "false"                                                          |
| CANTALOUPE_HEAPCACHE_TARGET_SIZE                                                       | "2G"                                                             |
| CANTALOUPE_HTTP_ACCEPT_QUEUE_LIMIT                                                     |                                                                  |
| CANTALOUPE_HTTP_ENABLED                                                                | "true"                                                           |
| CANTALOUPE_HTTP_HOST                                                                   | "0.0.0.0"                                                        |
| CANTALOUPE_HTTP_MAX_THREADS                                                            |                                                                  |
| CANTALOUPE_HTTP_MIN_THREADS                                                            |                                                                  |
| CANTALOUPE_HTTP_PORT                                                                   | "8182"                                                           |
| CANTALOUPE_HTTPS_ENABLED                                                               | "false"                                                          |
| CANTALOUPE_HTTPS_HOST                                                                  | "0.0.0.0"                                                        |
| CANTALOUPE_HTTPS_KEY_PASSWORD                                                          | "password"                                                       |
| CANTALOUPE_HTTPS_KEY_STORE_PASSWORD                                                    | "password"                                                       |
| CANTALOUPE_HTTPS_KEY_STORE_PATH                                                        | "/path/to/keystore.jks"                                          |
| CANTALOUPE_HTTPS_KEY_STORE_TYPE                                                        | "JKS"                                                            |
| CANTALOUPE_HTTPS_PORT                                                                  | "8183"                                                           |
| CANTALOUPE_HTTPSOURCE_ALLOW_INSECURE                                                   | "false"                                                          |
| CANTALOUPE_HTTPSOURCE_BASICLOOKUPSTRATEGY_AUTH_BASIC_SECRET                            |                                                                  |
| CANTALOUPE_HTTPSOURCE_BASICLOOKUPSTRATEGY_AUTH_BASIC_USERNAME                          |                                                                  |
| CANTALOUPE_HTTPSOURCE_BASICLOOKUPSTRATEGY_URL_PREFIX                                   |                                                                  |
| CANTALOUPE_HTTPSOURCE_BASICLOOKUPSTRATEGY_URL_SUFFIX                                   |                                                                  |
| CANTALOUPE_HTTPSOURCE_CHUNKING_CACHE_ENABLED                                           | "true"                                                           |
| CANTALOUPE_HTTPSOURCE_CHUNKING_CACHE_MAX_SIZE                                          | "5M"                                                             |
| CANTALOUPE_HTTPSOURCE_CHUNKING_CHUNK_SIZE                                              | "512K"                                                           |
| CANTALOUPE_HTTPSOURCE_CHUNKING_ENABLED                                                 | "true"                                                           |
| CANTALOUPE_HTTPSOURCE_LOOKUP_STRATEGY                                                  | "BasicLookupStrategy"                                            |
| CANTALOUPE_HTTPSOURCE_REQUEST_TIMEOUT                                                  |                                                                  |
| CANTALOUPE_JAVA_OPTS                                                                   |                                                                  |
| CANTALOUPE_JDBCCACHE_CONNECTION_TIMEOUT                                                | "10"                                                             |
| CANTALOUPE_JDBCCACHE_DERIVATIVE_IMAGE_TABLE                                            | "derivative_cache"                                               |
| CANTALOUPE_JDBCCACHE_INFO_TABLE                                                        | "info_cache"                                                     |
| CANTALOUPE_JDBCCACHE_PASSWORD                                                          | "password"                                                       |
| CANTALOUPE_JDBCCACHE_URL                                                               | "jdbc:postgresql://database:5432/cantaloupe"                     |
| CANTALOUPE_JDBCCACHE_USER                                                              | "admin"                                                          |
| CANTALOUPE_JDBCSOURCE_CONNECTION_TIMEOUT                                               | "10"                                                             |
| CANTALOUPE_JDBCSOURCE_PASSWORD                                                         | "password"                                                       |
| CANTALOUPE_JDBCSOURCE_URL                                                              | "jdbc:postgresql://database:5432/cantaloupe"                     |
| CANTALOUPE_JDBCSOURCE_USER                                                             | "admin"                                                          |
| CANTALOUPE_LOG_ACCESS_CONSOLEAPPENDER_ENABLED                                          | "true"                                                           |
| CANTALOUPE_LOG_ACCESS_FILEAPPENDER_ENABLED                                             | "false"                                                          |
| CANTALOUPE_LOG_ACCESS_FILEAPPENDER_PATHNAME                                            | "/opt/cantaloupe/logs/cantaloupe.access.log"                     |
| CANTALOUPE_LOG_ACCESS_ROLLINGFILEAPPENDER_ENABLED                                      | "false"                                                          |
| CANTALOUPE_LOG_ACCESS_ROLLINGFILEAPPENDER_PATHNAME                                     | "/opt/cantaloupe/logs/cantaloupe.access.log"                     |
| CANTALOUPE_LOG_ACCESS_ROLLINGFILEAPPENDER_POLICY                                       | "TimeBasedRollingPolicy"                                         |
| CANTALOUPE_LOG_ACCESS_ROLLINGFILEAPPENDER_TIMEBASEDROLLINGPOLICY_FILENAME_PATTERN      | "/opt/cantaloupe/logs/cantaloupe.access-%d{yyyy-MM-dd}.log"      |
| CANTALOUPE_LOG_ACCESS_ROLLINGFILEAPPENDER_TIMEBASEDROLLINGPOLICY_MAX_HISTORY           | "30"                                                             |
| CANTALOUPE_LOG_ACCESS_SYSLOGAPPENDER_ENABLED                                           | "false"                                                          |
| CANTALOUPE_LOG_ACCESS_SYSLOGAPPENDER_FACILITY                                          | "LOCAL0"                                                         |
| CANTALOUPE_LOG_ACCESS_SYSLOGAPPENDER_HOST                                              |                                                                  |
| CANTALOUPE_LOG_ACCESS_SYSLOGAPPENDER_PORT                                              | "514"                                                            |
| CANTALOUPE_LOG_APPLICATION_CONSOLEAPPENDER_ENABLED                                     | "true"                                                           |
| CANTALOUPE_LOG_APPLICATION_CONSOLEAPPENDER_LOGSTASH_ENABLED                            | "false"                                                          |
| CANTALOUPE_LOG_APPLICATION_FILEAPPENDER_ENABLED                                        | "false"                                                          |
| CANTALOUPE_LOG_APPLICATION_FILEAPPENDER_LOGSTASH_ENABLED                               | "false"                                                          |
| CANTALOUPE_LOG_APPLICATION_FILEAPPENDER_PATHNAME                                       | "/opt/cantaloupe/logs/cantaloupe.application.log"                |
| CANTALOUPE_LOG_APPLICATION_LEVEL                                                       | "debug"                                                          |
| CANTALOUPE_LOG_APPLICATION_ROLLINGFILEAPPENDER_ENABLED                                 | "false"                                                          |
| CANTALOUPE_LOG_APPLICATION_ROLLINGFILEAPPENDER_LOGSTASH_ENABLED                        | "false"                                                          |
| CANTALOUPE_LOG_APPLICATION_ROLLINGFILEAPPENDER_PATHNAME                                | "/opt/cantaloupe/logs/cantaloupe.application.log"                |
| CANTALOUPE_LOG_APPLICATION_ROLLINGFILEAPPENDER_POLICY                                  | "TimeBasedRollingPolicy"                                         |
| CANTALOUPE_LOG_APPLICATION_ROLLINGFILEAPPENDER_TIMEBASEDROLLINGPOLICY_FILENAME_PATTERN | "/opt/cantaloupe/logs/cantaloupe.application-%d{yyyy-MM-dd}.log" |
| CANTALOUPE_LOG_APPLICATION_ROLLINGFILEAPPENDER_TIMEBASEDROLLINGPOLICY_MAX_HISTORY      | "30"                                                             |
| CANTALOUPE_LOG_APPLICATION_SYSLOGAPPENDER_ENABLED                                      | "false"                                                          |
| CANTALOUPE_LOG_APPLICATION_SYSLOGAPPENDER_FACILITY                                     | "LOCAL0"                                                         |
| CANTALOUPE_LOG_APPLICATION_SYSLOGAPPENDER_HOST                                         |                                                                  |
| CANTALOUPE_LOG_APPLICATION_SYSLOGAPPENDER_PORT                                         | "514"                                                            |
| CANTALOUPE_LOG_ERROR_FILEAPPENDER_ENABLED                                              | "false"                                                          |
| CANTALOUPE_LOG_ERROR_FILEAPPENDER_LOGSTASH_ENABLED                                     | "false"                                                          |
| CANTALOUPE_LOG_ERROR_FILEAPPENDER_PATHNAME                                             | "/opt/cantaloupe/logs/cantaloupe.error.log"                      |
| CANTALOUPE_LOG_ERROR_RESPONSES                                                         | "false"                                                          |
| CANTALOUPE_LOG_ERROR_ROLLINGFILEAPPENDER_ENABLED                                       | "false"                                                          |
| CANTALOUPE_LOG_ERROR_ROLLINGFILEAPPENDER_LOGSTASH_ENABLED                              | "false"                                                          |
| CANTALOUPE_LOG_ERROR_ROLLINGFILEAPPENDER_PATHNAME                                      | "/opt/cantaloupe/logs/cantaloupe.error.log"                      |
| CANTALOUPE_LOG_ERROR_ROLLINGFILEAPPENDER_POLICY                                        | "TimeBasedRollingPolicy"                                         |
| CANTALOUPE_LOG_ERROR_ROLLINGFILEAPPENDER_TIMEBASEDROLLINGPOLICY_FILENAME_PATTERN       | "/opt/cantaloupe/logs/cantaloupe.error-%d{yyyy-MM-dd}.log"       |
| CANTALOUPE_LOG_ERROR_ROLLINGFILEAPPENDER_TIMEBASEDROLLINGPOLICY_MAX_HISTORY            | "30"                                                             |
| CANTALOUPE_MAX_PIXELS                                                                  | "10000000"                                                       |
| CANTALOUPE_MAX_SCALE                                                                   | "1.0"                                                            |
| CANTALOUPE_META_IDENTIFIER_TRANSFORMER_STANDARDMETAIDENTIFIERTRANSFORMER_DELIMITER     | ";"                                                              |
| CANTALOUPE_META_IDENTIFIER_TRANSFORMER                                                 | "StandardMetaIdentifierTransformer"                              |
| CANTALOUPE_OPENJPEGPROCESSOR_PATH_TO_BINARIES                                          |                                                                  |
| CANTALOUPE_OVERLAYS_BASICSTRATEGY_ENABLED                                              | "false"                                                          |
| CANTALOUPE_OVERLAYS_BASICSTRATEGY_IMAGE                                                | "/path/to/overlay_png"                                           |
| CANTALOUPE_OVERLAYS_BASICSTRATEGY_INSET                                                | "10"                                                             |
| CANTALOUPE_OVERLAYS_BASICSTRATEGY_OUTPUT_HEIGHT_THRESHOLD                              | "300"                                                            |
| CANTALOUPE_OVERLAYS_BASICSTRATEGY_OUTPUT_WIDTH_THRESHOLD                               | "400"                                                            |
| CANTALOUPE_OVERLAYS_BASICSTRATEGY_POSITION                                             | "bottom right"                                                   |
| CANTALOUPE_OVERLAYS_BASICSTRATEGY_STRING_BACKGROUND_COLOR                              | "rgba(0, 0, 0, 100)"                                             |
| CANTALOUPE_OVERLAYS_BASICSTRATEGY_STRING_COLOR                                         | "white"                                                          |
| CANTALOUPE_OVERLAYS_BASICSTRATEGY_STRING_FONT_MIN_SIZE                                 | "18"                                                             |
| CANTALOUPE_OVERLAYS_BASICSTRATEGY_STRING_FONT_SIZE                                     | "24"                                                             |
| CANTALOUPE_OVERLAYS_BASICSTRATEGY_STRING_FONT_WEIGHT                                   | "1.0"                                                            |
| CANTALOUPE_OVERLAYS_BASICSTRATEGY_STRING_FONT                                          | "Helvetica"                                                      |
| CANTALOUPE_OVERLAYS_BASICSTRATEGY_STRING_GLYPH_SPACING                                 | "0.02"                                                           |
| CANTALOUPE_OVERLAYS_BASICSTRATEGY_STRING_STROKE_COLOR                                  | "black"                                                          |
| CANTALOUPE_OVERLAYS_BASICSTRATEGY_STRING_STROKE_WIDTH                                  | "1"                                                              |
| CANTALOUPE_OVERLAYS_BASICSTRATEGY_STRING                                               | "Copyright. All rights reserved."                                |
| CANTALOUPE_OVERLAYS_BASICSTRATEGY_TYPE                                                 | "image"                                                          |
| CANTALOUPE_OVERLAYS_STRATEGY                                                           | "BasicStrategy"                                                  |
| CANTALOUPE_PRINT_STACK_TRACE_ON_ERROR_PAGES                                            | "true"                                                           |
| CANTALOUPE_PROCESSOR_BACKGROUND_COLOR                                                  | "white"                                                          |
| CANTALOUPE_PROCESSOR_DOWNSCALE_FILTER                                                  | "bicubic"                                                        |
| CANTALOUPE_PROCESSOR_DOWNSCALE_LINEAR                                                  | "false"                                                          |
| CANTALOUPE_PROCESSOR_DPI                                                               | "150"                                                            |
| CANTALOUPE_PROCESSOR_FALLBACK_RETRIEVAL_STRATEGY                                       | "DownloadStrategy"                                               |
| CANTALOUPE_PROCESSOR_IMAGEIO_BMP_READER                                                |                                                                  |
| CANTALOUPE_PROCESSOR_IMAGEIO_GIF_READER                                                |                                                                  |
| CANTALOUPE_PROCESSOR_IMAGEIO_GIF_WRITER                                                |                                                                  |
| CANTALOUPE_PROCESSOR_IMAGEIO_JPG_READER                                                |                                                                  |
| CANTALOUPE_PROCESSOR_IMAGEIO_JPG_WRITER                                                |                                                                  |
| CANTALOUPE_PROCESSOR_IMAGEIO_PNG_READER                                                |                                                                  |
| CANTALOUPE_PROCESSOR_IMAGEIO_PNG_WRITER                                                |                                                                  |
| CANTALOUPE_PROCESSOR_IMAGEIO_TIF_READER                                                |                                                                  |
| CANTALOUPE_PROCESSOR_IMAGEIO_TIF_WRITER                                                |                                                                  |
| CANTALOUPE_PROCESSOR_IMAGEIO_XPM_READER                                                |                                                                  |
| CANTALOUPE_PROCESSOR_JPG_PROGRESSIVE                                                   | "true"                                                           |
| CANTALOUPE_PROCESSOR_JPG_QUALITY                                                       | "80"                                                             |
| CANTALOUPE_PROCESSOR_MANUALSELECTIONSTRATEGY_AVI                                       | "FfmpegProcessor"                                                |
| CANTALOUPE_PROCESSOR_MANUALSELECTIONSTRATEGY_BMP                                       | "Java2dProcessor"                                                |
| CANTALOUPE_PROCESSOR_MANUALSELECTIONSTRATEGY_FALLBACK                                  | "Java2dProcessor"                                                |
| CANTALOUPE_PROCESSOR_MANUALSELECTIONSTRATEGY_FLV                                       | "FfmpegProcessor"                                                |
| CANTALOUPE_PROCESSOR_MANUALSELECTIONSTRATEGY_GIF                                       | "Java2dProcessor"                                                |
| CANTALOUPE_PROCESSOR_MANUALSELECTIONSTRATEGY_JP2                                       | "GrokProcessor"                                                  |
| CANTALOUPE_PROCESSOR_MANUALSELECTIONSTRATEGY_JPG                                       | "TurboJpegProcessor"                                             |
| CANTALOUPE_PROCESSOR_MANUALSELECTIONSTRATEGY_MOV                                       | "FfmpegProcessor"                                                |
| CANTALOUPE_PROCESSOR_MANUALSELECTIONSTRATEGY_MP4                                       | "FfmpegProcessor"                                                |
| CANTALOUPE_PROCESSOR_MANUALSELECTIONSTRATEGY_MPG                                       | "FfmpegProcessor"                                                |
| CANTALOUPE_PROCESSOR_MANUALSELECTIONSTRATEGY_PDF                                       | "PDFBox"                                                         |
| CANTALOUPE_PROCESSOR_MANUALSELECTIONSTRATEGY_PNG                                       | "Java2dProcessor"                                                |
| CANTALOUPE_PROCESSOR_MANUALSELECTIONSTRATEGY_TIF                                       | "Java2dProcessor"                                                |
| CANTALOUPE_PROCESSOR_MANUALSELECTIONSTRATEGY_WEBM                                      | "FfmpegProcessor"                                                |
| CANTALOUPE_PROCESSOR_MANUALSELECTIONSTRATEGY_XPM                                       |                                                                  |
| CANTALOUPE_PROCESSOR_PDF_MAX_MEMORY_BYTES                                              | "-1"                                                             |
| CANTALOUPE_PROCESSOR_PDF_SCRATCH_FILE_ENABLED                                          | "false"                                                          |
| CANTALOUPE_PROCESSOR_SELECTION_STRATEGY                                                | "ManualSelectionStrategy"                                        |
| CANTALOUPE_PROCESSOR_SHARPEN                                                           | "0"                                                              |
| CANTALOUPE_PROCESSOR_STREAM_RETRIEVAL_STRATEGY                                         | "StreamStrategy"                                                 |
| CANTALOUPE_PROCESSOR_TIF_COMPRESSION                                                   | "LZW"                                                            |
| CANTALOUPE_PROCESSOR_UPSCALE_FILTER                                                    | "bicubic"                                                        |
| CANTALOUPE_REDISCACHE_DATABASE                                                         | "0"                                                              |
| CANTALOUPE_REDISCACHE_HOST                                                             | "localhost"                                                      |
| CANTALOUPE_REDISCACHE_PASSWORD                                                         |                                                                  |
| CANTALOUPE_REDISCACHE_PORT                                                             | "6379"                                                           |
| CANTALOUPE_REDISCACHE_SSL                                                              | "false"                                                          |
| CANTALOUPE_S3CACHE_ACCESS_KEY_ID                                                       |                                                                  |
| CANTALOUPE_S3CACHE_BUCKET_NAME                                                         |                                                                  |
| CANTALOUPE_S3CACHE_ENDPOINT                                                            |                                                                  |
| CANTALOUPE_S3CACHE_OBJECT_KEY_PREFIX                                                   |                                                                  |
| CANTALOUPE_S3CACHE_REGION                                                              |                                                                  |
| CANTALOUPE_S3CACHE_SECRET_KEY                                                          |                                                                  |
| CANTALOUPE_S3SOURCE_ACCESS_KEY_ID                                                      |                                                                  |
| CANTALOUPE_S3SOURCE_BASICLOOKUPSTRATEGY_BUCKET_NAME                                    |                                                                  |
| CANTALOUPE_S3SOURCE_BASICLOOKUPSTRATEGY_PATH_PREFIX                                    |                                                                  |
| CANTALOUPE_S3SOURCE_BASICLOOKUPSTRATEGY_PATH_SUFFIX                                    |                                                                  |
| CANTALOUPE_S3SOURCE_CHUNKING_CACHE_ENABLED                                             | "true"                                                           |
| CANTALOUPE_S3SOURCE_CHUNKING_CACHE_MAX_SIZE                                            | "5M"                                                             |
| CANTALOUPE_S3SOURCE_CHUNKING_CHUNK_SIZE                                                | "512K"                                                           |
| CANTALOUPE_S3SOURCE_CHUNKING_ENABLED                                                   | "true"                                                           |
| CANTALOUPE_S3SOURCE_ENDPOINT                                                           |                                                                  |
| CANTALOUPE_S3SOURCE_LOOKUP_STRATEGY                                                    | "BasicLookupStrategy"                                            |
| CANTALOUPE_S3SOURCE_REGION                                                             |                                                                  |
| CANTALOUPE_S3SOURCE_SECRET_KEY                                                         |                                                                  |
| CANTALOUPE_SLASH_SUBSTITUTE                                                            |                                                                  |
| CANTALOUPE_SOURCE_DELEGATE                                                             | "false"                                                          |
| CANTALOUPE_SOURCE_STATIC                                                               | "HttpSource"                                                     |
| CANTALOUPE_TEMP_PATHNAME                                                               |                                                                  |

[Cantaloupe Caching]: https://cantaloupe-project.github.io/manual/3.1/caching.html
[Cantaloupe Documentation]: https://cantaloupe-project.github.io/manual/3.1/getting-started.html
[Cantaloupe Logs]: https://cantaloupe-project.github.io/manual/3.1/logging.html
[Cantaloupe]: https://cantaloupe-project.github.io/
