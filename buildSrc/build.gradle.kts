group = "io.github.nigelgbanks"

repositories {
    mavenCentral()
    gradlePluginPortal()
}

plugins {
    id("com.gradle.plugin-publish") version "1.2.1"
    `java-gradle-plugin`
    `kotlin-dsl`
}

kotlin {
    jvmToolchain(11)
}

dependencies {
    implementation("commons-io:commons-io:2.15.1")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin:2.16.1")
    implementation("com.fasterxml.jackson.dataformat:jackson-dataformat-yaml:2.16.1")
}

java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(21))
    }
}

gradlePlugin {
    website.set("https://github.com/Islandora-Devops/isle-gradle-docker-plugin")
    vcsUrl.set("https://github.com/Islandora-Devops/isle-gradle-docker-plugin")

    plugins {
        create("Isle") {
            id = "io.github.nigelgbanks.Isle"
            implementationClass = "plugins.IslePlugin"
            displayName = "Isle"
            description = "Main gradle plugin for the Islandora Isle project"
            tags.set(listOf("isle"))
        }
        create("IsleReports") {
            id = "io.github.nigelgbanks.IsleReports"
            implementationClass = "plugins.ReportsPlugin"
            displayName = "IsleReports"
            description = "Generates security reports for a single project"
            tags.set(listOf("isle"))
        }
        create("IsleTests") {
            id = "io.github.nigelgbanks.IsleTests"
            implementationClass = "plugins.TestsPlugin"
            displayName = "IsleTests"
            description = "Perform tests with docker-compose files"
            tags.set(listOf("isle"))
        }
    }
}
