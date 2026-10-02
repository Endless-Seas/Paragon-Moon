#!/usr/bin/env bash
set -euo pipefail

source dependencies.sh

curl --fail --location "https://github.com/$RUST_G_REPO/releases/download/$RUST_G_VERSION/librust_g.so" --output librust_g.so.download
printf '%s  %s\n' "$RUST_G_LINUX_SHA256" librust_g.so.download | sha256sum --check --status
mv librust_g.so.download librust_g.so
chmod +x librust_g.so
ldd librust_g.so
