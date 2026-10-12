# TASKS.md
Status: PENDING / IN-PROGRESS / BLOCKED / DONE. Each task has a completion condition.

## IN-PROGRESS
(none)

## PENDING — M0 Skeleton
- [ ] T001 Repo skeleton, Makefile, lint config. Done when `make lint` runs clean on empty modules.
- [ ] T002 `bootstrap` dispatcher with exact usage text. Done when AC1 test passes.
- [ ] T003 `bootstrap list` with all 23 types + aliases. Done when AC2 test passes.
- [ ] T004 `lib/ui.sh` + `lib/log.sh` with NO_COLOR and secret redaction. Done when unit tests pass.
- [ ] T005 Simulator fixtures + parity script. Done when `make parity` passes.

## PENDING — M1 Engine
- [ ] T010 State library and module DAG resolver. Done when resolver tests (cycles, missing deps) pass.
- [ ] T011 `plan` command (no side effects). Done when snapshot-diff test shows zero changes.
- [ ] T012 `fetch_verified` + `tools/manifest.py`. Done when checksum-mismatch and offline tests pass.
- [ ] T013 `apply/verify/uninstall` with resume + idempotency. Done when AC4/AC5 tests pass.
- [ ] T014 `doctor` preflight with cpuinfo fixtures. Done when CPU-variant tests pass.

## PENDING — M2 Guardrails
- [ ] T020 Zone + conflict matrix enforcement. Done when R6 tests pass.
- [ ] T021 Forbidden-operation scanner and agent-step template. Done when AC6 tests pass.
- [ ] T022 Isolation check (MALWARE_NODE) and Z0 check (OOB_NODE). Done when AC7 tests pass.

## PENDING — M3-M8
See IMPLEMENTATION_PLAN.md; create one task per module listed in NODE_CATALOG.md with: install/verify/uninstall + test + golden plan + README.

## BLOCKED
(none yet) — format: `- [ ] Txxx <title> — BLOCKED: <exact question>`

## DONE
(none)
