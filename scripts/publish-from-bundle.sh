#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=./common.sh
source "$SCRIPT_DIR/common.sh"

bundle_root="${1:-}"
if [[ -z "$bundle_root" ]]; then
  echo "Usage: $0 <bundle-root> [--dry-run]" >&2
  exit 1
fi

DRY_RUN="false"
if [[ "${2:-}" == "--dry-run" ]]; then
  DRY_RUN="true"
fi

if [[ ! -d "$bundle_root/packages" || ! -d "$bundle_root/manifests" ]]; then
  echo "Invalid bundle root: $bundle_root" >&2
  echo "Expected subdirectories: packages/, manifests/" >&2
  exit 1
fi

version="$(require_version)"
manifest="$bundle_root/manifests/$version.json"
if [[ ! -f "$manifest" ]]; then
  echo "Expected manifest not found: $manifest" >&2
  exit 1
fi

export NPM_CONFIG_CACHE="${NPM_CONFIG_CACHE:-$REPO_ROOT/.npm-cache}"

if [[ "$DRY_RUN" != "true" ]]; then
  if [[ "${ALLOW_NPM_PUBLISH:-false}" != "true" ]]; then
    echo "Refusing to publish: set ALLOW_NPM_PUBLISH=true to enable live publish." >&2
    exit 1
  fi
  if [[ -z "${NPM_TOKEN:-}" ]]; then
    echo "NPM_TOKEN is required for publish" >&2
    exit 1
  fi
fi

stage_root="$(mktemp -d)"

cleanup() {
  rm -rf "$stage_root"
}

trap cleanup EXIT

for target in $(resolve_targets); do
  pkg="$(package_for_target "$target")"
  pkg_dir="$bundle_root/packages/$pkg"
  if [[ ! -d "$pkg_dir" ]]; then
    echo "Missing package directory in bundle: $pkg_dir" >&2
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
      npm pack --dry-run
    else
      npm publish --access public
    fi
  )
done

echo "Bundle publish flow complete for $version"
