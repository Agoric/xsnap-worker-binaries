#!/usr/bin/env bash
set -euo pipefail

version="${1:-}"
out_dir="${2:-}"
repo="${3:-Agoric/xsnap-worker-binaries}"

if [[ -z "$version" || -z "$out_dir" ]]; then
  echo "Usage: $0 <version> <output-dir> [repo]" >&2
  echo "Example: $0 0.15.0 /tmp/xsnap-assets" >&2
  exit 1
fi

mkdir -p "$out_dir"
tag="v$version"

tarball="xsnap-worker-binaries-$version.tar.gz"
manifest="xsnap-worker-manifest-$version.json"

gh release download "$tag" \
  --repo "$repo" \
  --pattern "$tarball" \
  --pattern "$manifest" \
  --dir "$out_dir"

echo "Downloaded release assets to $out_dir"
echo "- $out_dir/$tarball"
echo "- $out_dir/$manifest"
