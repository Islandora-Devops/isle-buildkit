package buildkit

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strings"

	"github.com/hashicorp/hcl/v2"
	"github.com/hashicorp/hcl/v2/hclparse"
	"github.com/zclconf/go-cty/cty"
)

type Metadata struct {
	Root             string
	Images           []string
	PublishedImages  map[string]string
	LocalTagSuffixes map[string]string
	Dependencies     map[string][]string
}

func LoadMetadata(root string) (*Metadata, error) {
	parser := hclparse.NewParser()
	file, diagnostics := parser.ParseHCLFile(filepath.Join(root, "docker-bake.hcl"))
	if diagnostics.HasErrors() {
		return nil, fmt.Errorf("parse docker-bake.hcl: %s", diagnostics.Error())
	}

	content, _, diagnostics := file.Body.PartialContent(&hcl.BodySchema{
		Attributes: []hcl.AttributeSchema{
			{Name: "IMAGES"},
			{Name: "PUBLISHED_IMAGES"},
			{Name: "LOCAL_TAG_SUFFIXES"},
			{Name: "DEPENDENCIES"},
		},
	})
	if diagnostics.HasErrors() {
		return nil, fmt.Errorf("read docker-bake.hcl attributes: %s", diagnostics.Error())
	}
	attributes := content.Attributes

	images, err := stringListAttribute(attributes, "IMAGES")
	if err != nil {
		return nil, err
	}
	if len(images) == 0 {
		return nil, errors.New("docker-bake.hcl IMAGES is empty")
	}

	published, err := optionalStringMapAttribute(attributes, "PUBLISHED_IMAGES")
	if err != nil {
		return nil, err
	}
	for _, image := range images {
		if published[image] == "" {
			published[image] = image
		}
	}
	localTagSuffixes, err := optionalStringMapAttribute(attributes, "LOCAL_TAG_SUFFIXES")
	if err != nil {
		return nil, err
	}
	dependencies, err := stringListMapAttribute(attributes, "DEPENDENCIES")
	if err != nil {
		return nil, err
	}

	return &Metadata{
		Root:             root,
		Images:           images,
		PublishedImages:  published,
		LocalTagSuffixes: localTagSuffixes,
		Dependencies:     dependencies,
	}, nil
}

func expressionValue(attributes hcl.Attributes, name string) (cty.Value, error) {
	attribute, ok := attributes[name]
	if !ok {
		return cty.NilVal, fmt.Errorf("docker-bake.hcl is missing %s", name)
	}
	value, diagnostics := attribute.Expr.Value(nil)
	if diagnostics.HasErrors() {
		return cty.NilVal, fmt.Errorf("evaluate %s: %s", name, diagnostics.Error())
	}
	return value, nil
}

func stringListAttribute(attributes hcl.Attributes, name string) ([]string, error) {
	value, err := expressionValue(attributes, name)
	if err != nil {
		return nil, err
	}
	return ctyStringList(value, name)
}

func stringMapAttribute(attributes hcl.Attributes, name string) (map[string]string, error) {
	value, err := expressionValue(attributes, name)
	if err != nil {
		return nil, err
	}
	result := map[string]string{}
	for key, item := range value.AsValueMap() {
		if item.Type() != cty.String {
			return nil, fmt.Errorf("%s[%s] must be a string", name, key)
		}
		result[key] = item.AsString()
	}
	return result, nil
}

func optionalStringMapAttribute(attributes hcl.Attributes, name string) (map[string]string, error) {
	if _, ok := attributes[name]; !ok {
		return map[string]string{}, nil
	}
	return stringMapAttribute(attributes, name)
}

func stringListMapAttribute(attributes hcl.Attributes, name string) (map[string][]string, error) {
	value, err := expressionValue(attributes, name)
	if err != nil {
		return nil, err
	}
	result := map[string][]string{}
	for key, item := range value.AsValueMap() {
		values, err := ctyStringList(item, fmt.Sprintf("%s[%s]", name, key))
		if err != nil {
			return nil, err
		}
		result[key] = values
	}
	return result, nil
}

func ctyStringList(value cty.Value, name string) ([]string, error) {
	if !value.CanIterateElements() {
		return nil, fmt.Errorf("%s must be a list of strings", name)
	}
	var result []string
	for _, item := range value.AsValueSlice() {
		if item.Type() != cty.String {
			return nil, fmt.Errorf("%s must be a list of strings", name)
		}
		result = append(result, item.AsString())
	}
	return result, nil
}

func (m *Metadata) KnownImage(image string) bool {
	for _, candidate := range m.Images {
		if candidate == image {
			return true
		}
	}
	return false
}

func (m *Metadata) PublishedImage(image string) string {
	if value := m.PublishedImages[image]; value != "" {
		return value
	}
	return image
}

func (m *Metadata) DependenciesOf(image string) ([]string, error) {
	values, ok := m.Dependencies[image]
	if !ok {
		return nil, fmt.Errorf("unknown image in dependency graph: %s", image)
	}
	return append([]string(nil), values...), nil
}

func (m *Metadata) PrimaryVersion(image string) (string, error) {
	value, err := dockerfileArgDefault(filepath.Join(m.Root, "images", image, "Dockerfile"), "SOFTWARE_VERSION")
	if err != nil {
		return "", err
	}
	if value == "" {
		return "", fmt.Errorf("image %s does not define SOFTWARE_VERSION", image)
	}
	return normalizeVersion(image, value), nil
}

func dockerfileArgDefault(dockerfile string, arg string) (string, error) {
	content, err := os.ReadFile(dockerfile)
	if err != nil {
		return "", err
	}
	pattern := regexp.MustCompile(`(?m)^[[:space:]]*(?:ARG[[:space:]]+)?` + regexp.QuoteMeta(arg) + `=([^[:space:]\\]+).*`)
	matches := pattern.FindAllSubmatch(content, -1)
	if len(matches) == 0 {
		return "", nil
	}
	return strings.Trim(string(matches[len(matches)-1][1]), `"`), nil
}

func normalizeVersion(image, version string) string {
	version = strings.Trim(version, `"`)
	version = regexp.MustCompile(`-r[0-9]+$`).ReplaceAllString(version, "")
	switch image {
	case "blazegraph":
		candidate := regexp.MustCompile(`^CANDIDATE_([0-9]+)_([0-9]+)_([0-9]+)$`)
		if match := candidate.FindStringSubmatch(version); match != nil {
			return strings.Join(match[1:], ".")
		}
	case "go1-26":
		return strings.TrimPrefix(version, "go")
	}
	return version
}

func normalizeDockerTag(value string) string {
	replaced := regexp.MustCompile(`[^A-Za-z0-9_.-]+`).ReplaceAllString(value, "-")
	return strings.Trim(replaced, "-")
}

func (m *Metadata) Tags(image, mode, fallback string) ([]string, error) {
	switch mode {
	case "version":
		return m.versionTags(image, fallback)
	case "fallback":
		return []string{m.fallbackTag(image, fallback)}, nil
	default:
		return nil, fmt.Errorf("mode must be version or fallback, got %q", mode)
	}
}

func (m *Metadata) FirstTag(image, mode, fallback string) (string, error) {
	tags, err := m.Tags(image, mode, fallback)
	if err != nil {
		return "", err
	}
	if len(tags) == 0 {
		return "", fmt.Errorf("no tags for %s", image)
	}
	return tags[0], nil
}

func (m *Metadata) versionTags(image, fallback string) ([]string, error) {
	version, err := m.PrimaryVersion(image)
	if err != nil {
		return []string{normalizeDockerTag(fallback)}, nil
	}

	var words []string
	semverPatch := regexp.MustCompile(`^([0-9]+)\.([0-9]+)\.`)
	semverMinor := regexp.MustCompile(`^([0-9]+)\.([0-9]+)$`)
	integer := regexp.MustCompile(`^[0-9]+$`)
	switch {
	case semverPatch.MatchString(version):
		match := semverPatch.FindStringSubmatch(version)
		words = append(words, version, match[1]+"."+match[2])
		if includeMajorTag(image) {
			words = append(words, match[1])
		}
	case semverMinor.MatchString(version):
		match := semverMinor.FindStringSubmatch(version)
		words = append(words, version)
		if includeMajorTag(image) {
			words = append(words, match[1])
		}
	case integer.MatchString(version):
		words = append(words, version)
	default:
		words = append(words, normalizeDockerTag(version))
	}

	suffix := versionTagSuffix(image)
	var result []string
	for _, word := range words {
		result = append(result, appendTagSuffix(word, suffix))
	}
	if m.IncludeLatestTag(image) {
		if suffix != "" {
			result = append(result, "latest-"+suffix)
		}
		result = append(result, "latest")
	}
	return uniqueStrings(result), nil
}

func (m *Metadata) fallbackTag(image, fallback string) string {
	return appendTagSuffix(normalizeDockerTag(fallback), m.LocalTagSuffixes[image])
}

func versionTagSuffix(image string) string {
	switch image {
	case "nginx-php83":
		return "php8.3"
	case "nginx-php84":
		return "php8.4"
	default:
		return ""
	}
}

func includeMajorTag(image string) bool {
	switch image {
	case "go1-26", "php83", "php84":
		return false
	default:
		return true
	}
}

func appendTagSuffix(tag, suffix string) string {
	if suffix == "" {
		return tag
	}
	return tag + "-" + suffix
}

func uniqueStrings(values []string) []string {
	seen := map[string]bool{}
	var result []string
	for _, value := range values {
		if value == "" || seen[value] {
			continue
		}
		seen[value] = true
		result = append(result, value)
	}
	return result
}

func (m *Metadata) IncludeLatestTag(image string) bool {
	published := m.PublishedImage(image)
	candidate := ""
	for _, candidateImage := range m.Images {
		if m.PublishedImage(candidateImage) == published {
			candidate = candidateImage
		}
	}
	return candidate == image
}

func (m *Metadata) DescriptionImages() [][2]string {
	var result [][2]string
	for _, image := range m.Images {
		if m.IncludeLatestTag(image) {
			result = append(result, [2]string{m.PublishedImage(image), image})
		}
	}
	return result
}

func (m *Metadata) Contexts(image, repository, mode, fallback string, buildImagesJSON string) ([]string, error) {
	dependencies, err := m.DependenciesOf(image)
	if err != nil {
		return nil, err
	}

	buildImages, err := parseBuildImages(buildImagesJSON)
	if err != nil {
		return nil, err
	}

	var result []string
	for _, dependency := range dependencies {
		tagMode := contextTagMode(dependency, mode, buildImages)
		tagFallback := fallback
		if tagMode == "version" && mode == "fallback" {
			tagFallback = "main"
		}
		tag, err := m.FirstTag(dependency, tagMode, tagFallback)
		if err != nil {
			return nil, err
		}
		result = append(result, fmt.Sprintf("%s=docker-image://%s/%s:%s", dependency, repository, m.PublishedImage(dependency), tag))
	}
	return result, nil
}

func parseBuildImages(value string) (map[string]bool, error) {
	result := map[string]bool{}
	if strings.TrimSpace(value) == "" {
		return result, nil
	}
	var images []string
	if err := json.Unmarshal([]byte(value), &images); err != nil {
		return nil, fmt.Errorf("parse build images JSON: %w", err)
	}
	for _, image := range images {
		result[image] = true
	}
	return result, nil
}

func contextTagMode(image, mode string, buildImages map[string]bool) string {
	if mode == "version" {
		return "version"
	}
	if buildImages[image] {
		return "fallback"
	}
	return "version"
}

func (m *Metadata) Plan(base, head, forceImage string, forceAll bool) (*Plan, error) {
	affected := []string{}
	addAffected := func(image string) {
		if !m.KnownImage(image) || containsString(affected, image) {
			return
		}
		affected = append(affected, image)
	}

	if forceAll {
		affected = append(affected, m.Images...)
	} else if forceImage != "" {
		addAffected(forceImage)
	} else {
		paths, err := changedFiles(m.Root, base, head)
		if err != nil {
			return nil, err
		}
		global := false
		for _, path := range paths {
			if path == "" {
				continue
			}
			if strings.HasPrefix(path, "images/") {
				parts := strings.Split(path, "/")
				if len(parts) >= 2 && m.KnownImage(parts[1]) {
					addAffected(parts[1])
				} else {
					global = true
				}
				continue
			}
			if isGlobalPath(path) {
				global = true
			}
		}
		if global {
			affected = append([]string(nil), m.Images...)
		}
	}

	affected = m.expandDependents(affected)
	levels := map[int][]string{}
	levelCache := map[string]int{}
	for _, image := range m.Images {
		if !containsString(affected, image) {
			continue
		}
		level, err := m.dependencyLevel(image, levelCache, map[string]bool{})
		if err != nil {
			return nil, err
		}
		if level < 0 || level > 3 {
			return nil, fmt.Errorf("image %s has dependency level %d, but the workflow only defines levels 0-3", image, level)
		}
		levels[level] = append(levels[level], image)
	}

	var tests []string
	testLevels := map[int][]string{}
	for _, image := range affected {
		if _, err := os.Stat(filepath.Join(m.Root, "images", image, "tests")); err == nil {
			tests = append(tests, image)
			testLevels[levelCache[image]] = append(testLevels[levelCache[image]], image)
		}
	}

	return &Plan{
		Images:     affected,
		Level0:     levels[0],
		Level1:     levels[1],
		Level2:     levels[2],
		Level3:     levels[3],
		Tests:      tests,
		TestLevel0: testLevels[0],
		TestLevel1: testLevels[1],
		TestLevel2: testLevels[2],
		TestLevel3: testLevels[3],
		HasBuilds:  len(affected) > 0,
	}, nil
}

type Plan struct {
	Images     []string
	Level0     []string
	Level1     []string
	Level2     []string
	Level3     []string
	Tests      []string
	TestLevel0 []string
	TestLevel1 []string
	TestLevel2 []string
	TestLevel3 []string
	HasBuilds  bool
}

func changedFiles(root, base, head string) ([]string, error) {
	if head == "" {
		head = "HEAD"
	}

	if base != "" && gitOK(root, "cat-file", "-e", base+"^{commit}") {
		return gitLines(root, "diff", "--name-only", base, head)
	}
	if gitOK(root, "rev-parse", "--verify", head+"^") {
		return gitLines(root, "diff", "--name-only", head+"^", head)
	}
	return gitLines(root, "ls-files")
}

func gitOK(root string, args ...string) bool {
	command := exec.Command("git", append([]string{"-c", "safe.directory=" + root, "-C", root}, args...)...)
	return command.Run() == nil
}

func gitLines(root string, args ...string) ([]string, error) {
	command := exec.Command("git", append([]string{"-c", "safe.directory=" + root, "-C", root}, args...)...)
	output, err := command.Output()
	if err != nil {
		return nil, fmt.Errorf("git %s: %w", strings.Join(args, " "), err)
	}
	return splitLines(string(output)), nil
}

func splitLines(value string) []string {
	lines := strings.Split(strings.ReplaceAll(value, "\r\n", "\n"), "\n")
	result := lines[:0]
	for _, line := range lines {
		if line != "" {
			result = append(result, line)
		}
	}
	return result
}

func isGlobalPath(path string) bool {
	return path == "docker-bake.hcl" ||
		path == "Makefile" ||
		path == "go.mod" ||
		path == "go.sum" ||
		strings.HasPrefix(path, "cmd/") ||
		strings.HasPrefix(path, "internal/") ||
		strings.HasPrefix(path, "ci/") ||
		strings.HasPrefix(path, ".github/workflows/")
}

func (m *Metadata) expandDependents(affected []string) []string {
	result := append([]string(nil), affected...)
	for {
		changed := false
		for _, image := range m.Images {
			if containsString(result, image) {
				continue
			}
			for _, dependency := range m.Dependencies[image] {
				if containsString(result, dependency) {
					result = append(result, image)
					changed = true
					break
				}
			}
		}
		if !changed {
			return result
		}
	}
}

func (m *Metadata) dependencyLevel(image string, cache map[string]int, stack map[string]bool) (int, error) {
	if level, ok := cache[image]; ok {
		return level, nil
	}
	if stack[image] {
		return 0, fmt.Errorf("dependency cycle detected at %s", image)
	}
	stack[image] = true
	max := -1
	dependencies, err := m.DependenciesOf(image)
	if err != nil {
		return 0, err
	}
	for _, dependency := range dependencies {
		level, err := m.dependencyLevel(dependency, cache, stack)
		if err != nil {
			return 0, err
		}
		if level > max {
			max = level
		}
	}
	delete(stack, image)
	cache[image] = max + 1
	return cache[image], nil
}

func containsString(values []string, needle string) bool {
	for _, value := range values {
		if value == needle {
			return true
		}
	}
	return false
}

func isMetadataCommand(command string) bool {
	switch command {
	case "list", "dependencies", "published-image", "description-images", "version", "tags", "first-tag", "contexts", "plan":
		return true
	default:
		return false
	}
}

func RunMetadata(root string, args []string, stdout, stderr io.Writer) int {
	if len(args) == 0 {
		printUsage(stderr)
		return 2
	}

	metadata, err := LoadMetadata(root)
	if err != nil {
		fmt.Fprintln(stderr, err)
		return 1
	}

	command := args[0]
	args = args[1:]
	var runErr error
	switch command {
	case "list":
		runErr = requireArgs(command, args, 0)
		if runErr == nil {
			for _, image := range metadata.Images {
				fmt.Fprintln(stdout, image)
			}
		}
	case "dependencies":
		runErr = requireArgs(command, args, 1)
		if runErr == nil {
			dependencies, err := metadata.DependenciesOf(args[0])
			if err != nil {
				runErr = err
			} else {
				fmt.Fprintln(stdout, strings.Join(dependencies, " "))
			}
		}
	case "published-image":
		runErr = requireArgs(command, args, 1)
		if runErr == nil {
			fmt.Fprintln(stdout, metadata.PublishedImage(args[0]))
		}
	case "description-images":
		runErr = requireArgs(command, args, 0)
		if runErr == nil {
			for _, pair := range metadata.DescriptionImages() {
				fmt.Fprintf(stdout, "%s %s\n", pair[0], pair[1])
			}
		}
	case "version":
		runErr = requireArgs(command, args, 1)
		if runErr == nil {
			version, err := metadata.PrimaryVersion(args[0])
			if err != nil {
				runErr = err
			} else {
				fmt.Fprintln(stdout, version)
			}
		}
	case "tags":
		runErr = requireArgs(command, args, 3)
		if runErr == nil {
			tags, err := metadata.Tags(args[0], args[1], args[2])
			if err != nil {
				runErr = err
			} else {
				fmt.Fprintln(stdout, strings.Join(tags, " "))
			}
		}
	case "first-tag":
		runErr = requireArgs(command, args, 3)
		if runErr == nil {
			tag, err := metadata.FirstTag(args[0], args[1], args[2])
			if err != nil {
				runErr = err
			} else {
				fmt.Fprintln(stdout, tag)
			}
		}
	case "contexts":
		if len(args) != 4 && len(args) != 5 {
			runErr = fmt.Errorf("usage: contexts <image> <repository> <version|fallback> <fallback-tag> [build-images-json]")
			break
		}
		buildImages := ""
		if len(args) == 5 {
			buildImages = args[4]
		}
		contexts, err := metadata.Contexts(args[0], args[1], args[2], args[3], buildImages)
		if err != nil {
			runErr = err
		} else {
			fmt.Fprintln(stdout, strings.Join(contexts, " "))
		}
	case "plan":
		runErr = runPlan(metadata, args, stdout)
	default:
		runErr = fmt.Errorf("unknown metadata command %q", command)
	}

	if runErr != nil {
		fmt.Fprintln(stderr, runErr)
		return 1
	}
	return 0
}

func requireArgs(command string, args []string, count int) error {
	if len(args) != count {
		return fmt.Errorf("%s expects %d argument(s), got %d", command, count, len(args))
	}
	return nil
}

func runPlan(metadata *Metadata, args []string, stdout io.Writer) error {
	base := ""
	head := "HEAD"
	forceImage := ""
	forceAll := false
	for len(args) > 0 {
		switch args[0] {
		case "--base":
			if len(args) < 2 {
				return errors.New("--base requires a value")
			}
			base = args[1]
			args = args[2:]
		case "--head":
			if len(args) < 2 {
				return errors.New("--head requires a value")
			}
			head = args[1]
			args = args[2:]
		case "--image":
			if len(args) < 2 {
				return errors.New("--image requires a value")
			}
			forceImage = args[1]
			args = args[2:]
		case "--all":
			forceAll = true
			args = args[1:]
		default:
			return fmt.Errorf("unknown plan flag %q", args[0])
		}
	}

	plan, err := metadata.Plan(base, head, forceImage, forceAll)
	if err != nil {
		return err
	}

	lines := map[string]any{
		"images":      plan.Images,
		"level0":      plan.Level0,
		"level1":      plan.Level1,
		"level2":      plan.Level2,
		"level3":      plan.Level3,
		"tests":       plan.Tests,
		"test_level0": plan.TestLevel0,
		"test_level1": plan.TestLevel1,
		"test_level2": plan.TestLevel2,
		"test_level3": plan.TestLevel3,
		"has_builds":  plan.HasBuilds,
	}
	order := []string{"images", "level0", "level1", "level2", "level3", "tests", "test_level0", "test_level1", "test_level2", "test_level3", "has_builds"}
	for _, key := range order {
		switch value := lines[key].(type) {
		case bool:
			fmt.Fprintf(stdout, "%s=%t\n", key, value)
		default:
			encoded, err := compactJSON(value)
			if err != nil {
				return err
			}
			fmt.Fprintf(stdout, "%s=%s\n", key, encoded)
		}
	}
	return nil
}

func compactJSON(value any) (string, error) {
	encoded, err := json.Marshal(value)
	if err != nil {
		return "", err
	}
	var buffer bytes.Buffer
	if err := json.Compact(&buffer, encoded); err != nil {
		return "", err
	}
	return buffer.String(), nil
}

func sortedKeys[V any](values map[string]V) []string {
	keys := make([]string, 0, len(values))
	for key := range values {
		keys = append(keys, key)
	}
	sort.Strings(keys)
	return keys
}
