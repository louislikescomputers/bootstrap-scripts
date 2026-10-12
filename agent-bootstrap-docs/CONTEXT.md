# CONTEXT.md — keep short and current

Updated: (agent updates at end of every session)

## Status
Docs-only phase complete. No code yet. Next: M0.

## Next task
T001 repo skeleton, then T002 dispatcher.

## Unresolved questions
1. Netboot path for Artix: use live ISO via netboot.xyz then run wizard; confirm feasibility on old BIOS/PXE machines.
2. Coordinator RAM threshold default (proposed 64 GB) — confirm.
3. FLARE-VM/REMnux image sourcing and licensing handling on offline mirror.
4. Gateway choice default: Caddy vs HAProxy (proposed HAProxy + keepalived for TCP/HTTP health checks).
5. Which Ghidra MCP bridge implementation to pin.

## Known problems / risks
- Some old hardware had distro compatibility problems (e.g. Ubuntu); test matrix must include a real old machine.
- Compiling llama.cpp/LocalAI on old CPUs is very slow; BUILD_NODE is the mitigation.
- Small disks: GGUF storage must live on MIRROR_NODE or attached storage.

## Reminders
Never touch kernel/boot/partitions. Simulator output must match real CLI.
