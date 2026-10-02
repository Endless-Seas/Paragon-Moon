#!/bin/bash
set -euo pipefail

original_dir=$PWD
cd "${1:?Pass the TGS game directory}"

# Use the same release and verified artifact as CI; never build a floating fork.
bash tools/ci/install_rust_g.sh
env TG_BOOTSTRAP_CACHE="$original_dir/bootstrap" CBT_BUILD_MODE=TGS tools/bootstrap/javascript.sh tools/build/build.ts
