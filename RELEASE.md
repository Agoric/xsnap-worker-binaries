# Release Process

## Preconditions
- All CI checks pass on `main`.
- A successful `build-real` workflow run exists for the same version.
- `NPM_TOKEN` is configured in GitHub Actions secrets.
- Live publish is disabled unless `ALLOW_NPM_PUBLISH=true`.

## GitHub Release (No NPM)
Promote build artifacts to a GitHub release first:
```bash
gh workflow run publish-github-release \
  -f version=X.Y.Z \
  -f build_real_run_id=<build-real-run-id> \
  -f prerelease=true \
  -f dry_run=true
```
Set `dry_run=false` when ready to create the release.

## Bundle Validation (No Publish)
```bash
gh workflow run release \
  -f version=X.Y.Z \
  -f build_real_run_id=<build-real-run-id> \
  -f publish_live=false
```

## Live Publish (Guarded)
```bash
gh workflow run release \
  -f version=X.Y.Z \
  -f build_real_run_id=<build-real-run-id> \
  -f publish_live=true
```
This still requires repository variable `ALLOW_NPM_PUBLISH=true`.

## Post-publish
- Confirm all four package versions are visible on npm:
```bash
VERSION=X.Y.Z npm run ci:check-npm
```
- Publish/share `manifests/X.Y.Z.json` for agoric-sdk consumption.
