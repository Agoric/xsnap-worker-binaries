#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./common.sh
source "$SCRIPT_DIR/common.sh"

version="$(require_version)"
out="manifests/$version.json"
mkdir -p manifests

{
  mapfile -t targets < <(resolve_targets)

  echo "{"
  echo "  \"version\": \"$version\","
  echo "  \"generatedAt\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\","
  echo "  \"targets\": {"

  for i in "${!targets[@]}"; do
    target="${targets[$i]}"
    pkg="$(package_for_target "$target")"
    release_path="packages/$pkg/bin/release/xsnap-worker"
    debug_path="packages/$pkg/bin/debug/xsnap-worker"

    if [[ ! -f "$release_path" || ! -f "$debug_path" ]]; then
      echo "Missing staged binaries for $target" >&2
      exit 1
    fi

    release_sha="$(sha256_file "$release_path")"
    debug_sha="$(sha256_file "$debug_path")"

    comma=","
    if [[ "$i" -eq $((${#targets[@]} - 1)) ]]; then
      comma=""
    fi

    cat <<JSON
    "$target": {
      "package": "@agoric/$pkg",
      "release": {
        "path": "bin/release/xsnap-worker",
        "sha256": "$release_sha"
      },
      "debug": {
        "path": "bin/debug/xsnap-worker",
        "sha256": "$debug_sha"
      }
    }$comma
JSON
  done

  echo "  }"
  echo "}"
} > "$out"

echo "Wrote $out"
