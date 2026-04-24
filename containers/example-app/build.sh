#!/bin/bash

set -euo pipefail

rm -rf dist

pnpm exec esbuild \
    --bundle \
    --minify \
    --sourcemap \
    --target=es2022 \
    --platform=node \
    --entry-names=[name] \
    --outdir=dist \
    src/server.ts
