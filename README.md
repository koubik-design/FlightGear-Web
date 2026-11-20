# FlightGear-Web

**Status: Phase 1 — dependency compatibility validation.** This is an independent experimental browser-port project, not an official FlightGear distribution.

## Project constraints

- Native C++ FlightGear / SimGear / OpenSceneGraph port.
- WebAssembly compiled with Emscripten and rendered through WebGL 2.0 / OpenGL ES 3.0.
- Fully client-side runtime; no cloud rendering or streamed simulator video.
- No Three.js or Cesium replacement renderer.
- Browser-local persistence, add-on isolation and multiplayer adapters are later milestones.

## Phase 1: toolchain and dependency baseline

The initial Emscripten/CMake smoke test passes in GitHub Actions. Phase 1 is not complete until FlightGear's maintained OpenSceneGraph fork has also built as static GLES3 libraries and linked into a WebAssembly probe.

See [Phase 1 dependency build and acceptance criteria](docs/PHASE1_DEPENDENCIES.md).

### Build the toolchain image

```sh
docker build -f docker/Dockerfile -t flightgear-web:emsdk-7.0.0 .
```

### Verify the compiler

```sh
docker run --rm -v "$PWD:/workspace" -w /workspace \
  flightgear-web:emsdk-7.0.0 bash scripts/verify-toolchain.sh
```

### Build the OpenSceneGraph GLES3 dependency

```sh
docker run --rm -v "$PWD:/workspace" -w /workspace \
  flightgear-web:emsdk-7.0.0 bash scripts/build-osg-web.sh
```

## GitHub Pages

After enabling **Settings → Pages → Source → GitHub Actions**, pushes to `main` deploy the static status page from `web/`.

Project site: <https://koubik-design.github.io/FlightGear-Web/>

## Releases

Use [docs/RELEASE_TEMPLATE.md](docs/RELEASE_TEMPLATE.md). Publish only tested milestone artifacts; the diagnostic compiler probe is not a simulator release.

## Licensing

Preserve upstream notices. Determine and document the correct combined distribution terms before publishing derived binaries or bundled third-party libraries.

## Disclaimer

This project is not affiliated with or endorsed by the FlightGear project.
