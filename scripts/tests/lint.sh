#!/bin/bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# Run linting across all workspaces
pnpm install --frozen-lockfile
pnpm run lint
