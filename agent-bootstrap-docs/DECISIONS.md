# DECISIONS.md

Format: ID, decision, alternatives, why, consequences.

## D001 POSIX sh core
Alternatives: Python, Go, Rust, bash. Why: runs on minimal live ISOs and old machines with no extra runtime. Consequences: stricter coding rules; Python used only for helpers/tests.

## D002 Node types are module compositions
Alternatives: monolithic per-node scripts. Why: reuse (docker, ghidra, monitoring-agent appear in many nodes); easier tests. Consequences: module contract must be stable.

## D003 Zones (Z0-Z3) as first-class
Alternatives: ad-hoc firewall rules. Why: air-gapped OOB switch, isolated malware lab, and cluster network are core to the environment. Consequences: doctor must detect zones; zones.conf required.

## D004 Mirror-first with pinned checksums
Alternatives: always upstream. Why: speed, offline, small disks, no-AVX2 prebuilt binaries. Consequences: MIRROR_NODE/BUILD_NODE become important (backed up).

## D005 Guardrails cannot be disabled by flags
Why: agents run with autonomy; kernel/boot/userspace must never break. Consequences: some power-user tasks need manual work outside bootstrap.

## D006 Artix runit first, three init flavours rendered from templates
Alternatives: systemd only. Why: user's chosen distro; floating-window desktop. Consequences: tests on three init systems.

## D007 ZAP instead of Burp; no freemium tools
Why: fully open source requirement. Consequences: fewer polished GUI features in PENTEST_NODE.

## D008 FLARE-VM treated as [EXT]
Why: needs Windows licensing/evaluation media. Consequences: documented manual import; REMnux is default path.

## D009 No permanent head node; GATEWAY_NODE fronts active coordinator
Alternatives: client-side failover. Why: agents stay simple. Consequences: keepalived/HAProxy health checks must be reliable.

## D010 File-based state, SQLite only for inventory/tasks/evals
Why: inspectable, no daemon. Consequences: concurrency handled with lock files and WAL.

## D011 Extra node types added: RANGE, FORENSICS, FUZZ, SIEM, THREATINTEL, SECRETS, EGRESS
Why: complete the security lab and support autonomous agents safely. Consequences: 23 node types total; optional/heavy ones (Wazuh, OpenCTI) flagged.

## D012 Default coordinator RAM threshold 64 GB (to confirm)
Why: large quantised Qwen3.8 plus max context needs RAM. Consequences: tunable via BS_COORD_MIN_RAM_GB.
