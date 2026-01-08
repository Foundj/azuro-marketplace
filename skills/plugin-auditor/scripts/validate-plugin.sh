#!/usr/bin/env bash
#
# validate-plugin.sh - Plugin structure and quality validator
#
# Usage: ./validate-plugin.sh <path-to-plugin> [--json]
#
# Validates:
#   - Directory structure (Manifest location, Component roots)
#   - Manifest content (Required fields, Metadata)
#   - Component validity (Commands, Agents, Hooks)
#   - Safety practices (Relative paths, Permissions)
#   - Embedded skills (Recursively)
#
# Exit codes:
#   0 - All checks passed
#   1 - Critical errors
#   2 - Errors found
#   3 - Warnings only

set -euo pipefail

# Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Icons
ICON_PASS="✅"
ICON_FAIL="❌"
ICON_WARN="⚠️"
ICON_INFO="ℹ️"
ICON_CRITICAL="🚨"

# Counters
CRITICAL_COUNT=0
ERROR_COUNT=0
WARNING_COUNT=0
INFO_COUNT=0

# Issue Lists for JSON output
declare -a ISSUES_LIST=()

# Score tracking
STRUCTURE_SCORE=0
MANIFEST_SCORE=0
COMPONENTS_SCORE=0
SAFETY_SCORE=0
SKILLS_SCORE=0

# Helper Functions
escape_json() {
    echo "$1" | sed 's/"/\\"/g' | sed 's/$/\\n/' | tr -d '\n' | sed 's/\\n$//'
}

add_issue() {
    local type="$1"
    local message="$2"
    local clean_msg
    clean_msg=$(escape_json "$message")
    ISSUES_LIST+=("{\"type\": \"$type\", \"message\": \"$clean_msg\"}")
}

log_critical() {
    if [[ "$JSON_OUTPUT" == "false" ]]; then
        echo -e "${RED}${ICON_CRITICAL} [CRITICAL] $1${NC}"
    fi
    add_issue "CRITICAL" "$1"
    ((CRITICAL_COUNT++)) || true
}

log_error() {
    if [[ "$JSON_OUTPUT" == "false" ]]; then
        echo -e "${RED}${ICON_FAIL} [ERROR] $1${NC}"
    fi
    add_issue "ERROR" "$1"
    ((ERROR_COUNT++)) || true
}

log_warning() {
    if [[ "$JSON_OUTPUT" == "false" ]]; then
        echo -e "${YELLOW}${ICON_WARN} [WARNING] $1${NC}"
    fi
    add_issue "WARNING" "$1"
    ((WARNING_COUNT++)) || true
}

log_info() {
    if [[ "$JSON_OUTPUT" == "false" ]]; then
        echo -e "${BLUE}${ICON_INFO} [INFO] $1${NC}"
    fi
    add_issue "INFO" "$1"
    ((INFO_COUNT++)) || true
}

log_pass() {
    if [[ "$JSON_OUTPUT" == "false" ]]; then
        echo -e "${GREEN}${ICON_PASS} $1${NC}"
    fi
}

usage() {
    echo "Usage: $0 <path-to-plugin>"
    echo ""
    echo "Validates a plugin directory for structure and quality."
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo "  -v, --verbose Show detailed output"
    echo "  -j, --json    Output results as JSON"
    exit 0
}

# Parse arguments
PLUGIN_PATH=""
VERBOSE=false
JSON_OUTPUT=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help) 
            usage
            ;; 
        -v|--verbose)
            VERBOSE=true
            shift
            ;; 
        -j|--json)
            JSON_OUTPUT=true
            shift
            ;; 
        *)
            PLUGIN_PATH="$1"
            shift
            ;; 
    esac
done

if [[ -z "$PLUGIN_PATH" ]]; then
    if [[ "$JSON_OUTPUT" == "true" ]]; then
        echo '{"error": "Plugin path required"}'
        exit 1
    else
        echo "Error: Plugin path required"
        usage
    fi
fi

# Resolve to absolute path
PLUGIN_PATH="$(cd "$PLUGIN_PATH" 2>/dev/null && pwd)" || {
    if [[ "$JSON_OUTPUT" == "true" ]]; then
        echo "{\"error\": \"Path does not exist: $PLUGIN_PATH\"}"
        exit 1
    else
        log_critical "Path does not exist: $PLUGIN_PATH"
        exit 1
    fi
}

PLUGIN_NAME="$(basename "$PLUGIN_PATH")"
MANIFEST_PATH="$PLUGIN_PATH/.claude-plugin/plugin.json"

if [[ "$JSON_OUTPUT" == "false" ]]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Validating Plugin: $PLUGIN_NAME"
    echo "  Path: $PLUGIN_PATH"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📁 Structure Checks"
    echo "──────────────────────────────────────────────────"
fi

# ============================================================ 
# DIMENSION 1: Structure (20 points)
# ============================================================ 

# Check Manifest Location (10 points)
if [[ -f "$MANIFEST_PATH" ]]; then
    log_pass "Manifest found at .claude-plugin/plugin.json (+10)"
    STRUCTURE_SCORE=$((STRUCTURE_SCORE + 10))
else
    log_critical "Manifest missing: .claude-plugin/plugin.json not found"
    if [[ "$JSON_OUTPUT" == "false" ]]; then
        echo ""
        echo "Result: CRITICAL FAILURE - Cannot continue validation"
    fi
    exit 1
fi

# Check Component Nesting (5 points)
# Components should NOT be inside .claude-plugin
WRONG_NESTING=0
for dir in commands agents skills hooks; do
    if [[ -d "$PLUGIN_PATH/.claude-plugin/$dir" ]]; then
        log_error "Incorrect nesting: '$dir' should be at plugin root, NOT inside .claude-plugin/"
        WRONG_NESTING=1
    fi
done

if [[ $WRONG_NESTING -eq 0 ]]; then
    log_pass "Component nesting is correct (+5)"
    STRUCTURE_SCORE=$((STRUCTURE_SCORE + 5))
fi

# Check Naming Convention (5 points)
if echo "$PLUGIN_NAME" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
    log_pass "Plugin directory is kebab-case (+5)"
    STRUCTURE_SCORE=$((STRUCTURE_SCORE + 5))
else
    log_warning "Plugin directory should be kebab-case: $PLUGIN_NAME"
fi

if [[ "$JSON_OUTPUT" == "false" ]]; then
    echo ""
    echo "  Structure Score: $STRUCTURE_SCORE/20"
    echo ""
    echo "📋 Manifest Checks"
    echo "──────────────────────────────────────────────────"
fi

# ============================================================ 
# DIMENSION 2: Manifest (20 points)
# ============================================================ 

# Read manifest content
MANIFEST_CONTENT=$(cat "$MANIFEST_PATH")

# Check Valid JSON (5 points)
if echo "$MANIFEST_CONTENT" | python3 -c "import sys, json; json.load(sys.stdin)" >/dev/null 2>&1; then
    log_pass "Manifest is valid JSON (+5)"
    MANIFEST_SCORE=$((MANIFEST_SCORE + 5))
else
    log_critical "Manifest is invalid JSON"
    # We continue but other checks might fail
fi

# Check Required Fields (10 points)
HAS_NAME=$(echo "$MANIFEST_CONTENT" | grep -q '"name":' && echo 1 || echo 0)
HAS_VERSION=$(echo "$MANIFEST_CONTENT" | grep -q '"version":' && echo 1 || echo 0)

if [[ $HAS_NAME -eq 1 ]]; then
    log_pass "  'name' field present"
    MANIFEST_SCORE=$((MANIFEST_SCORE + 5))
else
    log_error "Missing 'name' field in plugin.json"
fi

if [[ $HAS_VERSION -eq 1 ]]; then
    log_pass "  'version' field present"
    MANIFEST_SCORE=$((MANIFEST_SCORE + 5))
else
    log_error "Missing 'version' field in plugin.json"
fi

# Check Metadata (5 points)
META_SCORE=0
if echo "$MANIFEST_CONTENT" | grep -q '"description":'; then META_SCORE=$((META_SCORE + 2)); fi
if echo "$MANIFEST_CONTENT" | grep -q '"author":'; then META_SCORE=$((META_SCORE + 2)); fi
if echo "$MANIFEST_CONTENT" | grep -q '"license":'; then META_SCORE=$((META_SCORE + 1)); fi

if [[ $META_SCORE -eq 5 ]]; then
    log_pass "Full metadata present (+5)"
elif [[ $META_SCORE -gt 0 ]]; then
    log_pass "Partial metadata present (+$META_SCORE)"
    log_info "Consider adding description, author, and license"
fi
MANIFEST_SCORE=$((MANIFEST_SCORE + META_SCORE))

if [[ "$JSON_OUTPUT" == "false" ]]; then
    echo ""
    echo "  Manifest Score: $MANIFEST_SCORE/20"
    echo ""
    echo "🧩 Component Checks"
    echo "──────────────────────────────────────────────────"
fi

# ============================================================ 
# DIMENSION 3: Components (30 points)
# ============================================================ 

# Commands (10 points)
COMMANDS_DIR="$PLUGIN_PATH/commands"
CMD_SCORE=10
CMD_ISSUES=0
if [[ -d "$COMMANDS_DIR" ]]; then
    for cmd in "$COMMANDS_DIR"/*.md; do
        [[ -e "$cmd" ]] || continue # handle empty dir
        # Check frontmatter
        if ! head -n 20 "$cmd" | grep -q "^description:"; then
            log_error "Command $(basename "$cmd") missing 'description' in frontmatter"
            CMD_ISSUES=$((CMD_ISSUES + 1))
        fi
        if ! head -n 20 "$cmd" | grep -q "^argument-hint:"; then
            log_warning "Command $(basename "$cmd") missing 'argument-hint' in frontmatter"
            CMD_ISSUES=$((CMD_ISSUES + 1))
        fi
    done
fi

if [[ $CMD_ISSUES -gt 0 ]]; then
    CMD_SCORE=$((CMD_SCORE - CMD_ISSUES * 2))
    if [[ $CMD_SCORE -lt 0 ]]; then CMD_SCORE=0; fi
    log_info "Command validation passed with issues"
else
    log_pass "Command validation passed (or no commands)"
fi
COMPONENTS_SCORE=$((COMPONENTS_SCORE + CMD_SCORE))

# Agents (10 points)
AGENTS_DIR="$PLUGIN_PATH/agents"
AGENT_SCORE=10
AGENT_ISSUES=0
if [[ -d "$AGENTS_DIR" ]]; then
    for agent in "$AGENTS_DIR"/*.md; do
        [[ -e "$agent" ]] || continue
        # Check required fields
        if ! head -n 20 "$agent" | grep -q "^name:"; then
             log_error "Agent $(basename "$agent") missing 'name'"
             AGENT_ISSUES=$((AGENT_ISSUES + 1))
        fi
        if ! head -n 20 "$agent" | grep -q "^description:"; then
             log_error "Agent $(basename "$agent") missing 'description'"
             AGENT_ISSUES=$((AGENT_ISSUES + 1))
        fi
    done
fi

if [[ $AGENT_ISSUES -gt 0 ]]; then
    AGENT_SCORE=$((AGENT_SCORE - AGENT_ISSUES * 2))
    if [[ $AGENT_SCORE -lt 0 ]]; then AGENT_SCORE=0; fi
    log_info "Agent validation passed with issues"
else
    log_pass "Agent validation passed (or no agents)"
fi
COMPONENTS_SCORE=$((COMPONENTS_SCORE + AGENT_SCORE))

# Hooks (10 points)
HOOKS_FILE="$PLUGIN_PATH/hooks/hooks.json"
HOOKS_SCORE=10
if [[ -f "$HOOKS_FILE" ]]; then
    # Simple check for valid events
    if ! grep -qE '"(PreToolUse|PostToolUse|UserPromptSubmit|SessionStart|SessionEnd|Stop|SubagentStop|PreCompact)"' "$HOOKS_FILE"; then
         log_warning "hooks.json does not seem to contain standard events"
         HOOKS_SCORE=5
    else
         log_pass "Hooks configuration looks valid"
    fi
elif [[ -d "$PLUGIN_PATH/hooks" ]]; then
    log_warning "hooks/ directory exists but hooks.json is missing"
    HOOKS_SCORE=0
fi
COMPONENTS_SCORE=$((COMPONENTS_SCORE + HOOKS_SCORE))

if [[ "$JSON_OUTPUT" == "false" ]]; then
    echo ""
    echo "  Components Score: $COMPONENTS_SCORE/30"
    echo ""
    echo "🛡️ Safety Checks"
    echo "──────────────────────────────────────────────────"
fi

# ============================================================ 
# DIMENSION 4: Safety (15 points)
# ============================================================ 

# Path Safety (10 points)
# Check for hardcoded absolute paths in JSON files
HARDCODED_PATHS=$(grep -rE "/Users/|/home/" "$PLUGIN_PATH" --include="*.json" 2>/dev/null || true)
if [[ -n "$HARDCODED_PATHS" ]]; then
    log_error "Detected hardcoded absolute paths. Use \${CLAUDE_PLUGIN_ROOT} instead."
    SAFETY_SCORE=$((SAFETY_SCORE + 2))
else
    log_pass "No hardcoded absolute paths detected (+10)"
    SAFETY_SCORE=$((SAFETY_SCORE + 10))
fi

# Permissions (5 points)
NON_EXEC_SCRIPTS=0
if [[ -d "$PLUGIN_PATH/scripts" ]]; then
    NON_EXEC_SCRIPTS=$(find "$PLUGIN_PATH/scripts" -type f ! -perm -111 2>/dev/null | wc -l | tr -d ' ')
fi

if [[ $NON_EXEC_SCRIPTS -gt 0 ]]; then
    log_warning "$NON_EXEC_SCRIPTS script(s) in scripts/ are not executable"
    SAFETY_SCORE=$((SAFETY_SCORE + 0))
else
    log_pass "Script permissions are correct (+5)"
    SAFETY_SCORE=$((SAFETY_SCORE + 5))
fi

if [[ "$JSON_OUTPUT" == "false" ]]; then
    echo ""
    echo "  Safety Score: $SAFETY_SCORE/15"
    echo ""
    echo "🧠 Embedded Skills Checks"
    echo "──────────────────────────────────────────────────"
fi

# ============================================================ 
# DIMENSION 5: Skills (15 points)
# ============================================================ 

SKILLS_DIR="$PLUGIN_PATH/skills"
TOTAL_SKILLS=0
PASSED_SKILLS=0

if [[ -d "$SKILLS_DIR" ]]; then
    # Find all SKILL.md files to identify skill roots
    SKILL_FILES=$(find "$SKILLS_DIR" -name "SKILL.md")
    
    if [[ -n "$SKILL_FILES" ]]; then
        for skill_file in $SKILL_FILES; do
            skill_root=$(dirname "$skill_file")
            TOTAL_SKILLS=$((TOTAL_SKILLS + 1))
            
            # Use validate-skill.sh if available
            SKILL_VALIDATOR="$(dirname "$0")/../../skill-auditor/scripts/validate-skill.sh"
            if [[ -f "$SKILL_VALIDATOR" ]]; then
                # Run validator in json mode to get score/status
                VALIDATION_OUTPUT=$("$SKILL_VALIDATOR" "$skill_root" --json 2>/dev/null || echo '{"error": "failed"}')
                
                # Check for "grade": "A" or "B" or "status": "PRODUCTION READY"
                if echo "$VALIDATION_OUTPUT" | grep -qE '"grade": "(A|B|A-|B+)"'; then
                     PASSED_SKILLS=$((PASSED_SKILLS + 1))
                     $VERBOSE && log_pass "  Skill $(basename "$skill_root"): Pass"
                else
                     $VERBOSE && log_warning "  Skill $(basename "$skill_root"): Needs improvement"
                     # Add specific skill issue
                     add_issue "WARNING" "Skill $(basename "$skill_root") failed validation standards"
                fi
            else
                log_warning "validate-skill.sh not found, skipping deep validation"
                PASSED_SKILLS=$((PASSED_SKILLS + 1)) # Assume pass if can't validate
            fi
        done
        
        # Calculate proportional score
        if [[ $TOTAL_SKILLS -gt 0 ]]; then
            SKILLS_SCORE=$(( 15 * PASSED_SKILLS / TOTAL_SKILLS ))
        fi
        log_pass "Validated $PASSED_SKILLS/$TOTAL_SKILLS embedded skills"
    else
         log_pass "No embedded skills found (N/A)"
         SKILLS_SCORE=15
    fi
else
    log_pass "No embedded skills found (N/A)"
    SKILLS_SCORE=15
fi

if [[ "$JSON_OUTPUT" == "false" ]]; then
    echo ""
    echo "  Skills Score: $SKILLS_SCORE/15"
    echo ""
fi

# ============================================================ 
# Final Summary
# ============================================================ 

TOTAL_SCORE=$((STRUCTURE_SCORE + MANIFEST_SCORE + COMPONENTS_SCORE + SAFETY_SCORE + SKILLS_SCORE))

# Calculate grade
if [[ $TOTAL_SCORE -ge 90 ]]; then
    GRADE="A"
    STATUS="PRODUCTION READY"
elif [[ $TOTAL_SCORE -ge 80 ]]; then
    GRADE="B"
    STATUS="GOOD"
elif [[ $TOTAL_SCORE -ge 70 ]]; then
    GRADE="C"
    STATUS="ACCEPTABLE"
elif [[ $TOTAL_SCORE -ge 60 ]]; then
    GRADE="D"
    STATUS="POOR"
else
    GRADE="F"
    STATUS="FAILING"
fi

if [[ "$JSON_OUTPUT" == "true" ]]; then
    # Generate JSON output manually
    ISSUES_JSON=$(printf ",%s" "${ISSUES_LIST[@]}")
    ISSUES_JSON=${ISSUES_JSON:1} # Remove leading comma
    
    echo "{"
    echo "  \"name\": \"$PLUGIN_NAME\","
    echo "  \"path\": \"$PLUGIN_PATH\","
    echo "  \"score\": {"
    echo "    \"total\": $TOTAL_SCORE,"
    echo "    \"grade\": \"$GRADE\","
    echo "    \"status\": \"$STATUS\","
    echo "    \"breakdown\": {"
    echo "      \"structure\": $STRUCTURE_SCORE,"
    echo "      \"manifest\": $MANIFEST_SCORE,"
    echo "      \"components\": $COMPONENTS_SCORE,"
    echo "      \"safety\": $SAFETY_SCORE,"
    echo "      \"skills\": $SKILLS_SCORE"
    echo "    }"
    echo "  },"
    echo "  \"issues\": [$ISSUES_JSON],
    echo "  \"counts\": {"
    echo "    \"critical\": $CRITICAL_COUNT,"
    echo "    \"error\": $ERROR_COUNT,"
    echo "    \"warning\": $WARNING_COUNT,"
    echo "    \"info\": $INFO_COUNT"
    echo "  }"
    echo "}"
else
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "                 SUMMARY"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "  📁 Structure:   $STRUCTURE_SCORE/20"
    echo "  📋 Manifest:    $MANIFEST_SCORE/20"
    echo "  🧩 Components:  $COMPONENTS_SCORE/30"
    echo "  🛡️ Safety:      $SAFETY_SCORE/15"
    echo "  🧠 Skills:      $SKILLS_SCORE/15"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  TOTAL: $TOTAL_SCORE/100  |  GRADE: $GRADE  |  $STATUS"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    if [[ $CRITICAL_COUNT -gt 0 ]]; then
        echo -e "${RED}Critical Issues: $CRITICAL_COUNT${NC}"
    fi
    if [[ $ERROR_COUNT -gt 0 ]]; then
        echo -e "${RED}Errors: $ERROR_COUNT${NC}"
    fi
    if [[ $WARNING_COUNT -gt 0 ]]; then
        echo -e "${YELLOW}Warnings: $WARNING_COUNT${NC}"
    fi
    if [[ $INFO_COUNT -gt 0 ]]; then
        echo -e "${BLUE}Info: $INFO_COUNT${NC}"
    fi

    echo ""
fi

# Exit code based on severity
if [[ $CRITICAL_COUNT -gt 0 ]]; then
    exit 1
elif [[ $ERROR_COUNT -gt 0 ]]; then
    exit 2
elif [[ $WARNING_COUNT -gt 0 ]]; then
    exit 3
else
    exit 0
fi
