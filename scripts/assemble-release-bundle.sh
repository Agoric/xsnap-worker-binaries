#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck source=./common.sh
source "$SCRIPT_DIR/common.sh"

version="$(require_version)"
input_root="${1:-collected}"
output_root="${2:-release/$version}"

if [[ ! -d "$input_root" ]]; then
  echo "Input artifact directory not found: $input_root" >&2
  exit 1
fi

rm -rf "$output_root"
mkdir -p "$output_root/dist" "$output_root/packages" "$output_root/manifests"

for target in $(resolve_targets); do
  pkg="$(package_for_target "$target")"

  src_release="$input_root/dist/$target/release/xsnap-worker"
  src_debug="$input_root/dist/$target/debug/xsnap-worker"

  if [[ ! -f "$src_release" || ! -f "$src_debug" ]]; then
    echo "Missing dist binaries for $target in $input_root" >&2
    exit 1
  fi

  mkdir -p "$output_root/dist/$target/release" "$output_root/dist/$target/debug"
  cp "$src_release" "$output_root/dist/$target/release/xsnap-worker"
  cp "$src_debug" "$output_root/dist/$target/debug/xsnap-worker"

  if [[ ! -d "$REPO_ROOT/packages/$pkg" ]]; then
    echo "Missing package template for $pkg in repo" >&2
    exit 1
  fi

  cp -R "$REPO_ROOT/packages/$pkg" "$output_root/packages/$pkg"
  rm -rf "$output_root/packages/$pkg/bin"
  mkdir -p "$output_root/packages/$pkg/bin"

  src_pkg_bin="$input_root/packages/$pkg/bin"
  if [[ ! -d "$src_pkg_bin" ]]; then
    echo "Missing packaged bin directory for $pkg in $input_root" >&2
    exit 1
  fi

  cp -R "$src_pkg_bin/release" "$output_root/packages/$pkg/bin/release"
  cp -R "$src_pkg_bin/debug" "$output_root/packages/$pkg/bin/debug"
done

TARGETS="$(resolve_targets | paste -sd, -)" \
  VERSION="$version" \
  "$SCRIPT_DIR/merge-target-manifests.sh" \
  "$input_root/manifests" \
  "$output_root/manifests/$version.json"

tarball="$output_root/xsnap-worker-binaries-$version.tar.gz"
tar -czf "$tarball" -C "$output_root" dist packages manifests

echo "Assembled release bundle at $output_root"
echo "Tarball: $tarball"
