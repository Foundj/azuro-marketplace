#!/bin/bash

# Execution Tracker Hook
# Tracks timing and token usage for ultrawork phases
# Outputs execution report at session end

set -euo pipefail

LOG_PREFIX="⏱️  Tracker"

# ============================================================================
# Configuration
# ============================================================================

TRACKER_DIR="${HOME}/.claude/tracker"
TRACKER_FILE="${TRACKER_DIR}/session-$(date +%Y%m%d-%H%M%S).json"
PHASE_FILE="${TRACKER_DIR}/current-phase.txt"

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    echo -e "\033[0;34m${LOG_PREFIX}: $1\033[0m"
}

log_warn() {
    echo -e "\033[1;33m${LOG_PREFIX} ⚠️: $1\033[0m"
}

ensure_dir() {
    mkdir -p "$TRACKER_DIR" 2>/dev/null || true
}

get_timestamp() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

get_timestamp_ms() {
    # macOS compatible
    date -u +"%Y-%m-%dT%H:%M:%S.000Z"
}

# ============================================================================
# Phase Tracking
# ============================================================================

start_phase() {
    local phase="$1"
    ensure_dir

    local start_time=$(get_timestamp_ms)

    # Record phase start
    if [[ -f "$TRACKER_FILE" ]]; then
        jq --arg phase "$phase" --arg time "$start_time" \
            '.phases[$phase] = {start: $time, end: null, duration_ms: null}' \
            "$TRACKER_FILE" > "${TRACKER_FILE}.tmp" && mv "${TRACKER_FILE}.tmp" "$TRACKER_FILE"
    else
        cat > "$TRACKER_FILE" << EOF
{
    "session_start": "$start_time",
    "session_end": null,
    "total_duration_ms": null,
    "phases": {
        "$phase": {
            "start": "$start_time",
            "end": null,
            "duration_ms": null
        }
    },
    "token_estimate": {
        "total": 0,
        "by_phase": {}
    }
}
EOF
    fi

    echo "$phase" > "$PHASE_FILE"
    log_info "Started Phase: $phase"
}

end_phase() {
    local phase="$1"
    ensure_dir

    local end_time=$(get_timestamp_ms)

    if [[ -f "$TRACKER_FILE" ]]; then
        # Get start time
        local start_time=$(jq -r ".phases[\"$phase\"].start // empty" "$TRACKER_FILE" 2>/dev/null || echo "")

        if [[ -n "$start_time" ]]; then
            # Calculate duration (simplified - actual calculation would need date math)
            local duration_ms=0

            jq --arg phase "$phase" --arg time "$end_time" --argjson duration "$duration_ms" \
                '.phases[$phase].end = $time | .phases[$phase].duration_ms = $duration' \
                "$TRACKER_FILE" > "${TRACKER_FILE}.tmp" && mv "${TRACKER_FILE}.tmp" "$TRACKER_FILE"
        fi
    fi

    log_info "Completed Phase: $phase"
}

# ============================================================================
# Report Generation
# ============================================================================

generate_report() {
    ensure_dir

    if [[ ! -f "$TRACKER_FILE" ]]; then
        log_warn "No tracking data found"
        return 0
    fi

    local session_start=$(jq -r '.session_start // "unknown"' "$TRACKER_FILE")
    local session_end=$(get_timestamp_ms)
    local phase_count=$(jq '.phases | length' "$TRACKER_FILE")

    # Update session end
    jq --arg time "$session_end" '.session_end = $time' "$TRACKER_FILE" > "${TRACKER_FILE}.tmp" && mv "${TRACKER_FILE}.tmp" "$TRACKER_FILE"

    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    EXECUTION REPORT                              ║"
    echo "╠═══════════════════════════════════════════════════════════════╣"
    echo "║                                                               ║"
    printf "║  Session Start: %-44s ║\n" "$session_start"
    printf "║  Session End:   %-44s ║\n" "$session_end"
    printf "║  Phases Tracked: %-42d ║\n" "$phase_count"
    echo "║                                                               ║"
    echo "╠═══════════════════════════════════════════════════════════════╣"
    echo "║                    PHASE TIMINGS                                ║"
    echo "╠═══════════════════════════════════════════════════════════════╣"

    # List phases
    jq -r '.phases | to_entries[] | "║  \(.key): \(.value.duration_ms // "N/A") ms"' "$TRACKER_FILE" 2>/dev/null || true

    echo "║                                                               ║"
    echo "╠═══════════════════════════════════════════════════════════════╣"
    echo "║                    PERFORMANCE TIPS                              ║"
    echo "╠═══════════════════════════════════════════════════════════════╣"

    # Add performance tips based on timing
    echo "║  • Use parallel subagent dispatch for independent tasks        ║"
    echo "║  • Compress context after each wave to reduce token usage      ║"
    echo "║  • Run dependency analysis before Phase 5 for optimization    ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
}

# ============================================================================
# Hook Input Processing
# ============================================================================

# Read hook input if available
if [[ -t 0 ]]; then
    # Interactive mode - just show help
    echo "Execution Tracker Hook"
    echo ""
    echo "Usage: This hook is called by Claude Code at session end."
    echo ""
    echo "Tracked phases:"
    echo "  - Phase 0: Confidence Gate"
    echo "  - Phase 1: Task Analysis"
    echo "  - Phase 2: Clarification"
    echo "  - Phase 3: Worktree Isolation"
    echo "  - Phase 4: Plan Generation"
    echo "  - Phase 5: Subagent Execution"
    echo "  - Phase 6: Two-Stage Review"
    echo "  - Phase 7: Continuation"
    echo "  - Phase 8: Finishing"
    echo "  - Phase 9: Completion"
    exit 0
fi

# Read stdin for hook data
HOOK_INPUT=$(cat)
HOOK_EVENT=$(echo "$HOOK_INPUT" | jq -r '.hook_event_name // "unknown"' 2>/dev/null || echo "unknown")

# ============================================================================
# Main Logic
# ============================================================================

case "$HOOK_EVENT" in
    "Stop")
        generate_report
        ;;
    *)
        # Unknown event - do nothing
        ;;
esac

exit 0