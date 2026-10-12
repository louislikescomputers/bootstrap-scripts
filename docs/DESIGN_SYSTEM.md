# DESIGN_SYSTEM.md — CLI/TUI and simulator

The "UI" is terminal output and the web terminal simulator.

## Colours (ANSI 16-colour only; must work on a serial console)
- ok/green, warn/yellow, error/red, info/cyan, dim/bright-black, headings/bold.
- Honour `NO_COLOR`, `--no-color`, and non-TTY output (plain).
- Never convey meaning by colour alone: prefix symbols `[ok] [warn] [fail] [skip] [..]` (ASCII fallback; optional unicode via `BS_UNICODE=1`).

## Typography/spacing
Monospace; max width 80 columns; wrap at 78; 2-space indent for nested items; blank line between sections; tables use aligned plain-space columns (no box drawing by default).

## Components
- Usage block (exact text in SPECIFICATION section 4).
- Plan table: module | version | download size | service | port.
- Progress line: `[..] module (n/N)` replaced by result on completion; plain lines when not a TTY.
- Summary block: counts of ok/skipped/failed + next steps.
- Prompt: `Proceed? [y/N]` (default No); `--yes` skips.
- Wizard: numbered menus, one question per screen, `b` back, `q` quit, shows plan before apply.

## Accessibility
Screen-reader friendly plain lines; no animation required; spinners disabled when non-TTY; error messages state cause + fix + docs reference.

## States
- Loading: progress line. Empty: "No modules installed. Run `bootstrap list`." Error: `[fail] <module>: <cause>. Fix: <action>. See OPERATIONS.md#<anchor>`.

## Simulator (web)
Dark background, monospace, chips above prompt for common commands (`help`, `bootstrap`, `bootstrap list`, `plan <TYPE>`, `ls`); prompt `louis@n1:~/agent-bootstrap$`; header text "Bootstrap Terminal Simulator — SIMULATION. Type help, or tap a chip above."; responsive (chips wrap on mobile); output fixtures only, no real execution; tab-completion for node types.
