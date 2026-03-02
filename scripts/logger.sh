#!/bin/bash
#
# logger.sh - Unified logging module for ai-dev v4.0
#
# Usage:
#   LOG_CONTEXT="Context" source logger.sh
#   log_info "message"
#

# Colors
LOG_RED='\033[0;31m'
LOG_GREEN='\033[0;32m'
LOG_YELLOW='\033[0;33m'
LOG_BLUE='\033[0;34m'
LOG_PURPLE='\033[0;35m'
LOG_CYAN='\033[0;36m'
LOG_NC='\033[0m' # No Color

# Icons
ICON_INFO="🔵"
ICON_SUCCESS="🟢"
ICON_WARN="🟡"
ICON_ERROR="🔴"
ICON_DEBUG="🔍"

# Config
LOG_CONTEXT="${LOG_CONTEXT:-Core}"
LOG_FILE=".agent/logs/ai-dev.log"
QUIET_MODE="${QUIET_MODE:-false}"

# Ensure log directory exists
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true

_log_to_file() {
    local level="$1"
    local msg="$2"
    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    echo "[$timestamp] [$level] [$LOG_CONTEXT] $msg" >> "$LOG_FILE" 2>/dev/null || true
}

log_info() {
    local msg="$1"
    [[ "$QUIET_MODE" == "true" ]] || echo -e "${LOG_BLUE}${ICON_INFO} [$LOG_CONTEXT] INFO: ${msg}${LOG_NC}" >&2
    _log_to_file "INFO" "$msg"
}

log_success() {
    local msg="$1"
    [[ "$QUIET_MODE" == "true" ]] || echo -e "${LOG_GREEN}${ICON_SUCCESS} [$LOG_CONTEXT] SUCCESS: ${msg}${LOG_NC}" >&2
    _log_to_file "SUCCESS" "$msg"
}

log_warn() {
    local msg="$1"
    [[ "$QUIET_MODE" == "true" ]] || echo -e "${LOG_YELLOW}${ICON_WARN} [$LOG_CONTEXT] WARN: ${msg}${LOG_NC}" >&2
    _log_to_file "WARN" "$msg"
}

log_error() {
    local msg="$1"
    echo -e "${LOG_RED}${ICON_ERROR} [$LOG_CONTEXT] ERROR: ${msg}${LOG_NC}" >&2
    _log_to_file "ERROR" "$msg"
}

log_debug() {
    local msg="$1"
    if [[ "${DEBUG:-false}" == "true" ]]; then
        echo -e "${LOG_CYAN}${ICON_DEBUG} [$LOG_CONTEXT] DEBUG: ${msg}${LOG_NC}" >&2
    fi
    _log_to_file "DEBUG" "$msg"
}
