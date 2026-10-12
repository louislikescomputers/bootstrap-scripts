# SECURITY.md

## Principles
Least privilege, explicit zones, verified artifacts, no secrets in repo/logs, defence by default for security-lab nodes.

## Requirements
S1 Root only where `NEEDS_ROOT=yes`; drop privileges for services; services run as dedicated users.
S2 All downloads verified by pinned SHA-256 (and signatures where upstream provides them). Mirror serves a signed `SHA256SUMS`.
S3 Zone enforcement (ARCHITECTURE.md). Z3 nodes have no route to Z1/Z2; OOB (Z0) never bridged.
S4 Agent-written steps pass the forbidden-operation scanner: no kernel, bootloader, initramfs, partition, firmware, core-package removal. Scanner is allowlist-first for AGENT_NODE steps and cannot be disabled by flags.
S5 MALWARE_NODE: dedicated host, host-only networking, VM snapshot revert per session, samples in encrypted dir, no shared folders/clipboard/USB passthrough by default, INetSim/FakeNet-NG for simulated services, never bridge to LAN.
S6 PENTEST_NODE: `scope.yaml` required (targets, window, contact, authorisation reference); wrappers + firewall allowlist enforce scope; session logging with hashes; tools absent from PATH without scope. Only for systems you own or are authorised in writing to test.
S7 Evidence/sample handling: hash on ingest, read-only mounts (FORENSICS), chain-of-custody log.
S8 Secrets: stored only in SECRETS_NODE (age+sops default or OpenBao) or `chmod 600` files under `/etc/agent-bootstrap/secrets/`; never in env dumps, logs, state, templates. Logs are scrubbed by `lib/log.sh` (pattern + known-secret redaction).
S9 Input validation: node type, flags, URLs, paths validated against allowlists; no `eval` of user input; quote all expansions; reject paths with `..` for artifact destinations.
S10 Network services default to listening on the zone interface only; Grafana/Forgejo/etc. behind Caddy with auth; default credentials never shipped.
S11 Backups encrypted; restore tested; keys held separately.
S12 Egress for autonomous agents goes through EGRESS_NODE with allowlists and logs.
S13 Supply chain: pin versions; build LocalAI/llama.cpp from pinned tags on BUILD_NODE; record provenance (git SHA, flags) in the mirror manifest.
S14 Tools with dual use are installed only on their node types, documented, and not exposed to other zones.

## Permissions
- `bootstrap` user commands: `list`, `plan`, `status`, `verify`, `doctor` need no root.
- `apply`, `uninstall` need root (sudo/doas) and ask for confirmation unless `--yes`.
- Agent accounts on AGENT_NODE are unprivileged; sudo only for a fixed allowlist of non-system-modifying commands.

## Privacy
No telemetry. Metrics/logs stay inside the lab. Prompt/regression data stored locally.

## Vulnerability reporting
Report privately to the project owner (maintainer contact in README.md). Do not open public issues for vulnerabilities. Include version, node type, reproduction steps. Acknowledge within 7 days; fix or mitigation plan within 30 days; note in CHANGELOG under "Security".
