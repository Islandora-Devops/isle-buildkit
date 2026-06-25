package buildkit

import (
	"bytes"
	"strings"
	"testing"
)

func TestRunTestsAllowsKnownImageWithNoTests(t *testing.T) {
	root := repoRoot(t)
	var stdout bytes.Buffer
	var stderr bytes.Buffer

	code := RunTests(root, []string{"--image", "imagemagick"}, &stdout, &stderr)
	if code != 0 {
		t.Fatalf("RunTests(--image imagemagick) exit code = %d, want 0; stderr = %q", code, stderr.String())
	}
	if !strings.Contains(stdout.String(), "no tests selected") {
		t.Fatalf("stdout = %q, want no tests selected message", stdout.String())
	}
	if stderr.Len() != 0 {
		t.Fatalf("stderr = %q, want empty", stderr.String())
	}
}

func TestRunTestsFailsUnknownTestSelector(t *testing.T) {
	root := repoRoot(t)
	var stdout bytes.Buffer
	var stderr bytes.Buffer

	code := RunTests(root, []string{"--test", "DoesNotExist"}, &stdout, &stderr)
	if code != 2 {
		t.Fatalf("RunTests(--test DoesNotExist) exit code = %d, want 2", code)
	}
	if !strings.Contains(stderr.String(), "no tests matched selector(s): DoesNotExist") {
		t.Fatalf("stderr = %q, want unmatched selector message", stderr.String())
	}
}
