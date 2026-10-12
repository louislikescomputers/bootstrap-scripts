# lib/log.sh — logging with secret redaction (SECURITY.md S8, R5).
# POSIX sh. All persistent log lines must go through log_line/log_* so that
# known secret shapes are scrubbed before they ever touch disk.
#
# Redaction policy:
#  - Any token of the form KEY=VALUE where KEY matches a secret-ish name
#    (token|secret|password|passwd|apikey|api_key|authorization|bearer|psk)
#    has its VALUE replaced with [REDACTED].
#  - Common provider token prefixes (sk-, ghp_, github_pat_, xox[bap]-,
#    AIza..., Bearer <b64>) are replaced wherever they appear.
#  - Long high-entropy base64/hex strings (>32 chars) are replaced as a
#    last-resort catch-all.

: "${BS_LOG_DIR:=}"   # set by dispatcher; empty => no file logging
: "${BS_LOG_LEVEL:=info}"

# BS_REDACT_* hold sed programs; built once per shell.
_BS_REDACT_PATTERNS='s#([Tt][Oo][Kk][Ee][Nn]|[Ss][Ee][Cc][Rr][Ee][Tt]|[Pp][Aa][Ss][Ss][Ww][Oo][Rr][Dd]|[Pp][Aa][Ss][Ss][Ww][Dd]|[Aa][Pp][Ii][_]\?[Kk][Ee][Yy]|[Aa][Uu][Tt][Hh][Oo][Rr][Ii][Zz][Aa][Tt][Ii][Oo][Nn]|[Bb][Ee][Aa][Rr][Ee][Rr]|[Pp][Ss][Kk])=[^ ]*#\1=[REDACTED]#g'
_BS_REDACT_TOKENS='s#\(sk\|ghp\|gho\|github_pat\|xoxb\|xoxp\|xoxa\)-[A-Za-z0-9_-]\{6,\}#[REDACTED]#g; s#AIza[A-Za-z0-9_-]\{20,\}#[REDACTED]#g; s#[Bb][Ee][Aa][Rr][Ee][Rr] [A-Za-z0-9_+/=-]\{8,\}#Bearer [REDACTED]#g'
_BS_REDACT_ENTROPY='s#[A-Za-z0-9+/]\{33,\}=\{0,2\}#[REDACTED]#g'

# log_redact — read stdin, write redacted text to stdout.
log_redact() {
	sed -e "$_BS_REDACT_PATTERNS" \
		-e "$_BS_REDACT_TOKENS" \
		-e "$_BS_REDACT_ENTROPY"
}

# log_level_num <level> -> echo number
_log_level_num() {
	case "$1" in
	debug) echo 0 ;;
	info) echo 1 ;;
	warn) echo 2 ;;
	error) echo 3 ;;
	*) echo 1 ;;
	esac
}

# log_line <level> <message...> — timestamped, redacted line to stderr copy +
# log file (when BS_LOG_DIR is set). Levels below BS_LOG_LEVEL are dropped.
log_line() {
	_level=$1; shift
	case "$_level" in
	DEBUG) _level_n=0 ;;
	INFO) _level_n=1 ;;
	WARN) _level_n=2 ;;
	ERROR) _level_n=3 ;;
	*) _level_n=1 ;;
	esac
	_min=$(_log_level_num "${BS_LOG_LEVEL:-info}")
	[ "$_level_n" -lt "$_min" ] && return 0

	_ts=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
	_msg="$_ts $_level $*"
	printf '%s\n' "$_msg" | log_redact >&2

	if [ -n "${BS_LOG_DIR:-}" ]; then
		_logfile="${BS_LOG_DIR}/bootstrap.log"
		# best effort; never fail the caller over logging
		mkdir -p -- "$BS_LOG_DIR" 2>/dev/null || return 0
		printf '%s\n' "$_msg" | log_redact >>"$_logfile" 2>/dev/null || true
	fi
	return 0
}

log_debug() { log_line DEBUG "$@"; }
log_info() { log_line INFO "$@"; }
log_warn() { log_line WARN "$@"; }
log_error() { log_line ERROR "$@"; }

# log_run_start <command> <node-type> — open a run record (DATA_MODEL.md).
# The full redacted command line is written to runs/<ts>-<type>.log.
log_run_start() {
	_cmd=$1; _type=${2:-none}
	[ -n "${BS_LOG_DIR:-}" ] || return 0
	_runid=$(date -u '+%Y%m%dT%H%M%SZ')
	BS_RUN_FILE="${BS_LOG_DIR}/runs/${_runid}-${_type}.log"
	mkdir -p -- "${BS_LOG_DIR}/runs" 2>/dev/null || return 0
	printf 'RUN_START %s cmd=%s type=%s\n' "$_runid" "$_cmd" "$_type" |
		log_redact >"$BS_RUN_FILE"
	export BS_RUN_FILE
}

# log_run_end <result> — append result to the open run record.
log_run_end() {
	[ -n "${BS_RUN_FILE:-}" ] || return 0
	printf 'RUN_END %s result=%s\n' "$(date -u '+%Y%m%dT%H%M%SZ')" "${1:-unknown}" |
		log_redact >>"$BS_RUN_FILE"
}
