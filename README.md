# ISLE: Docker Prototype <!-- omit in toc -->

[![LICENSE](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](./LICENSE)
![CI](https://github.com/Islandora-Devops/isle-buildkit/workflows/CI/badge.svg?branch=main)

- [Introduction](#introduction)
- [Requirements](#requirements)
- [Building](#building)
  - [Build All Images](#build-all-images)
  - [Build Specific Image](#build-specific-image)
  - [Building Continuously](#building-continuously)
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
Islandora 8 site.

## Requirements

To build the Docker images using the provided Gradle build scripts requires:

- [Docker 19.03+](https://docs.docker.com/get-docker/)
- [OpenJDK or Oracle JDK 8+](https://www.java.com/en/download/)

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
delimited by ``:`` instead of ``/`` (Unix) or ``\`` (Windows).

The root project ``:`` can be omitted.

So if you want to run a particular task ``taskname`` that resided in the project
folder ``project/subproject`` you would specify it like so:

```bash
./gradlew :project:subproject:taskname
```

To get more verbose output from Gradle use the ``--info`` argument like so:

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
``islandora/tomcat``, you can use the following:

```bash
./gradlew tomcat:build
```

### Building Continuously

It is often helpful to build continuously where-in any change you make to any of
the Dockerfiles or other project files, will automatically trigger the building
of that image and any downstream dependencies. To do this add the
``--continuous`` flag like so:

```bash
./gradlew build --continuous
```

When this is combined with the use of ``watchtower`` and
``restart: unless-stopped`` in a ``docker-compose.yml`` file. Images will be
redeployed with the latest changes while you develop automatically.

## Running

There is no method for running the containers in `isle-buildkit`, instead please
refer to <https://github.com/Islandora-Devops/isle-dc>.

## Docker Images

The following docker images are provided:

- [abuild](./abuild/README.md)
- [activemq](./activemq/README.md)
- [alpaca](./alpaca/README.md)
- [base](./base/README.md)
- [blazegraph](./blazegraph/README.md)
- [build](./build/README.md)
- [cantaloupe](./cantaloupe/README.md)
- [crayfish](./crayfish/README.md)
- [crayfits](./crayfits/README.md)
- [drupal](./drupal/README.md)
- [fcrepo](./fcrepo/README.md)
- [fits](./fits/README.md)
- [gemini](./gemini/README.md)
- [homarus](./homarus/README.md)
- [houdini](./houdini/README.md)
- [hypercube](./hypercube/README.md)
- [imagemagick](./imagemagick/README.md)
- [java](./java/README.md)
- [karaf](./karaf/README.md)
- [mariadb](./mariadb/README.md)
- [matomo](./matomo/README.md)
- [milliner](./milliner/README.md)
- [nginx](./nginx/README.md)
- [recast](./recast/README.md)
- [demo](./demo/README.md)
- [solr](./solr/README.md)
- [tomcat](./tomcat/README.md)

Many are intermediate images used to build other images in the list, for example
[java](./java/README.md). Please see the README of each image to find out what
settings, and ports, are exposed and what functionality it provides.

## Design Considerations

All of the images build by this project are derived from the
[Alpine Docker Image](https://hub.docker.com/_/alpine) which is a Linux
distribution built around ``musl`` ``libc`` and ``BusyBox``. The image is only 5
MB in size and has access to a package repository. It has been chosen for its
small size, and ease of generating custom packages (as is done in the
[imagemagick](./imagemagick/README.md) image).

The [base](./base/README.md) image includes two tools essential to the
functioning of all the images.

- [Confd](https://github.com/kelseyhightower/confd) - Configuration Management
- [S6 Overlay](https://github.com/just-containers/s6-overlay) - Process Manager
  / Initialization system.

### Confd

``confd`` is used for all Configuration Management, it is how images are
customized on startup and during runtime. For each Docker image there will be a
folder ``rootfs/etc/confd`` that has the following layout:

```bash
./rootfs/etc/confd
├── conf.d
│   └── file.ext.toml
├── confd.toml
└── templates
    └── file.ext.tmpl
```

``confd.toml`` Is the configuration of ``confd`` and will typically limit the
namespace from which ``confd`` will read key values. For example in ``activemq``:

```toml
backend = "env"
confdir = "/etc/confd"
log-level = "debug"
interval = 600
noop = false
prefix = "/activemq"
```

The prefix is set to ``/activemq`` which means only keys / value pairs under
this prefix can be used by templates. We restrict images by prefix to force them
to define their own settings, reducing dependencies between images, and to allow
for greater customization. For example you could have Gemini use PostgreSQL as a
backend and Drupal using MariaDB since they do not share the same Database
configuration.

The ``file.ext.toml`` and ``file.ext.tmpl`` work as a pair where the ``toml``
file defines where the template will be render to and who owns it, and the
``tmpl`` file being the template in question. Ideally these files should match
the same name of the file they are generating minus the ``toml`` or ``tmpl``
suffix. This is to make the discovery of them easier.

``confd`` is also the source of all truth when it comes to configuration. We've
established a order of precedence in which environment variables can be
provided.

1. Confd backend (highest)
2. Secrets kept in `/run/secrets`
3. Environment variables passed into the container
4. Environment variables defined in Dockerfile(s)
5. Environment variables defined in the `/etc/defaults` directory (lowest only used for multiline variables, such as JWT)

If not defined in the highest level the next level applies and so forth down the
list.

`/etc/defaults` and the environment variables declared in the Dockerfile(s) used
to create the image are **required** to define all environment variables used by
scripts and Confd templates.

``confd`` templates are **required** to use `getenv` function for all default
values to ensure this order of precedence is followed.

### S6 Overlay

From this tool we only really take advantage of two features:

- Initialization scripts (*found in ``rootfs/etc/cont-init.d``*)
- Service scripts (*found in ``rootfs/etc/services.d``*)

Initialization scripts are run when the container is started and they execute in
alphabetical order. So to control the execution order they are prefix with
numbers.

One initialization script ``01-confd-render-templates.sh`` is shared by all the
images. It does a first past render of the ``confd`` templates so subsequent
scripts can run. The rest of the scripts do the minimal steps required to get
the container into a ready state before the Service scripts start.

The services scripts have the following structure:

```bash
./rootfs/etc/services.d
└── SERVICE_NAME
    ├── finish
    └── run
```

The ``run`` script is responsible for starting the service in the
**foreground**. The ``finish`` script can perform any cleanup necessary before
stopping the service, but in general it is used to kill the container, like so:

```bash
s6-svscanctl -t /var/run/s6/services
```

There are only a few Service scripts:

- activemq
- confd
- fpm
- karaf
- mysqld
- nginx
- solr
- tomcat

Of these only ``confd`` can be configured to run in every container, it
periodically listens for changes in it's configured backend (e.g. ``etcd`` or
``environment variables``) and will re-render the templates upon any change.

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
    │       └── fits
    ├── mariadb
    └── nginx
        ├── crayfish
        │   ├── gemini
        │   ├── homarus
        │   ├── houdini (consumes "imagemagick" as well during its build stage)
        │   ├── hypercube
        │   ├── milliner
        │   └── recast
        ├── crayfits
        ├── drupal
        │   └── demo
        └── matomo
```

[abuild](./abuild/README.md) and [imagemagick](./imagemagick/README.md) stand
outside of the hierarchy as they are use only to build packages that are
consumed by other images during their build stage.

### Folder Layout

To make reasoning about what files go where each image follows the same
filesystem layout for copying files into the image.

A folder called ``rootfs`` maps directly onto the linux filesystem of the final
image. So for example ``rootfs/etc/islandora/configs`` will be
``/etc/islandora/configs`` in the generated image.

### Build System

Gradle is used as the build system, it is setup such that it will automatically
detect which folders should be considered
[projects](https://docs.gradle.org/current/dsl/org.gradle.api.Project.html) and
what dependencies exist between them. The only caveat is
that the projects cannot be nested, though that use case does not really apply.

The dependencies are resolved by parsing the Dockerfile and looking for:

- ``FROM``statements
- ``--mount=type=bind`` statements
- ``COPY --from`` statements

As they are capable of referring to other images.

This means to add a new Docker image to the project you do not need to modify
the build scripts, simply add a new folder and place your Dockerfile inside of
it. It will be discovered and built in the correct order relative to the other
images assuming you refer to the other image using the `repository` build
argument.

For example:

```Dockerfile
ARG repository=local
ARG tag=latest
FROM ${repository}/base:${tag}
```

## Design Constraints

To be able to support a wide variety of backends for ``confd``, as well as
orchestration tools, all calls to ``getv`` **must use getenv for the default
value**. With the exception of keys that do not get used unless defined like
``DRUPAL_SITE_{SITE}_NAME``. This means the whatever backend for configuration,
wether it be ``etcd``, ``consul``, or ``environment variables``, containers can
successfully start without any other container present. Additionally it ensure
that the order of precedence for configuration settings.

This does not completely remove dependencies between containers, for example,
when the [demo](../docker/demo/README.md) starts it requires a running
[fcrepo](../docker/fcrepo/README.md) to be able to ingest nodes created by
``islandora_default`` features. In these cases an initialization script can
block until another container is available or a timeout has been reached. For
example:

```bash
local fcrepo_host=${DRUPAL_DEFAULT_FCREPO_HOST}
local fcrepo_port=${DRUPAL_DEFAULT_FCREPO_PORT}
local fcrepo_url=

# Indexing fails if port 80 is given explicitly.
if [[ "${fcrepo_port}" == "80" ]]; then
    fcrepo_url="http://${fcrepo_host}/fcrepo/rest/"
else
    fcrepo_url="http://${fcrepo_host}:${fcrepo_port}/fcrepo/rest/"
fi

#...

# Need access to Solr before we can actually import the right config.
if timeout 300 wait-for-open-port.sh "${fcrepo_host}" "${fcrepo_port}" ; then
    echo "Fcrepo Found"
else
    echo "Could not connect to Fcrepo"
    exit 1
fi
```

This allows container to start up in any order, and to be orchestrated by any tool.

## Issues / FAQ

**Question:** I'm getting the following error when building:

```bash
failed to solve with frontend dockerfile.v0: failed to solve with frontend gateway.v0: runc did not terminate successfully: context canceled
```

**Answer:** If possible upgrade Docker to the latest version, and switch to using the
[Overlay2](https://docs.docker.com/storage/storagedriver/overlayfs-driver/#configure-docker-with-the-overlay-or-overlay2-storage-driver)
filesystem with Docker.
