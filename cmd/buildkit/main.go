package main

import (
	"fmt"
	"os"
	"path/filepath"

	"github.com/Islandora-Devops/isle-buildkit/internal/buildkit"
)

func main() {
	root, err := findRoot()
	if err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(2)
	}

	os.Exit(buildkit.Run(root, os.Args[1:], os.Stdout, os.Stderr))
}

func findRoot() (string, error) {
	dir, err := os.Getwd()
	if err != nil {
		return "", err
	}

	for {
		if _, err := os.Stat(filepath.Join(dir, "docker-bake.hcl")); err == nil {
			return dir, nil
		}

		parent := filepath.Dir(dir)
		if parent == dir {
			return "", fmt.Errorf("could not find docker-bake.hcl from %s", dir)
		}
		dir = parent
	}
}
