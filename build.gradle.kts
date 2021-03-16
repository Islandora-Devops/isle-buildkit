import tasks.ApproximateImageDigestTask

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

subprojects {
    if (parent == rootProject) {
        // All build tasks should generate an approximate image digest for test results caching.
        tasks.register<ApproximateImageDigestTask>("digest") {
            dependsOn("build")
        }
        // Task groups all sub-project tests into single task.
        tasks.register("test") {
            group = "Islandora"
            description = "Run tests"
            dependsOn(project.subprojects.mapNotNull { it.tasks.matching { task -> task.name == "test" } })
        }
    }
}