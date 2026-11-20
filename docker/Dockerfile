# Pinned Emscripten SDK container used by all browser-target builds.
FROM emscripten/emsdk:7.0.0@sha256:6bd7aef93408b10bf7b36642cb7c91119b302f720b9ec2d20439f73cf07fe894

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
       cmake ninja-build python3 git curl ca-certificates pkg-config \
       unzip xz-utils tar gzip \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /workspace
CMD ["bash"]
