#!/usr/bin/env bash
set -euo pipefail

readonly TARGETS=(
  "linux-x64"
  "linux-arm64"
  "darwin-x64"
  "darwin-arm64"
)

package_for_target() {
  case "$1" in
    linux-x64) echo "xsnap-linux-x64" ;;
    linux-arm64) echo "xsnap-linux-arm64" ;;
    darwin-x64) echo "xsnap-darwin-x64" ;;
    darwin-arm64) echo "xsnap-darwin-arm64" ;;
    *)
      echo "Unsupported target: $1" >&2
      return 1
      ;;
  esac
}

sha256_file() {
  local path="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$path" | awk '{print $1}'
  else
    shasum -a 256 "$path" | awk '{print $1}'
  fi
}

require_version() {
  local version="${VERSION:-}"
  if [[ -z "$version" ]]; then
    echo "VERSION env var is required (example: VERSION=0.15.0)" >&2
    return 1
  fi
  echo "$version"
}
