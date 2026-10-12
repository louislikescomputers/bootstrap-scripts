# agent-bootstrap

Modular bootstrap tool that turns a bare machine into one of 23 node types for a mixed-hardware AI and security lab (LLM cluster, agent hosts, RE/malware/pentest labs, vibecoding workstation, and infrastructure nodes).

## Node types
core: `CLUSTER_NODE ORCHESTRATION_NODE AGENT_NODE MALWARE_NODE`
security: `RE_NODE PENTEST_NODE RANGE_NODE FORENSICS_NODE FUZZ_NODE SIEM_NODE THREATINTEL_NODE`
dev: `VIBECODE_NODE`
infra: `GATEWAY_NODE MONITORING_NODE MIRROR_NODE BUILD_NODE RETRIEVAL_NODE EVAL_NODE PROVISION_NODE OOB_NODE BACKUP_NODE SECRETS_NODE EGRESS_NODE`
aliases: `AGENT_BOX`, `LAB_HOST`. Details: NODE_CATALOG.md.

## Requirements
Linux (Artix runit primary; Debian/Ubuntu systemd and OpenRC supported), POSIX sh, curl/wget, sha256sum, tar, root for `apply`. Python 3 for helpers/tests.

## Install
```
git clone <repo> agent-bootstrap && cd agent-bootstrap
./bootstrap doctor
```
## Use
```
./bootstrap                      # usage
./bootstrap list
./bootstrap plan CLUSTER_NODE
sudo ./bootstrap apply CLUSTER_NODE --mirror http://mirror.lab
./bootstrap verify CLUSTER_NODE
./bootstrap status
./bootstrap wizard
```
Offline: `sudo ./bootstrap apply AGENT_NODE --offline --mirror http://mirror.lab`.

## Develop
`make verify` (lint, tests, parity, golden plans). See AGENTS.md, CONTRIBUTING.md, TESTING.md.

## Docs map
SPECIFICATION, NODE_CATALOG, MASTERPROMPT, AGENTS, ARCHITECTURE, IMPLEMENTATION_PLAN, TESTING, SECURITY, TASKS, CONTEXT, DATA_MODEL, API, DESIGN_SYSTEM, CONFIGURATION, DEPLOYMENT, DECISIONS, OPERATIONS, CHANGELOG, USER_GUIDE, CONTRIBUTING.

Maintainer contact for security reports: see SECURITY.md (set before first release).
