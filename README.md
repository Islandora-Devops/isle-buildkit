# ISLE: Docker Prototype <!-- omit in toc -->

[![LICENSE](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](./LICENSE)
![CI](https://github.com/Islandora-Devops/isle-buildkit/workflows/CI/badge.svg?branch=main)

- [Introduction](#introduction)
- [Requirements](#requirements)
- [Building](#building)
  - [Build All Images](#build-all-images)
  - [Build Specific Image](#build-specific-image)
  - [Building Continuously](#building-continuously)
- [Testing](#testing)
- [Running](#running)
- [Docker Images](#docker-images)
- [Design Considerations](#design-considerations)
  - [Confd](#confd)
  - [S6 Overlay](#s6-overlay)
  - [Image Hierarchy](#image-hierarchy)
  - [Folder Layout](#folder-layout)
  - [Build System](#build-system)
- [Design Constraints](#design-constraints)
- [Issues / FAQ](#issues--faq)

## Introduction

This repository provides a number of docker images which can be used to build an
Islandora site. On commit, these images are automatically pushed to
[Docker Hub] via Github Actions. Which are consumed by [isle-dc] and can be used
by other Docker orchestration tools such as Swarm / Kubernetes.

It is **not** meant as a starting point for new users or those unfamiliar with
Docker, or basic server administration.

If you are looking to use islandora please read the [official documentation] and
use either [isle-dc] or the [Isle Site Template] to deploy via [Docker] or the
[islandora-playbook] to deploy via [Ansible].

## Requirements

To build the Docker images using the provided Gradle build scripts requires:

- [Docker 19.03+](https://docs.docker.com/get-docker/)
- [OpenJDK or Oracle JDK 11+](https://www.java.com/en/download/)

That being said the images themselves are compatible with older versions of
Docker.

## Building

The build scripts rely on Gradle and should function equally well across
platforms. The only difference being the script you call to interact with gradle
(the following assumes you are executing from the **root directory** of the
project):

**Linux or OSX:**

```bash
./gradlew
```

**Windows:**

```bash
gradlew.bat
```

For the remaining examples the **Linux or OSX** call method will be used, if
using Windows substitute the call to Gradle script.

Gradle is a project/task based build system to query all the available tasks use
the following command.

```bash
./gradlew tasks --all
```

Which should return something akin to:

```bash
> Task :tasks

------------------------------------------------------------
Tasks runnable from root project
------------------------------------------------------------

...

Islandora tasks
---------------
abuild:build - Creates Docker image.
activemq:build - Creates Docker image.
alpaca:build - Creates Docker image.
base:build - Creates Docker image.

...
```

In Gradle each Project maps onto a folder in the file system path where it is
delimited by `:` instead of `/` (Unix) or `\` (Windows).

The root project `:` can be omitted.

So if you want to run a particular task `taskname` that resided in the project
folder `project/subproject` you would specify it like so:

```bash
./gradlew :project:subproject:taskname
```

To get more verbose output from Gradle use the `--info` argument like so:

```bash
./gradlew :PROJECT:TASK --info
```

To build all the docker images you can use the following command:

### Build All Images

The following will build all the images in the correct order.

```bash
./gradlew build
```

### Build Specific Image

To build a specific image and it's dependencies, for example
`islandora/tomcat`, you can use the following:

```bash
./gradlew tomcat:build
```

### Building Continuously

It is often helpful to build continuously where-in any change you make to any of
the `Dockerfile` files or other project files, will automatically trigger the
building of that image and any downstream dependencies. To do this add the
`--continuous` flag like so:

```bash
./gradlew build --continuous
```

## Testing

There are a number of automated tests that are included in this repository which
can be found in the `tests` folders of each docker image project.

To run these tests use the following command:

```bash
./gradlew test
```

To manually test changes in a functioning environment use the command:

```bash
./gradlew up
```

This will bring up the environment based on [islandora-starter-site]. When
completed a message will print like so:

```
For all services the credentials are:

Username: admin
Password: password

The following services can be reached at the given URLs:

ActiveMQ: https://activemq.islandora.dev/
Blazegraph: https://blazegraph.islandora.dev/bigdata/
Drupal: https://islandora.dev/
Fedora: https://fcrepo.islandora.dev/fcrepo/rest/
Matomo: https://islandora.dev/matomo/index.php
Solr: https://solr.islandora.dev/solr/#/
Traefik: https://traefik.islandora.dev/dashboard/#/
```

To destroy this environment use the following command:

```bash
./gradlew down
```

The two commands can be used at once to ensure you are starting from a clean
environment:

```bash
./gradlew down up
```

## Running

While `isle-buildkit` does provide a [test environment](#testing), it is not
meant for development on Islandora or as production environment. Instead please
refer to [isle-dc], or the [Isle Site Template], for how to build your own
Islandora site.

## Docker Images

The following docker images are provided:

- [abuild]
- [activemq]
- [alpaca]
- [base]
- [blazegraph]
- [cantaloupe]
- [crayfish]
- [crayfits]
- [drupal]
- [fcrepo]
- [fcrepo6]
- [fits]
- [handle]
- [homarus]
- [houdini]
- [hypercube]
- [imagemagick]
- [java]
- [karaf]
- [mariadb]
- [matomo]
- [milliner]
- [nginx]
- [postgresql]
- [recast]
- [ripgrep]
- [solr]
- [test]
- [tomcat]

Many are intermediate images used to build other images in the list, for example
[java](./java/README.md). Please see the `README.md` of each image to find out
what settings, and ports, are exposed and what functionality it provides, as
well as how to update it to the latest releases.

## Design Considerations

All of the images build by this project are derived from the
[Alpine Docker Image] which is a Linux distribution built around [musl libc] and
[BusyBox].

> N.B. While [musl libc] is of general higher quality vs. [glibc], it is less
> commonly used and many libraries have come to depend on the undefined behavior
> of [glibc] so in some of our images we patch in [glibc] to ensure their
> correct function.

The image is only `5MB` in size and has access to a package repository. It has
been chosen for its small size, and ease of generating custom packages (as is
done in the [imagemagick] image).

The [base] image includes two tools essential to the functioning of all the
images.

- [Confd]: Configuration Management
- [S6 Overlay]: Process Manager / Initialization system

### Confd

`confd` is used for all Configuration Management, it is how images are
customized on startup and during runtime. For each Docker image there will be a
folder `rootfs/etc/confd` that has the following layout:

```bash
./rootfs/etc/confd
├── conf.d
│   └── file.ext.toml
└── templates
    └── file.ext.tmpl
```

The `file.ext.toml` and `file.ext.tmpl` work as a pair. The `toml` file
defines where the template will be render to and who owns it. The `tmpl` file
being the template in question. Ideally these files should match the same name
of the file they are generating minus the `toml` or `tmpl` suffix. This is
to make their discovery easier.

Additionally in the `base` image there is `confd.toml` which sets defaults
such a the `log-level`:

```toml
backend = "env"
confdir = "/etc/confd"
log-level = "error"
interval = 600
noop = false
```

`confd` is also the source of all truth when it comes to configuration. We
have established a order of precedence in which environment variables at runtime
are defined.

1. Confd backend (highest)
2. Secrets kept in `/run/secrets` (Except when using `Kubernetes`)
3. Environment variables passed into the container
4. Environment variables defined in Dockerfile(s)
5. Environment variables defined in the `/etc/defaults` directory (lowest only used for multiline variables, such as JWT)

If not defined in the highest level the next level applies and so forth down the
list.

> N.B. `/etc/defaults` and the environment variables declared in the
> Dockerfile(s) used to create the image are **required** to define all
> environment variables used by scripts and `confd` templates. If not
> specified in either of those locations the environment variables will not be
> available even if its defined at a **higher** level i.e. `confd`.

The logic which enforces these rules is performed in
[container-environment.sh](base/rootfs/etc/s6-overlay/scripts/container-environment.sh)

> N.B Some containers derive environment variables dynamically from other
> environment variables. In these cases they are expected to provided an
> additional `oneshot` services that must be executed before the `confd-oneshot`
> so that the variables are defined before `confd` is used to render
> templates.

By either using the command `with-contenv` or starting a script with
`#!/command/with-contenv bash` the environment defined will follow the order
of precedence above. Additionally Within `confd` templates it is **required**
to use `getenv` function for fetching data, as the *final* value is written to
the container environment.

### S6 Overlay

[S6 Overlay] is the process supervisor we use in all the containers. It ensures
initialization happens in the correct order and services start in the correct
order (e.g. `fpm-php` starts prior to `nginx`, etc).

There are two types of services:

- `oneshot` Services: Short lived services, used to prepare the container prior to running services
- `longrun` Services: Long lived services like Nginx

Both types of services can have dependencies on one another, which indicates the
order in which they are executed. `oneshot` services are run to **completion**
before their dependent services are executed. `longrun` services are meant to
run indefinitely, if for some reason one fails the container will stop and exit
with the code of the failed service (provided a `finish` script is provided).

The `longrun` services have the following structure:

```bash
./rootfs/etc/s6-overlay/s6-rc.d
└── SERVICE_NAME
    ├── dependencies.d
    │   └── base
    ├── finish
    ├── run
    └── type
```

The `run` script is responsible for starting the service in the
**foreground**. The `finish` script can perform any cleanup necessary before
stopping the service, but in general it is used to kill the container, like so:

```bash
/run/s6/basedir/bin/halt
```

To declare dependencies between services, just add an empty file with the
services name in it's `dependencies.d` folder.

For scripts we want to run at startup run we must register them. This can be
done by placing an empty file named for the service in
`./rootfs/etc/s6-overlay/s6-rc.d/user/contents.d`.

There are only a few `longrun` services:

- activemq
- confd (optional, not enabled by default)
- fpm
- karaf
- mysqld
- nginx
- solr
- tomcat

Of these only `confd` can be configured to run in every container, it
periodically listens for changes in it's configured backend (e.g. `etcd` or
`environment variables`) and will re-render the templates upon any change (see
it's [README.md](./base/README.md), for more information).

`oneshot` services are pretty much the same, except they use they `up` and
`down` instead of `run` and `finish`.

Additionally `up` is an [execline] script and does not support `bash`. So we
typically just call out to a `bash` script instead, which by convention can be
found in `./rootfs/etc/s6-overlay/scripts`.

One `oneshot` service is of particular interest to **all** the containers. The
`ready` service, which does not do anything in and of itself. It is meant as a
placeholder that other services can rely on to ensure that typical actions have
been performed, such as the configuration of environment variables, the
rendering of templates and so on.

> N.B. **All** `longrun` services should have a dependency on the `ready`
> service.

If you need to wait until a service to be ready for use, use the following
command:

```bash
# Wait for PHP-FPM to report it has started.
s6-svwait -U /run/service/fpm
```

> N.B. This requires the service to make use of
> [notification-fd](https://skarnet.org/software/s6/notifywhenup.html), which at
> the time of writing is only implemented for `nginx` and `php-fpm`

### Image Hierarchy

In order to save space and reduce the amount of duplication across images, they
are arranged in a hierarchy, that roughly follows below:

```bash
├── abuild
│   └── imagemagick
└── base
    ├── java
    │   ├── activemq
    │   ├── karaf
    │   │   └── alpaca
    │   ├── solr
    │   └── tomcat
    │       ├── blazegraph
    │       ├── cantaloupe
    │       ├── fcrepo
    │       ├── fcrepo6
    │       └── fits
    ├── mariadb
    ├── postgresql
    └── nginx
        ├── crayfish
        │   ├── homarus
        │   ├── houdini (consumes "imagemagick" as well during its build stage)
        │   ├── hypercube
        │   ├── milliner
        │   ├── recast
        │   └── riprap
        ├── crayfits
        ├── drupal
        │   └── test
        └── matomo
```

[abuild], [download], [composer], and [imagemagick] stand outside of the
hierarchy as they are use only to build packages that are consumed by other
images during their build stage.

### Folder Layout

To make reasoning about what files go where each image follows the same
filesystem layout for copying files into the image.

A folder called `rootfs` maps directly onto the linux filesystem of the final
image. So for example `rootfs/etc/islandora/configs` will be
`/etc/islandora/configs` in the generated image.

### Build System

Gradle is used as the build system, it is setup such that it will automatically
detect which folders should be considered
[projects](https://docs.gradle.org/current/dsl/org.gradle.api.Project.html) and
what dependencies exist between them. The only caveat is
that the projects cannot be nested, though that use case does not really apply.

The dependencies are resolved by parsing the Dockerfile and looking for:

- `FROM` statements
- `--mount=type=bind` statements
- `COPY --from` statements

As they are capable of referring to other images.

This means to add a new Docker image to the project you do not need to modify
the build scripts, simply add a new folder and place your Dockerfile inside of
it. It will be discovered and built in the correct order relative to the other
images assuming you refer to the other image using the `repository` build
argument.

For example:

```Dockerfile
# syntax=docker/dockerfile:1.4.3
ARG repository=local
ARG tag=latest
FROM ${repository}/base:${tag}
```

## Design Constraints

To be able to support a wide variety of backends for `confd`, as well as
orchestration tools, all calls **must use** `getenv` for the default value. With
the exception of keys that do not get used unless defined like
`DRUPAL_SITE_{SITE}_NAME`. This means the whatever backend for configuration,
wether it be `etcd`, `consul`, or `environment variables`, containers can
successfully start without any other container present. Additionally it ensure
that the order of precedence for configuration settings.

This does not completely remove dependencies between containers, for example,
when the [fcrepo6] starts it requires a running database like [mariadb] to be
able to start. In these cases an `oneshot` service can block until another
container is available or a timeout has been reached. For example:

```bash
# Need access to database to start wait up to 5 minutes (i.e 300 seconds).
if timeout 300 wait-for-open-port.sh "${DB_HOST}" "${DB_PORT}" ; then
    echo "Database Found"
else
    echo "Could not connect to Database"
    exit 1
fi
```

This allows container to start up in any order, and to be orchestrated by any tool.

## Issues / FAQ

**Question:** I'm getting the following error when building:

```bash
failed to solve with frontend dockerfile.v0: failed to solve with frontend
gateway.v0: runc did not terminate successfully: context canceled
```

**Answer:** If possible upgrade Docker to the latest version, and switch to
using the [Overlay2] filesystem with Docker.


**Question:** I'm getting the following error when running many tests at once:

```bash
ERROR: could not find an available, non-overlapping IPv4 address pool among the
defaults to assign to the network
```
**Answer:** By default Docker only allows **31** concurrent bridge networks to
be created, but you can change this in your `/etc/docker/daemon.json` file by
adding the following, and restarting `Docker`:

```json
{
  "default-address-pools" : [
    {
      "base" : "172.17.0.0/12",
      "size" : 20
    },
    {
      "base" : "192.168.0.0/16",
      "size" : 24
    }
  ]
}
```

[abuild]: ./abuild/README.md
[activemq]: ./activemq/README.md
[alpaca]: ./alpaca/README.md
[base]: ./base/README.md
[blazegraph]: ./blazegraph/README.md
[cantaloupe]: ./cantaloupe/README.md
[crayfish]: ./crayfish/README.md
[crayfits]: ./crayfits/README.md
[drupal]: ./drupal/README.md
[fcrepo]: ./fcrepo/README.md
[fcrepo6]: ./fcrepo6/README.md
[fits]: ./fits/README.md
[handle]: ./handle/README.md
[homarus]: ./homarus/README.md
[houdini]: ./houdini/README.md
[hypercube]: ./hypercube/README.md
[imagemagick]: ./imagemagick/README.md
[java]: ./java/README.md
[karaf]: ./karaf/README.md
[mariadb]: ./mariadb/README.md
[matomo]: ./matomo/README.md
[milliner]: ./milliner/README.md
[nginx]: ./nginx/README.md
[postgresql]: ./postgresql/README.md
[recast]: ./recast/README.md
[ripgrep]: ./ripgrep/README.md
[solr]: ./solr/README.md
[test]: ./test/README.md
[tomcat]: ./tomcat/README.md

[Alpine Docker Image]: https://hub.docker.com/_/alpine
[Ansible]: https://docs.ansible.com/ansible/latest/user_guide/index.html#getting-started
[BusyBox]: https://busybox.net/
[Confd]: https://github.com/kelseyhightower/confd
[Docker Hub]: https://hub.docker.com/u/islandora
[Docker]: https://docs.docker.com/get-started/
[execline]: https://skarnet.org/software/execline/index.html
[glibc]: https://www.gnu.org/software/libc/
[islandora-playbook]: https://github.com/Islandora-Devops/islandora-playbook
[islandora-starter-site]: https://github.com/Islandora/islandora-starter-site
[Isle Site Template]: https://github.com/Islandora-Devops/isle-site-template
[isle-dc]: https://github.com/Islandora-Devops/isle-dc
[musl libc]: https://musl.libc.org/
[official documentation]: https://islandora.github.io/documentation/
[Overlay2]: https://docs.docker.com/storage/storagedriver/overlayfs-driver#configure-docker-with-the-overlay-or-overlay2-storage-driver
[S6 Overlay]: https://github.com/just-containers/s6-overlay
