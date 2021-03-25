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
    .forEach { docker ->
        // Include as a sub-project.
        include(docker.relativeTo(rootProject.projectDir).path)
        // Include any tests as sub-projects of the docker project.
        val tests = docker.resolve("tests")
        if (tests.isDirectory) {
            include(tests.relativeTo(rootProject.projectDir).path.replace("/", ":"))
            // Add any sub-folders that container project files as well.
            tests
                .walk()
                .filter { it.isDirectory && it.resolve("build.gradle.kts").exists() }
                .forEach {
                    include(it.relativeTo(rootProject.projectDir).path.replace("/", ":"))
                }
        }
    }
