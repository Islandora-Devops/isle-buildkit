rootProject.name = "docker"

// Include any folder that has a Dockerfile as a sub-project.
rootProject.projectDir
        .walk()
        .maxDepth(1) // Only immediate directories.
        .filter { it.isDirectory && it.resolve("Dockerfile").exists() } // Must have a Dockerfile.
        .forEach {
            // Include as a sub-project.
            include(it.relativeTo(rootProject.projectDir).path)
        }