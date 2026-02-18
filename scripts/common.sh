#!/usr/bin/env bash
set -euo pipefail

readonly SUPPORTED_TARGETS=(
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

resolve_targets() {
  local raw="${TARGETS:-}"
  local target

  if [[ -z "$raw" ]]; then
    printf '%s\n' "${SUPPORTED_TARGETS[@]}"
    return 0
  fi

  raw="${raw//,/ }"
  for target in $raw; do
    package_for_target "$target" >/dev/null
    printf '%s\n' "$target"
  done
}

platform_path_for_target() {
  case "$1" in
    linux-*) echo "lin" ;;
    darwin-*) echo "mac" ;;
    *)
      echo "Unsupported target for platform path: $1" >&2
      return 1
      ;;
  esac
}

normalize_arch() {
  case "$1" in
    x86_64|amd64) echo "x64" ;;
    arm64|aarch64) echo "arm64" ;;
    *)
      echo "Unsupported host architecture: $1" >&2
      return 1
      ;;
  esac
}

host_target() {
  local os arch
  case "$(uname -s)" in
    Linux) os="linux" ;;
    Darwin) os="darwin" ;;
    *)
      echo "Unsupported host OS: $(uname -s)" >&2
      return 1
      ;;
  esac
  arch="$(normalize_arch "$(uname -m)")"
  echo "$os-$arch"
}

assert_target_matches_host() {
  local target="$1"
  local host
  host="$(host_target)"
  if [[ "$target" != "$host" ]]; then
    echo "Target $target does not match host $host." >&2
    echo "Set TARGETS=$host or run on a matching runner." >&2
    return 1
  fi
}
