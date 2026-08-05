#!/bin/bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# Run linting across all workspaces
pnpm install --ignore-scripts --frozen-lockfile
pnpm run lint
