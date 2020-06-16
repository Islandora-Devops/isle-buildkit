rootProject.name = "isle-buildkit"

// Include plugin for building Docker images.
sourceControl {
    gitRepository(uri("https://github.com/Islandora-Devops/isle-gradle-docker-plugin.git")) {
        producesModule("ca.islandora:isle-gradle-docker-plugin")
    }
}

// Include any folder that has a Dockerfile as a sub-project.
rootProject.projectDir
        .walk()
        .maxDepth(1) // Only immediate directories.
        .filter { it.isDirectory && it.resolve("Dockerfile").exists() } // Must have a Dockerfile.
        .forEach {
            // Include as a sub-project.
            include(it.relativeTo(rootProject.projectDir).path)
        }
