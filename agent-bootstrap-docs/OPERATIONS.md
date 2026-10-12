# OPERATIONS.md

## Logging
Bootstrap logs: `/var/log/agent-bootstrap/`. Services log via the init system; Loki + Alloy/Promtail ship logs to MONITORING_NODE. Redaction applied to bootstrap logs.

## Monitoring
Dashboards: nodes up, RAM, context size, active model, watchdog events, active coordinator, disk free on MIRROR_NODE, backup age, eval trend.
Alerts (Grafana/Uptime Kuma): node down >5 min, no healthy coordinator, watchdog restarts >3/h, disk <15 %, backup older than 26 h, mirror checksum mismatch, clock skew >2 s.

## Backups (BACKUP_NODE)
Targets: `/etc/agent-bootstrap`, secrets store (encrypted), SIEM rules/detection content, Forgejo repos, inventory.db, tasks.db, eval.db, Grafana dashboards. Daily incremental, weekly full verification, monthly restore test. Retention 7 daily/4 weekly/6 monthly.

## Recovery
- Node dead: OOB_NODE power-cycle -> console (conserver) -> check watchdog events. If unrecoverable, re-provision via PROVISION_NODE (role from inventory).
- Coordinator loss: gateway fails over; verify `GET /gateway/active`.
- Mirror loss: restore from backup or rebuild via BUILD_NODE; nodes with local cache continue.
- State corruption: delete module state file then `bootstrap verify`/`apply` (idempotent).

## Incident troubleshooting
| Symptom | Check | Fix |
|---|---|---|
| Illegal instruction (SIGILL) | CPU variant | Use baseline build from mirror |
| Node not joining cluster | init service, rpc-server port, zone | `bootstrap verify CLUSTER_NODE`, check firewall |
| Download slow | mirror reachability | Fix mirror or use `--offline` cache |
| Apply refused | guardrail code 3 | Read message; do not bypass |
| Clock/TLS errors | chrony | Sync time via PROVISION_NODE |
| Gateway 502 | healthchecks | Start a coordinator-capable node |
| Out of disk | `df`, GGUF location | Move GGUFs to mirror/attached storage |

## Security-lab operations
MALWARE_NODE: revert snapshots after each session; rotate sample dir; never connect to LAN. PENTEST_NODE: archive evidence per engagement; delete after retention window.
