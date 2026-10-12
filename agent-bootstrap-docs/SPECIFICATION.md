# SPECIFICATION.md — agent-bootstrap

## 1. What we are building
`bootstrap` is a modular, offline-capable provisioning tool that turns a bare machine (or VM) into one of **23 node types** for a mixed-hardware AI/security lab: an LLM inference cluster, agent and orchestration hosts, reverse-engineering / malware / pentest / forensics labs, a vibecoding workstation, and the supporting infrastructure (gateway, monitoring, mirror, build, provisioning, OOB, backup, and more).

It is a mix of **fixed, tested shell scripts** (the reliable part) and **agent-written steps** (the adaptive part), and ships with a **Bootstrap Terminal Simulator** whose output must match the real CLI.

Full node list and modules: **NODE_CATALOG.md** (authoritative).

## 2. Target users
- Primary: Louis (single operator, strong technical/cybersecurity background) bootstrapping 10 now and 100+ spare machines eventually.
- Secondary: beginners using VIBECODE_NODE, who need guided, forgiving flows.
- Tertiary: coding agents running bootstrap on AGENT_NODEs/other hosts under guardrails.

## 3. Environment and constraints
- Default OS: Artix Linux (runit) on most nodes; also support Debian/Ubuntu-family (systemd) and OpenRC; DL380 G7 and other old servers included. Windows only as VMs (FLARE-VM) **[EXT]**.
- Hardware: ~13 CPUs, 300+ GB RAM combined, one 250-500 GB drive per node, many CPUs without AVX2, headless nodes, Cisco switches over cat5, a separate air-gapped console/OOB switch, internet up to 5 Gbps.
- Nodes come and go; no permanent head node.
- Fully open source tooling by default; no freemium/ads. Exceptions flagged **[EXT]**.
- Priority: answer accuracy and maximum context tokens over speed.

## 4. Command surface (must match the simulator)
```
$ bootstrap
usage: bootstrap NODE_TYPE [options]
       bootstrap list | plan | apply | verify | status | doctor | uninstall | wizard

core:     CLUSTER_NODE  ORCHESTRATION_NODE  AGENT_NODE  MALWARE_NODE
security: RE_NODE  PENTEST_NODE  RANGE_NODE  FORENSICS_NODE  FUZZ_NODE  SIEM_NODE  THREATINTEL_NODE
dev:      VIBECODE_NODE
infra:    GATEWAY_NODE  MONITORING_NODE  MIRROR_NODE  BUILD_NODE  RETRIEVAL_NODE  EVAL_NODE
          PROVISION_NODE  OOB_NODE  BACKUP_NODE  SECRETS_NODE  EGRESS_NODE
aliases:  AGENT_BOX=AGENT_NODE   LAB_HOST=(choose: MALWARE|RE|PENTEST|RANGE|FORENSICS)
```
Subcommands:
- `bootstrap list [--group G]` — node types and one-line descriptions.
- `bootstrap plan TYPE [--with TYPE2 ...]` — print exactly what would change (default safe first step).
- `bootstrap apply TYPE [...]` — execute. Idempotent, resumable.
- `bootstrap verify TYPE` — run each module's verify step; non-zero on failure.
- `bootstrap status` — installed modules, versions, last result, zone, roles.
- `bootstrap doctor` — preflight (CPU flags, RAM, disk, network zone, init system, mirror reachable).
- `bootstrap uninstall TYPE|MODULE` — remove what bootstrap installed (never touches kernel/boot).
- `bootstrap wizard` — interactive guided flow, asks few questions, shows plan before applying.
- Global options: `--yes`, `--dry-run`, `--offline`, `--mirror URL`, `--zone Z0|Z1|Z2|Z3`, `--init runit|openrc|systemd`, `--log-dir`, `--no-color`.

## 5. Features
F1 Node types as module compositions; modules reusable across nodes.
F2 Preflight (`doctor`) detects CPU flags (AVX/AVX2/AVX512), RAM, disks, init system, distro, network zone.
F3 Mirror-first fetching with checksum verification; fall back to upstream; offline mode.
F4 Idempotent apply with per-module state, resume after interruption, safe re-run.
F5 Combining roles with `--with` (e.g. MONITORING_NODE + GATEWAY_NODE on a small fleet) subject to the conflict matrix (§7).
F6 Zone enforcement: each node type declares allowed network zones; violations are refused with a clear message.
F7 Agent-writable steps: `templates/agent-step.md` lets an agent propose a step; it is validated against guardrails and shown in `plan` before running.
F8 Cluster auto-join: CLUSTER_NODEs start LocalAI/llama.cpp rpc-server via the init service and join with minimal interaction; watchdog restarts and reports.
F9 Monitoring hooks: every node installs a lightweight `monitoring-agent` (node_exporter + textfile metrics) when a MONITORING_NODE is configured.
F10 Provisioning at scale via PROVISION_NODE: netboot, unattended wizard run, inventory registration.
F11 Safety rails for security nodes (scope-guard, isolation checks, snapshots, evidence hashing).
F12 Simulator parity: `tests/simulator-parity` compares real `bootstrap` usage/list/plan text with simulator fixtures.

## 6. User workflows
W1 First cluster node: boot Artix live -> run wizard -> choose CLUSTER_NODE -> `doctor` -> plan -> apply -> node joins and appears on the monitoring dashboard.
W2 Scale-out: PROVISION_NODE netboots a spare machine -> wizard runs unattended with role from inventory -> verify -> status reported.
W3 Offline install: MIRROR_NODE populated once; new nodes use `--offline`.
W4 Agent host: `bootstrap apply AGENT_NODE` -> guardrails installed first -> tools -> sample project template with AGENTS.md.
W5 Malware lab: dedicated workstation -> `apply MALWARE_NODE` -> isolation check -> VMs imported -> baseline snapshots.
W6 Pentest engagement: create `scope.yaml` -> `apply PENTEST_NODE` -> tools enabled only within scope -> evidence logs hashed -> report from templates.
W7 Build once: BUILD_NODE builds llama.cpp/LocalAI variants -> publishes to MIRROR_NODE -> CLUSTER_NODEs fetch matching variant for their CPU.
W8 Change evaluation: EVAL_NODE runs regression prompts before/after a quant/context/version change and prints a diff.
W9 Recovery: node fails -> OOB_NODE power-cycles / opens console -> watchdog event visible in Grafana.
W10 Backup/restore test: BACKUP_NODE runs schedule and a periodic restore-test.

## 7. Business rules
R1 Every module has install, verify and uninstall; apply is not "done" until verify passes.
R2 Never modify kernel, bootloader, initramfs, partition table, or firmware from any bootstrap path or agent-written step. Never break userspace (no removal of base/core packages; snapshot or backup before bulk changes where fs supports it).
R3 Dry-run/plan output must be a faithful superset of what apply will do.
R4 Downloads must be checksum- or signature-verified; unpinned downloads are refused unless `--allow-unpinned`.
R5 Secrets never written to logs, state files, templates, or the repo.
R6 Conflict matrix (hard unless overridden where noted):
   - MALWARE_NODE conflicts with CLUSTER, ORCHESTRATION, AGENT, GATEWAY, MONITORING, MIRROR, BUILD, PROVISION, BACKUP (any Z1/Z2 role). No override except dedicated-host flag + isolation check.
   - PENTEST_NODE conflicts with CLUSTER_NODE. 
   - OOB_NODE only on Z0.
   - FUZZ_NODE + CLUSTER_NODE: warn.
   - Others combinable; warn on RAM/disk shortfall.
R7 Coordinator capability is decided by RAM threshold and flags; only coordinator-capable nodes download the Qwen3.8 GGUF + model YAML.
R8 Small disks: large artifacts (GGUF) are pulled from MIRROR_NODE on demand and may be stored on attached storage; bootstrap checks free space before download.
R9 PENTEST tools require a valid scope file; no scope = tools disabled.
R10 Licences: no automatic download of proprietary media; guide the user to supply it.

## 8. Edge cases
- CPU lacks AVX2/AVX: choose baseline build; refuse variants that would SIGILL.
- Mirror unreachable: fall back to upstream if online; else fail with actionable message.
- Interrupted apply: resume from last verified module.
- Init system mismatch: render the right service files (runit/OpenRC/systemd) from templates.
- Docker absent where optional: use native binaries.
- Hostname/DHCP not stable: warn and recommend PROVISION_NODE.
- Two coordinators simultaneously: gateway picks by priority; document split-brain handling in OPERATIONS.md.
- Disk < threshold: abort before download.
- Clock skew breaks TLS: doctor checks time; chrony module fixes where permitted.
- Air-gapped hosts with no internet: `--offline` + mirror required.
- Agent proposes disallowed step: rejected with reason and logged.

## 9. Acceptance criteria
AC1 `bootstrap` with no args prints the usage in §4 exactly (simulator identical).
AC2 `bootstrap list` shows all 23 types in 4 groups plus the two aliases.
AC3 `plan` for each node type lists modules, downloads (with sizes/checksums), services, ports, zone, and conflicts; makes no changes.
AC4 `apply` then `apply` again changes nothing (idempotent).
AC5 `verify` fails (non-zero) when a service is stopped or a binary mismatches checksum.
AC6 Attempted kernel/boot/partition change by an agent step is rejected in tests.
AC7 MALWARE_NODE refuses on a host with Z1/Z2 interfaces; PENTEST tools unavailable without scope file; OOB_NODE refuses outside Z0.
AC8 CLUSTER_NODE on a no-AVX2 CPU installs a baseline build and the rpc-server starts.
AC9 Offline apply of CLUSTER_NODE succeeds from a populated mirror.
AC10 Shellcheck clean; test matrix passes on Artix (runit), Debian (systemd) and an OpenRC distro container/VM.
AC11 All 20+ docs in this repo exist and are cross-consistent (CI link/consistency check).

## 10. Out of scope (v1)
- Distro installation itself on bare metal beyond netboot hand-off and live-ISO wizard run.
- Writing or distributing malware, exploits, or evasion tooling; bootstrap installs analysis/testing tools only.
- Managing the models' training or fine-tuning.
- A web UI (the terminal simulator is a demo/teaching tool, not a control plane).
- Windows host support (Windows only as guest VMs).
- Kernel, bootloader, firmware management.
- High-availability for MIRROR/BUILD/PROVISION nodes (backups only).
