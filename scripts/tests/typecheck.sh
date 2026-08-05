#!/bin/bash

set -euo pipefail

cd "$(git rev-parse --show-toplevel)"

# run typecheck
pnpm install --frozen-lockfile
pnpm run generate-dependencies
pnpm run typecheck
