# AGENTS.md — Rules for coding agents working on this repo

## Required reading
`MASTERPROMPT.md`, `SPECIFICATION.md` (esp. section 7), `NODE_CATALOG.md`, `ARCHITECTURE.md`, `SECURITY.md`, then `CONTEXT.md` and `TASKS.md`.

## Coding rules
- POSIX sh for `bootstrap`, `lib/`, and modules; `set -eu`; quote everything; no bashisms unless the module declares `SHELL=bash`.
- Every module implements `install.sh`, `verify.sh`, `uninstall.sh`, `module.conf` (contract in ARCHITECTURE.md). Idempotent and safe to re-run.
- Use `lib/` helpers (`log_*`, `fetch_verified`, `render_template`, `svc_install`, `zone_require`, `state_*`) instead of ad-hoc code.
- Pin versions and checksums in `module.conf`; no `latest`.
- Service files come from `templates/svc/{runit,openrc,systemd}`; never hand-write one init flavour only.
- Output through `lib/ui.sh`; respect `NO_COLOR` and `--no-color`.
- Small commits, one concern each; conventional commit messages (CONTRIBUTING.md).

## Build and test commands
```
make lint        # shellcheck + shfmt -d + docs link check
make test        # unit tests (bats) 
make test-matrix # container matrix: artix-runit, debian-systemd, openrc
make parity      # simulator parity check
make plan-all    # runs `bootstrap plan` for all node types, diffs against golden files
make verify      # lint + test + parity + plan-all
```

## Prohibited changes (never, even if a task seems to ask)
- Any step that modifies kernel, bootloader/GRUB/EFI entries, initramfs, partition tables, firmware, or removes core/base packages.
- Disabling or weakening: zone checks, scope-guard, isolation checks, checksum verification, guardrails.
- Writing secrets, tokens, or real hostnames/IPs into the repo, logs, or state.
- Adding exploit, malware, ransomware or evasion code. Only installers/wrappers for analysis and testing tools.
- Adding proprietary or freemium dependencies without an **[EXT]** flag and user approval.
- Rewriting history or deleting tests to make a run green.

## Checks before declaring work complete
1. `make verify` passes.
2. New/changed module has install, verify, uninstall and a test; `plan` output golden file updated.
3. Idempotency: running `apply` twice makes no second change (test exists).
4. Docs updated (README, NODE_CATALOG if modules changed, CONFIGURATION if options changed).
5. `TASKS.md`, `CONTEXT.md`, `CHANGELOG.md` updated; decisions recorded.
6. If you were unsure about a rule in SPECIFICATION section 7 or SECURITY.md, you stopped and asked instead of guessing.

## When blocked
Mark the task BLOCKED in `TASKS.md` with the exact question and continue with the next unblocked task.
