PLATFORMS ?= linux/amd64,linux/arm64

build:
	$(MAKE) -C .. version
	ver=$$(head -n 1 ../.version 2> /dev/null || echo unknown); \
	verb=$$(echo $$ver | sed 's/\+.*//'); \
	echo "version: $$verb"; \
	BUILDKIT_PROGRESS=plain pnpm dlx @devcontainers/cli build --workspace-folder .. --config ./devcontainer-template.json --no-cache --image-name "ghcr.io/nhsdigital/nhs-notify-template-repository:$$verb"

publish:
	$(MAKE) -C .. version
	ver=$$(head -n 1 ../.version 2> /dev/null || echo unknown); \
	verb=$$(echo $$ver | sed 's/\+.*//'); \
	echo "version: $$verb"; \
	BUILDKIT_PROGRESS=plain pnpm dlx @devcontainers/cli build --workspace-folder .. --config ./devcontainer-template.json --platform $(PLATFORMS) --push --no-cache --image-name "ghcr.io/nhsdigital/nhs-notify-template-repository:$$verb" --image-name "ghcr.io/nhsdigital/nhs-notify-template-repository:latest"

debug:
	pnpm dlx @devcontainers/cli up --workspace-folder .. --config ./devcontainer-template.json
	pnpm dlx @devcontainers/cli exec --workspace-folder .. --config ./devcontainer-template.json ls -la ./.devcontainer
	pnpm dlx @devcontainers/cli exec --workspace-folder .. --config ./devcontainer-template.json cat ./.devcontainer/packages.txt
