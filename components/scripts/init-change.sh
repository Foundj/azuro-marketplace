#!/bin/bash

# Initialize Change Script for ai-dev
# Creates a new change directory with required files

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

CODEBOX_DIR="codebox"
CHANGES_DIR="${CODEBOX_DIR}/changes/active"
TEMPLATES_DIR="${HOME}/.claude/skills/ai-dev/templates"

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    echo "📝 Init Change: $1"
}

log_error() {
    echo "📝 Init Change ❌: $1" >&2
}

generate_change_id() {
    echo "CHG-$(date +%Y%m%d)-$(printf '%03d' $((RANDOM % 1000)))"
}

# ============================================================================
# Main Functions
# ============================================================================

create_change() {
    local change_id="${1:-$(generate_change_id)}"
    local summary="${2:-New change}"
    local change_dir="${CHANGES_DIR}/${change_id}"
    
    # Check if already exists
    if [[ -d "$change_dir" ]]; then
        log_error "Change $change_id already exists"
        exit 1
    fi
    
    # Create directory
    mkdir -p "$change_dir"
    
    # Create state.json
    cat > "${change_dir}/state.json" <<EOF
{
  "changeId": "${change_id}",
  "summary": "${summary}",
  "createdAt": "$(date -Iseconds)",
  "currentPhase": 0,
  "status": "active",
  "phaseHistory": [],
  "implementationComplete": false,
  "qualityValidationComplete": false,
  "workerConfig": {
    "enabled": true,
    "maxDepth": 2,
    "spawnThreshold": 80,
    "handbackTimeout": 1800
  },
  "workerHierarchy": {
    "sessionType": "parent",
    "depth": 0,
    "parentChain": []
  },
  "workerSessions": [],
  "ooda": {
    "active": false,
    "iteration": 0,
    "maxIterations": 50,
    "completionPromise": "DONE"
  }
}
EOF
    
    # Create proposal.md template
    cat > "${change_dir}/proposal.md" <<EOF
# Requirement Proposal

> Change ID: ${change_id}
> Created: $(date -Iseconds)
> Status: pending_interview

## Summary

${summary}

## Global Requirements Reference

<!-- Will be filled by requirement-interviewer -->

## Requirements

<!-- Will be filled by requirement-interviewer -->

## Success Criteria

- [ ] 

## Interview Status

- [ ] Phase 1: Requirement Interview - Pending
EOF
    
    # Create phase0-context.md placeholder
    cat > "${change_dir}/phase0-context.md" <<EOF
# Phase 0: Context Pre-Check

> Generated: $(date -Iseconds)
> Change ID: ${change_id}

## Project Context

<!-- Will be filled by scan-project.sh -->

## Knowledge Check

<!-- Will be filled by query-knowledge.sh -->

## Issues Detected

<!-- Any blocking/warning issues -->
EOF
    
    log_info "Created change: $change_dir"
    echo "$change_dir"
}

# ============================================================================
# CLI Interface
# ============================================================================

usage() {
    cat <<EOF
Usage: $(basename "$0") [change_id] [summary]

Arguments:
    change_id    Optional change ID (auto-generated if not provided)
    summary      Optional one-line summary of the change

Examples:
    $(basename "$0")                           # Auto-generate ID
    $(basename "$0") CHG-20250105-001         # Specific ID
    $(basename "$0") CHG-20250105-001 "User login feature"
EOF
}

main() {
    local change_id="${1:-}"
    local summary="${2:-New change}"
    
    case "$change_id" in
        -h|--help)
            usage
            exit 0
            ;;
        *)
            create_change "$change_id" "$summary"
            ;;
    esac
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
