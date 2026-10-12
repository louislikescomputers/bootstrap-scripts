# USER_GUIDE.md

## Quick start
```
bootstrap                 # shows usage
bootstrap list            # see all node types
bootstrap doctor          # check this machine
bootstrap plan AGENT_NODE # preview
sudo bootstrap apply AGENT_NODE
bootstrap verify AGENT_NODE
```
Not sure what to pick? `bootstrap wizard` asks what the machine is for.

## Which node type do I want?
- Run the big model across machines: `CLUSTER_NODE` (+ one `GATEWAY_NODE` so agents have a single address).
- Let agents code autonomously: `AGENT_NODE` (with `EGRESS_NODE` for internet access). Alias: `AGENT_BOX`.
- Code with AI help yourself: `VIBECODE_NODE`.
- Coordinate multiple agents: `ORCHESTRATION_NODE` (+ `RETRIEVAL_NODE` for better long-document answers).
- Reverse engineer files/firmware/apps: `RE_NODE`.
- Analyse suspicious samples safely: `MALWARE_NODE` on a dedicated, isolated machine.
- Test systems you are authorised to test: `PENTEST_NODE` with a `scope.yaml`; practice on `RANGE_NODE`.
- Memory/disk forensics: `FORENSICS_NODE`. Fuzzing: `FUZZ_NODE`. Detection rules: `SIEM_NODE`. IOC/feeds: `THREATINTEL_NODE`.
- Fleet plumbing: `MIRROR_NODE` (fast/offline installs), `BUILD_NODE` (prebuilt binaries for old CPUs), `PROVISION_NODE` (install 100+ machines), `MONITORING_NODE` (dashboards), `OOB_NODE` (power/console), `BACKUP_NODE`, `SECRETS_NODE`, `EVAL_NODE` (did my change make answers better?).

## Common workflows
1. First-time lab: MIRROR_NODE + BUILD_NODE -> a few CLUSTER_NODEs -> GATEWAY_NODE -> MONITORING_NODE -> AGENT_NODE.
2. Pentest: write scope.yaml (targets, window, contact) -> `apply PENTEST_NODE` -> run tools (wrappers check scope) -> evidence saved and hashed -> use report templates.
3. Malware analysis: boot dedicated workstation -> `apply MALWARE_NODE` (passes isolation check) -> import VMs -> work in snapshots -> revert.
4. Offline install: populate the mirror once, then add `--offline --mirror http://mirror.lab`.

## Troubleshooting
- "refused (guardrail)": the tool protects zones, scope, kernel/boot. Read the message; it is not a bug.
- Download fails checksum: re-sync mirror; never use `--allow-unpinned` in prod.
- Node won't join cluster: see OPERATIONS.md table.
- Illegal instruction: your CPU lacks AVX2; fetch the baseline build.
- Simulator shows different output than real CLI: run `make parity` and report it.
