#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./common.sh
source "$SCRIPT_DIR/common.sh"

DRY_RUN="false"
if [[ "${1:-}" == "--dry-run" ]]; then
  DRY_RUN="true"
fi

version="$(require_version)"

if [[ "$DRY_RUN" != "true" && -z "${NPM_TOKEN:-}" ]]; then
  echo "NPM_TOKEN is required for publish" >&2
  exit 1
fi

for target in "${TARGETS[@]}"; do
  pkg="$(package_for_target "$target")"
  pkg_dir="packages/$pkg"
  if [[ ! -d "$pkg_dir" ]]; then
    echo "Missing package directory: $pkg_dir" >&2
    exit 1
  fi

  (
    cd "$pkg_dir"
    npm version --no-git-tag-version "$version" >/dev/null
    if [[ "$DRY_RUN" == "true" ]]; then
      npm publish --access public --dry-run
    else
      npm publish --access public
    fi
  )
done

echo "Publish flow complete for $version"
