# APK dependency and source-build evaluation

Evaluated 2026-10-26 against isle-buildkit commit
`97b805931d3a7baf6dff73c0a6d99f941e801f77` and
[isle-site-template commit 5a0f9a7](https://github.com/islandora-devops/isle-site-template/tree/5a0f9a7df61e4a43b3fd2fb5ee334b083150e761).
This is a source/configuration review, not a built-image SBOM or vulnerability scan.
The reported six-hour packaging delay is incident context supplied by the maintainer;
release and package publication timestamps were not independently established.

## Recommendation

1. Build NGINX from source next, using the existing vendored-aport approach.
2. Establish an upstream-controlled MariaDB build, including clients, as the next
   database priority. It is an application dependency, not a production public listener.
3. Prioritize Cantaloupe's native parsers and Java runtime alongside MariaDB:
   FFmpeg and OpenJPEG are still Alpine packages on a public request path.
4. Cover internal media processors that consume externally supplied files:
   Ghostscript, Poppler, Tesseract, FFmpeg, and FITS native dependencies.
5. Leave PostgreSQL on Alpine packages, per maintainer priority. Continue normal
   updates and compatibility tests; its client is also inherited through base.

Source-build the components where we need control over emergency patch timing;
do not take on rebuilding every OS utility. A local APK remains an APK: the
important distinction is whether its release depends on Alpine publishing it.

## Exposure in the site template

The production defaults publish only Traefik's HTTP/HTTPS ports. Routing comes
from files, so `exposedByDefault=false` does not make these file-defined routes
private. These are configured network paths; actual Internet reachability also
depends on deployment firewalls, DNS, and overrides. Authentication does not
remove the need to patch request parsers.

| Service | Configured exposure | Patch-relevant components |
| --- | --- | --- |
| Traefik | Host ports 80/443 by default | External upstream image, Go HTTP/TLS runtime |
| Drupal | Public host route through Traefik | NGINX, PHP and extensions, linked libraries, Drupal/Composer dependencies |
| Cantaloupe | Public `/cantaloupe` route | Java, embedded server/JAR dependencies, native image/video processors |
| Fedora | Public `fcrepo.${DOMAIN}` route | Tomcat, Java, Fedora/Syn and JAR dependencies |
| MariaDB | Internal production service; dev override publishes `3306:3306` | Server, utilities, clients and linked libraries |
| ActiveMQ, Solr, Blazegraph | HTTP routes enabled only when `DEVELOPMENT_ENVIRONMENT=true` | Java and application dependencies |
| Traefik dashboard | Development-mode route/API | Traefik itself |
| Alpaca, crayfits, FITS, homarus, houdini, hypercube, mergepdf, milliner | No public route or published port in the reviewed production template | Internal processing of application data; several parse user-supplied files |
| init | Explicit profile, no public listener | Base tooling; administrative container |

Evidence: template [Compose](https://github.com/islandora-devops/isle-site-template/blob/5a0f9a7df61e4a43b3fd2fb5ee334b083150e761/docker-compose.yml),
[development override](https://github.com/islandora-devops/isle-site-template/blob/5a0f9a7df61e4a43b3fd2fb5ee334b083150e761/docker-compose.dev.yml),
and [routing files](https://github.com/islandora-devops/isle-site-template/tree/5a0f9a7df61e4a43b3fd2fb5ee334b083150e761/conf/traefik).
The development MariaDB mapping binds all host interfaces by default; use
`127.0.0.1:3306:3306` if only host-local development access is needed.

## Inventory of all 26 build targets

All runtime targets inherit the base APK set, directly or through another target.
The ImageMagick and Leptonica targets produce packages for other images and are
not application runtime services. Listed additions are explicit Dockerfile
installs; dependency closure requires inspecting the built image.

| Target | Parent/runtime APK additions or inheritance | Assessment |
| --- | --- | --- |
| base | Alpine; bash, ca-certificates, curl, git, gnupg, gzip, jq, mariadb-client, mysql-client, netcat-openbsd, openssl, patch, postgresql16-client, procps, shadow, util-linux, wget, yq | Shared patch surface for every runtime |
| nginx | base; nginx, icu-data-full; locally built PHP 8.4 CLI/FPM and extensions | Highest-priority new source build: NGINX |
| drupal | nginx; no additional explicit APKs | Public; inherits PHP/NGINX and their library dependencies |
| test | drupal; no additional explicit APKs | Test site, inherits the same surface |
| milliner | nginx; no additional explicit APKs | Internal PHP application, benefits from NGINX build |
| mariadb | base; mariadb, mariadb-server-utils | Source-build server/client family together |
| postgresql | base; postgresql16 | Retain Alpine packaging |
| java | base; openjdk21, maven | Java runtime affects public Cantaloupe and Fedora |
| tomcat | java; upstream Tomcat archive, no additional explicit APKs | Already independent of Alpine for Tomcat |
| fcrepo | tomcat; upstream Fedora artifacts, Syn build | Public; Java remains Alpine-controlled |
| cantaloupe | java; ffmpeg, openjpeg-tools; direct libjpeg-turbo/Grok/CLI11 source builds | Public native parser priority |
| activemq | java; upstream ActiveMQ archive | Development-only public route in template |
| solr | java; upstream Solr archive | Development-only public route in template |
| alpaca | java; application built with Gradle in separate builder | Internal; inherited Java remains relevant |
| handle | java; upstream Handle archive/JDBC artifacts | Not present in reviewed template |
| fits | tomcat; file, java-jna, libmediainfo, libzen, perl, py3-pip, python3 | Internal untrusted-file parsing; upstream FITS and servlet archives |
| scyllaridae | base; mailcap; locally built Go application | Shared internal processor runtime |
| crayfits | scyllaridae; no additional explicit APKs | Internal wrapper calling FITS using curl |
| homarus | scyllaridae; ffmpeg | Share source-built FFmpeg with Cantaloupe/transcriber |
| houdini | scyllaridae; locally built imagemagick APKs | Existing source build; delegates/libraries still relevant |
| hypercube | scyllaridae; local leptonica APKs; poppler-utils, tesseract-ocr and language data | Source-build parser packages in a later phase |
| mergepdf | scyllaridae; local leptonica APKs; ghostscript, tesseract-ocr and language data | Ghostscript is a strong next parser candidate |
| transcriber | scyllaridae; ffmpeg, sdl2-dev; source-built whisper.cpp | Not in reviewed template; share FFmpeg build, assess whether runtime SDL development package is needed |
| transkribus | base; local imagemagick APKs; aspnetcore8-runtime, nodejs, npm; npm xslt3 | Not in reviewed template; retain upstream runtime update options |
| imagemagick | Alpine package builder; alpine-sdk, bash, sudo and codec/delegate development dependencies | Already locally source-built; package consumers still install Alpine dependency closure |
| leptonica | Alpine package builder; alpine-sdk, bash, sudo and image codec development dependencies | Already locally source-built; codecs still depend on Alpine |

See `images/<target>/Dockerfile` and `docker-bake.hcl` for the inventory sources.
The named Alpine context is pinned in Bake; `FROM alpine` here is not evidence
that the supported Bake build uses an unpinned base.

Build-only installs include NGINX's PHP-stage alpine-sdk/sudo, Alpaca's Gradle
image, transcriber's build-base/cmake, Transkribus's dotnet8-sdk, and FITS's
temporary strip-nondeterminism package. Cantaloupe installs and removes compiler
and codec development packages in its runtime stage; verify the final linked
libraries rather than assuming every temporary dependency survives removal.
ImageMagick's builder includes Ghostscript/delegate dependencies; Leptonica's
includes giflib, JPEG, PNG, WebP, OpenJPEG, TIFF, and zlib development packages.

## Decisions and implementation scope

### NGINX: implement first

`images/nginx/Dockerfile` still installs `nginx` from Alpine despite building PHP
locally. Vendor the supported Alpine NGINX aport and required patches, build a
signed local APK in an isolated stage, and install that package with the PHP
packages. Preserve paths, service users, compiled modules, and configuration
compatibility. Track the supported upstream release line directly and update
source checksums automatically, following PHP's existing pattern.

Validate both architectures with `nginx -t`, module/build-option inspection,
existing startup/health/client-IP tests, and Drupal HTTP/PHP integration.

### MariaDB: include clients in the change

`images/mariadb/Dockerfile` installs the server and utilities, but
`images/base/Dockerfile` also pins `mariadb-client` and `mysql-client` across all
runtime images. Replacing only the server would leave Alpine-controlled clients
and can create package-version conflicts. Build the supported MariaDB line's
required subpackages together and wire compatible clients into base. Prefer an
isolated Alpine builder to avoid a base-to-MariaDB dependency cycle.

Keep the existing data layout, ownership, plugin set, initialization scripts,
and healthcheck. Validate first boot, Drupal/Fedora connections, backup/restore,
and an upgrade from the currently supported persisted database version on amd64
and arm64. Measure build time: database compilation can consume the packaging
time saved. Rollback involving an upgraded data directory needs a tested restore
path; an old image tag alone is insufficient.

### Cantaloupe and file processors: include indirect public input

`images/cantaloupe/Dockerfile` obtains FFmpeg/OpenJPEG through Alpine, while
libjpeg-turbo and Grok already have direct source builds. Prioritize source-built
FFmpeg and OpenJPEG packages and inspect actual configured processor selection
before claiming each binary is used for every request. Audit bundled Java
codecs/server dependencies too; changing APK provenance does not update JARs.

The internal processors are also patch-relevant: homarus invokes FFmpeg,
hypercube invokes Tesseract/Poppler, and mergepdf invokes Tesseract/Ghostscript.
They can consume externally supplied content through application workflows
without being public HTTP endpoints. FITS adds libmagic/file and MediaInfo
parsers. Share package producers where the same component has multiple consumers;
do not duplicate FFmpeg recipes per image. Test representative media derivatives,
OCR and PDF output, codec availability, and licensing/build options.

### Shared libraries and externally maintained images

PHP's vendored recipe still uses Alpine libraries: OpenSSL, curl, PCRE2,
libxml2/libxslt, ICU, image codecs, libzip, LDAP, and others. NGINX source builds
will likewise retain linked dependencies. OpenSSL's CLI package in base is not
the entire TLS library surface. Establish final-image package and ELF dependency
inventories before choosing additional library builds; rebuild consumers where
linkage requires it. Keep Alpine defaults for routine utilities unless an
actual incident or reachable vulnerability justifies owning their builds.

OpenJDK is Alpine-controlled throughout the Java hierarchy. Consider a verified,
musl-compatible upstream runtime distribution before taking on a complete JDK
source build. Preserve architecture and JNI compatibility. Evaluate moving Maven
out of runtime images after confirming startup does not require it.

The template also uses upstream Traefik and a pinned legacy Blazegraph image.
Neither has a build target here. Track their image digests, bundled runtimes,
and release latency separately; this review cannot establish their internal APK
inventories. Traefik is the first public HTTP/TLS hop and must be part of the
emergency update process. Drupal's Composer lockfile is another public dependency
surface outside this repo's APK packaging.

## Release latency and acceptance criteria

`.github/workflows/renovate.yml` runs daily at 10:15 UTC. `renovate.json` places
most non-Repology minor/patch updates into a Wednesday group. APK updates and PHP
have unrestricted package-rule schedules, but still rely on workflow invocation.
Moving NGINX or MariaDB to upstream tracking without explicit urgent-update rules
could therefore trade an Alpine packaging delay for a longer detection delay.

Add upstream tracking and checksum synchronization with an explicit emergency
path that bypasses weekly grouping and can be invoked immediately. Use the
existing PHP update mechanism as the model; no generic build framework is needed.
Set a release-to-published-image target and measure upstream publication,
detection, PR/merge, architecture builds/tests, publication, and site deployment
separately. Source builds remove only the Alpine publication dependency.

Before promoting each conversion:

- Verify source checksums and retain aport provenance, patches and licenses.
- Keep local packages signed and package metadata available to SBOM/scanning.
- Build and test amd64 and arm64, including application behavior and linked libs.
- Retain vulnerability scanning and document accepted exceptions.
- Confirm an emergency update can reach consumers, including template image pins
  and rebuilds of the site-specific Drupal image.

The manual push workflow defaults `strip-apk-pinning=true`; that path skips the
normal test and Grype jobs. Use the normal tested release path
(`strip-apk-pinning=false`) for security conversions and emergency releases.
No image conversion or runtime configuration change is made by this evaluation.

## Validation limits

Reviewed every Dockerfile, Bake dependency mapping, update/release workflows,
vendored PHP recipe, template Compose files, and template Traefik routes. No
containers were built or run. Transitive package versions, enabled runtime
processors, deployed overrides, vulnerability status, and actual release/build
timings require runtime/SBOM and incident evidence before implementation claims.
