# Phase 1 — dependency and graphics-toolchain baseline

## Scope

Phase 1 is complete only when the pinned Emscripten environment can compile the required browser-target foundations and the FlightGear-maintained OpenSceneGraph fork can be built for OpenGL ES 3 / WebGL 2. The FlightGear and SimGear application port is Phase 2.

The current compatibility build uses:

- Emscripten SDK container: `emscripten/emsdk:7.0.0`
- FlightGear-maintained OpenSceneGraph fork: `https://gitlab.com/flightgear/openscenegraph.git`
- OSG branch: `next`
- OSG pinned commit: `9090931c7753db996744d5d94dc00c9928a1d509`
- OSG renderer profile: `GLES3`
- Emscripten ports: zlib and libpng
- Static OSG and OpenThreads libraries

FlightGear's contributor documentation specifically directs developers to its maintained OpenSceneGraph fork and recommends building that fork before building SimGear and FlightGear. See [FlightGear's contributor build guide](https://docs.flightgear.org/contributors-guide/guidelines/building.html).

## Run the dependency build locally

```sh
docker build -f docker/Dockerfile -t flightgear-web:emsdk-7.0.0 .
docker run --rm -v "$PWD:/workspace" -w /workspace \
  flightgear-web:emsdk-7.0.0 bash scripts/build-osg-web.sh
```

The build checks out the exact commit in `third_party/versions.env` and records the toolchain and dependency versions in `build/dependencies/dependency-manifest.txt`. The CI artifact contains installed static libraries, headers, the manifest, configure/build logs, and a small HTML/WASM link probe.

## What the link probe proves

The probe includes OSG scene-graph headers and GLES 3 headers, instantiates core OSG types, calls a GLES function, and links to the produced OSG/OpenThreads static archives. It verifies compile/link compatibility only. It does not create a browser graphics context, render a frame, or establish that the full FlightGear renderer is already ported.

## Known boundary before Phase 2

- OSG's browser window/context integration still needs a browser-specific graphics-context implementation.
- SimGear and FlightGear have not yet been built or ported.
- Desktop-only services (OpenAL device access, joystick APIs, filesystem paths, subprocesses, sockets, and GUI/launcher dependencies) need explicit browser adapters or feature gates.

## Phase 1 acceptance checklist

- [x] Pinned Emscripten container and CMake/Ninja smoke test.
- [x] FlightGear OSG source commit pinned.
- [ ] Build OSG fork as static GLES3 libraries.
- [ ] Link a C++/OSG/GLES3 WebAssembly probe.
- [ ] Verify a clean CI rebuild and archive the dependency artifact.
