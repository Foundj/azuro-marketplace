#!/bin/bash

# Initialize Version Script for ai-dev
# Creates a new versioned task directory under docs/tasks/

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

TASKS_DIR="docs/tasks"

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    echo "📝 Init Version: $1"
}

log_error() {
    echo "📝 Init Version ❌: $1" >&2
}

get_next_version() {
    if [[ ! -d "$TASKS_DIR" ]] || [[ -z "$(ls -d ${TASKS_DIR}/v* 2>/dev/null)" ]]; then
        echo "v1.0"
        return
    fi

    local max_version=""
    for dir in "${TASKS_DIR}"/v*/; do
        local v=$(basename "$dir")
        if [[ -z "$max_version" ]]; then
            max_version="$v"
        else
            local cur=$(echo "$v" | sed 's/^v//')
            local max=$(echo "$max_version" | sed 's/^v//')
            if [[ $(echo "$cur $max" | awk '{if ($1 > $2) print 1; else print 0}') -eq 1 ]]; then
                max_version="$v"
            fi
        fi
    done

    local major=$(echo "$max_version" | sed 's/^v//' | cut -d. -f1)
    local minor=$(echo "$max_version" | sed 's/^v//' | cut -d. -f2)
    echo "v${major}.$((minor + 1))"
}

# ============================================================================
# Main Functions
# ============================================================================

create_version() {
    local version="${1:-$(get_next_version)}"
    local summary="${2:-New feature}"
    local version_dir="${TASKS_DIR}/${version}"

    # Check if already exists
    if [[ -d "$version_dir" ]]; then
        log_error "Version $version already exists at $version_dir"
        exit 1
    fi

    # Create directory structure
    mkdir -p "$version_dir"
    mkdir -p "${version_dir}/research"

    # Create state.json (OODA compatibility)
    cat > "${version_dir}/state.json" <<EOF
{
  "version": "${version}",
  "summary": "${summary}",
  "createdAt": "$(date -Iseconds)",
  "currentPhase": 0,
  "status": "active",
  "phaseHistory": [],
  "implementationComplete": false,
  "qualityValidationComplete": false,
  "ooda": {
    "active": false,
    "iteration": 0,
    "maxIterations": 50,
    "completionPromise": "DONE"
  }
}
EOF

    log_info "Created version: $version_dir"
    echo "$version_dir"
}

# ============================================================================
# CLI Interface
# ============================================================================

usage() {
    cat <<EOF
Usage: $(basename "$0") [version] [summary]

Arguments:
    version      Optional version (auto-incremented if not provided, e.g., v2.0)
    summary      Optional one-line summary of the feature

Examples:
    $(basename "$0")                           # Auto-increment version
    $(basename "$0") v2.0                      # Specific version
    $(basename "$0") v2.0 "User permission management"
EOF
}

main() {
    local version="${1:-}"
    local summary="${2:-New feature}"

    case "$version" in
        -h|--help)
            usage
            exit 0
            ;;
        *)
            create_version "$version" "$summary"
            ;;
    esac
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
