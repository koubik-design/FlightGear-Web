# Pinned Emscripten SDK container used by all browser-target builds.
FROM emscripten/emsdk:7.0.0

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
       cmake ninja-build python3 git curl ca-certificates pkg-config \
       unzip xz-utils tar gzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
CMD ["bash"]
