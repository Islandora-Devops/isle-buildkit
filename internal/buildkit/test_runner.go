package buildkit

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"os/exec"
	"os/signal"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
	"strings"
	"syscall"
	"time"
)

type stringSliceFlag []string

func (s *stringSliceFlag) String() string {
	return strings.Join(*s, ",")
}

func (s *stringSliceFlag) Set(value string) error {
	*s = append(*s, value)
	return nil
}

type TestOptions struct {
	Images          []string
	Tests           []string
	Repository      string
	Mode            string
	FallbackTag     string
	BuildImagesJSON string
	Pull            bool
	LogsDir         string
	Timeout         time.Duration
	List            bool
	KeepGoing       bool
	Verbose         bool
	ImageRefs       map[string]string
}

type TestCase struct {
	Image string
	Name  string
	Dir   string
}

type testSpec struct {
	Timeout          time.Duration
	ExpectedExitCode map[string][]int
	OutputConditions map[string]string
	HealthCheck      bool
	SetupEtcd        bool
	StopAfter        time.Duration
	CheckClientIPLog bool
}

type Runner struct {
	root      string
	ctx       context.Context
	metadata  *Metadata
	options   TestOptions
	stdout    io.Writer
	stderr    io.Writer
	resolver  *imageResolver
	startTime time.Time
}

type imageResolver struct {
	metadata       *Metadata
	repository     string
	mode           string
	fallbackTag    string
	buildImages    map[string]bool
	useBuildImages bool
}

func RunTests(root string, args []string, stdout, stderr io.Writer) int {
	ctx, cancel := context.WithCancel(context.Background())
	signals := make(chan os.Signal, 1)
	done := make(chan struct{})
	signal.Notify(signals, os.Interrupt, syscall.SIGTERM)
	defer close(done)
	defer signal.Stop(signals)
	defer cancel()
	go func() {
		select {
		case <-signals:
			cancel()
			signal.Stop(signals)
		case <-done:
		}
	}()

	metadata, err := LoadMetadata(root)
	if err != nil {
		fmt.Fprintln(stderr, err)
		return 1
	}

	options, err := parseTestOptions(args)
	if err != nil {
		fmt.Fprintln(stderr, err)
		return 2
	}

	buildImages, err := parseBuildImages(options.BuildImagesJSON)
	if err != nil {
		fmt.Fprintln(stderr, err)
		return 2
	}

	runner := Runner{
		root:     root,
		ctx:      ctx,
		metadata: metadata,
		options:  options,
		stdout:   stdout,
		stderr:   stderr,
		resolver: &imageResolver{
			metadata:       metadata,
			repository:     options.Repository,
			mode:           options.Mode,
			fallbackTag:    options.FallbackTag,
			buildImages:    buildImages,
			useBuildImages: strings.TrimSpace(options.BuildImagesJSON) != "",
		},
	}

	cases, err := runner.selectTests()
	if err != nil {
		fmt.Fprintln(stderr, err)
		return 2
	}
	if options.List {
		for _, test := range cases {
			fmt.Fprintf(stdout, "%s/%s\n", test.Image, test.Name)
		}
		return 0
	}
	if len(cases) == 0 {
		fmt.Fprintln(stdout, "no tests selected")
		return 0
	}

	failed := 0
	for _, test := range cases {
		if ctx.Err() != nil {
			fmt.Fprintln(stderr, "\ninterrupted")
			return 130
		}
		result := runner.runOne(test)
		if result.Interrupted {
			return 130
		}
		if !result.Passed {
			failed++
			if !options.KeepGoing {
				break
			}
		}
	}
	if failed > 0 {
		fmt.Fprintf(stderr, "\n%d test(s) failed\n", failed)
		return 1
	}
	fmt.Fprintf(stdout, "\n%d test(s) passed\n", len(cases))
	return 0
}

func parseTestOptions(args []string) (TestOptions, error) {
	var images stringSliceFlag
	var tests stringSliceFlag
	var imageRefs stringSliceFlag
	defaultTag := os.Getenv("TAGS")
	if defaultTag == "" {
		defaultTag = "local"
	} else {
		defaultTag = strings.Fields(defaultTag)[0]
	}
	defaultRepository := os.Getenv("REPOSITORY")
	if defaultRepository == "" {
		defaultRepository = "islandora"
	}

	options := TestOptions{
		Repository:  defaultRepository,
		Mode:        "fallback",
		FallbackTag: defaultTag,
		LogsDir:     "build/test-logs",
		Timeout:     5 * time.Minute,
		ImageRefs:   map[string]string{},
	}

	flags := flag.NewFlagSet("test", flag.ContinueOnError)
	var usage bytes.Buffer
	flags.SetOutput(&usage)
	flags.Var(&images, "image", "image to test; may be passed more than once")
	flags.Var(&tests, "test", "test to run as image/name or images/image/tests/name; may be passed more than once")
	flags.StringVar(&options.Repository, "repository", options.Repository, "container repository for generated image refs")
	flags.StringVar(&options.Mode, "mode", options.Mode, "tag mode: fallback or version")
	flags.StringVar(&options.FallbackTag, "tag", options.FallbackTag, "fallback tag used for generated image refs")
	flags.StringVar(&options.BuildImagesJSON, "build-images-json", "", "JSON image list built in this run; matching images use fallback tags")
	flags.BoolVar(&options.Pull, "pull", false, "run docker compose pull --ignore-pull-failures before each test")
	flags.StringVar(&options.LogsDir, "logs-dir", options.LogsDir, "directory for saved compose logs")
	flags.DurationVar(&options.Timeout, "timeout", options.Timeout, "default timeout per test")
	flags.BoolVar(&options.List, "list", false, "list selected tests without running them")
	flags.BoolVar(&options.KeepGoing, "keep-going", false, "continue after a failed test")
	flags.BoolVar(&options.Verbose, "verbose", false, "print compose logs for passing tests too")
	flags.Var(&imageRefs, "image-ref", "override an image env var as NAME=reference; may be passed more than once")

	if err := flags.Parse(args); err != nil {
		return options, fmt.Errorf("%w\n%s", err, strings.TrimSpace(usage.String()))
	}

	options.Images = append(options.Images, images...)
	options.Tests = append(options.Tests, tests...)
	for _, arg := range flags.Args() {
		if strings.Contains(arg, "/") || strings.HasPrefix(arg, "images") {
			options.Tests = append(options.Tests, arg)
		} else {
			options.Images = append(options.Images, arg)
		}
	}
	for _, value := range imageRefs {
		name, ref, ok := strings.Cut(value, "=")
		if !ok || name == "" || ref == "" {
			return options, fmt.Errorf("--image-ref must be NAME=reference, got %q", value)
		}
		options.ImageRefs[name] = ref
	}
	if options.Mode != "fallback" && options.Mode != "version" {
		return options, fmt.Errorf("--mode must be fallback or version, got %q", options.Mode)
	}
	return options, nil
}

func (r *Runner) selectTests() ([]TestCase, error) {
	all, err := r.discoverTests()
	if err != nil {
		return nil, err
	}

	imageFilter := map[string]bool{}
	for _, image := range r.options.Images {
		if !r.metadata.KnownImage(image) {
			return nil, fmt.Errorf("unknown image %q", image)
		}
		imageFilter[image] = true
	}

	testFilter := map[string]bool{}
	for _, value := range r.options.Tests {
		image, name, err := normalizeTestSelector(value)
		if err != nil {
			return nil, err
		}
		if image != "" && !r.metadata.KnownImage(image) {
			return nil, fmt.Errorf("unknown image %q in test selector %q", image, value)
		}
		if image == "" {
			testFilter[name] = true
		} else {
			testFilter[image+"/"+name] = true
		}
	}

	if len(imageFilter) == 0 && len(testFilter) == 0 {
		return all, nil
	}

	var selected []TestCase
	for _, test := range all {
		if imageFilter[test.Image] {
			selected = append(selected, test)
			continue
		}
		if testFilter[test.Image+"/"+test.Name] || testFilter[test.Name] {
			selected = append(selected, test)
		}
	}
	if len(selected) == 0 && len(testFilter) > 0 {
		return nil, fmt.Errorf("no tests matched selector(s): %s", strings.Join(r.options.Tests, ", "))
	}
	return selected, nil
}

func (r *Runner) discoverTests() ([]TestCase, error) {
	var result []TestCase
	for _, image := range r.metadata.Images {
		testsDir := filepath.Join(r.root, "images", image, "tests")
		entries, err := os.ReadDir(testsDir)
		if errors.Is(err, os.ErrNotExist) {
			continue
		}
		if err != nil {
			return nil, err
		}
		sort.Slice(entries, func(i, j int) bool { return entries[i].Name() < entries[j].Name() })
		for _, entry := range entries {
			if !entry.IsDir() {
				continue
			}
			dir := filepath.Join(testsDir, entry.Name())
			if _, err := os.Stat(filepath.Join(dir, "docker-compose.yml")); err != nil {
				continue
			}
			result = append(result, TestCase{Image: image, Name: entry.Name(), Dir: dir})
		}
	}
	return result, nil
}

func normalizeTestSelector(value string) (string, string, error) {
	value = strings.Trim(value, "/")
	parts := strings.Split(value, "/")
	if len(parts) == 1 {
		return "", parts[0], nil
	}
	if len(parts) == 2 {
		return parts[0], parts[1], nil
	}
	if len(parts) >= 4 && parts[0] == "images" && parts[2] == "tests" {
		return parts[1], parts[3], nil
	}
	return "", "", fmt.Errorf("test selector must be name, image/name, or images/image/tests/name: %q", value)
}

func (r *Runner) runOne(test TestCase) testResult {
	start := time.Now()
	fmt.Fprintf(r.stdout, "\n=== RUN %s/%s\n", test.Image, test.Name)

	spec := r.specFor(test)
	env := r.composeEnv(test)
	logDir := filepath.Join(r.root, r.options.LogsDir, test.Image, test.Name)
	if err := os.MkdirAll(logDir, 0o755); err != nil {
		return r.failedBeforeCompose(test, start, fmt.Errorf("create log directory: %w", err))
	}

	result := testResult{
		Test:      test,
		StartedAt: start,
		LogDir:    logDir,
		ExitCodes: map[string]int{},
		Logs:      map[string]string{},
	}

	if down := r.composeOutput(r.ctx, test, env, "down", "-v"); down.Err != nil && r.options.Verbose {
		fmt.Fprintf(r.stderr, "warning: pre-test cleanup failed for %s/%s: %v\n%s\n", test.Image, test.Name, down.Err, down.Output)
	}

	if r.options.Pull {
		pull := r.composeOutput(r.ctx, test, env, "pull", "--ignore-pull-failures")
		if pull.Err != nil {
			result.Failures = append(result.Failures, fmt.Sprintf("docker compose pull failed: %v", pull.Err))
			result.CommandOutput = pull.Output
			result.Interrupted = r.ctx.Err() != nil
			r.finishFailure(result)
			r.cleanup(test, env)
			return result
		}
	}

	if err := r.setup(test, env, spec); err != nil {
		result.Failures = append(result.Failures, err.Error())
		result.Interrupted = r.ctx.Err() != nil
		r.finishFailure(result)
		r.cleanup(test, env)
		return result
	}

	services, err := r.services(test, env)
	if err != nil {
		result.Failures = append(result.Failures, err.Error())
		result.Interrupted = r.ctx.Err() != nil
		r.finishFailure(result)
		r.cleanup(test, env)
		return result
	}

	for _, service := range services {
		if _, ok := spec.ExpectedExitCode[service]; !ok {
			spec.ExpectedExitCode[service] = []int{0}
		}
	}

	upResult := r.runComposeUp(test, env, spec, logDir)
	result.CommandOutput = upResult.Output
	if upResult.TimedOut {
		result.Failures = append(result.Failures, fmt.Sprintf("docker compose up timed out after %s", spec.Timeout))
	}
	for _, failure := range upResult.Failures {
		result.Failures = append(result.Failures, failure)
	}
	result.Interrupted = upResult.Interrupted || r.ctx.Err() != nil
	if result.Interrupted {
		result.Failures = append(result.Failures, "interrupted")
	}

	r.captureDiagnostics(&result, test, env, services, logDir)
	for service, expected := range spec.ExpectedExitCode {
		actual, ok := result.ExitCodes[service]
		if !ok {
			result.Failures = append(result.Failures, fmt.Sprintf("missing exit code for service %s; expected %s", service, formatExitCodes(expected)))
			continue
		}
		if !containsInt(expected, actual) {
			result.Failures = append(result.Failures, fmt.Sprintf("service %s exited %d; expected %s", service, actual, formatExitCodes(expected)))
		}
	}
	if spec.CheckClientIPLog {
		if err := checkClientIPLog(result.Logs["nginx"]); err != nil {
			result.Failures = append(result.Failures, err.Error())
		}
	}

	if len(result.Failures) > 0 {
		r.finishFailure(result)
	} else {
		result.Passed = true
		if r.options.Verbose {
			r.printDiagnostics(result)
		}
		fmt.Fprintf(r.stdout, "--- PASS %s/%s (%s)\n", test.Image, test.Name, time.Since(start).Round(time.Second))
	}

	r.cleanup(test, env)
	return result
}

func (r *Runner) failedBeforeCompose(test TestCase, start time.Time, err error) testResult {
	result := testResult{Test: test, StartedAt: start, Failures: []string{err.Error()}}
	r.finishFailure(result)
	return result
}

func (r *Runner) specFor(test TestCase) testSpec {
	spec := testSpec{
		Timeout:          r.options.Timeout,
		ExpectedExitCode: map[string][]int{},
		OutputConditions: map[string]string{},
	}

	if test.Name == "ServiceHealthcheck" {
		spec.HealthCheck = true
	}

	switch test.Image {
	case "activemq", "cantaloupe", "fcrepo", "mariadb", "nginx", "solr":
		if test.Name == "ServiceHealthcheck" {
			spec.HealthCheck = true
		}
		if test.Image == "nginx" && test.Name == "ServiceLogsClientIp" {
			spec.CheckClientIPLog = true
		}
	case "alpaca":
		if test.Name == "ServiceStartsWithDefaults" {
			spec.OutputConditions["alpaca"] = "[main] (AlpacaDriver) Alpaca started"
		}
	case "base":
		switch test.Name {
		case "EnvironmentPrecedence":
			spec.SetupEtcd = true
		case "ServiceStartsWithDefaults":
			spec.OutputConditions["base"] = "service confd successfully started"
		case "SigIntExitCode":
			spec.ExpectedExitCode["base"] = []int{130}
		case "SigKillExitCode":
			spec.ExpectedExitCode["base"] = []int{137}
			spec.StopAfter = 10 * time.Second
		case "SigTermExitCode":
			spec.ExpectedExitCode["base"] = []int{143}
		case "SigTermExitHandled":
			spec.ExpectedExitCode["base"] = []int{15}
		}
	case "drupal":
		spec.Timeout = 10 * time.Minute
	case "test":
		if test.Name == "IntegrationTests" {
			spec.Timeout = 10 * time.Minute
		}
	case "nginx-php83", "nginx-php84":
		if test.Name == "ServiceLogsClientIp" {
			spec.CheckClientIPLog = true
		}
	}

	return spec
}

func (r *Runner) setup(test TestCase, env []string, spec testSpec) error {
	if !spec.SetupEtcd {
		return nil
	}

	up := r.composeOutput(r.ctx, test, env, "up", "-d", "etcd")
	if up.Err != nil {
		return fmt.Errorf("setup failed while starting etcd: %v\n%s", up.Err, up.Output)
	}
	execResult := r.composeOutput(r.ctx, test, env, "exec", "-T", "etcd", "sh", "/populate-etcd.sh")
	if execResult.Err != nil {
		return fmt.Errorf("setup failed while populating etcd: %v\n%s", execResult.Err, execResult.Output)
	}
	return nil
}

func (r *Runner) services(test TestCase, env []string) ([]string, error) {
	result := r.composeOutput(r.ctx, test, env, "config", "--services")
	if result.Err != nil {
		return nil, fmt.Errorf("docker compose config --services failed: %v\n%s", result.Err, result.Output)
	}
	services := splitLines(result.Output)
	if len(services) == 0 {
		return nil, errors.New("docker compose config returned no services")
	}
	return services, nil
}

type composeUpResult struct {
	Output      string
	ExitCode    int
	TimedOut    bool
	Interrupted bool
	Failures    []string
}

func (r *Runner) runComposeUp(test TestCase, env []string, spec testSpec, logDir string) composeUpResult {
	ctx, cancel := context.WithTimeout(r.ctx, spec.Timeout)
	defer cancel()

	var output bytes.Buffer
	upLog, err := os.Create(filepath.Join(logDir, "up.log"))
	if err != nil {
		return composeUpResult{Failures: []string{fmt.Sprintf("create compose up log: %v", err)}}
	}
	defer upLog.Close()

	command := r.composeCommand(ctx, test, env, "up", "--abort-on-container-exit")
	writer := io.MultiWriter(&output, upLog)
	command.Stdout = writer
	command.Stderr = writer

	if err := command.Start(); err != nil {
		return composeUpResult{Failures: []string{fmt.Sprintf("docker compose up failed to start: %v", err)}}
	}

	wait := make(chan commandResult, 1)
	done := make(chan struct{})
	var final commandResult
	go func() {
		err := command.Wait()
		final = commandResult{
			Output:   output.String(),
			ExitCode: exitCode(err),
			Err:      err,
			TimedOut: ctx.Err() == context.DeadlineExceeded,
		}
		wait <- final
		close(done)
	}()

	var monitorFailures []string
	if spec.StopAfter > 0 {
		go func() {
			timer := time.NewTimer(spec.StopAfter)
			defer timer.Stop()
			select {
			case <-timer.C:
				ctx, cancel := r.newCleanupContext()
				_ = r.composeOutput(ctx, test, env, "stop")
				cancel()
			case <-done:
			}
		}()
	}

	if spec.HealthCheck {
		if err := r.waitForHealthy(ctx, test, env, done); err != nil {
			monitorFailures = append(monitorFailures, err.Error())
		} else {
			ctx, cancel := r.newCleanupContext()
			_ = r.composeOutput(ctx, test, env, "stop")
			cancel()
		}
	}

	if len(spec.OutputConditions) > 0 {
		if err := r.waitForOutput(ctx, test, env, spec.OutputConditions, done); err != nil {
			monitorFailures = append(monitorFailures, err.Error())
		} else {
			ctx, cancel := r.newCleanupContext()
			_ = r.composeOutput(ctx, test, env, "stop")
			cancel()
		}
	}

	<-done
	return composeUpResult{
		Output:      final.Output,
		ExitCode:    final.ExitCode,
		TimedOut:    final.TimedOut,
		Interrupted: errors.Is(ctx.Err(), context.Canceled),
		Failures:    monitorFailures,
	}
}

func (r *Runner) waitForHealthy(ctx context.Context, test TestCase, env []string, done <-chan struct{}) error {
	ticker := time.NewTicker(5 * time.Second)
	defer ticker.Stop()
	attempts := 20
	for attempt := 1; attempt <= attempts; attempt++ {
		healthy, err := r.anyHealthyContainer(ctx, test, env)
		if err == nil && healthy {
			fmt.Fprintf(r.stdout, "healthy service found for %s/%s\n", test.Image, test.Name)
			return nil
		}
		select {
		case <-ctx.Done():
			return fmt.Errorf("no service reported healthy before timeout: %w", ctx.Err())
		case <-done:
			return errors.New("docker compose up exited before any service reported healthy")
		case <-ticker.C:
		}
	}
	return fmt.Errorf("no service reported healthy after %d attempts", attempts)
}

func (r *Runner) anyHealthyContainer(ctx context.Context, test TestCase, env []string) (bool, error) {
	ps := r.composeOutput(ctx, test, env, "ps", "-q")
	if ps.Err != nil {
		return false, ps.Err
	}
	containers := splitLines(ps.Output)
	for _, container := range containers {
		inspect := commandOutput(ctx, test.Dir, env, "docker", "inspect", container)
		if inspect.Err != nil {
			continue
		}
		var data []struct {
			State struct {
				Health *struct {
					Status string `json:"Status"`
				} `json:"Health"`
			} `json:"State"`
		}
		if err := json.Unmarshal([]byte(inspect.Output), &data); err != nil {
			continue
		}
		if len(data) > 0 && data[0].State.Health != nil && data[0].State.Health.Status == "healthy" {
			return true, nil
		}
	}
	return false, nil
}

func (r *Runner) waitForOutput(ctx context.Context, test TestCase, env []string, conditions map[string]string, done <-chan struct{}) error {
	found := map[string]bool{}
	ticker := time.NewTicker(2 * time.Second)
	defer ticker.Stop()
	for {
		for service, needle := range conditions {
			if found[service] {
				continue
			}
			logs := r.composeOutput(ctx, test, env, "logs", "--no-color", service)
			if strings.Contains(logs.Output, needle) {
				found[service] = true
				fmt.Fprintf(r.stdout, "found expected output in %s logs: %q\n", service, needle)
			}
		}
		if len(found) == len(conditions) {
			return nil
		}
		select {
		case <-ctx.Done():
			return fmt.Errorf("missing expected log output before timeout: %s", missingOutputConditions(conditions, found))
		case <-done:
			return fmt.Errorf("docker compose up exited before expected log output appeared: %s", missingOutputConditions(conditions, found))
		case <-ticker.C:
		}
	}
}

func missingOutputConditions(conditions map[string]string, found map[string]bool) string {
	var missing []string
	for service, needle := range conditions {
		if !found[service] {
			missing = append(missing, fmt.Sprintf("%s must contain %q", service, needle))
		}
	}
	sort.Strings(missing)
	return strings.Join(missing, "; ")
}

func (r *Runner) captureDiagnostics(result *testResult, test TestCase, env []string, services []string, logDir string) {
	ctx, cancel := r.newCleanupContext()
	defer cancel()

	ps := r.composeOutput(ctx, test, env, "ps", "--all")
	result.ComposePS = ps.Output
	_ = os.WriteFile(filepath.Join(logDir, "ps.txt"), []byte(ps.Output), 0o644)
	if ps.Err != nil {
		result.Failures = append(result.Failures, fmt.Sprintf("docker compose ps --all failed: %v", ps.Err))
	}

	result.ExitCodes = r.exitCodes(test, env)
	for _, service := range services {
		logs := r.composeOutput(ctx, test, env, "logs", "--no-color", service)
		result.Logs[service] = logs.Output
		_ = os.WriteFile(filepath.Join(logDir, service+".log"), []byte(logs.Output), 0o644)
		if logs.Err != nil {
			result.Failures = append(result.Failures, fmt.Sprintf("docker compose logs %s failed: %v", service, logs.Err))
		}
	}
}

func (r *Runner) exitCodes(test TestCase, env []string) map[string]int {
	result := map[string]int{}
	ctx, cancel := r.newCleanupContext()
	defer cancel()

	ps := r.composeOutput(ctx, test, env, "ps", "-aq")
	for _, container := range splitLines(ps.Output) {
		inspect := commandOutput(ctx, test.Dir, env, "docker", "inspect", container)
		if inspect.Err != nil {
			continue
		}
		var data []struct {
			Config struct {
				Labels map[string]string `json:"Labels"`
			} `json:"Config"`
			State struct {
				ExitCode int `json:"ExitCode"`
			} `json:"State"`
		}
		if err := json.Unmarshal([]byte(inspect.Output), &data); err != nil || len(data) == 0 {
			continue
		}
		service := data[0].Config.Labels["com.docker.compose.service"]
		if service != "" {
			result[service] = data[0].State.ExitCode
		}
	}
	return result
}

func checkClientIPLog(logs string) error {
	pattern := regexp.MustCompile(`"GET / HTTP/1\.1" [0-9]{3} [0-9]+ "-" "curl/[^"]+" "1\.2\.3\.4"`)
	if pattern.MatchString(logs) {
		return nil
	}
	return errors.New(`nginx logs did not contain a request with X-Forwarded-For "1.2.3.4"`)
}

func (r *Runner) finishFailure(result testResult) {
	fmt.Fprintf(r.stdout, "--- FAIL %s/%s (%s)\n", result.Test.Image, result.Test.Name, time.Since(result.StartedAt).Round(time.Second))
	r.printDiagnostics(result)
}

func (r *Runner) printDiagnostics(result testResult) {
	if len(result.Failures) > 0 {
		fmt.Fprintln(r.stdout, "\nFailure reasons:")
		for _, failure := range result.Failures {
			fmt.Fprintf(r.stdout, "  - %s\n", failure)
		}
	}
	if result.LogDir != "" {
		fmt.Fprintf(r.stdout, "\nSaved logs: %s\n", result.LogDir)
	}
	if strings.TrimSpace(result.ComposePS) != "" {
		fmt.Fprintln(r.stdout, "\ndocker compose ps --all:")
		fmt.Fprintln(r.stdout, strings.TrimRight(result.ComposePS, "\n"))
	}
	if len(result.ExitCodes) > 0 {
		fmt.Fprintln(r.stdout, "\nContainer exit codes:")
		for _, service := range sortedKeys(result.ExitCodes) {
			fmt.Fprintf(r.stdout, "  %s: %d\n", service, result.ExitCodes[service])
		}
	}
	if strings.TrimSpace(result.CommandOutput) != "" {
		fmt.Fprintln(r.stdout, "\ndocker compose up output:")
		fmt.Fprintln(r.stdout, strings.TrimRight(result.CommandOutput, "\n"))
	}
	if len(result.Logs) > 0 {
		fmt.Fprintln(r.stdout, "\nService logs:")
		for _, service := range sortedKeys(result.Logs) {
			fmt.Fprintf(r.stdout, "\n--- %s ---\n", service)
			fmt.Fprintln(r.stdout, strings.TrimRight(result.Logs[service], "\n"))
		}
	}
}

func (r *Runner) cleanup(test TestCase, env []string) {
	ctx, cancel := r.newCleanupContext()
	defer cancel()

	down := r.composeOutput(ctx, test, env, "down", "-v")
	if down.Err != nil {
		fmt.Fprintf(r.stderr, "warning: cleanup failed for %s/%s: %v\n%s\n", test.Image, test.Name, down.Err, down.Output)
	}
}

func (r *Runner) newCleanupContext() (context.Context, context.CancelFunc) {
	return context.WithTimeout(context.Background(), 30*time.Second)
}

type testResult struct {
	Test          TestCase
	StartedAt     time.Time
	Passed        bool
	Failures      []string
	LogDir        string
	ComposePS     string
	ExitCodes     map[string]int
	Logs          map[string]string
	CommandOutput string
	Interrupted   bool
}

func (r *Runner) composeEnv(test TestCase) []string {
	env := map[string]string{}
	for _, value := range os.Environ() {
		key, item, ok := strings.Cut(value, "=")
		if ok {
			env[key] = item
		}
	}

	computed := r.resolver.envFor(test.Image)
	for key, value := range computed {
		if _, exists := env[key]; !exists {
			env[key] = value
		}
	}
	for key, value := range r.options.ImageRefs {
		env[key] = value
	}
	if home := os.Getenv("HOME"); home != "" {
		env["HOME"] = home
	}

	keys := sortedKeys(env)
	result := make([]string, 0, len(keys))
	for _, key := range keys {
		result = append(result, key+"="+env[key])
	}
	return result
}

func (r *imageResolver) envFor(currentImage string) map[string]string {
	env := map[string]string{}
	for _, image := range r.metadata.Images {
		env[imageEnvName(image)] = r.ref(image)
	}
	for _, image := range r.metadata.Images {
		if r.metadata.IncludeLatestTag(image) {
			env[imageEnvName(r.metadata.PublishedImage(image))] = r.ref(image)
		}
	}
	env[imageEnvName(r.metadata.PublishedImage(currentImage))] = r.ref(currentImage)
	return env
}

func (r *imageResolver) ref(image string) string {
	mode := r.mode
	fallback := r.fallbackTag
	if r.useBuildImages {
		mode = contextTagMode(image, r.mode, r.buildImages)
		if mode == "version" && r.mode == "fallback" {
			fallback = "main"
		}
	}
	tag, err := r.metadata.FirstTag(image, mode, fallback)
	if err != nil {
		tag = normalizeDockerTag(fallback)
	}
	return fmt.Sprintf("%s/%s:%s", r.repository, r.metadata.PublishedImage(image), tag)
}

func imageEnvName(image string) string {
	replacer := strings.NewReplacer("-", "_", ".", "_")
	return strings.ToUpper(replacer.Replace(image))
}

func (r *Runner) composeOutput(ctx context.Context, test TestCase, env []string, args ...string) commandResult {
	return commandOutput(ctx, test.Dir, env, "docker", append([]string{"compose"}, args...)...)
}

func (r *Runner) composeCommand(ctx context.Context, test TestCase, env []string, args ...string) *exec.Cmd {
	command := exec.CommandContext(ctx, "docker", append([]string{"compose"}, args...)...)
	command.Dir = test.Dir
	command.Env = env
	return command
}

type commandResult struct {
	Output   string
	ExitCode int
	Err      error
	TimedOut bool
}

func commandOutput(ctx context.Context, dir string, env []string, name string, args ...string) commandResult {
	command := exec.CommandContext(ctx, name, args...)
	command.Dir = dir
	command.Env = env
	var output bytes.Buffer
	command.Stdout = &output
	command.Stderr = &output
	err := command.Run()
	return commandResult{
		Output:   output.String(),
		ExitCode: exitCode(err),
		Err:      err,
		TimedOut: ctx.Err() == context.DeadlineExceeded,
	}
}

func exitCode(err error) int {
	if err == nil {
		return 0
	}
	var exitErr *exec.ExitError
	if errors.As(err, &exitErr) {
		return exitErr.ExitCode()
	}
	return -1
}

func containsInt(values []int, needle int) bool {
	for _, value := range values {
		if value == needle {
			return true
		}
	}
	return false
}

func formatExitCodes(values []int) string {
	parts := make([]string, len(values))
	for index, value := range values {
		parts[index] = strconv.Itoa(value)
	}
	return "[" + strings.Join(parts, ", ") + "]"
}
