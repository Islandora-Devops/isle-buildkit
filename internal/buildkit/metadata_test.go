package buildkit

import (
	"os"
	"path/filepath"
	"testing"
)

func TestMetadataFallbackTagsUseRepositoryTag(t *testing.T) {
	root := repoRoot(t)
	metadata, err := LoadMetadata(root)
	if err != nil {
		t.Fatal(err)
	}

	cases := []struct {
		image    string
		mode     string
		fallback string
		want     []string
	}{
		{image: "activemq", mode: "fallback", fallback: "local", want: []string{"local"}},
		{image: "nginx", mode: "fallback", fallback: "6.x", want: []string{"6.x"}},
	}

	for _, tt := range cases {
		got, err := metadata.Tags(tt.image, tt.mode, tt.fallback)
		if err != nil {
			t.Fatalf("Tags(%s): %v", tt.image, err)
		}
		if len(got) != len(tt.want) {
			t.Fatalf("Tags(%s) = %v, want %v", tt.image, got, tt.want)
		}
		for index := range got {
			if got[index] != tt.want[index] {
				t.Fatalf("Tags(%s) = %v, want %v", tt.image, got, tt.want)
			}
		}
	}
}

func TestComposeEnvUsesIdentityImageNames(t *testing.T) {
	root := repoRoot(t)
	metadata, err := LoadMetadata(root)
	if err != nil {
		t.Fatal(err)
	}

	resolver := imageResolver{
		metadata:    metadata,
		repository:  "islandora",
		mode:        "fallback",
		fallbackTag: "6.x",
	}

	env := resolver.envFor("activemq")
	if env["ACTIVEMQ"] != "islandora/activemq:6.x" {
		t.Fatalf("ACTIVEMQ = %q", env["ACTIVEMQ"])
	}

	env = resolver.envFor("fcrepo")
	if env["FCREPO"] != "islandora/fcrepo:6.x" {
		t.Fatalf("FCREPO = %q", env["FCREPO"])
	}
}

func repoRoot(t *testing.T) string {
	t.Helper()
	dir, err := os.Getwd()
	if err != nil {
		t.Fatal(err)
	}
	for {
		if _, err := os.Stat(filepath.Join(dir, "docker-bake.hcl")); err == nil {
			return dir
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			t.Fatal("could not find docker-bake.hcl")
		}
		dir = parent
	}
}
