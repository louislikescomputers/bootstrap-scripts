# TESTING.md

## Strategy
Pyramid: lint -> unit (bats) -> module tests in containers -> golden `plan` tests -> parity -> integration on VMs/real hardware (manual checklists for hardware-only paths).

## Commands
```
make lint | make test | make test-matrix | make parity | make plan-all | make verify
```

## Important test cases
- Dispatcher: no args prints exact usage; unknown type exits 2; aliases (`AGENT_BOX`, `LAB_HOST`) resolve.
- `plan` makes no changes (filesystem snapshot diff before/after).
- Idempotency: `apply` x2 -> second run reports all modules skipped.
- Resume: kill during module N; rerun resumes at N.
- Checksum mismatch aborts; unpinned artifact refused.
- Offline mode with populated mirror fixture succeeds; without it fails clearly.
- CPU variant: fake `/proc/cpuinfo` fixtures (with/without avx, avx2, avx512) choose the right build.
- Init rendering: runit/OpenRC/systemd service files validate (runit `sv check` or syntax checks where possible).
- Guardrails: agent steps containing kernel/grub/efibootmgr/mkinitcpio/dd-to-disk/parted/fdisk/flash/firmware/`pacman -R base`/`apt remove` of core are rejected.
- Zones: MALWARE_NODE refused when a Z1/Z2 interface present; OOB_NODE refused outside Z0; conflicts matrix enforced.
- PENTEST: tools not on PATH without scope.yaml; out-of-scope target refused by wrapper; expired window refused.
- Secrets: grep tests ensure no tokens in logs/state.
- Coordinator logic: RAM threshold, `--worker-only`.
- Disk-space preflight stops before large download.
- Verify fails when service stopped.
- Gateway health-check script selects the live coordinator in a simulated multi-backend test.
- Simulator parity: fixtures equal real output.

## Test data
`tests/fixtures/cpuinfo/*`, `tests/fixtures/mirror/` (tiny dummy artifacts with real checksums), `tests/fixtures/scope/*.yaml`, `tests/fixtures/agent-steps/{allowed,forbidden}/*`.

## Regression checks
Golden `plan` outputs in `tests/golden/`; any diff must be reviewed and committed deliberately. Model-quality regression is handled by EVAL_NODE prompt sets (`templates/regression-prompts/`).

## Release acceptance
All SPECIFICATION AC1-AC11 pass; matrix green on three init systems; manual hardware checklist done on: a no-AVX2 machine, a DL380, a VM-based MALWARE_NODE; docs consistency check passes; CHANGELOG updated.
