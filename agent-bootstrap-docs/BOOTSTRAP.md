# BOOTSTRAP.md — runtime quick reference

Usage: `bootstrap NODE_TYPE [options]` — see SPECIFICATION.md section 4 for the exact text.
Flow: doctor -> guardrails -> plan -> apply -> verify -> status.
Node types and modules: NODE_CATALOG.md. Hard rules: never touch kernel/boot/partitions; zones enforced; checksums required.
Agent-written steps: propose via `templates/agent-steps/`, they are scanned and shown in `plan` before running.
