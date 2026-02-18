#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=./common.sh
source "$SCRIPT_DIR/common.sh"

DRY_RUN="false"
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN="true"
fi

version="$(require_version)"
export NPM_CONFIG_CACHE="${NPM_CONFIG_CACHE:-$REPO_ROOT/.npm-cache}"

if [[ "$DRY_RUN" != "true" && -z "${NPM_TOKEN:-}" ]]; then
  echo "NPM_TOKEN is required for publish" >&2
  exit 1
fi

stage_root="$(mktemp -d)"

cleanup() {
  rm -rf "$stage_root"
}

trap cleanup EXIT

# Create isolated package copies and stamp the release version there.
for target in $(resolve_targets); do
  pkg="$(package_for_target "$target")"
  pkg_dir="$REPO_ROOT/packages/$pkg"
  if [[ ! -d "$pkg_dir" ]]; then
    echo "Missing package directory: $pkg_dir" >&2
    exit 1
  fi

  staged_pkg="$stage_root/$pkg"
  cp -R "$pkg_dir" "$staged_pkg"

  (
    cd "$staged_pkg"
    node -e '
      const fs = require("fs");
      const path = "package.json";
      const pkg = JSON.parse(fs.readFileSync(path, "utf8"));
      pkg.version = process.argv[1];
      fs.writeFileSync(path, `${JSON.stringify(pkg, null, 2)}\n`);
    ' "$version"
  )
done

PACKAGES_DIR="$stage_root" "$SCRIPT_DIR/validate-version-sync.sh"

for target in $(resolve_targets); do
  pkg="$(package_for_target "$target")"
  pkg_dir="$stage_root/$pkg"

  (
    cd "$pkg_dir"
    if [[ "$DRY_RUN" == "true" ]]; then
      # Use pack dry-run to validate package contents without hitting npm registry.
      npm pack --dry-run
    else
      npm publish --access public
    fi
  )
done

echo "Publish flow complete for $version"
