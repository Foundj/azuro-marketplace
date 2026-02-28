#!/usr/bin/env bash
#
# find-skill.sh - Search skills by name, keyword, or trigger phrase
#
# Usage:
#   ./find-skill.sh <query>           # Search name + description + triggers
#   ./find-skill.sh --name <pattern>  # Search by name only
#   ./find-skill.sh --trigger <word>  # Search triggers only
#   ./find-skill.sh --status ga       # Filter by status (ga/experimental)
#   ./find-skill.sh --list            # List all skills with scores
#
# Examples:
#   ./find-skill.sh brainstorm
#   ./find-skill.sh 头脑风暴
#   ./find-skill.sh --status experimental
#   ./find-skill.sh --trigger "explore ideas"

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# Resolve skills root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILLS_ROOT="${SCRIPT_DIR}/../../../skills"

if [ ! -d "$SKILLS_ROOT" ]; then
  echo -e "${RED}Error: Skills directory not found at ${SKILLS_ROOT}${NC}" >&2
  exit 1
fi

# Parse arguments
MODE="search"
QUERY=""
STATUS_FILTER=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --name)
      MODE="name"
      QUERY="$2"
      shift 2
      ;;
    --trigger)
      MODE="trigger"
      QUERY="$2"
      shift 2
      ;;
    --status)
      STATUS_FILTER="$2"
      shift 2
      ;;
    --list)
      MODE="list"
      shift
      ;;
    --help|-h)
      echo "Usage: find-skill.sh [options] [query]"
      echo ""
      echo "Options:"
      echo "  --name <pattern>    Search by skill name only"
      echo "  --trigger <word>    Search trigger phrases only"
      echo "  --status <status>   Filter by status (ga/experimental)"
      echo "  --list              List all skills"
      echo "  --help              Show this help"
      exit 0
      ;;
    -*)
      echo -e "${RED}Unknown option: $1${NC}" >&2
      exit 1
      ;;
    *)
      QUERY="$1"
      shift
      ;;
  esac
done

if [[ "$MODE" != "list" && -z "$QUERY" && -z "$STATUS_FILTER" ]]; then
  echo -e "${RED}Error: Query required. Use --list to show all skills.${NC}" >&2
  exit 1
fi

# --status without query implies listing filtered by status
if [[ -z "$QUERY" && -n "$STATUS_FILTER" && "$MODE" == "search" ]]; then
  MODE="list"
fi

# Extract frontmatter field value (handles multi-line description)
get_field() {
  local file="$1"
  local field="$2"
  sed -n '/^---$/,/^---$/p' "$file" | grep -E "^${field}:" | head -1 | sed "s/^${field}:[[:space:]]*//" | sed 's/^|[[:space:]]*//'
}

# Extract triggers list (BSD awk compatible)
get_triggers() {
  local file="$1"
  local in_triggers=0
  local result=""
  while IFS= read -r line; do
    if [[ "$line" == "triggers:" ]]; then
      in_triggers=1
      continue
    fi
    if [[ $in_triggers -eq 1 ]]; then
      if [[ "$line" =~ ^[[:space:]]*-[[:space:]] ]]; then
        local val="${line#*- }"
        if [[ -n "$result" ]]; then
          result="${result}, ${val}"
        else
          result="$val"
        fi
      else
        break
      fi
    fi
  done < "$file"
  echo "$result"
}

# Get status field
get_status() {
  local file="$1"
  sed -n '/^---$/,/^---$/p' "$file" | grep -E "^status:" | head -1 | sed 's/^status:[[:space:]]*//'
}

# Get version field
get_version() {
  local file="$1"
  sed -n '/^---$/,/^---$/p' "$file" | grep -E "^version:" | head -1 | sed 's/^version:[[:space:]]*//'
}

# Print header
echo ""
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [[ "$MODE" == "list" ]]; then
  echo -e "${BOLD}  Skill Directory${NC}"
else
  echo -e "${BOLD}  Searching: ${CYAN}${QUERY}${NC}"
fi
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Search and display results
MATCH_COUNT=0

for SKILL_DIR in "$SKILLS_ROOT"/*/; do
  SKILL_MD="${SKILL_DIR}SKILL.md"
  [ -f "$SKILL_MD" ] || continue

  SKILL_NAME=$(basename "$SKILL_DIR")
  DESCRIPTION=$(get_field "$SKILL_MD" "description" || echo "")
  STATUS=$(get_status "$SKILL_MD" || echo "unknown")
  VERSION=$(get_version "$SKILL_MD" || echo "0.0.0")
  TRIGGERS=$(get_triggers "$SKILL_MD" || echo "")

  # Apply status filter
  if [[ -n "$STATUS_FILTER" && "$STATUS" != "$STATUS_FILTER" ]]; then
    continue
  fi

  # Apply search filter
  MATCHED=false
  case "$MODE" in
    list)
      MATCHED=true
      ;;
    name)
      if echo "$SKILL_NAME" | grep -qi "$QUERY" 2>/dev/null; then
        MATCHED=true
      fi
      ;;
    trigger)
      if echo "$TRIGGERS" | grep -qi "$QUERY" 2>/dev/null; then
        MATCHED=true
      fi
      ;;
    search)
      # Search across name, description, and triggers
      if echo "$SKILL_NAME" | grep -qi "$QUERY" 2>/dev/null; then
        MATCHED=true
      elif echo "$DESCRIPTION" | grep -qi "$QUERY" 2>/dev/null; then
        MATCHED=true
      elif echo "$TRIGGERS" | grep -qi "$QUERY" 2>/dev/null; then
        MATCHED=true
      elif grep -qi "$QUERY" "$SKILL_MD" 2>/dev/null; then
        MATCHED=true
      fi
      ;;
  esac

  if $MATCHED; then
    MATCH_COUNT=$((MATCH_COUNT + 1))

    # Format status badge
    if [[ "$STATUS" == "ga" ]]; then
      STATUS_BADGE="${GREEN}GA${NC}"
    elif [[ "$STATUS" == "experimental" ]]; then
      STATUS_BADGE="${YELLOW}EXP${NC}"
    else
      STATUS_BADGE="${BLUE}${STATUS}${NC}"
    fi

    # Print result
    echo -e "  ${BOLD}${CYAN}${SKILL_NAME}${NC}  ${STATUS_BADGE}  v${VERSION}"

    # Show first line of description (truncated)
    if [[ -n "$DESCRIPTION" ]]; then
      DESC_LINE=$(echo "$DESCRIPTION" | head -1 | cut -c1-70)
      echo -e "  ${DESC_LINE}"
    fi

    # Show triggers (truncated)
    if [[ -n "$TRIGGERS" ]]; then
      TRIG_LINE=$(echo "$TRIGGERS" | cut -c1-70)
      echo -e "  ${BLUE}Triggers:${NC} ${TRIG_LINE}"
    fi

    echo ""
  fi
done

# Summary
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
if [[ "$MODE" == "list" ]]; then
  echo -e "  ${GREEN}Total: ${MATCH_COUNT} skills${NC}"
else
  echo -e "  ${GREEN}Found: ${MATCH_COUNT} matches${NC}"
fi
echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
