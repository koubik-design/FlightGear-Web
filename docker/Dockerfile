# Reproducible browser toolchain baseline.
# Keep this tag pinned; upgrade it deliberately and validate the CI result.
FROM emscripten/emsdk:7.0.0

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
       cmake \
       ninja-build \
       python3 \
       git \
       ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace

CMD ["bash"]
