# lib/ui.sh — user interface helpers (DESIGN_SYSTEM.md).
# POSIX sh. Source from bootstrap/lib consumers; requires BS_* config vars
# to be initialised by the caller (defaults applied here as a safety net).
#
# Rules implemented here:
#  - Colours: ANSI 16-colour only, honoured only when stdout is a TTY and
#    neither NO_COLOR nor --no-color (BS_NO_COLOR=1) is set.
#  - Meaning is never carried by colour alone: every message has an ASCII
#    status prefix ([ok] [warn] [fail] [skip] [..]) plus optional unicode
#    glyph when BS_UNICODE=1.
#  - All user-facing output goes through these functions.

# Defaults (caller may override before sourcing or via env/flags).
: "${BS_NO_COLOR:=0}"
: "${BS_UNICODE:=0}"
: "${BS_QUIET:=0}"

if [ "${BS_NO_COLOR:-0}" = "1" ] || [ -n "${NO_COLOR:-}" ] || [ ! -t 1 ]; then
	UI_C_OK=''; UI_C_WARN=''; UI_C_ERR=''; UI_C_INFO=''; UI_C_DIM=''; UI_C_BOLD=''
	UI_C_RESET=''
else
	UI_C_OK=$(printf '\033[32m')
	UI_C_WARN=$(printf '\033[33m')
	UI_C_ERR=$(printf '\033[31m')
	UI_C_INFO=$(printf '\033[36m')
	UI_C_DIM=$(printf '\033[90m')
	UI_C_BOLD=$(printf '\033[1m')
	UI_C_RESET=$(printf '\033[0m')
fi

if [ "${BS_UNICODE:-0}" = "1" ]; then
	UI_SYM_OK=$(printf '\xe2\x9c\x93') # check
	UI_SYM_WARN=$(printf '\xe2\x9a\xa0') # warning
	UI_SYM_ERR=$(printf '\xe2\x9c\x97') # cross
	UI_SYM_SKIP=$(printf '\xe2\x97\x8b') # circle
	UI_SYM_RUN=$(printf '\xe2\x96\xb6') # play
else
	UI_SYM_OK='ok'; UI_SYM_WARN='warn'; UI_SYM_ERR='fail'; UI_SYM_SKIP='skip'; UI_SYM_RUN='..'
fi

# ui_print <color> <symbol-ascii> <symbol-unicode> <message...>
ui_print() {
	_ui_color=$1; _ui_ascii=$2; _ui_sym=$3; shift 3
	[ "${BS_QUIET:-0}" = "1" ] && return 0
	if [ "$_ui_ascii" = "--" ]; then
		printf '%s%s%s\n' "$_ui_color" "$*" "$UI_C_RESET"
	else
		printf '%s[%s]%s %s%s %s\n' "$UI_C_BOLD" "$_ui_ascii" "$UI_C_RESET" \
			"$_ui_color" "$_ui_sym" "$UI_C_RESET$*"
	fi
}

ui_ok()   { ui_print "$UI_C_OK"   'ok'   "$UI_SYM_OK"   "$@"; }
ui_warn() { ui_print "$UI_C_WARN" 'warn' "$UI_SYM_WARN" "$@" >&2; }
ui_err()  { ui_print "$UI_C_ERR"  'fail' "$UI_SYM_ERR"  "$@" >&2; }
ui_info() { ui_print "$UI_C_INFO" '--'   '--'           "$@"; }
ui_dim()  { ui_print "$UI_C_DIM"  '--'   '--'           "$@"; }
ui_step() { ui_print "$UI_C_DIM"  '..'   "$UI_SYM_RUN"  "$@"; }

# ui_heading <text> — bold section heading.
ui_heading() { ui_print "$UI_C_BOLD" '--' '--' "$@"; }

# ui_die <exit-code> <message...> — print error and exit (API.md codes).
ui_die() {
	_code=$1; shift
	ui_err "$*"
	exit "$_code"
}

# ui_confirm <prompt> — read one y/N answer; default No. Returns 0 on yes.
# Honours BS_ASSUME_YES (--yes): auto-confirms without prompting.
ui_confirm() {
	_prompt=${1:-Proceed? [y/N]}
	if [ "${BS_ASSUME_YES:-0}" = "1" ]; then
		return 0
	fi
	if [ ! -t 0 ]; then
		# non-interactive stdin: safe default is No
		return 1
	fi
	printf '%s ' "$_prompt" >&2
	IFS= read -r _ans || return 1
	case "$_ans" in
	y | Y | yes | YES) return 0 ;;
	*) return 1 ;;
	esac
}
