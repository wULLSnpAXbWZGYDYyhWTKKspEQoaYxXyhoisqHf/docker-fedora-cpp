dcmd = docker
dfile = Dockerfile
dtag = immawanderer/fedora-cpp:testbuild
dargs = build -t $(dtag) --no-cache --pull - < $(dfile)
cleanargs = image rm -f $(dtag)
pruneargs = system prune -af
dargskaniko = run --rm -it -w=$(kanikowdir) -v $$PWD:$(kanikowdir):z
kanikoexecutorimg = gcr.io/kaniko-project/executor:v1.8.1-debug
kanikowdir = /src
kanikocontext = .
kanikoargs = -f=$(dfile) -c=$(kanikocontext) --use-new-run --snapshotMode=redo --build-arg BUILD_DATE=$(build_date) --build-arg VCS_REF=$(vcs_ref) --no-push
vcs_ref = $$(git rev-parse --short HEAD)
build_date= $$(date -u +"%Y-%m-%dT%H:%M:%SZ")
hadolintimg = hadolint/hadolint
hadolinttag = v2.9.3-alpine
hadolintargs = run --rm -i -v $$PWD/.hadolint.yaml:/root/.config/hadolint.yaml

.PHONY: hadolint build kaniko clean test prune

hadolint:
	$(dcmd) $(hadolintargs) $(hadolintimg):$(hadolinttag) < $(dfile)

kaniko:
	$(dcmd) $(dargskaniko) $(kanikoexecutorimg) $(kanikoargs)

build:
	$(dcmd) $(dargs)

clean:
	$(dcmd) $(cleanargs)

test: hadolint build kaniko

prune:
	$(dcmd) $(pruneargs)
