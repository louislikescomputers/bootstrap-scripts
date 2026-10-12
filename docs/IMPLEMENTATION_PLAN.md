# IMPLEMENTATION_PLAN.md

Each milestone ends with `make verify` green and docs updated. IDs link to SPECIFICATION (F# features, AC# criteria).

## M0 — Skeleton (F1, AC1)
1. Repo layout, Makefile, shellcheck/shfmt/bats config.
2. `bootstrap` dispatcher: usage, `list`, alias resolution (reads `nodes/`).
3. `lib/ui.sh`, `lib/log.sh`; NO_COLOR handling.
4. Simulator fixtures + parity check for `usage` and `list`.

## M1 — Engine (F2, F3, F4, AC3, AC4, AC5)
1. `lib/state.sh`, module DAG resolver, `plan` (no side effects), `apply`, `verify`, `uninstall`, resume logic.
2. `lib/fetch.sh` + `tools/manifest.py`: mirror-first, checksum verify, offline mode.
3. `doctor`: CPU flags, RAM/disk, init system, distro, time, zone detection.
4. Golden-file tests for `plan`.

## M2 — Guardrails (F6, F7, F11, AC6, AC7)
1. `lib/guardrails.sh`: zone checks, conflict matrix, resource checks, forbidden-operation scanner for agent steps (kernel/boot/partition/firmware/core pkg removal).
2. Agent-step template and validator; rejection tests.
3. Isolation check for MALWARE_NODE; Z0 check for OOB_NODE.

## M3 — Base + service layer
1. Modules: `base`, `init-service` (runit/openrc/systemd templates), `docker`, `monitoring-agent`.
2. Test matrix containers for Artix/Debian/OpenRC.

## M4 — Cluster (F8, AC8, AC9)
1. Modules: `pinned-build`, `llamacpp-rpc`, `localai-workers`, `node-watchdog`, `model-qwen`, `model-yaml`.
2. CPU-variant selection (no-AVX2 baseline); coordinator-capability logic.
3. Offline apply test from mirror fixture.

## M5 — Infra backbone
1. MIRROR_NODE, BUILD_NODE (publish to mirror), GATEWAY_NODE, MONITORING_NODE (+ dashboards, textfile exporters).
2. PROVISION_NODE, OOB_NODE, BACKUP_NODE (F10, W2, W9, W10).

## M6 — Agents and orchestration
1. AGENT_NODE (guardrails first), ORCHESTRATION_NODE, RETRIEVAL_NODE, EVAL_NODE, VIBECODE_NODE.
2. AGENTS.md project templates.

## M7 — Security labs
1. MALWARE_NODE (isolation, snapshots, REMnux import, FLARE-VM guidance **[EXT]**, INetSim, tools).
2. RE_NODE (Ghidra + MCP bridge etc.).
3. PENTEST_NODE with scope-guard + evidence logging; RANGE_NODE.
4. FORENSICS_NODE, FUZZ_NODE, SIEM_NODE, THREATINTEL_NODE.

## M8 — Remaining infra and polish
1. SECRETS_NODE, EGRESS_NODE.
2. `wizard` UX, `--with` combos, LAB_HOST selector.
3. Docs consistency checker (AC11), release v1.0.0.

## Dependencies
M0 -> M1 -> M2 -> M3 -> (M4, M5, M6 in parallel after M3) -> M7 (needs M2, M5 mirror) -> M8.
