#!/usr/bin/env bash
# Native tests of the pure rules, plus type-checks of both packages for wasm.
set -euo pipefail
cd "$(dirname "$0")/.."
odin test src/game -collection:tggd=src -o:speed -define:ODIN_TEST_THREADS=1
odin check src/game -collection:tggd=src -target:js_wasm32 -no-entry-point -vet-shadowing -vet-unused
odin check src/web -collection:tggd=src -target:js_wasm32 -vet-shadowing -vet-unused
