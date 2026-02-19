# Compatibility Contract

## Linux ABI baseline

Linux `xsnap-worker` artifacts must be compatible with the runtime used by
`agoric-sdk` Docker images, which currently build from `node:20-bullseye`.
That means Linux binaries must not require GLIBC newer than `2.31`.

This repository enforces that in CI via the `build-real` workflow by checking
both `release` and `debug` binaries for each Linux target.

## Why this matters

`agoric-sdk` integration and Docker build jobs execute `xsnap-worker` during
validation (for example version checks and smoke tests). If binaries are built
against newer GLIBC symbols (for example from Ubuntu 24 runners), they fail at
runtime in bullseye-based environments.

## Policy

1. Linux binaries should be produced in a bullseye-compatible environment.
2. Releases must fail if Linux binaries require GLIBC newer than `2.31`.
3. If `agoric-sdk` runtime base image changes, update this document and the CI
   floor check in the same PR.
