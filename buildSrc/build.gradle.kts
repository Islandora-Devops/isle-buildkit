import org.jetbrains.kotlin.gradle.tasks.KotlinCompile

group = "io.github.nigelgbanks"

repositories {
    mavenCentral()
    gradlePluginPortal()
}

plugins {
    id("com.gradle.plugin-publish") version "1.1.0"
    `java-gradle-plugin`
    `kotlin-dsl`
}

afterEvaluate {
    tasks.withType<KotlinCompile>().configureEach {
        kotlinOptions {
            apiVersion = "1.6"
            languageVersion = "1.6"
        }
    }
}

dependencies {
    implementation("org.apache.commons:commons-io:1.3.2")
    implementation("com.fasterxml.jackson.module:jackson-module-kotlin:2.14.1")
    implementation("com.fasterxml.jackson.dataformat:jackson-dataformat-yaml:2.14.1")
}

java {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
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
        create("IsleDockerHub") {
            id = "io.github.nigelgbanks.IsleDockerHub"
            implementationClass = "plugins.DockerHubPlugin"
            displayName = "IsleDockerHub"
            description = "Tasks for managing DockerHub tags, etc."
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

extensions.findByName("buildScan")?.withGroovyBuilder {
    setProperty("termsOfServiceUrl", "https://gradle.com/terms-of-service")
    setProperty("termsOfServiceAgree", "yes")
}
