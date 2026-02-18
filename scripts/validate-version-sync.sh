#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./common.sh
source "$SCRIPT_DIR/common.sh"

version="$(require_version)"
packages_dir="${PACKAGES_DIR:-packages}"

for target in "${TARGETS[@]}"; do
  pkg="$(package_for_target "$target")"
  pkg_json="$packages_dir/$pkg/package.json"

  if [[ ! -f "$pkg_json" ]]; then
    echo "Missing package.json: $pkg_json" >&2
    exit 1
  fi

  current=$(
    node -e 'const fs=require("fs"); const p=JSON.parse(fs.readFileSync(process.argv[1], "utf8")); process.stdout.write(p.version);' "$pkg_json"
  )

  if [[ "$current" != "$version" ]]; then
    echo "Version mismatch in $pkg_json: expected $version, found $current" >&2
    exit 1
  fi
done

echo "All package versions match $version"
