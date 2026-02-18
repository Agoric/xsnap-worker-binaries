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

assert_target_matches_host "$TARGET"

REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AGORIC_SDK_REPO="${AGORIC_SDK_REPO:-https://github.com/Agoric/agoric-sdk.git}"
AGORIC_SDK_REF="${AGORIC_SDK_REF:-master}"
AGORIC_SDK_DIR="${AGORIC_SDK_DIR:-$REPO_ROOT/.cache/agoric-sdk}"

if [[ ! -d "$AGORIC_SDK_DIR/.git" ]]; then
  mkdir -p "$(dirname "$AGORIC_SDK_DIR")"
  git clone "$AGORIC_SDK_REPO" "$AGORIC_SDK_DIR"
fi

(
  cd "$AGORIC_SDK_DIR"
  git fetch --tags origin
  git checkout "$AGORIC_SDK_REF"
)

(
  cd "$AGORIC_SDK_DIR/packages/xsnap"
  node src/build.js
)

platform_path="$(platform_path_for_target "$TARGET")"
release_src="$AGORIC_SDK_DIR/packages/xsnap/xsnap-native/xsnap/build/bin/$platform_path/release/xsnap-worker"
debug_src="$AGORIC_SDK_DIR/packages/xsnap/xsnap-native/xsnap/build/bin/$platform_path/debug/xsnap-worker"

if [[ ! -f "$release_src" || ! -f "$debug_src" ]]; then
  echo "Expected build outputs are missing for $TARGET" >&2
  echo "Release: $release_src" >&2
  echo "Debug:   $debug_src" >&2
  exit 1
fi

cp "$release_src" "$OUT_DIR/release/xsnap-worker"
cp "$debug_src" "$OUT_DIR/debug/xsnap-worker"
chmod +x "$OUT_DIR/release/xsnap-worker" "$OUT_DIR/debug/xsnap-worker"

echo "Built real artifacts for $TARGET from $AGORIC_SDK_REF"
