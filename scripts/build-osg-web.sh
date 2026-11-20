#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VERSIONS_FILE="${ROOT_DIR}/third_party/versions.env"
BUILD_ROOT="${ROOT_DIR}/build/dependencies"
SOURCE_DIR="${BUILD_ROOT}/src/openscenegraph"
BUILD_DIR="${BUILD_ROOT}/build/openscenegraph"
INSTALL_DIR="${BUILD_ROOT}/install"
MANIFEST="${BUILD_ROOT}/dependency-manifest.txt"
LOG_DIR="${BUILD_ROOT}/logs"

# shellcheck disable=SC1090
source "$VERSIONS_FILE"

mkdir -p "$BUILD_ROOT/src" "$LOG_DIR" "$INSTALL_DIR"
: > "$MANIFEST"

for tool in git emcmake em++ em-config cmake ninja embuilder; do
    command -v "$tool" >/dev/null 2>&1 || {
        echo "ERROR: required tool not found: $tool" >&2
        exit 1
    }
done

echo "== Emscripten ports =="
read -r -a PORTS <<< "$EMSCRIPTEN_PORTS"
embuilder build "${PORTS[@]}"

echo "== Fetch pinned FlightGear-maintained OpenSceneGraph fork =="
rm -rf "$SOURCE_DIR" "$BUILD_DIR"
git clone --depth 1 --branch "$OSG_REF" "$OSG_REPOSITORY" "$SOURCE_DIR"
if [[ "$(git -C "$SOURCE_DIR" rev-parse HEAD)" != "$OSG_COMMIT" ]]; then
    git -C "$SOURCE_DIR" fetch --depth=1 origin "$OSG_COMMIT"
    git -C "$SOURCE_DIR" checkout --detach "$OSG_COMMIT"
fi
RESOLVED_OSG_COMMIT="$(git -C "$SOURCE_DIR" rev-parse HEAD)"
if [[ "$RESOLVED_OSG_COMMIT" != "$OSG_COMMIT" ]]; then
    echo "ERROR: expected OSG commit $OSG_COMMIT, got $RESOLVED_OSG_COMMIT" >&2
    exit 1
fi

{
    echo "OSG_REPOSITORY=$OSG_REPOSITORY"
    echo "OSG_REF=$OSG_REF"
    echo "OSG_COMMIT=$RESOLVED_OSG_COMMIT"
    echo "OSG_OPENGL_PROFILE=$OSG_OPENGL_PROFILE"
    echo "EMSCRIPTEN_VERSION=$(em++ --version | head -n 1)"
    echo "CMAKE_VERSION=$(cmake --version | head -n 1)"
    echo "BUILD_TARGET=wasm32-emscripten"
} | tee "$MANIFEST"

SYSROOT="$(em-config SYSROOT)"
GL_LIBRARY="$(find "$SYSROOT" -type f \( -name 'libGL.a' -o -name 'libGLESv2.a' \) -print -quit || true)"
if [[ -z "$GL_LIBRARY" ]]; then
    echo "ERROR: no Emscripten GL shim library found under $SYSROOT" >&2
    exit 1
fi

PORT_FLAGS="--use-port=zlib --use-port=libpng"
LINK_FLAGS="-sMAX_WEBGL_VERSION=2 -sMIN_WEBGL_VERSION=2 -sFULL_ES3=1"

echo "== Configure OpenSceneGraph for OpenGL ES 3 / WebGL 2 =="
emcmake cmake -S "$SOURCE_DIR" -B "$BUILD_DIR" -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX="$INSTALL_DIR" \
    -DCMAKE_PREFIX_PATH="$SYSROOT" \
    -DCMAKE_C_FLAGS="$PORT_FLAGS" \
    -DCMAKE_CXX_FLAGS="$PORT_FLAGS" \
    -DCMAKE_EXE_LINKER_FLAGS="$LINK_FLAGS" \
    -DOPENGL_PROFILE="$OSG_OPENGL_PROFILE" \
    -DOPENGL_gl_LIBRARY="$GL_LIBRARY" \
    -DOSG_GL_LIBRARY_STATIC=ON \
    -DOSG_WINDOWING_SYSTEM=None \
    -DDYNAMIC_OPENSCENEGRAPH=OFF \
    -DDYNAMIC_OPENTHREADS=OFF \
    -DBUILD_OSG_APPLICATIONS=OFF \
    -DBUILD_OSG_EXAMPLES=OFF \
    -DBUILD_OSG_PLUGINS_BY_DEFAULT=OFF \
    -DBUILD_OSG_DEPRECATED_SERIALIZERS=OFF \
    -DOSG_USE_UTF8_FILENAME=ON \
    -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
    2>&1 | tee "$LOG_DIR/osg-configure.log"

echo "== Build OpenSceneGraph static libraries =="
cmake --build "$BUILD_DIR" --parallel 2 2>&1 | tee "$LOG_DIR/osg-build.log"
cmake --install "$BUILD_DIR" 2>&1 | tee "$LOG_DIR/osg-install.log"

OSG_LIBRARY="$(find "$INSTALL_DIR" -type f -name 'libosg.a' -print -quit || true)"
THREADS_LIBRARY="$(find "$INSTALL_DIR" -type f -name 'libOpenThreads.a' -print -quit || true)"
if [[ -z "$OSG_LIBRARY" || -z "$THREADS_LIBRARY" ]]; then
    echo "ERROR: expected libosg.a and libOpenThreads.a were not installed." >&2
    exit 1
fi

echo "OSG_LIBRARY=$OSG_LIBRARY" | tee -a "$MANIFEST"
echo "OPENTHREADS_LIBRARY=$THREADS_LIBRARY" | tee -a "$MANIFEST"

echo "== Compile an OSG + GLES3 WebAssembly link probe =="
cat > "$BUILD_ROOT/osg_web_probe.cpp" <<'CPP'
#include <osg/Group>
#include <osg/Matrix>
#include <osg/Version>
#include <GLES3/gl3.h>

int main() {
    osg::ref_ptr<osg::Group> root = new osg::Group;
    const osg::Matrixd identity = osg::Matrixd::identity();
    (void)root;
    (void)identity;
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    return osgGetVersion().empty() ? 1 : 0;
}
CPP

em++ "$BUILD_ROOT/osg_web_probe.cpp" \
    -I"$INSTALL_DIR/include" \
    "$OSG_LIBRARY" "$THREADS_LIBRARY" \
    --use-port=zlib --use-port=libpng \
    -sMAX_WEBGL_VERSION=2 -sMIN_WEBGL_VERSION=2 -sFULL_ES3=1 \
    -sALLOW_MEMORY_GROWTH=1 \
    -o "$BUILD_ROOT/osg-web-probe.html"

test -s "$BUILD_ROOT/osg-web-probe.html"
test -s "$BUILD_ROOT/osg-web-probe.wasm"

echo "SUCCESS: pinned FlightGear OSG fork built as static GLES3 libraries and linked into a WebAssembly probe."
echo "Manifest: $MANIFEST"
