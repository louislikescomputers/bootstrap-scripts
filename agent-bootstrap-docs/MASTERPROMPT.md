# MASTERPROMPT.md — Instructions for the coding agent

You are building **agent-bootstrap**: a modular bootstrap tool that provisions 23 node types for a mixed-hardware AI and security lab. Read this file fully, then the required documents below, before writing code.

## Vision
One command (`bootstrap NODE_TYPE`) turns any spare machine into a verified, monitored, role-specific node, reliably, repeatably, and offline when needed. Fixed scripts handle everything critical; agent-written steps handle adaptation and are always gated by guardrails.

## Required reading, in order
1. `SPECIFICATION.md` — what and why, rules R1-R10, acceptance criteria AC1-AC11.
2. `NODE_CATALOG.md` — every node type and module (authoritative).
3. `ARCHITECTURE.md` — layout and module contract.
4. `AGENTS.md` — your working rules.
5. `IMPLEMENTATION_PLAN.md`, then `TASKS.md` and `CONTEXT.md` — what to do next.
6. `SECURITY.md`, `TESTING.md`, `CONFIGURATION.md`, `DATA_MODEL.md`, `API.md`, `DECISIONS.md` as relevant.

## Goals
- Idempotent, resumable, verifiable provisioning.
- Works on old hardware: no AVX2, tiny disks, headless, Artix/runit first.
- Mirror-first, offline-capable.
- Safe by construction: zones, scope-guard, isolation checks, no kernel/boot changes.
- Simulator parity with the real CLI.

## Constraints
- POSIX `sh` for the dispatcher and modules (must run on a minimal live ISO). Bash only where a module declares it. Python 3 (stdlib only) for helpers like the checksum/manifest tool and the simulator fixtures generator.
- Fully open source dependencies; flag **[EXT]** items; never auto-download proprietary media.
- No secrets in the repo, logs or state.
- Do not implement malicious payloads, exploits, or evasion. You are writing installers, verifiers, wrappers and docs for analysis/testing tools.

## Deliverables
1. Repo per ARCHITECTURE.md folder structure.
2. `bootstrap` dispatcher + `lib/`.
3. One module directory per module in NODE_CATALOG.md (install/verify/uninstall/module.conf/README).
4. One `nodes/<TYPE>.conf` per node type, plus alias handling.
5. Templates for runit/OpenRC/systemd service files, AGENTS.md project templates, scope.yaml, regression prompts.
6. Test suite per TESTING.md and CI definitions (Forgejo/Woodpecker).
7. Simulator fixtures regenerated from the real CLI output.
8. All docs kept current (CONTEXT.md and TASKS.md at the end of every session).

## Workflow
1. Open `CONTEXT.md` and `TASKS.md`; pick the first unblocked task.
2. Implement the smallest slice, with tests first where practical.
3. Run the checks in `AGENTS.md` before declaring done.
4. Update `TASKS.md`, `CONTEXT.md`, and `CHANGELOG.md`; record any design choice in `DECISIONS.md`.
5. Stop and ask when a task conflicts with a rule in SPECIFICATION.md section 7 or SECURITY.md.

## Definition of done
All acceptance criteria in SPECIFICATION.md section 9 pass in CI, docs are consistent, and `bootstrap` with no args prints the documented usage.
