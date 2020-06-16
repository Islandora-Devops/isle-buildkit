buildscript {
    repositories {
        gradlePluginPortal()
    }
    dependencies {
        classpath("ca.islandora:isle-gradle-docker-plugin:0.0.1")
    }
}
apply(plugin = "ca.islandora.gradle.docker")