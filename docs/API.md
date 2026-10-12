# API.md — Interfaces and contracts

No public web API in v1. Interfaces are the CLI, module contract, and service contracts between nodes.

## 1. CLI contract
Exit codes: 0 ok, 1 generic failure, 2 usage error, 3 guardrail refusal, 4 preflight failed, 5 verify failed, 6 download/checksum failure, 10 skipped (module-level only).
Output: human text on stdout; `--json` emits machine-readable results for `list`, `plan`, `status`, `verify`.
`plan --json` shape: `{"type":"CLUSTER_NODE","zone":"Z1","modules":[{"name":"...","version":"...","artifacts":[{"name":"...","sha256":"...","size":0}],"services":[],"ports":[]}],"conflicts":[],"warnings":[]}`

## 2. Module contract
See ARCHITECTURE.md. Environment inputs, exit codes, `module.conf` fields are the contract.

## 3. Gateway (GATEWAY_NODE)
- `GET /v1/models`, `POST /v1/chat/completions`, `POST /v1/completions`, `POST /v1/embeddings` — OpenAI-compatible, proxied to the active coordinator (LocalAI).
- `GET /gateway/healthz` — gateway alive; `GET /gateway/active` — current coordinator.
- Errors: 502 no healthy coordinator; 503 draining; 429 optional rate limiting.
- Auth: bearer token (from SECRETS_NODE) for non-lab clients; lab clients by zone ACL.
- Health check of each coordinator: `GET /readyz` (LocalAI) and a small completion probe at low frequency.

## 4. Node watchdog
Local only: writes Prometheus textfile metrics `bootstrap_watchdog_restarts_total`, `bootstrap_context_size`, `bootstrap_active_model`, `bootstrap_node_role`; logs events to journal/syslog as `watchdog: <event> key=value`.

## 5. Mirror HTTP layout (MIRROR_NODE)
```
/ggufs/<model>/<file>.gguf
/releases/<name>/<version>/<arch>-<cpu_variant>/<file>
/pkgs/apt/ , /pkgs/pacman/
/SHA256SUMS  /SHA256SUMS.sig  /manifest.tsv
```
Read-only HTTP GET; range requests supported for resumable GGUF downloads.

## 6. Monitoring endpoints
node_exporter `:9100`, Prometheus `:9090`, Grafana `:3000`, Loki `:3100`, Uptime Kuma `:3001` (all zone-bound, behind Caddy where exposed).

## 7. Ghidra MCP bridge (MALWARE_NODE / RE_NODE)
MCP server exposing: `list_functions`, `decompile_function`, `get_xrefs`, `rename`, `add_comment`, `list_strings`. Read-mostly; write operations limited to annotations in the project. Local socket/loopback only unless explicitly configured.

## 8. External contracts
Upstream release URLs/tags for LocalAI, llama.cpp, Qdrant, Ghidra, etc. are pinned in `module.conf`; changes require a DECISIONS.md entry. Optional future: read-only `bootstrap-mcp` exposing `plan/status/verify` to agents (not v1).
