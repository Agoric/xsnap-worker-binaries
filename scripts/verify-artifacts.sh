#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./common.sh
source "$SCRIPT_DIR/common.sh"

version="$(require_version)"
manifest="manifests/$version.json"

mapfile -t targets < <(resolve_targets)
if [[ ! -f "$manifest" ]]; then
  echo "Missing manifest: $manifest" >&2
  exit 1
fi

for target in "${targets[@]}"; do
  pkg="$(package_for_target "$target")"
  for mode in release debug; do
    bin="packages/$pkg/bin/$mode/xsnap-worker"
    if [[ ! -f "$bin" ]]; then
      echo "Missing binary: $bin" >&2
      exit 1
    fi
    if [[ ! -x "$bin" ]]; then
      echo "Binary is not executable: $bin" >&2
      exit 1
    fi
  done
done

# Verify manifest hashes against staged binaries.
for target in "${targets[@]}"; do
  pkg="$(package_for_target "$target")"
  release="packages/$pkg/bin/release/xsnap-worker"
  debug="packages/$pkg/bin/debug/xsnap-worker"

  expected_release=$(
    node -e '
      const fs = require("fs");
      const manifest = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
      const target = process.argv[2];
      process.stdout.write(manifest.targets[target].release.sha256);
    ' "$manifest" "$target"
  )

  expected_debug=$(
    node -e '
      const fs = require("fs");
      const manifest = JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
      const target = process.argv[2];
      process.stdout.write(manifest.targets[target].debug.sha256);
    ' "$manifest" "$target"
  )

  actual_release="$(sha256_file "$release")"
  actual_debug="$(sha256_file "$debug")"

  if [[ "$expected_release" != "$actual_release" ]]; then
    echo "Release hash mismatch for $target" >&2
    exit 1
  fi

  if [[ "$expected_debug" != "$actual_debug" ]]; then
    echo "Debug hash mismatch for $target" >&2
    exit 1
  fi
done

echo "Verified binaries and manifest for $version"
