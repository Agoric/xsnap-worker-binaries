#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./common.sh
source "$SCRIPT_DIR/common.sh"

for target in $(resolve_targets); do
  pkg="$(package_for_target "$target")"
  pkg_dir="packages/$pkg"
  in_release="dist/$target/release/xsnap-worker"
  in_debug="dist/$target/debug/xsnap-worker"

  if [[ ! -f "$in_release" || ! -f "$in_debug" ]]; then
    echo "Missing build output for $target" >&2
    exit 1
  fi

  mkdir -p "$pkg_dir/bin/release" "$pkg_dir/bin/debug"
  cp "$in_release" "$pkg_dir/bin/release/xsnap-worker"
  cp "$in_debug" "$pkg_dir/bin/debug/xsnap-worker"
  chmod +x "$pkg_dir/bin/release/xsnap-worker" "$pkg_dir/bin/debug/xsnap-worker"

done

echo "Staged binaries into packages/*/bin"
