# xsnap-worker-binaries

Prebuilt `xsnap-worker` binary packages for `@agoric/xsnap`.

## Support Matrix
- `linux-x64`
- `linux-arm64`
- `darwin-x64`
- `darwin-arm64`

Windows is not supported.

## Package Names
- `@agoric/xsnap-linux-x64`
- `@agoric/xsnap-linux-arm64`
- `@agoric/xsnap-darwin-x64`
- `@agoric/xsnap-darwin-arm64`

## Repository Layout
- `packages/`: platform npm packages.
- `scripts/`: build, stage, verify, and publish scripts.
- `manifests/`: generated SHA256 manifests.
- `.github/workflows/`: CI, verify, and release workflows.

## Release Contract
For version `X.Y.Z`:
1. Publish all four platform packages at `X.Y.Z`.
2. Verify package availability on npm.
3. Unblock `@agoric/xsnap@X.Y.Z` release in agoric-sdk.

## Quick Start
```bash
npm run ci:build
npm run ci:stage
npm run ci:manifest
npm run ci:verify
```

`ci:build` uses mock artifacts by default for bootstrap validation.

Real build mode is available:
```bash
TARGETS="$(uname | tr '[:upper:]' '[:lower:]')-$(uname -m | sed -e 's/x86_64/x64/' -e 's/aarch64/arm64/' -e 's/arm64/arm64/')" \
npm run ci:build:real
```

Notes for real mode:
- Build host must match target (`linux-x64`, `linux-arm64`, `darwin-x64`, `darwin-arm64`).
- Source is pulled from `Agoric/agoric-sdk` (override with `AGORIC_SDK_REPO`, `AGORIC_SDK_REF`, `AGORIC_SDK_DIR`).

## build-real Workflow Output
The `build-real` workflow builds each supported target in a matrix, then assembles a combined artifact:
- `release-bundle-<version>` (GitHub Actions artifact)
- Includes:
  - `dist/<target>/{release,debug}/xsnap-worker`
  - `packages/<package>/` with staged `bin/` content
  - merged manifest `manifests/<version>.json`
  - `xsnap-worker-binaries-<version>.tar.gz`
