#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
# shellcheck source=./common.sh
source "$SCRIPT_DIR/common.sh"

TARGET="${1:-}"
MODE="${2:-}"

if [[ -z "$TARGET" ]]; then
  echo "Usage: $0 <target> [--mock]" >&2
  exit 1
fi

if [[ -n "$MODE" && "$MODE" != "--mock" ]]; then
  echo "Unknown option: $MODE" >&2
  exit 1
fi

package_for_target "$TARGET" >/dev/null

OUT_DIR="dist/$TARGET"
mkdir -p "$OUT_DIR/release" "$OUT_DIR/debug"

if [[ "$MODE" == "--mock" ]]; then
  cat > "$OUT_DIR/release/xsnap-worker" <<MOCK
#!/usr/bin/env sh
echo "mock xsnap-worker release for $TARGET"
MOCK
  cat > "$OUT_DIR/debug/xsnap-worker" <<MOCK
#!/usr/bin/env sh
echo "mock xsnap-worker debug for $TARGET"
MOCK
  chmod +x "$OUT_DIR/release/xsnap-worker" "$OUT_DIR/debug/xsnap-worker"
  echo "Built mock artifacts for $TARGET"
  exit 0
fi

echo "Real build mode not wired yet for $TARGET." >&2
echo "Provide build integration in scripts/build-target.sh before release." >&2
exit 1
