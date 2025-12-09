# AGENTS.md
<!-- vale off -->

## Scope

This file is for **AI agents** working within NHS Notify repositories.
Humans should read `README.md` and the docs for how we actually work day to day.
Keep anything language or tool-specific in nested `AGENTS.md` files (for example under `infrastructure/terraform` or `lambdas`).

## Repository Layout (high level)

At a glance, the main areas are:

- `infrastructure/terraform/` – Terraform components, and shared modules for AWS accounts and environments.
- `lambdas/` – TypeScript lambda projects (each with their own `package.json`, Jest config, etc.). Root level packages.json defines workspaces and scripts. Tests for the lambda are stored in `lambdas/{name}/src/__test`.
- `src/` and `utils/` – Shared code and utilities (for example `utils/logger`).
- `docs/` – Documentation site, ADRs, RFCS, and other long‑form docs.
- `.github/workflows/` and `.github/actions/` – GitHub Actions workflows and composite actions.
- `scripts/` – Helper scripts and tooling used by humans and workflows.
- `tests/` – Cross‑cutting tests and harnesses for the repo.

Agents should look for a nested `AGENTS.md` in or near these areas before making non‑trivial changes.

## Root package.json – role and usage

The root `package.json` is the orchestration manifestgit co for this repo. It does not ship application code; it wires up shared dev tooling and delegates to workspace-level projects.

- Workspaces: Declares the set of npm workspaces (e.g. under `lambdas/`, `utils/`, `tests/`, `scripts/`). Agents should add a new workspace path here when introducing a new npm project.
- Scripts: Provides top-level commands that fan out across workspaces using `--workspaces` (lint, typecheck, unit tests) and project-specific runners (e.g. `lambda-build`).
- Dev tool dependencies: Centralises Jest, TypeScript, ESLint configurations and plugins to keep versions consistent across workspaces. Workspace projects should rely on these unless a local override is strictly needed.
- Overrides/resolutions: Pins transitive dependencies (e.g. Jest/react-is) to avoid ecosystem conflicts. Agents must not remove overrides without verifying tests across all workspaces.

Agent guidance:

- Before adding or removing a workspace, update the root `workspaces` array and ensure CI scripts still succeed with `npm run lint`, `npm run typecheck`, and `npm run test:unit` at the repo root.
- When adding repo-wide scripts, keep names consistent with existing patterns (e.g. `lint`, `lint:fix`, `typecheck`, `test:unit`, `lambda-build`) and prefer `--workspaces` fan-out.
- Do not publish from the root. If adding a new workspace intended for publication, mark that workspace package as `private: false` and keep the root as private.
- Validate changes by running the repo pre-commit hooks: `make githooks-run`.

Success criteria for changes affecting the root `package.json`:

- `npm run lint`, `npm run typecheck`, and `npm run test:unit` pass at the repo root.
- Workspace discovery is correct (new projects appear under `npm run typecheck --workspaces`).
- No regression in lambda build tooling (`npm run lambda-build`).

## What Agents Can / Can’t Do

Agents **can**:

- Propose changes to code, tests, GitHub workflows, Terraform, and docs.
- Suggest new scripts, Make targets, or composite actions by copying existing patterns.
- Run tests to validate proposed solutions.

Agents **must not**:

- Create, push, or merge branches or PRs.
- Introduce new technologies, providers, or big architectural patterns without clearly calling out that an ADR is needed.
- Invent secrets or hard‑code real credentials anywhere.

## Working With This Repo

- All dependencies can be setup using the command `make config` from the repository root.
- **Don’t guess commands.** Derive them from what’s already here or ask for guidance form the human user:
  - Prefer `Makefile` targets, `scripts/`, `.github/workflows/`, and `.github/actions/`.
- For Terraform, follow `infrastructure/terraform/{components,modules}` and respect `versions.tf`.
- Keep diffs small and focused. Avoid mixing refactors with behaviour changes unless you explain why.

## Quality Expectations

When proposing a change, agents should:

- Keep code formatted and idiomatic (Terraform, TypeScript, Bash, YAML).
- Stick to existing patterns where available (for example `utils/logger`, composite actions under `.github/actions`).
- Use available information on best practices within the specific area of the codebase.
- **Always** run local pre-commit hooks from the repo root with:

  ```sh
    pre-commit run \
    --config scripts/config/pre-commit.yaml
  ```

  to catch formatting and basic lint issues. Domain specific checks will be defined in appropriate nested AGENTS.md files.

- Suggest at least one extra validation step (for example `npm test` in a lambda, or triggering a specific workflow).
- Any required follow up activites which fall outside of the current task's scope should be clearly marked with a 'TODO: CCM-12345' comment. The human user should be prompted to create and provide a JIRA ticket ID to be added to the comment.

## Security & Safety

- All agent-generated changes **must** be reviewed and merged by a human.
- Provide a concise, clear summary of the proposed changes to make human review easier (what changed, why (refer directly to the guidance in relevant Agents.MD files when applicable), and how it was validated). It should be directly pastable into the PR description and make it clear that AI assistance was used.
- Never output real secrets or tokens. Use placeholders and rely on the GitHub/AWS secrets already wired into workflows.

## Escalation / Blockers

If you are blocked by an unavailable secret, unclear architectural constraint, missing upstream module, or failing tooling you cannot safely fix, stop and ask a single clear clarifying question rather than guessing.
