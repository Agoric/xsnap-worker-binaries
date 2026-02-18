#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./common.sh
source "$SCRIPT_DIR/common.sh"

version="$(require_version)"
attempts="${NPM_CHECK_ATTEMPTS:-10}"
sleep_seconds="${NPM_CHECK_SLEEP_SECONDS:-15}"

for target in $(resolve_targets); do
  pkg="$(package_for_target "$target")"
  scoped_pkg="@agoric/$pkg"

  echo "Checking npm availability for $scoped_pkg@$version"
  ok="false"
  for try in $(seq 1 "$attempts"); do
    if npm view "$scoped_pkg@$version" version >/dev/null 2>&1; then
      ok="true"
      break
    fi
    if [[ "$try" -lt "$attempts" ]]; then
      sleep "$sleep_seconds"
    fi
  done

  if [[ "$ok" != "true" ]]; then
    echo "Package not available after retries: $scoped_pkg@$version" >&2
    exit 1
  fi
done

echo "All supported platform packages are available at version $version"
