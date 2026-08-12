package buildkit

import (
	"fmt"
	"io"
)

func Run(root string, args []string, stdout, stderr io.Writer) int {
	if len(args) == 0 {
		printUsage(stderr)
		return 2
	}

	switch args[0] {
	case "metadata":
		return RunMetadata(root, args[1:], stdout, stderr)
	case "test":
		return RunTests(root, args[1:], stdout, stderr)
	case "help", "-h", "--help":
		printUsage(stdout)
		return 0
	default:
		if isMetadataCommand(args[0]) {
			return RunMetadata(root, args, stdout, stderr)
		}
		fmt.Fprintf(stderr, "unknown command %q\n\n", args[0])
		printUsage(stderr)
		return 2
	}
}

func printUsage(w io.Writer) {
	fmt.Fprint(w, `Usage:
  buildkit metadata <command> [args...]
  buildkit test [flags]

Metadata commands match ci/image-metadata.sh:
  list
  dependencies <image>
  published-image <image>
  description-images
  version <image>
  tags <image> <version|fallback> <fallback-tag>
  first-tag <image> <version|fallback> <fallback-tag>
  contexts <image> <repository> <version|fallback> <fallback-tag> [build-images-json]
  plan [--base <ref>] [--head <ref>] [--image <image>] [--all]
`)
}
