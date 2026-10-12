# CONTRIBUTING.md

## Workflow
Fork/branch from `main` on the Forgejo instance; one concern per branch.
Branch names: `feat/<module>`, `fix/<topic>`, `docs/<topic>`, `chore/<topic>`.
Commits: Conventional Commits (`feat(module-ghidra): add headless wrapper`).
Run `make verify` before opening a PR.

## Pull request expectations
- Describes what/why, links task ID (Txxx) and spec section/AC.
- Includes tests, updated golden `plan` outputs, docs updates.
- No secrets, no proprietary binaries, no kernel/boot-touching code.
- Small (<400 changed lines where possible).

## Review requirements
- At least one reviewer (the maintainer for guardrail, security, zone, scope-guard or crypto/checksum changes).
- CI green; reviewer checks idempotency, uninstall correctness, zone behaviour, and docs.
- Changes to SPECIFICATION section 7 or SECURITY.md require a DECISIONS.md entry.

## Coding agents
Follow AGENTS.md. Update TASKS.md/CONTEXT.md/CHANGELOG.md in the same PR.

## Licensing
Contributions under the project's open source licence (choose and add LICENSE before first release).
