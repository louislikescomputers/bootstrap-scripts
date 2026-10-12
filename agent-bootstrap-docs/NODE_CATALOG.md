# NODE_CATALOG.md — Every node type and its modules

Source of truth for `nodes/<NODE_TYPE>.conf`. Each node type is a **list of modules** (see ARCHITECTURE.md). Zones: Z0 = OOB/air-gapped, Z1 = cluster network, Z2 = services/agents, Z3 = isolated lab (no route to Z1/Z2 or the internet unless a module explicitly opens a controlled path). "Needs" = other node types that should exist for full function (not hard dependencies; bootstrap warns, never blocks, except where marked HARD).

License policy: fully open source by default. Exceptions are flagged **[EXT]** (user supplies licence/eval media, e.g. Windows for FLARE-VM) and are never downloaded automatically.

## A. Core nodes

### CLUSTER_NODE  (zone Z1)
Modules: `base`, `init-service`, `docker` (optional runtime), `llamacpp-rpc`, `localai-workers`, `pinned-build`, `node-watchdog`, `model-qwen` (coordinator-capable only), `model-yaml` (coordinator-capable only), `monitoring-agent`.
- Coordinator-capable = RAM >= configurable threshold (default 64 GB) and operator did not pass `--worker-only`. All others are workers.
- Pinned LocalAI/llama.cpp build comes from MIRROR_NODE/BUILD_NODE; falls back to upstream release at the pinned tag; falls back to compile (warn: slow, no-AVX2 aware flags).
- Must work with no AVX2. Detect CPU flags and choose the matching build variant.
- Any node can be shut down at any time: no node is a permanent head. Gateway handles which coordinator is active.
- Needs: GATEWAY_NODE, MIRROR_NODE, BUILD_NODE.

### ORCHESTRATION_NODE  (zone Z2)
Modules: `base`, `docker`, `python-uv`, `smolagents`, `langgraph`, `mcp-sdk` (Python+TS), `mcp-servers` (filesystem, git, fetch), `qdrant`, `sqlite-state`, `embedding-small`, `monitoring-agent`.
- SQLite holds task state (WAL mode, nightly backup via BACKUP_NODE).
- MCP filesystem server is rooted to a configured workspace dir only.
- Needs: GATEWAY_NODE (LLM endpoint), RETRIEVAL_NODE (optional, otherwise local Qdrant).

### AGENT_NODE  (zone Z2)  — alias `AGENT_BOX`
Modules: `base`, `git`, `uv`, `rustup`, `node`, `docker`, `aider`, `opencode`, `vscodium-cline-roo`, `precommit`, `project-templates` (each with AGENTS.md), `agent-guardrails`, `monitoring-agent`.
- Autonomous coding agents run here, never on cluster nodes.
- `agent-guardrails` enforces: no kernel, bootloader, initramfs, partition or firmware changes; never break userspace (package removals of core packages are blocked; snapshot before bulk changes).
- Needs: GATEWAY_NODE, EGRESS_NODE (recommended), SECRETS_NODE (optional).

### MALWARE_NODE  (zone Z3, dedicated separate workstation)  — part of `LAB_HOST`
Modules: `base`, `kvm-qemu`, `virt-manager`, `isolated-net` (host-only bridge, no uplink), `remnux-vm`, `flarevm-vm` **[EXT]**, `inetsim`, `fakenet-ng` (inside FLARE VM), `ghidra`, `ghidra-mcp`, `rizin-cutter`, `radare2`, `capa`, `floss`, `yara`, `sigma`, `oletools`, `cyberchef` (local offline copy), `wireshark`, `capev2` (optional), `snapshot-tools`.
- HARD rule: refuses to install on a host with an interface in Z1/Z2 unless `--i-know-this-host-is-dedicated` and the isolation check passes.
- All VMs revert to a clean snapshot after each session; samples live only in a dedicated encrypted dir and never in synced folders.
- Needs: MIRROR_NODE (offline tool/VM image cache).

## B. Requested additions

### RE_NODE  (zone Z2 or Z3)  — part of `LAB_HOST`
Static/dynamic reverse engineering of *non-hostile or already-contained* binaries, firmware, game files, apps.
Modules: `base`, `ghidra`, `ghidra-mcp`, `rizin-cutter`, `radare2`, `gdb-pwndbg`, `angr`, `frida`, `binwalk`, `unblob`, `jadx`, `apktool`, `capstone-keystone-unicorn`, `lief`, `imhex`, `diaphora`, `yara`, `qemu-user-binfmt`, `quickbms` (optional), `re-workspace-templates`.
- Boundary with MALWARE_NODE: RE_NODE does not execute unknown/hostile samples. Anything suspicious is handed to MALWARE_NODE.
- Ghidra headless + MCP bridge so agents can drive analysis.

### PENTEST_NODE  (zone Z2 or Z3)  — part of `LAB_HOST`
Authorised security testing only.
Modules: `base`, `scope-guard`, `nmap`, `masscan`, `zaproxy`, `mitmproxy`, `sqlmap`, `ffuf`, `nuclei`, `impacket`, `netexec`, `metasploit`, `hashcat-john`, `wordlists`, `bloodhound-ce`, `wireshark-tcpdump`, `evidence-logging` (tmux/script session capture, hashed), `report-templates` (Markdown).
- `scope-guard` is mandatory: needs a signed-off `scope.yaml` (targets CIDR/hosts, window, contact). Wrapper functions and an egress firewall allowlist block traffic to anything outside scope. No scope file = tools not on PATH.
- Burp Suite is intentionally excluded (not fully open source); ZAP is used instead.
- Needs: RANGE_NODE for practice, SECRETS_NODE (optional).

### VIBECODE_NODE  (zone Z2)
Beginner-friendly human + AI coding workstation (not autonomous).
Modules: `base`, `desktop-floating` (floating-window desktop, no tiling WM by default), `vscodium-cline-roo`, `aider`, `opencode`, `git`, `uv`, `node`, `rustup`, `docker`, `precommit`, `project-templates`, `endpoint-config` (points tools at the GATEWAY OpenAI-compatible URL), `live-preview`, `beginner-cheatsheets`, `terminal-quality-of-life` (ripgrep, fd, tmux, fzf).
- Difference from AGENT_NODE: has a GUI and guided onboarding; AGENTS.md templates are simpler; no unattended autonomy defaults.

## C. Suggested infrastructure nodes

### GATEWAY_NODE  (Z1+Z2)
`base`, `caddy` or `haproxy` (flag), `keepalived`, `coordinator-healthcheck`, `monitoring-agent`.
One stable virtual IP/hostname for the OpenAI-compatible API; health-checks all coordinator-capable nodes and routes to the active one. Agents never implement failover.

### MONITORING_NODE  (Z1+Z2)
`base`, `docker`, `prometheus`, `grafana`, `loki`, `alloy-or-promtail`, `uptime-kuma`, `textfile-exporters` (context size, watchdog events, active model), `dashboards`.
Dashboard: nodes up, RAM, current context size, watchdog events, active coordinator.

### MIRROR_NODE  (Z1+Z2)
`base`, `caddy-files` (or nginx), `apt-cacher-ng`, `pacman-cache` (pacoloco or equivalent), `syncthing`, `gguf-store`, `release-store`, `checksums` (SHA256SUMS + manifest), `offline-index`.
Holds GGUFs, release binaries, package caches so wizard installs are fast and work offline; sidesteps small 250-500 GB local disks (large store lives here or on attached storage).

### BUILD_NODE  (Z2)
`base`, `docker`, `forgejo`, `woodpecker-server`, `woodpecker-agent`, `build-recipes` (llama.cpp and LocalAI for no-AVX2 and other arches), `artifact-publish` (to MIRROR_NODE), `buildx-qemu`.
Builds once, old machines download binaries.

### RETRIEVAL_NODE  (Z2)
`base`, `docker`, `qdrant`, `embedding-cpu`, `reranker`, `ingest-pipeline`, `collections-config`.

### EVAL_NODE  (Z2)
`base`, `uv`, `lm-eval-harness`, `llama-bench`, `regression-prompts`, `results-store` (SQLite + CSV), `compare-runs`.
Shows whether a change to quant, context size or version made answers better or worse (answer accuracy is the priority metric, not speed).

### PROVISION_NODE  (Z1, plus Z0 optionally)
`base`, `dnsmasq` (DHCP/DNS/TFTP), `netbootxyz`, `ansible`, `chrony`, `inventory`, `wizard-at-scale`.
Netboots and installs the 100+ spare machines; owns DHCP/DNS/time; runs the wizard unattended at scale. Needs reserved static leases for stable hostnames.

### OOB_NODE  (Z0 only; air-gapped switch)
`base`, `ipmitool`, `freeipmi`, `conserver`, `power-wrappers`, `console-logs`.
Power-cycle and console access to DL380s and others without touching the cluster network. HARD: refuses to start with any interface outside Z0 up.

### BACKUP_NODE  (Z2)
`base`, `restic` or `borg` (flag), `btrfs-send` / `zfs-send` (if fs present), `schedule`, `restore-test`.
Protects configs, tokens, detection rules, project repos. Encrypted repos; keys stored per SECURITY.md.

## D. Additional suggested nodes

### RANGE_NODE  (Z3)
`base`, `docker`, `kvm-qemu`, `isolated-net`, `vulnerable-targets` (DVWA, Juice Shop, WebGoat, Metasploitable-class VMs), `reset-scripts`. Safe practice targets for PENTEST_NODE.

### FORENSICS_NODE  (Z3)
`base`, `volatility3`, `sleuthkit-autopsy`, `plaso`, `bulk-extractor`, `ewf-tools`, `evidence-store` (hash on ingest, read-only mounts), `timeline-templates`.

### FUZZ_NODE  (Z2/Z3)
`base`, `aflplusplus`, `clang-sanitizers`, `honggfuzz`, `corpus-manager`, `crash-triage`, `cpu-pinning`, `ramdisk-workdir`. Uses spare CPUs for coverage-guided fuzzing; warn if combined with CLUSTER_NODE.

### SIEM_NODE  (Z2)
`base`, `docker`, `wazuh` (optional heavy), `sigma-cli`, `rule-repo`, `log-forwarders`. Detection engineering and rule testing; rule repo backed up by BACKUP_NODE.

### THREATINTEL_NODE  (Z2)
`base`, `docker`, `misp`, `ioc-store`, `yara-rule-repos`, `feed-importers`. (OpenCTI optional, heavy.)

### SECRETS_NODE  (Z2)
`base`, `age-sops` (default) or `openbao` (flag), `token-distribution`, `rotation-scripts`. Central place for API tokens and keys; others fetch via short-lived pull.

### EGRESS_NODE  (Z2)
`base`, `squid-or-tinyproxy`, `dns-filter` (unbound/dnsmasq lists), `allowlists`, `access-logs`. Controlled internet path for autonomous agents.

## E. Legacy aliases
- `CLUSTER_NODE` unchanged.
- `AGENT_BOX` -> `AGENT_NODE`.
- `LAB_HOST` -> interactive selector among `MALWARE_NODE`, `RE_NODE`, `PENTEST_NODE`, `RANGE_NODE`, `FORENSICS_NODE` (non-interactive: pass the exact type).
