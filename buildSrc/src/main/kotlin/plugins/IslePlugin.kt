package plugins

import org.gradle.api.Plugin
import org.gradle.api.Project
import org.gradle.api.provider.Property
import org.gradle.kotlin.dsl.apply
import org.gradle.kotlin.dsl.property
import org.gradle.kotlin.dsl.provideDelegate
import org.gradle.kotlin.dsl.withGroovyBuilder

@Suppress("unused")
class IslePlugin : Plugin<Project> {

    companion object {
        // Check if the project should have docker related tasks.
        val Project.isDockerProject: Boolean
            get() = projectDir.resolve("Dockerfile").exists()
    }

    override fun apply(pluginProject: Project): Unit = pluginProject.run {
        apply<SharedPropertiesPlugin>()
        apply<ReportsPlugin>()
        apply<TestsPlugin>()

        // Make all build directories relative to the root, only supports projects up to a depth of one for now.
        subprojects {
            layout.buildDirectory.convention(
                rootProject.layout.buildDirectory.dir(projectDir.relativeTo(rootDir).path)
            )
        }
    }
}

inline fun <reified T : Any> Project.memoizedProperty(crossinline function: () -> T): Property<T> {
    val property = objects.property<T>()
    val value: T by lazy { function() }
    property.set(value)
    property.disallowChanges()
    property.finalizeValueOnRead()
    return property
}
