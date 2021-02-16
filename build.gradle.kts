buildscript {
    repositories {
        gradlePluginPortal()
        maven {
            url = uri("https://plugins.gradle.org/m2/")
        }
    }
    dependencies {
        classpath("ca.islandora:isle-gradle-docker-plugin:0.0.3")
        classpath("com.palantir.gradle.gitversion:gradle-git-version:0.12.3")
    }
}

apply(plugin = "ca.islandora.gradle.docker")
