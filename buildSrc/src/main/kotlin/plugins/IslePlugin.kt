package plugins

import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.api.provider.Property
import org.gradle.api.tasks.Delete
import org.gradle.kotlin.dsl.*

@Suppress("unused")
class IslePlugin : Plugin<Project> {

    companion object {
        // Check if the project should have docker related tasks.
        val Project.isDockerProject: Boolean
            get() = projectDir.resolve("Dockerfile").exists()
    }

    override fun apply(pluginProject: Project): Unit = pluginProject.run {
        apply<SharedPropertiesPlugin>()
        apply<DockerHubPlugin>()
        apply<BuildPlugin>()
        apply<ReportsPlugin>()
        apply<TestsPlugin>()

        // Return repository to initial "clean" state.
        tasks.register<Delete>("clean") {
            group = "Isle"
            description = "Destroy absolutely everything"
            delete(layout.buildDirectory)
            dependsOn("pruneBuildCaches", "destroyBuilders", "destroyRegistryVolume", "destroyRegistryNetwork")
        }

        extensions.findByName("buildScan")?.withGroovyBuilder {
            setProperty("termsOfServiceUrl", "https://gradle.com/terms-of-service")
            setProperty("termsOfServiceAgree", "yes")
        }

        // Make all build directories relative to the root, only supports projects up to a depth of one for now.
        subprojects {
            buildDir = rootProject.buildDir.resolve(projectDir.relativeTo(rootDir))
            layout.buildDirectory.set(buildDir)
        }
    }
}

inline fun <reified T> Project.memoizedProperty(crossinline function: () -> T): Property<T> {
    val property = objects.property<T>()
    val value: T by lazy { function() }
    property.set(value)
    property.disallowChanges()
    property.finalizeValueOnRead()
    return property
}
