# ISLE: Gradle Docker Plugin <!-- omit in toc -->

[![LICENSE](https://img.shields.io/badge/license-MIT-blue.svg?style=flat-square)](./LICENSE)
![CI](https://github.com/Islandora-Devops/isle-gradle-docker-plugin/workflows/CI/badge.svg)

- [Introduction](#introduction)
- [Requirements](#requirements)
- [Building](#building)
    - [Build and Publish the Plugin](#build-and-publish-the-plugin)
- [Using the Plugin](#using-the-plugin)
- [Using the Plugin from Source](#using-the-plugin-from-source)

## Introduction

This repository provides a Gradle plugin that supports building interdependent Docker images with [Buildkit] support.

The plugin is setup such that it will automatically detect which folders should be considered
[projects](https://docs.gradle.org/current/dsl/org.gradle.api.Project.html) and what dependencies exist between them.
The only caveat is that the projects cannot be nested, though that use case does not really apply.

The dependencies are resolved by parsing the Dockerfile and looking for ``FROM``
statements to determine which images are required to build it.

This means to add a new Docker image to the project you do not need to modify the build scripts, simply add a new folder
and place your Dockerfile inside it, and it will be discovered built in the correct order relative to the other images.

## Requirements

To build this plugin the following is required:

- [OpenJDK or Oracle JDK 11+](https://www.java.com/en/download/)

## Building

The build scripts rely on Gradle and should function equally well across platforms. The only difference being the script
you call to interact with gradle
(the following assumes you are executing from the **root directory** of the project):

**Linux or OSX:**

```bash
./gradlew
```

**Windows:**

```bash
gradlew.bat
```

For the remaining examples the **Linux or OSX** call method will be used, if using Windows substitute the call to Gradle
script.

Gradle is a project/task based build system to query all the available tasks use the following command.

```bash
./gradlew tasks --all
```

Which should return something akin to:

```bash
> Task :tasks

------------------------------------------------------------
Tasks runnable from root project
------------------------------------------------------------

Build tasks
-----------
assemble - Assembles the outputs of this project.
build - Assembles and tasks.tests this project.
buildDependents - Assembles and tasks.tests this project and all projects that depend on it.
buildNeeded - Assembles and tasks.tests this project and all projects it depends on.
classes - Assembles main classes.
clean - Deletes the build directory.
jar - Assembles a jar archive containing the main classes.
testClasses - Assembles test classes.

...
```

In Gradle each Project maps onto a folder in the file system path where it is delimited by ``:`` instead of ``/`` (Unix)
or ``\`` (Windows).

The root project ``:`` can be omitted.

So if you want to run a particular task ``taskname`` that resided in the project folder ``project/subproject`` you would
specify it like so:

```bash
./gradlew :project:subproject:taskname
```

To get more verbose output from Gradle use the ``--info`` argument like so:

```bash
./gradlew :PROJECT:TASK --info
```

To build all the docker images you can use the following command:

### Build and Publish the Plugin

The following will build and test the plugin.

```bash
./gradlew build
```

The following will publish the module to Github packages, which requires you setup a personal access token.

```bash
export GITHUB_REPOSITORY=Islandora-Devops/isle-gradle-docker-plugin
export GITHUB_ACTOR=nigelgbanks
export GITHUB_TOKEN=XXXXXXXXXXXXXXXXX
./gradlew build publish
```

Alternatively you can rely on the Github actions which will publish when a release is made.

> N.B. It is NOT POSSIBLE to delete/replace packages on a public repository (except *-SNAPSHOT). A new release must be made.

## Using the Plugin

To include this plugin for versions 0.11+ add the following to your `build.gradle.kts` file:

```kotlin
plugins {
    id("io.github.nigelgbanks.Isle") version "1.0.11"
}
```

## Using the Plugin from Source

To include this plugin in another project use the following snippet of Kotlin script in your Gradle project with
the `settings.gradle.kts` file that allows the plugin source to be discoverable:

```kotlin
sourceControl {
    gitRepository(uri("file:///PATH_TO_FOLDER/isle-gradle-docker-plugin/.git")) {
        producesModule("io.github.nigelgbanks:isle-gradle-docker-plugin")
    }
}
```

With that in place you can include the plugin in your respective project `build.gradle.kts` file:

```kotlin
buildscript {
    repositories {
        gradlePluginPortal()
    }
    dependencies {
        classpath("io.github.nigelgbanks:isle-gradle-docker-plugin") {
            version {
                branch = "BRANCH_NAME"
            }
        }
    }
}
apply(plugin = "io.github.nigelgbanks.Isle")
```

Note that it will only use **committed** changes.

[Buildkit]: https://github.com/moby/buildkit/blob/main/frontend/dockerfile/docs/experimental.md
