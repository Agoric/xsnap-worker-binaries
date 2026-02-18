#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./common.sh
source "$SCRIPT_DIR/common.sh"

MODE="${1:-}"
mapfile -t targets < <(resolve_targets)
for target in "${targets[@]}"; do
  "$SCRIPT_DIR/build-target.sh" "$target" "$MODE"
done
