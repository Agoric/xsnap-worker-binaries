# xsnap-worker-binaries Plan (Linux/macOS)

## Objective
Create and operate a dedicated repository that builds and publishes prebuilt `xsnap-worker` binaries as npm platform packages for Linux and macOS, version-locked to `@agoric/xsnap`.

Windows is not supported.

## Scope
This repo is responsible for:
- Building `xsnap-worker` binaries for supported targets.
- Packaging binaries into platform-specific npm packages.
- Producing SHA256 manifest artifacts for release/debug binaries.
- Publishing packages in a release flow that agoric-sdk can gate on.

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

5. Publish automation
- Implement versioned publish flow for all platform packages.
- Enforce all-or-nothing publish semantics for the supported package set.
- Add dry-run and validation mode.

6. Verification and smoke tests
- Verify package installability by platform constraints.
- Verify binary executability and debug/release path presence.
- Verify manifest and packaged bytes are consistent.

7. Release contract for agoric-sdk integration
- Document release order and expected artifacts:
  1) publish all supported platform packages at `X.Y.Z`
  2) verify npm availability
  3) unblock `@agoric/xsnap@X.Y.Z` publish in agoric-sdk
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
### Milestone 1: Bootstrap and conventions
- Create workspace layout and package naming conventions.
- Define binary path contract used by downstream resolver.
- Define versioning rules (exact `X.Y.Z`, no range drift).

Exit criteria:
- Repo structure exists and docs describe release contract.

### Milestone 2: Build + package on CI
- Build all supported targets in CI.
- Stage binaries into package directories.
- Produce installable tarballs for each platform package.

Exit criteria:
- CI artifacts include 4 platform package tarballs and both build modes.

### Milestone 3: Hash manifest + verification gates
- Generate per-version SHA256 manifest.
- Add CI checks for digest correctness and reproducibility constraints.
- Validate packaged artifact paths match manifest entries.

Exit criteria:
- CI fails on any hash/path mismatch.

### Milestone 4: Publish flow
- Add controlled publish pipeline (tag-driven).
- Ensure all four packages publish at the same version.
- Add post-publish availability checks.

Exit criteria:
- One command/workflow publishes all supported packages and verifies npm visibility.

### Milestone 5: Integration handoff to agoric-sdk
- Document artifact/manifest retrieval instructions.
- Provide sample inputs for agoric-sdk prepublish gate.
- Confirm release choreography with agoric-sdk maintainers.

Exit criteria:
- agoric-sdk can gate `@agoric/xsnap` publish on package availability and manifest.

## CI/CD Requirements
- Use GitHub Actions for build, verify, and publish workflows.
- Store npm publish token in GitHub secrets with least privilege.
- Use immutable tags for releases (`vX.Y.Z`).
- Run verification before publish and after publish.

## Versioning and Release Policy
- Platform packages use exact versions matching `@agoric/xsnap`.
- No partial releases for a version.
- Rebuilds for same version are disallowed unless explicitly yanked and republished under new version.

## Risks and Mitigations
- Cross-platform build drift:
  - Mitigation: pin toolchains and capture source/toolchain metadata in manifest.
- Missing package at wrapper publish time:
  - Mitigation: strict publish order + post-publish availability checks.
- Integrity mismatch:
  - Mitigation: mandatory SHA256 verification in CI and manifest artifact generation.

## Non-Goals
- `win32-x64` and `win32-arm64` build and publish.
- `.exe` packaging conventions.
- Windows-specific CI and runtime validation.

## Immediate Next Steps
1. Create baseline `README.md` and workflow skeletons.
2. Implement build scripts for the four supported targets.
3. Implement package staging and manifest generation scripts.
4. Add verify workflow and make it required before release workflow.
