# New Bounded Context Guidance

This guide is for the owner of a new repository that has just been created from `nhs-notify-repository-template`.
Work through it once, then [delete this file](#7-delete-this-file).

The template is a starting point, not a finished project.
Some of it works unchanged, some of it is a placeholder you must fill in, and some of it is an example you should delete.
Anything you keep, you maintain: unused examples still attract Dependabot PRs, vulnerability findings and CI time.

## Contents

- [1. Make the repository yours](#1-make-the-repository-yours)
- [2. Remove the examples](#2-remove-the-examples)
- [3. Configure the build and test entry points](#3-configure-the-build-and-test-entry-points)
- [4. Finish the placeholder workflows](#4-finish-the-placeholder-workflows)
- [5. Understand the tooling you are keeping](#5-understand-the-tooling-you-are-keeping)
- [6. Verify](#6-verify)
- [7. Delete this file](#7-delete-this-file)

## Legend

| Label | Meaning |
| ----- | ------- |
| **Keep** | Works out of the box. Leave it alone; changes here drift from the template. |
| **Configure** | Works once you supply repository-specific values. |
| **Placeholder** | Does nothing useful yet (for example `echo` steps). You must implement it or delete it. |
| **Example** | Illustrates a pattern. Copy what you need, then delete it. |

## 1. Make the repository yours

| File | Action |
| ---- | ------ |
| [README.md](./README.md) | Replace the whole template text: name, badges (CI/CD and Sonar badges still point at the template), purpose, setup, usage, design, contacts. Keep the prerequisites and `make config` instructions if still true. |
| [.github/CODEOWNERS](./.github/CODEOWNERS) | Set your team as owners. |
| [AGENTS.md](./AGENTS.md) | Keep. Update the layout section to match your repository, and add nested `AGENTS.md` files for areas with specific rules. |
| [project.code-workspace](./project.code-workspace) | Rename or adjust the workspace folders. |
| [package.json](./package.json) | Set `name`, and update the `workspaces`/`pnpm-workspace.yaml` globs to match your real packages. |
| `.github/ISSUE_TEMPLATE/` | Keep, or replace with your own. |

**Tip**: Search the repository for `repository-template` and `nhs-england-tools` and update remaining references that are not template-sync related.

## 2. Remove the examples

These exist to show a pattern. Delete them and copy the bits you need first.

| Path | What it shows | Action |
| ---- | ------------- | ------ |
| `lambdas/example-lambda/` | A TypeScript lambda with Jest `config`, `build.sh` and a `Dockerfile`. | **Example.** Copy as the basis for your first lambda, then rename or delete. |
| `containers/example-app/` | A containerised Node app with a `Dockerfile` and Jest. | **Example.** Delete unless you ship a container. If you delete it, also remove any `Dockerfile` based jobs and `docker` Dependabot entries you do not use. |
| `infrastructure/terraform/components/examplecomponent/` | A Terraform component wiring a zip lambda and a container lambda, remote state and `tfscaffold` locals. | **Example.** Rename it to your component, remove the lambda modules you do not need. `pre.sh.disabled` is an optional pre-hook: rename to `pre.sh` only if needed. |
| `infrastructure/terraform/modules/` | Empty (`.gitkeep`). | **Keep.** Put reusable modules here. |
| `tests/` | Empty (`.gitkeep`). | **Keep.** Put cross-cutting tests here. |
| `.gitleaksignore` | Historical template findings (docs and sample files that no longer exist). | **Delete the entries** and start empty. Add entries only for genuine false positives, with a comment. |
| `README.md` mermaid example, "Modularity" section | Documentation prompts. | Replace with real content. |

After deleting, regenerate the `lockfile` (`pnpm install`) and check that `pnpm-workspace.yaml` and `package.json` only reference paths that exist.

## 3. Configure the build and test entry points

[`Makefile`](./Makefile) and [scripts/tests/](./scripts/tests) are the single entry point for both local development and CI.
CI calls `make <target>`; do not put logic only in workflow YAML.

### `Makefile` targets

| Target | State | What to do |
| ------ | ----- | ---------- |
| `build` | **Template-specific, broken for you** (runs `cd docs && make build`; there is no `docs/`) | Replace with your build, for example `pnpm run lambda-build`, or remove. |
| `publish`, `deploy` | **Placeholder** | Implement, or remove if the pipeline does not use them. |
| `clean` | **Configure** | Add project clean-up. |
| `config` | **Configure** | Remove the `cd docs && make install` line unless you add a `docs/` site. Keep `_install-dependencies` and `version`. |

Run `make help` to list every target.
Targets in [scripts/init.mk](./scripts/init.mk) (`githooks-config`, `githooks-run`, `runner-act`, `help`) are **Keep**.

### Test targets (`scripts/tests/test.mk`)

`make test` runs the test targets. Each `make test-<name>` runs `scripts/tests/<name>.sh` if it exists.
A missing script means that test type is skipped locally; the CI job for it will fail if you call it, so only wire up the ones you have.

| Target | Script in template | State |
| ------ | ------------------ | ----- |
| `test-unit` | `unit.sh` | **Works** for `pnpm` workspaces: installs, runs `test:unit:silent`, merges `lcov` into `.reports/lcov.info` (used by Sonar). Needs a `test:unit:silent` script in each package. |
| `test-lint` | `lint.sh` | **Works** if your packages define `lint`. |
| `test-typecheck` | `typecheck.sh` | **Works** if your packages define `typecheck`. |
| `test-coverage` | none | **Placeholder.** Add `scripts/tests/coverage.sh` or drop the CI job. |
| `test-contract`, `test-integration`, `test-security`, `test-ui`, `test-ui-performance`, `test-accessibility` | none | **Placeholder.** Add a script in `scripts/tests/` only when you have that kind of test. |
| `test-load`, `test-capacity`, `test-soak`, `test-response-time` | none | **Placeholder.** Same. |

`scripts/tests/style.sh` is called by pre-commit style checks and is **Keep**.
Do not edit `scripts/tests/test.mk` itself (it is maintained in the template).

## 4. Finish the placeholder workflows

All workflows live in [.github/workflows/](./.github/workflows). Entry point is `cicd-1-pull-request.yaml`, which calls the four stage files.

### Stage 1: commit ([stage-1-commit.yaml](./.github/workflows/stage-1-commit.yaml))

**Keep** all of it. These are quality gates that work with no configuration:

| Job | Purpose |
| --- | ------- |
| Scan secrets | Gitleaks. |
| Validate action SHA pins | Fails if a GitHub Action is not pinned to a commit SHA. |
| Check file format | EditorConfig compliance. |
| Check Markdown format | `markdownlint`. |
| Run `terraform-docs` | Fails if generated Terraform docs are stale (run `make terraform-docs`). |
| Check English usage | Vale prose linting. |
| Check TODO usage | Every `TODO` must reference a ticket, for example `TODO: CCM-12345`. |
| Detect/Lint Terraform | Only runs when Terraform files changed. |
| Count lines of code | Report uploaded to the shared reporting bucket. |
| Scan dependencies | Syft SBOM and Grype vulnerability scan. |

### Stage 2: test ([stage-2-test.yaml](./.github/workflows/stage-2-test.yaml))

**Keep** unit, lint, `typecheck` and coverage jobs, which call the `make test-*` targets in [section 3](#3-configure-the-build-and-test-entry-points).
Remove the `test-coverage` job if you do not add a coverage script.
`perform-static-analysis` (Sonar) is **Configure**: needs the Sonar secrets.

### Stage 3: build ([stage-3-build.yaml](./.github/workflows/stage-3-build.yaml))

**Placeholder.** Jobs `Artefact 1` and `Artefact n` only run `echo`.
Replace them with real jobs that call `make build` (or specific build targets) and upload artefacts, or delete the stage and its `build` job in `cicd-1-pull-request.yaml` if you build elsewhere.

### Stage 4: acceptance ([stage-4-acceptance.yaml](./.github/workflows/stage-4-acceptance.yaml))

**Placeholder.** `Environment set up` only runs `echo` for "create infrastructure", "update database" and "deploy application".
The contract, security, UI and UI performance jobs call `make test-*` targets that do not exist in the template and will fail if you keep them without a script.
Keep only the jobs you implement. Dynamic environments are normally created by the `pr_*` workflows below, so you may not need the set-up job at all.

### Other workflows

| Workflow | State | Action |
| -------- | ----- | ------ |
| `cicd-4-pr-title-check.yaml` | **Keep** | Enforces PR title format. |
| `scorecard.yml` | **Keep** | OpenSSF Scorecard. |
| `scheduled-repository-template-sync.yaml` | **Keep** | Monthly PR with drift from the template. Review it; list intentional differences in `scripts/config/.repository-template-sync-ignore`. |
| `cicd-3-deploy.yaml` | **Example, remove** | Deploys a `docs/` site to GitHub Pages. Delete it unless you create a docs site. |
| `pr_create_dynamic_env.disabled` | **Placeholder, disabled** | Dispatches `nhs-notify-internal` to create a per-PR environment. |
| `pr_destroy_dynamic_env.disabled` | **Placeholder, disabled** | Tears that environment down. |
| `pr_closed.disabled` | **Placeholder, disabled** | Cleans up on PR close. |
| `release_created.disabled` | **Placeholder, disabled** | Dispatches a static environment deployment when a release is published. |

To enable a `.disabled` workflow, rename it to `.yaml` and resolve every `## Replace with ...` comment:

| Value | Meaning |
| ----- | ------- |
| `targetAccountGroup` | The account group in `nhs-notify-internal` your component deploys to (`dev` for PR environments, `nonprod` for releases). |
| `targetComponent` / `component` list | Your Terraform component name(s) under `infrastructure/terraform/components/`. |
| `targetWorkflow` | The `nhs-notify-internal` workflow that deploys your bounded context. |

Ask the platform team for the correct values if unsure. Delete the `.disabled` files you will not use.
Remove the `## Replace` comments after resolving them: they break the line continuation in a shell command if left inline.

## 5. Understand the tooling you are keeping

| Tool | `Config` | Purpose | Keep? |
| ---- | ------ | ------- | ----- |
| pre-commit | [scripts/config/pre-commit.yaml](./scripts/config/pre-commit.yaml) | Runs the same checks as stage 1 before commit. Install with `make config`, run with `make githooks-run`. | Yes |
| Gitleaks | `scripts/config/gitleaks.toml` | Secret scanning. | Yes |
| Vale | `scripts/config/vale/` | Prose linting for Markdown (NHS style, British English). Catches spelling and style slips in docs. Add words to the vocabulary rather than disabling it. | Yes, unless you have no Markdown (unlikely) |
| `markdownlint` | `scripts/config/markdownlint.yaml` | Markdown structure. | Yes |
| EditorConfig | `.editorconfig` | Whitespace and line endings. | Yes |
| Syft and Grype | `scripts/config/syft.yaml`, `grype.yaml` | SBOM generation and dependency vulnerability scan (`make githooks-dependencies`). | Yes |
| `Hadolint` | `scripts/config/hadolint.yaml` | `Dockerfile` linting. | Only if you have `Dockerfiles` |
| `terraform-docs` | `scripts/config/terraform-docs.yml` | Generates Terraform component `READMEs`. | Only if you have Terraform |
| SonarCloud | `scripts/config/sonar-scanner.properties` | Static analysis and coverage gate. | Yes |
| Dependabot | `.github/dependabot.yaml` | Automated dependency PRs. Ecosystems are `docker`, `github-actions`, `npm`, `pip`, `terraform` and `bundler`. | Yes, but remove ecosystems you do not use and update the commit-message prefix to your Jira project. |
| `.tool-versions` | asdf | Pins Node, `pnpm`, Terraform, Python and others. CI reads versions from here. Remove tools you do not use; bump versions deliberately. | Yes |
| `.devcontainer/` | VS Code `dev` container | Optional. Delete if the team does not use `dev` containers. | Optional |
| `scripts/docker/` | Docker build, lint and `goss` helpers | Delete if you have no containers. | Optional |
| `scripts/terraform/`, `infrastructure/terraform/bin/terraform.sh` | Terraform wrappers (`tfscaffold`) | Keep if you have Terraform. Update `etc/global.tfvars` for your domain, then follow the `tfscaffold` bootstrap docs to create the state bucket. | Optional |

## 6. Verify

From the repository root:

```shell
make config
make githooks-run
make test
```

Then open a draft PR and check that every CI/CD stage is green or intentionally removed.
There should be no job that only runs `echo`.

Checklist:

- [ ] README describes this bounded context, no template text or template badges remain
- [ ] All examples removed or renamed
- [ ] `.gitleaksignore` reset
- [ ] Stage 3 and stage 4 contain real jobs or have been removed
- [ ] `.disabled` workflows enabled with values filled in, or deleted
- [ ] `cicd-3-deploy.yaml` deleted unless publishing docs
- [ ] Dependabot ecosystems trimmed to those in use
- [ ] Sonar secrets set and badge updated

## 7. Delete this file

Once the checklist above is complete, delete this file and remove any links to it:

```shell
git rm NEW-BOUNDED-CONTEXT-GUIDANCE.md
```
