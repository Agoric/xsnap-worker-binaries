# Release Process

## Preconditions
- All CI checks pass on `main`.
- Four supported packages are ready to publish at the same version.
- `NPM_TOKEN` is configured in GitHub Actions secrets.

## Dry Run
```bash
VERSION=X.Y.Z npm run ci:build
VERSION=X.Y.Z npm run ci:stage
VERSION=X.Y.Z npm run ci:manifest
VERSION=X.Y.Z npm run ci:verify
VERSION=X.Y.Z npm run release:dry-run
```

## Publish
```bash
VERSION=X.Y.Z ./scripts/publish-all.sh
```

## Post-publish
- Confirm all four package versions are visible on npm:
```bash
VERSION=X.Y.Z npm run ci:check-npm
```
- Publish/share `manifests/X.Y.Z.json` for agoric-sdk consumption.
