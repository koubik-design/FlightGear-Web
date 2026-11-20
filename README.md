# FlightGear-Web

**Status: Phase 1 — toolchain bootstrap.** This repository is a browser-port engineering project, not an official FlightGear distribution. The simulator engine has not yet been ported or built for the browser.

## Project constraints

- Native C++ FlightGear / SimGear / OpenSceneGraph port.
- WebAssembly compiled with Emscripten and rendered through WebGL 2.0 / OpenGL ES 3.0.
- Fully client-side runtime; no cloud rendering or streamed simulator video.
- No Three.js or Cesium replacement renderer.
- Browser-local persistence and add-on isolation will be implemented in later phases.

## Phase 1: toolchain bootstrap

The first phase establishes a pinned Emscripten container, CMake/Ninja tooling, a WebAssembly smoke-test executable, CI verification, and a minimal GitHub Pages status page. It does **not** yet build FlightGear, SimGear, or OpenSceneGraph.

### Requirements

- Docker Engine or Docker Desktop
- Git
- A C++ editor (optional)

### Build the toolchain image

From the repository root:

```sh
docker build -f docker/Dockerfile -t flightgear-web:emsdk-7.0.0 .
```

### Verify the WebAssembly toolchain

```sh
docker run --rm -v "$PWD:/workspace" -w /workspace \
  flightgear-web:emsdk-7.0.0 ./scripts/verify-toolchain.sh
```

The smoke test is written to `build/wasm-toolchain/`. It verifies that Emscripten, CMake, Ninja, and the HTML/JavaScript/WebAssembly output pipeline work. It is only a compiler/toolchain probe—not a simulator build.

For an interactive container shell:

```sh
docker run --rm -it -v "$PWD:/workspace" -w /workspace \
  flightgear-web:emsdk-7.0.0 bash
```

## GitHub Pages

After enabling **Settings → Pages → Source → GitHub Actions**, pushes to `main` deploy the static site from `web/`.

Project site: <https://koubik-design.github.io/FlightGear-Web/>

The current page is intentionally a development-status placeholder. It is not a playable FlightGear build.

## Release policy

Create versioned Releases only for reviewed milestones with reproducible artifacts. Do not label the Phase 1 smoke test as a FlightGear simulator release. The build workflow will retain its diagnostic output as a GitHub Actions artifact; a GitHub Release should contain a tested build archive only when an actual distributable exists.

## Licensing

No standalone project license has been selected in this scaffold. FlightGear, SimGear, OpenSceneGraph, and any bundled dependencies have their own license and notice requirements. Preserve upstream notices and determine the correct combined distribution terms before publishing derived binaries.

## Disclaimer

This is an independent experimental browser-port effort and is not affiliated with or endorsed by the FlightGear project.
