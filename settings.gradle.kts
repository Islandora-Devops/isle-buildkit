rootProject.name = "isle-buildkit"

// Include any folder that has a Dockerfile as a sub-project.
rootProject.projectDir
    .resolve("images")
    .walk()
    .maxDepth(1) // Only immediate directories.
    .filter { it.isDirectory && it.resolve("Dockerfile").exists() } // Must have a Dockerfile.
    .forEach { docker ->
        // Include as a sub-project.
        include("images:${docker.name}")
        // Include any tests as sub-projects of the docker project.
        val tests = docker.resolve("tests")
        if (tests.isDirectory) {
            include("images:${docker.name}:tests")
            // Add any sub-folders that container project files as well.
            tests
                .walk()
                .filter { it.isDirectory && (it.resolve("build.gradle.kts").exists() || it.resolve("docker-compose.yml").exists())}
                .forEach {
                    include("images:${docker.name}:tests:${it.name}")
                }
        }
    }
