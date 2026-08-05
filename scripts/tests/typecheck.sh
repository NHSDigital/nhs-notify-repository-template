#!/bin/bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# run typecheck
pnpm install --ignore-scripts --frozen-lockfile
pnpm run generate-dependencies
pnpm run typecheck
