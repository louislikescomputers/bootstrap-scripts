# CHANGELOG
Format: Keep a Changelog; Semantic Versioning.

## [Unreleased]
### Added
- Initial documentation set: 23 node types (core, security, dev, infra), spec, architecture, plan, testing, security, ops docs.
- Node types beyond the original three (CLUSTER_NODE, AGENT_BOX, LAB_HOST): RE, PENTEST, VIBECODE, GATEWAY, MONITORING, MIRROR, BUILD, RETRIEVAL, EVAL, PROVISION, OOB, BACKUP, RANGE, FORENSICS, FUZZ, SIEM, THREATINTEL, SECRETS, EGRESS, ORCHESTRATION, MALWARE.
### Changed
- `AGENT_BOX` is now an alias of `AGENT_NODE`; `LAB_HOST` becomes a selector for lab node types.
### Migration
- Existing `bootstrap CLUSTER_NODE | AGENT_BOX | LAB_HOST` invocations keep working.
