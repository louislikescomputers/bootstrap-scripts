# DATA_MODEL.md

File-based, human-readable state; SQLite only where noted. Base dir `/var/lib/agent-bootstrap/` (state), `/etc/agent-bootstrap/` (config), `/var/log/agent-bootstrap/` (logs).

## Entities
### Node identity — `node.env`
`NODE_ID` (hostname-based, unique), `NODE_TYPES` (space list), `ZONE`, `INIT`, `ARCH`, `CPU_VARIANT` (baseline|avx|avx2|avx512), `RAM_MB`, `COORDINATOR_CAPABLE` (yes|no), `CREATED_AT`, `BOOTSTRAP_VERSION`.
Constraints: `NODE_ID` matches `[a-z0-9-]{1,63}`; `ZONE` in Z0..Z3.

### Module state — `modules/<name>.state`
`NAME`, `VERSION`, `STATUS` (pending|installing|installed|failed|removed), `INSTALLED_AT`, `LAST_VERIFY_AT`, `LAST_VERIFY_RC`, `ARTIFACT_SHA256S`, `FILES_CREATED` (path list for uninstall).
Constraint: STATUS=installed only after verify rc=0.

### Run record — `runs/<timestamp>-<type>.log` + `.json` summary
`RUN_ID`, `COMMAND`, `TYPE`, `START/END`, `RESULT`, per-module results.

### Artifact manifest (MIRROR_NODE) — `manifest.tsv` + `SHA256SUMS`
Columns: `name, version, arch, cpu_variant, sha256, size_bytes, source_url, build_git_sha, build_flags, published_at`.
Unique key: `(name, version, arch, cpu_variant)`.

### Fleet inventory (PROVISION_NODE) — SQLite `inventory.db`
Tables:
- `machines(id, mac, hostname, ip, role_types, zone, cpu_flags, ram_mb, disk_gb, notes, first_seen, last_seen)`; unique `mac`, unique `hostname`.
- `events(id, machine_id, kind, detail, ts)`; kinds: provisioned, applied, verify_failed, watchdog_restart, power_cycle.
FK: `events.machine_id -> machines.id`.

### Scope file — `scope.yaml` (PENTEST_NODE)
`engagement_id`, `authorisation_ref`, `contact`, `window{start,end}`, `targets[]` (CIDR/host/URL), `excluded[]`, `notes`. Validation: window must be current; targets non-empty; no targets in Z0/Z1 ranges unless explicitly `allow_internal: true` with ref.

### Orchestration task state (ORCHESTRATION_NODE) — SQLite `tasks.db`
`tasks(id, parent_id, title, status, agent, created_at, updated_at, result_ref)`, `runs(id, task_id, started, ended, rc, log_path)`. Status in pending|running|blocked|done|failed. WAL mode.

### Eval results (EVAL_NODE) — SQLite `eval.db`
`runs(id, ts, model, quant, ctx, build_ver, notes)`, `results(run_id, prompt_id, score, output_ref, latency_ms)`, `prompts(id, set_name, text, expected, tags)`.

## Migrations
`schema_version` table per SQLite DB; migrations in `migrations/NNN_name.sql`, forward-only, applied by `bootstrap` helper in a transaction with a pre-backup copy.

## Retention / deletion
- Run logs: keep 90 days or last 200 runs, whichever larger; compress after 7 days.
- Module state: kept until uninstall; uninstall deletes state.
- Eval results: keep forever (small); prune outputs older than 180 days.
- Evidence/samples: per-engagement; deleted by explicit command with hash log retained.
- Inventory events: 1 year.
- Secrets: rotation per SECURITY.md; old versions deleted after grace period.
