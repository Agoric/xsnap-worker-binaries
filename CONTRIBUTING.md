# Contributing

## Requirements
- Node.js 20+
- npm 10+
- Bash

## Local Validation
```bash
VERSION=0.0.0-dev npm run ci:build
VERSION=0.0.0-dev npm run ci:stage
VERSION=0.0.0-dev npm run ci:manifest
VERSION=0.0.0-dev npm run ci:verify
```

## Notes
- Windows is not supported.
- Keep package versions exactly aligned across all platform packages.
- Do not publish partial target sets.
