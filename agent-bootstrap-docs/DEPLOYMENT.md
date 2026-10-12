# DEPLOYMENT.md

## Build/release artifacts
- Git tag `vX.Y.Z`; tarball `agent-bootstrap-X.Y.Z.tar.zst` + `SHA256SUMS` published on MIRROR_NODE (`/releases/agent-bootstrap/`).
- Optional bootable helper: live-ISO hook script that fetches the tarball from the mirror and runs `bootstrap wizard`.

## Environments
- dev: containers + VMs. staging: 2-3 spare machines incl. one no-AVX2 box. prod: the fleet.

## CI/CD (Forgejo + Woodpecker on BUILD_NODE)
Pipeline: lint -> unit -> matrix (artix-runit, debian-systemd, openrc) -> golden plan -> parity -> docs consistency -> package -> publish to mirror (tags only).
Required to pass before merge to `main` and before tagging.

## Release procedure
1. Update CHANGELOG, bump VERSION.
2. `make verify` on BUILD_NODE.
3. Tag, CI builds package, publishes to MIRROR_NODE.
4. Canary: apply to one staging node per affected node type; `verify`.
5. Roll out gradually (PROVISION_NODE inventory groups); watch MONITORING_NODE.

## Migrations
SQLite schema migrations (DATA_MODEL.md) run automatically on `bootstrap` helper start, with automatic pre-migration copy. Config key renames get shims for one minor version.

## Rollback
- Bootstrap itself: previous release stays on mirror; `bootstrap --use-release X.Y.Z` or reinstall the tarball.
- Node roles: `bootstrap uninstall MODULE` for module regressions; pinned older artifact via `module.conf` revert.
- Models/builds: gateway can point to the previous coordinator build; mirror keeps last 2 versions per artifact.
- Never rollback via kernel/boot changes (out of scope).
