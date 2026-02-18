#!/bin/bash

set -euo pipefail

rm -rf dist

npx esbuild \
    --bundle \
    --minify \
    --sourcemap \
    --target=es2020 \
    --platform=node \
    --loader:.node=file \
    --entry-names=[name] \
    --outdir=dist \
    src/index.ts ## Update this to include your lambda's entry point
