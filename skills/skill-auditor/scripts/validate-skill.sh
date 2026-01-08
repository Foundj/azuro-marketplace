#!/usr/bin/env bash
#
# validate-skill.sh - Skill structure and quality validator
#
# Usage: ./validate-skill.sh <path-to-skill>
#
# Validates:
#   - SKILL.md existence
#   - Frontmatter structure (name, description, etc.)
#   - Field constraints (length, formatting)
#   - Word count
#   - Third-person description format
#   - Referenced files existence
#
# Exit codes:
#   0 - All checks passed
#   1 - Critical errors (skill unusable)
#   2 - Errors found (significant issues)
#   3 - Warnings only (usable but non-compliant)

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
DOCUMENTATION_SCORE=0
DISCOVERABILITY_SCORE=0
MAINTAINABILITY_SCORE=0
INTEGRATION_SCORE=0

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
    echo "Usage: $0 <path-to-skill>"
    echo ""
    echo "Validates a skill directory for structure and quality."
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo "  -v, --verbose Show detailed output"
    echo "  -j, --json    Output results as JSON"
    exit 0
}

# Parse arguments
SKILL_PATH=""
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
            SKILL_PATH="$1"
            shift
            ;; 
    esac
done

if [[ -z "$SKILL_PATH" ]]; then
    if [[ "$JSON_OUTPUT" == "true" ]]; then
        echo '{"error": "Skill path required"}'
        exit 1
    else
        echo "Error: Skill path required"
        usage
    fi
fi

# Resolve to absolute path
SKILL_PATH="$(cd "$SKILL_PATH" 2>/dev/null && pwd)" || {
    if [[ "$JSON_OUTPUT" == "true" ]]; then
        echo "{\"error\": \"Path does not exist: $SKILL_PATH\"}"
        exit 1
    else
        log_critical "Path does not exist: $SKILL_PATH"
        exit 1
    fi
}

SKILL_MD="$SKILL_PATH/SKILL.md"
SKILL_NAME="$(basename "$SKILL_PATH")"

if [[ "$JSON_OUTPUT" == "false" ]]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Validating Skill: $SKILL_NAME"
    echo "  Path: $SKILL_PATH"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📁 Structure Checks"
    echo "──────────────────────────────────────────────────"
fi

# ============================================================ 
# DIMENSION 1: Structure (25 points)
# ============================================================ 

# Check SKILL.md exists (10 points)
if [[ -f "$SKILL_MD" ]]; then
    log_pass "SKILL.md exists (+10)"
    STRUCTURE_SCORE=$((STRUCTURE_SCORE + 10))
else
    log_critical "SKILL.md not found"
    if [[ "$JSON_OUTPUT" == "false" ]]; then
        echo ""
        echo "Result: CRITICAL FAILURE - Cannot continue validation"
    fi
    exit 1
fi

# Check frontmatter exists (5 points)
if head -1 "$SKILL_MD" | grep -q "^---"$; then
    # Find closing ---
    FRONTMATTER_END=$(awk '/^---$/{c++;if(c==2){print NR;exit}}' "$SKILL_MD")
    if [[ -n "$FRONTMATTER_END" ]]; then
        log_pass "Valid frontmatter structure (+5)"
        STRUCTURE_SCORE=$((STRUCTURE_SCORE + 5))
        
        # Extract frontmatter
        FRONTMATTER=$(sed -n "2,$((FRONTMATTER_END - 1))p" "$SKILL_MD")
        
        # 1. Name Check
        if echo "$FRONTMATTER" | grep -qE "^name:"; then
            NAME_VAL=$(echo "$FRONTMATTER" | grep "^name:" | sed 's/name: *//' | tr -d '"' | tr -d "'")
            NAME_LEN=${#NAME_VAL}
            if [[ $NAME_LEN -gt 64 ]]; then
                log_error "Name field too long ($NAME_LEN chars, max 64)"
            else
                log_pass "  name field present and valid length"
            fi
        else
            log_error "Missing 'name' field in frontmatter"
        fi

        # 2. Description Check
        if echo "$FRONTMATTER" | grep -qE "^description:"; then
            # Simple grep check for existence, length checked in Documentation section
            log_pass "  description field present"
        else
            log_error "Missing 'description' field in frontmatter"
        fi

        # 3. License Check (Optional)
        if echo "$FRONTMATTER" | grep -qE "^license:"; then
            log_pass "  license field present"
        fi

        # 4. Compatibility Check (Optional)
        if echo "$FRONTMATTER" | grep -qE "^compatibility:"; then
            COMPAT_VAL=$(echo "$FRONTMATTER" | grep "^compatibility:" | sed 's/compatibility: *//')
            COMPAT_LEN=${#COMPAT_VAL}
            if [[ $COMPAT_LEN -gt 500 ]]; then
                 log_warning "compatibility field too long ($COMPAT_LEN chars, max 500)"
            else
                 log_pass "  compatibility field valid"
            fi
        fi

        # 5. Allowed-tools Check (Optional)
        if echo "$FRONTMATTER" | grep -qE "^allowed-tools:"; then
             log_pass "  allowed-tools field present"
             # Could add check for space delimiter here
        fi

        # 6. Version Check (Optional but recommended)
        if echo "$FRONTMATTER" | grep -qE "^version:"; then
            log_pass "  version field present"
        else
            log_warning "Missing 'version' field in frontmatter"
        fi
    else
        log_error "Frontmatter not properly closed (missing second ---)"
    fi
else
    log_error "No frontmatter found (must start with ---)"
fi

# Check directory naming (5 points)
if echo "$SKILL_NAME" | grep -qE "^[a-z0-9]+(-[a-z0-9]+)*$"; then
    log_pass "Directory name is kebab-case (+5)"
    STRUCTURE_SCORE=$((STRUCTURE_SCORE + 5))
else
    log_warning "Directory name should be kebab-case: $SKILL_NAME"
fi

# Check for recommended directories (5 points)
DIR_SCORE=0
for dir in references scripts examples; do
    if [[ -d "$SKILL_PATH/$dir" ]]; then
        $VERBOSE && log_pass "  $dir/ directory exists"
        DIR_SCORE=$((DIR_SCORE + 1))
    fi
done

if [[ $DIR_SCORE -gt 0 ]]; then
    log_pass "Has $DIR_SCORE optional directories (+$(( DIR_SCORE > 2 ? 5 : DIR_SCORE * 2 )))"
    STRUCTURE_SCORE=$((STRUCTURE_SCORE + (DIR_SCORE > 2 ? 5 : DIR_SCORE * 2)))
else
    log_info "Consider adding references/, scripts/, or examples/ directories"
fi

if [[ "$JSON_OUTPUT" == "false" ]]; then
    echo ""
    echo "  Structure Score: $STRUCTURE_SCORE/25"
    echo ""
    echo "📝 Documentation Checks"
    echo "──────────────────────────────────────────────────"
fi

# ============================================================ 
# DIMENSION 2: Documentation (25 points)
# ============================================================ 

# Get description from frontmatter (macOS compatible)
DESCRIPTION=$(awk '/^description:/{flag=1; next} /^[a-z_]+:/ || /^---/{flag=0} flag' "$SKILL_MD")
# If description is on the same line as the key
if [[ -z "$(echo "$DESCRIPTION" | tr -d '[:space:]')" ]]; then
    DESCRIPTION=$(grep "^description:" "$SKILL_MD" | sed 's/^description: *//')
fi

# Check description length
DESC_LENGTH=${#DESCRIPTION}
if [[ $DESC_LENGTH -ge 100 ]]; then
    if [[ $DESC_LENGTH -le 1024 ]]; then
        log_pass "Description is comprehensive ($DESC_LENGTH chars) (+5)"
        DOCUMENTATION_SCORE=$((DOCUMENTATION_SCORE + 5))
    else
        log_error "Description is too long ($DESC_LENGTH chars, max 1024)"
    fi
elif [[ $DESC_LENGTH -ge 50 ]]; then
    log_pass "Description is adequate ($DESC_LENGTH chars) (+3)"
    DOCUMENTATION_SCORE=$((DOCUMENTATION_SCORE + 3))
elif [[ $DESC_LENGTH -ge 1 ]]; then
    log_warning "Description is short ($DESC_LENGTH chars)"
    DOCUMENTATION_SCORE=$((DOCUMENTATION_SCORE + 1))
else
    log_error "Description is empty"
fi

# Check third-person format
if echo "$DESCRIPTION" | grep -qiE "this skill (should|can|is|provides|enables)"; then
    log_pass "Description uses third-person format (+5)"
    DOCUMENTATION_SCORE=$((DOCUMENTATION_SCORE + 5))
else
    log_warning "Description should use third-person (\"This skill should be used when...\")"
fi

# Check for trigger phrases
if echo "$DESCRIPTION" | grep -qiE '(should be used when|trigger|when.*user.*asks|"[^"].{3,30}")'; then
    log_pass "Description includes trigger phrases (+5)"
    DOCUMENTATION_SCORE=$((DOCUMENTATION_SCORE + 5))
else
    log_warning "Description should include specific trigger phrases"
fi

# Check for code examples in body
CODE_BLOCKS=$(grep -c '```' "$SKILL_MD" 2>/dev/null || echo 0)
if [[ $CODE_BLOCKS -ge 4 ]]; then
    log_pass "Multiple code examples present ($((CODE_BLOCKS / 2)) blocks) (+7)"
    DOCUMENTATION_SCORE=$((DOCUMENTATION_SCORE + 7))
elif [[ $CODE_BLOCKS -ge 2 ]]; then
    log_pass "Code examples present (+5)"
    DOCUMENTATION_SCORE=$((DOCUMENTATION_SCORE + 5))
else
    log_warning "Consider adding code examples"
fi

# Check word count
WORD_COUNT=$(wc -w < "$SKILL_MD" | tr -d ' ')
if [[ $WORD_COUNT -le 2000 ]]; then
    log_pass "SKILL.md is lean ($WORD_COUNT words) (+3)"
    DOCUMENTATION_SCORE=$((DOCUMENTATION_SCORE + 3))
elif [[ $WORD_COUNT -le 3000 ]]; then
    log_info "SKILL.md is acceptable ($WORD_COUNT words)"
    DOCUMENTATION_SCORE=$((DOCUMENTATION_SCORE + 2))
elif [[ $WORD_COUNT -le 5000 ]]; then
    log_warning "SKILL.md is getting long ($WORD_COUNT words) - consider moving content to references/"
    DOCUMENTATION_SCORE=$((DOCUMENTATION_SCORE + 1))
else
    log_error "SKILL.md is too long ($WORD_COUNT words) - must use progressive disclosure"
fi

if [[ "$JSON_OUTPUT" == "false" ]]; then
    echo ""
    echo "  Documentation Score: $DOCUMENTATION_SCORE/25"
    echo ""
    echo "🔍 Discoverability Checks"
    echo "──────────────────────────────────────────────────"
fi

# ============================================================ 
# DIMENSION 3: Discoverability (20 points)
# ============================================================ 

# Check for explicit trigger mentions
TRIGGER_PATTERNS='(trigger|TRIGGER|触发|when.*user.*asks)'
if grep -qiE "$TRIGGER_PATTERNS" "$SKILL_MD"; then
    log_pass "Explicit trigger definitions found (+8)"
    DISCOVERABILITY_SCORE=$((DISCOVERABILITY_SCORE + 8))
else
    log_warning "Consider adding explicit trigger phrases"
    DISCOVERABILITY_SCORE=$((DISCOVERABILITY_SCORE + 2))
fi

# Check for multilingual support (Chinese) - macOS compatible
if LC_ALL=C grep -q '[^\x00-\x7F]' "$SKILL_MD" 2>/dev/null && grep -qE '(中文|触发|审计|校验)' "$SKILL_MD" 2>/dev/null; then
    log_pass "Chinese language support detected (+5)"
    DISCOVERABILITY_SCORE=$((DISCOVERABILITY_SCORE + 5))
else
    log_info "Consider adding Chinese trigger phrases for bilingual support"
    DISCOVERABILITY_SCORE=$((DISCOVERABILITY_SCORE + 2))
fi

# Check for command bindings
if grep -qiE '(/[a-z:-]+|command:|slash command)' "$SKILL_MD"; then
    log_pass "Command bindings found (+4)"
    DISCOVERABILITY_SCORE=$((DISCOVERABILITY_SCORE + 4))
else
    log_info "Consider binding to slash commands"
    DISCOVERABILITY_SCORE=$((DISCOVERABILITY_SCORE + 1))
fi

# Check for synonym coverage
QUOTED_PHRASES=$(grep -oE '"[^"].{3,30}"' "$SKILL_MD" 2>/dev/null | wc -l | tr -d ' ')
if [[ $QUOTED_PHRASES -ge 5 ]]; then
    log_pass "Good synonym coverage ($QUOTED_PHRASES phrases) (+3)"
    DISCOVERABILITY_SCORE=$((DISCOVERABILITY_SCORE + 3))
elif [[ $QUOTED_PHRASES -ge 2 ]]; then
    log_pass "Some trigger phrases defined (+2)"
    DISCOVERABILITY_SCORE=$((DISCOVERABILITY_SCORE + 2))
else
    log_info "Consider adding more trigger phrase variations"
fi

if [[ "$JSON_OUTPUT" == "false" ]]; then
    echo ""
    echo "  Discoverability Score: $DISCOVERABILITY_SCORE/20"
    echo ""
    echo "🔧 Maintainability Checks"
    echo "──────────────────────────────────────────────────"
fi

# ============================================================ 
# DIMENSION 4: Maintainability (15 points)
# ============================================================ 

# Check for semantic version
if grep -qE "^version: [0-9]+\.[0-9]+\.[0-9]+" "$SKILL_MD"; then
    log_pass "Semantic version present (+5)"
    MAINTAINABILITY_SCORE=$((MAINTAINABILITY_SCORE + 5))
else
    log_warning "Missing or invalid semantic version"
fi

# Check for dependency declarations
if grep -qiE "(depend|require|prerequisite)" "$SKILL_MD"; then
    log_pass "Dependencies documented (+4)"
    MAINTAINABILITY_SCORE=$((MAINTAINABILITY_SCORE + 4))
else
    log_info "Consider documenting dependencies"
    MAINTAINABILITY_SCORE=$((MAINTAINABILITY_SCORE + 2))
fi

# Check script permissions
if [[ -d "$SKILL_PATH/scripts" ]]; then
    NON_EXEC=$(find "$SKILL_PATH/scripts" -type f ! -perm -111 2>/dev/null | wc -l | tr -d ' ')
    if [[ $NON_EXEC -eq 0 ]]; then
        log_pass "All scripts are executable (+3)"
        MAINTAINABILITY_SCORE=$((MAINTAINABILITY_SCORE + 3))
    else
        log_warning "$NON_EXEC script(s) not executable"
        MAINTAINABILITY_SCORE=$((MAINTAINABILITY_SCORE + 1))
    fi
else
    MAINTAINABILITY_SCORE=$((MAINTAINABILITY_SCORE + 3))
fi

# Check for changelog/version history
if grep -qiE "(changelog|version history|## v[0-9])" "$SKILL_MD" || [[ -f "$SKILL_PATH/CHANGELOG.md" ]]; then
    log_pass "Version history present (+3)"
    MAINTAINABILITY_SCORE=$((MAINTAINABILITY_SCORE + 3))
else
    log_info "Consider adding version history"
fi

if [[ "$JSON_OUTPUT" == "false" ]]; then
    echo ""
    echo "  Maintainability Score: $MAINTAINABILITY_SCORE/15"
    echo ""
    echo "🔗 Integration Checks"
    echo "──────────────────────────────────────────────────"
fi

# ============================================================ 
# DIMENSION 5: Integration (15 points)
# ============================================================ 

PROJECT_ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
if [[ -f "$PROJECT_ROOT/components/hooks/hooks.json" ]]; then
    if bash "$PROJECT_ROOT/components/hooks/scripts/validate-hooks.sh" "$PROJECT_ROOT/components/hooks/hooks.json" >/dev/null 2>&1; then
        log_pass "Global hooks.json is valid (+3)"
        INTEGRATION_SCORE=$((INTEGRATION_SCORE + 3))
    else
        log_error "Global hooks.json has structural errors"
    fi
fi

# Check for workflow integration
if grep -qiE "(workflow|phase|ai-dev|pipeline)" "$SKILL_MD"; then

    log_pass "Workflow integration documented (+6)"
    INTEGRATION_SCORE=$((INTEGRATION_SCORE + 6))
else
    log_info "Consider documenting workflow integration"
    INTEGRATION_SCORE=$((INTEGRATION_SCORE + 2))
fi

# Check for hook configuration
if grep -qiE "(hook|trigger|event|PreToolUse|PostToolUse)" "$SKILL_MD"; then
    log_pass "Hook/event awareness (+5)"
    INTEGRATION_SCORE=$((INTEGRATION_SCORE + 5))
else
    log_info "Consider documenting hook integration"
    INTEGRATION_SCORE=$((INTEGRATION_SCORE + 2))
fi

# Check for agent collaboration
if grep -qiE "(agent|delegate|collaborate|specialist)" "$SKILL_MD"; then
    log_pass "Agent collaboration documented (+4)"
    INTEGRATION_SCORE=$((INTEGRATION_SCORE + 4))
else
    log_info "Consider documenting agent collaboration"
    INTEGRATION_SCORE=$((INTEGRATION_SCORE + 1))
fi

if [[ "$JSON_OUTPUT" == "false" ]]; then
    echo ""
    echo "  Integration Score: $INTEGRATION_SCORE/15"
    echo ""
fi

# ============================================================ 
# Final Summary
# ============================================================ 

TOTAL_SCORE=$((STRUCTURE_SCORE + DOCUMENTATION_SCORE + DISCOVERABILITY_SCORE + MAINTAINABILITY_SCORE + INTEGRATION_SCORE))

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
    echo "  \"name\": \"$SKILL_NAME\","
    echo "  \"path\": \"$SKILL_PATH\","
    echo "  \"score\": {"
    echo "    \"total\": $TOTAL_SCORE,"
    echo "    \"grade\": \"$GRADE\","
    echo "    \"status\": \"$STATUS\","
    echo "    \"breakdown\": {"
    echo "      \"structure\": $STRUCTURE_SCORE,"
    echo "      \"documentation\": $DOCUMENTATION_SCORE,"
    echo "      \"discoverability\": $DISCOVERABILITY_SCORE,"
    echo "      \"maintainability\": $MAINTAINABILITY_SCORE,"
    echo "      \"integration\": $INTEGRATION_SCORE"
    echo "    }"
    echo "  },"
    echo "  \"issues\": [$ISSUES_JSON],"
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
    echo "  📁 Structure:       $STRUCTURE_SCORE/25"
    echo "  📝 Documentation:   $DOCUMENTATION_SCORE/25"
    echo "  🔍 Discoverability: $DISCOVERABILITY_SCORE/20"
    echo "  🔧 Maintainability: $MAINTAINABILITY_SCORE/15"
    echo "  🔗 Integration:     $INTEGRATION_SCORE/15"
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