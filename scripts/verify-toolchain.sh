#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="${ROOT_DIR}/build/wasm-toolchain"

for tool in em++ emcmake cmake ninja python3; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        echo "ERROR: required tool not found in PATH: $tool" >&2
        exit 1
    fi
done

echo "== Toolchain versions =="
em++ --version | head -n 2
cmake --version | head -n 1
ninja --version
python3 --version

echo "== Configure WebAssembly smoke test =="
rm -rf "$BUILD_DIR"
emcmake cmake -S "$ROOT_DIR" -B "$BUILD_DIR" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release

echo "== Compile WebAssembly smoke test =="
cmake --build "$BUILD_DIR" --parallel

if [[ ! -s "$BUILD_DIR/fgweb_toolchain_probe.html" ]]; then
    echo "ERROR: expected HTML launcher was not generated." >&2
    exit 1
fi

if ! find "$BUILD_DIR" -maxdepth 1 -type f -name '*.wasm' -size +0c | grep -q .; then
    echo "ERROR: expected non-empty .wasm output was not generated." >&2
    exit 1
fi

echo "SUCCESS: Emscripten generated an HTML launcher and a non-empty WASM module."
echo "Output directory: $BUILD_DIR"
