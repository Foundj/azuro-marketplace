#!/bin/bash

# .agent Setup Script
# Creates standardized .agent directory structure for ultrawork workflow
# Usage: bash .agent-setup.sh <feature-name> [worktree-path]

set -euo pipefail

LOG_PREFIX="📦 .agent"

log_info() {
    echo -e "\033[0;32m${LOG_PREFIX}: $1\033[0m"
}

log_warn() {
    echo -e "\033[1;33m${LOG_PREFIX} ⚠️: $1\033[0m"
}

log_error() {
    echo -e "\033[0;31m${LOG_PREFIX} ❌: $1\033[0m"
}

# ============================================================================
# Parse Arguments
# ============================================================================

FEATURE_NAME="${1:-}"
WORKTREE_PATH="${2:-.}"

if [[ -z "$FEATURE_NAME" ]]; then
    log_error "Feature name required"
    echo "Usage: .agent-setup.sh <feature-name> [worktree-path]"
    exit 1
fi

# Normalize path
AGENT_PATH="${WORKTREE_PATH}/.agent"

# ============================================================================
# Create Directory Structure
# ============================================================================

log_info "Creating .agent at: ${AGENT_PATH}"

mkdir -p "${AGENT_PATH}/changes"
mkdir -p "${AGENT_PATH}/archive"

# ============================================================================
# Create spec.md (Requirements Template)
# ============================================================================

cat > "${AGENT_PATH}/spec.md" << 'SPEC_EOF'
# [Feature Name] Specification

> Replace [Feature Name] with actual feature name

## Overview

Brief description of what this feature does and why it's needed.

## Requirements

### Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | [Requirement description] | Must |
| FR-02 | [Requirement description] | Should |
| FR-03 | [Requirement description] | Could |

### Non-Functional Requirements

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-01 | Performance | [target] |
| NFR-02 | Security | [target] |

## API Design (if applicable)

```[language]
// API examples or interface definitions
```

## File Structure

```
[src directories and files to be created/modified]
```

## Success Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]
- [ ] All tests pass
- [ ] Code review approved

## Dependencies

- [List any external dependencies or prerequisites]
SPEC_EOF

# Replace placeholder with actual feature name
sed -i "s/\[Feature Name\]/${FEATURE_NAME}/g" "${AGENT_PATH}/spec.md" 2>/dev/null || \
sed -i '' "s/\[Feature Name\]/${FEATURE_NAME}/g" "${AGENT_PATH}/spec.md"

log_info "Created spec.md (requirements template)"

# ============================================================================
# Create plan.md (Implementation Plan Template)
# ============================================================================

cat > "${AGENT_PATH}/plan.md" << 'PLAN_EOF'
# Implementation Plan

## Task Breakdown

### Task 1: [Task Name]

**Time Estimate:** [2-5 min]

**Files:**
- Create/Modify: `[file path]`

**TDD Steps:**
1. Write failing test
2. Run test to verify failure
3. Implement minimal code
4. Run test to verify pass
5. Commit

**Acceptance Criteria:**
- [ ] Test passes
- [ ] Code follows project patterns

---

### Task 2: [Task Name]

**Time Estimate:** [2-5 min]

**Files:**
- Create/Modify: `[file path]`

**TDD Steps:**
1. ...

---

## Execution Order

```
Task 1
  ↓
Task 2
  ↓
Task 3
  ↓
Task N
```

## Dependencies

- Task 2 depends on Task 1
- Task 3 depends on Task 2

## Total Estimated Time: [X] minutes
PLAN_EOF

log_info "Created plan.md (implementation template)"

# ============================================================================
# Create active.md (Progress Tracking)
# ============================================================================

DATE=$(date '+%Y-%m-%d')

cat > "${AGENT_PATH}/changes/active.md" << ACTIVE_EOF
# Active Tasks: [Feature Name]

## Current Sprint

### In Progress
- [ ] Task 1: [Name]

### Pending
- [ ] Task 2: [Name]
- [ ] Task 3: [Name]

### Completed
- (none yet)

---
Status: IN_PROGRESS
Started: ${DATE}
Last Updated: ${DATE}
ACTIVE_EOF

log_info "Created changes/active.md (progress tracking)"

# ============================================================================
# Create completed.md (Archive Template)
# ============================================================================

cat > "${AGENT_PATH}/changes/completed.md" << COMPLETED_EOF
# Completed Tasks: [Feature Name]

## Sprint Summary

### Task 1: [Name] ✅
- Completed: [date]
- Files: [list]
- Tests: [pass/fail]

### Task 2: [Name] ✅
- Completed: [date]
- Files: [list]
- Tests: [pass/fail]

---
Status: COMPLETED
Finished: [date]
COMPLETED_EOF

log_info "Created changes/completed.md (archive template)"

# ============================================================================
# Summary
# ============================================================================

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    📦 .agent READY                             ║"
echo "╠═══════════════════════════════════════════════════════════════╣"
echo "║                                                               ║"
echo "║  📁 Directory: ${AGENT_PATH}"
echo "║                                                               ║"
echo "║  📄 Files created:                                            ║"
echo "║     ├── spec.md          (requirements)                      ║"
echo "║     ├── plan.md          (implementation plan)               ║"
echo "║     └── changes/                                            ║"
echo "║         ├── active.md    (progress tracking)                ║"
echo "║         └── completed.md (archive)                          ║"
echo "║                                                               ║"
echo "║  📝 Next steps:                                              ║"
echo "║     1. Edit spec.md with requirements                        ║"
echo "║     2. Edit plan.md with task breakdown                     ║"
echo "║     3. Start implementation                                 ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""