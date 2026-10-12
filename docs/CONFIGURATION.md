# CONFIGURATION.md — never put real secrets here

Config precedence: CLI flags > environment (`BS_*`) > `/etc/agent-bootstrap/bootstrap.conf` > per-module `conf.d/<module>.env` > defaults.

## Global options
| Variable / flag | Default | Notes |
|---|---|---|
| `BS_MIRROR` / `--mirror` | unset | Base URL of MIRROR_NODE |
| `BS_OFFLINE` / `--offline` | 0 | Never contact upstream |
| `BS_ZONE` / `--zone` | auto-detect | Z0..Z3; detection by interface/subnet map |
| `BS_INIT` / `--init` | auto | runit, openrc, systemd |
| `BS_STATE_DIR` | /var/lib/agent-bootstrap | |
| `BS_LOG_DIR` | /var/log/agent-bootstrap | |
| `BS_ASSUME_YES` / `--yes` | 0 | Skips prompts, not guardrails |
| `BS_DRYRUN` / `--dry-run` | 0 | |
| `BS_ALLOW_UNPINNED` | 0 | Dev only; refused in production profile |
| `BS_NO_COLOR` / `NO_COLOR` | unset | |
| `BS_PROFILE` | prod | prod or dev |

## Cluster
| `BS_COORD_MIN_RAM_GB` | 64 | Coordinator-capable threshold |
| `BS_WORKER_ONLY` | 0 | Force worker role |
| `BS_CPU_VARIANT` | auto | baseline, avx, avx2, avx512 override |
| `BS_MODEL` | qwen3.8-gguf (pinned name) | From mirror |
| `BS_MODEL_QUANT` | set in module.conf | Priority: accuracy |
| `BS_CTX_TOKENS` | max that fits | Target context size |
| `BS_USE_DOCKER` | auto | Docker optional runtime |
| `BS_GATEWAY_VIP` | unset | Virtual IP for GATEWAY_NODE |

## Gateway / infra
`BS_GATEWAY_BACKEND` (haproxy|caddy), `BS_BACKUP_TOOL` (restic|borg), `BS_BACKUP_REPO`, `BS_SECRETS_BACKEND` (age-sops|openbao), `BS_EGRESS_PROXY` (squid|tinyproxy), `BS_NTP_SERVERS`, `BS_DHCP_RANGE`, `BS_OOB_IFACE`.

## Security labs
`BS_SCOPE_FILE` (default /etc/agent-bootstrap/scope.yaml), `BS_LAB_DEDICATED_HOST` (0/1), `BS_SAMPLE_DIR`, `BS_VM_IMAGE_DIR`, `BS_EVIDENCE_DIR`.

## Zone map file — `/etc/agent-bootstrap/zones.conf`
```
Z0=<iface or CIDR>
Z1=<CIDR>
Z2=<CIDR>
Z3=<bridge name>
```
(Placeholders only in the repo; real values stay on the machine.)

## Development vs production
- dev: `BS_PROFILE=dev` allows `--allow-unpinned`, container-based fake zones, skips root checks in tests.
- prod: pinned+verified artifacts only, guardrails strict, confirmation prompts on.
