# xsnap-worker-binaries Plan (Linux/macOS)

## Objective
Create and operate a dedicated repository that builds and publishes prebuilt `xsnap-worker` binaries for Linux and macOS, version-locked to `@agoric/xsnap`.

Current delivery strategy:
- Phase 1: distribute binaries and manifest via GitHub Releases for agoric-sdk consumption.
- Phase 2: publish platform npm packages.

Windows is not supported.

## Scope
This repo is responsible for:
- Building `xsnap-worker` binaries for supported targets.
- Packaging binaries into platform-specific npm packages.
- Producing SHA256 manifest artifacts for release/debug binaries.
- Publishing GitHub release artifacts that agoric-sdk can gate on.
- (Phase 2) Publishing npm packages with all-or-nothing semantics.

This repo is not responsible for:
- JS wrapper behavior in `@agoric/xsnap`.
- Runtime resolver logic inside agoric-sdk.
- Windows binaries.

## Supported Target Matrix
- `linux-x64`
- `linux-arm64`
- `darwin-x64`
- `darwin-arm64`

Planned package names:
- `@agoric/xsnap-linux-x64`
- `@agoric/xsnap-linux-arm64`
- `@agoric/xsnap-darwin-x64`
- `@agoric/xsnap-darwin-arm64`

## Deliverables
1. Repository bootstrap
- Initialize git repository and baseline docs.
- Add `README.md`, `PLAN.md`, and contribution/release notes.

2. Build pipeline
- Add CI workflow to build `xsnap-worker` for all supported targets.
- Produce both release and debug binaries per target.
- Normalize output layout for packaging and hashing.

3. Package templates
- Add per-platform package template with:
  - Minimal `package.json` (`os`, `cpu`, `files`, exact versioning policy).
  - Binary placement convention (release/debug paths).
  - License/readme metadata.

4. Hash manifest generation
- Generate SHA256 digests for all shipped binaries.
- Emit machine-readable manifest artifact per version (JSON).
- Include source revision metadata used to build binaries.

5. Release automation (Phase 1)
- Implement versioned GitHub release flow with bundle + manifest assets.
- Add dry-run and validation mode.

6. npm publish automation (Phase 2)
- Implement versioned publish flow for all platform packages.
- Enforce all-or-nothing publish semantics for the supported package set.
- Add post-publish npm availability checks.

7. Verification and smoke tests
- Verify package installability by platform constraints.
- Verify binary executability and debug/release path presence.
- Verify manifest and packaged bytes are consistent.

8. Release contract for agoric-sdk integration
- Document release order and expected artifacts:
  1) publish GitHub release assets for `X.Y.Z`
  2) verify artifact availability and manifest integrity
  3) unblock `@agoric/xsnap@X.Y.Z` publish in agoric-sdk
  4) (Phase 2) publish all supported platform packages at `X.Y.Z`
  5) (Phase 2) verify npm availability
- Provide a stable manifest artifact format that agoric-sdk can consume.

## Proposed Repository Structure
```text
.
├── .github/workflows/
│   ├── build.yml
│   ├── release.yml
│   └── verify.yml
├── packages/
│   ├── xsnap-linux-x64/
│   ├── xsnap-linux-arm64/
│   ├── xsnap-darwin-x64/
│   └── xsnap-darwin-arm64/
├── scripts/
│   ├── build-<target>.sh
│   ├── stage-packages.sh
│   ├── generate-manifest.sh
│   ├── verify-artifacts.sh
│   └── publish-all.sh
├── manifests/
│   └── (generated per release)
└── README.md
```

## Implementation Milestones
### Milestone 1: Bootstrap and conventions (Complete)
- Create workspace layout and package naming conventions.
- Define binary path contract used by downstream resolver.
- Define versioning rules (exact `X.Y.Z`, no range drift).

Exit criteria:
- Repo structure exists and docs describe release contract.
- Status: met.

### Milestone 2: Build + package on CI (Complete)
- Build all supported targets in CI.
- Stage binaries into package directories.
- Produce installable tarballs for each platform package.

Exit criteria:
- CI artifacts include 4 targets and both build modes.
- Status: met.

### Milestone 3: Hash manifest + verification gates (Complete)
- Generate per-version SHA256 manifest.
- Add CI checks for digest correctness and reproducibility constraints.
- Validate packaged artifact paths match manifest entries.

Exit criteria:
- CI fails on any hash/path mismatch.
- Status: met.

### Milestone 4: GitHub release flow (Complete)
- Add controlled release pipeline (tag-driven).
- Produce release bundle tarball + manifest asset.
- Add dry-run and validation steps before creating a release.

Exit criteria:
- One workflow creates GitHub release assets for a specific version.
- Status: met.
- Evidence: `v0.14.2` released on 2026-02-19 with
  - `xsnap-worker-binaries-0.14.2.tar.gz`
  - `xsnap-worker-manifest-0.14.2.json`

### Milestone 5: Integration handoff to agoric-sdk (Complete for GitHub artifacts)
- Document artifact/manifest retrieval instructions.
- Provide sample inputs for agoric-sdk prepublish gate.
- Confirm release choreography with agoric-sdk maintainers.

Exit criteria:
- agoric-sdk can fetch and run release binaries and consume manifest.
- Status: met for Phase 1.

### Milestone 6: npm publish flow (Deferred to Phase 2)
- Ensure all four packages publish at the same version.
- Add post-publish npm availability checks.
- Reconfirm integration contract once npm distribution is live.

Exit criteria:
- One workflow publishes all supported packages and verifies npm visibility.
- Status: deferred.

## CI/CD Requirements
- Use GitHub Actions for build, verify, and publish workflows.
- Store npm publish token in GitHub secrets with least privilege.
- Use immutable tags for releases (`vX.Y.Z`).
- Run verification before release/publish and after publish where applicable.

## Versioning and Release Policy
- Platform packages use exact versions matching `@agoric/xsnap`.
- No partial releases for a version.
- Rebuilds for same version are disallowed unless explicitly yanked and republished under new version.
- GitHub release assets are versioned as `vX.Y.Z` with matching artifact names.

## Risks and Mitigations
- Cross-platform build drift:
  - Mitigation: pin toolchains and capture source/toolchain metadata in manifest.
- Missing package at wrapper publish time:
  - Mitigation: in Phase 1 use GitHub release artifact checks; in Phase 2 enforce strict npm publish order + post-publish availability checks.
- Integrity mismatch:
  - Mitigation: mandatory SHA256 verification in CI and manifest artifact generation.

## Non-Goals
- `win32-x64` and `win32-arm64` build and publish.
- `.exe` packaging conventions.
- Windows-specific CI and runtime validation.

## Current Status Snapshot
- Phase 1 (GitHub release distribution): complete.
- Latest completed release: `v0.14.2` (2026-02-19), aligned to `@agoric/xsnap@0.14.2`.
- Phase 2 (npm publication): deferred by decision.

## Immediate Next Steps (Phase 2, when resumed)
1. Enable guarded npm publish path in `release.yml` for production use.
2. Publish all four platform packages for a target version.
3. Verify npm propagation with `ci:check-npm`.
4. Document final npm-based handoff checks in agoric-sdk release choreography.
