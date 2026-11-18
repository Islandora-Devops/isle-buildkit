# Java

Docker image for [Java] OpenJDK version 21.

Built from [Islandora-DevOps/isle-buildkit java](https://github.com/Islandora-DevOps/isle-buildkit/tree/main/images/java)

Please refer to the [Java Documentation] for more in-depth information.

Acts as base Docker image for all Java based services.

OpenJDK is compiled from upstream source as signed local APKs using the vendored
Alpine recipe in `build/`. The builder uses Alpine's OpenJDK only to bootstrap the
compiler; the runtime installs the locally built JDK and JRE packages. Maven,
Java certificate integration, and the default JVM path retain Alpine packaging.
The build runs HotSpot gtests; the longer JTReg suites remain disabled as in the
Alpine recipe.

Recipe and patches: [Alpine aports openjdk21](https://gitlab.alpinelinux.org/alpine/aports/-/tree/92e7eab1eec56a47219d3414a0a20f6ba7f1ec74/community/openjdk21),
licensed GPL-2.0-with-classpath-exception. Local changes add an upstream tag for
Renovate and allow the updater to select the source archive independently of the
APK version. Source and patch SHA-512 checksums are verified by `abuild`.

Run `bash ci/update-openjdk.sh jdk-21.0.13.1-ga` to synchronize the source tag,
checksum, build number, and Dockerfile package pin. Review patch compatibility
when updating. Renovate runs the same helper for OpenJDK source updates.
Build with `make bake TARGET=java`; test with `make test TARGET=java`.

## Dependencies

Requires `islandora/base` Docker image to build. Please refer to the
[Base Image README](../base/README.md) for additional information.

[Java Documentation]: https://docs.oracle.com/en/java/
[Java]: https://www.java.com/
