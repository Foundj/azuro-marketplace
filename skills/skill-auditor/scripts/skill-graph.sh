#!/usr/bin/env bash
#
# skill-graph.sh - Generate skill cross-reference graph
#
# Usage:
#   ./skill-graph.sh              # Show adjacency list
#   ./skill-graph.sh --dot        # Output DOT format (for Graphviz)
#   ./skill-graph.sh --stats      # Show reference statistics
#
# Examples:
#   ./skill-graph.sh --stats
#   ./skill-graph.sh --dot | dot -Tpng -o skill-graph.png

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
  echo -e "${RED}Error: Skills directory not found${NC}" >&2
  exit 1
fi

# Parse arguments
MODE="list"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dot) MODE="dot"; shift ;;
    --stats) MODE="stats"; shift ;;
    --help|-h)
      echo "Usage: skill-graph.sh [--dot|--stats]"
      echo ""
      echo "  (default)   Show adjacency list"
      echo "  --dot       Output DOT format for Graphviz"
      echo "  --stats     Show reference statistics"
      exit 0
      ;;
    *) echo -e "${RED}Unknown option: $1${NC}" >&2; exit 1 ;;
  esac
done

# Collect all skill names
declare -a SKILL_NAMES=()
for dir in "$SKILLS_ROOT"/*/; do
  if [ -f "$dir/SKILL.md" ]; then
    SKILL_NAMES+=("$(basename "$dir")")
  fi
done

# Build adjacency list: skill -> [referenced skills]
# Patterns detected:
#   1. ../skill-name/SKILL.md or ../skill-name/
#   2. `skill-name` in backticks (Agent Collaboration tables)
#   3. skills/skill-name references
declare -A EDGES  # "source:target" -> 1

for skill in "${SKILL_NAMES[@]}"; do
  skill_file="$SKILLS_ROOT/$skill/SKILL.md"

  for target in "${SKILL_NAMES[@]}"; do
    # Skip self-references
    [[ "$skill" == "$target" ]] && continue

    # Check for references to the target skill
    if grep -q "\.\./\b${target}\b" "$skill_file" 2>/dev/null ||
       grep -q "\`${target}\`" "$skill_file" 2>/dev/null ||
       grep -q "skills/${target}" "$skill_file" 2>/dev/null; then
      EDGES["${skill}:${target}"]=1
    fi
  done
done

# Output based on mode
case "$MODE" in
  list)
    echo ""
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  Skill Cross-Reference Graph${NC}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    for skill in "${SKILL_NAMES[@]}"; do
      targets=""
      for edge in "${!EDGES[@]}"; do
        src="${edge%%:*}"
        tgt="${edge#*:}"
        if [[ "$src" == "$skill" ]]; then
          if [[ -n "$targets" ]]; then
            targets="$targets, $tgt"
          else
            targets="$tgt"
          fi
        fi
      done

      if [[ -n "$targets" ]]; then
        echo -e "  ${CYAN}${skill}${NC} → ${targets}"
      fi
    done

    # Show orphans (no outgoing or incoming references)
    echo ""
    echo -e "${BOLD}  Orphans (no references):${NC}"
    for skill in "${SKILL_NAMES[@]}"; do
      has_ref=false
      for edge in "${!EDGES[@]}"; do
        src="${edge%%:*}"
        tgt="${edge#*:}"
        if [[ "$src" == "$skill" ]] || [[ "$tgt" == "$skill" ]]; then
          has_ref=true
          break
        fi
      done
      if ! $has_ref; then
        echo -e "  ${YELLOW}  $skill${NC}"
      fi
    done

    echo ""
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${GREEN}Total skills: ${#SKILL_NAMES[@]}  |  Edges: ${#EDGES[@]}${NC}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    ;;

  dot)
    echo "digraph skill_graph {"
    echo '  rankdir=LR;'
    echo '  node [shape=box, style="rounded,filled", fillcolor="#e8f4f8", fontname="Helvetica"];'
    echo '  edge [color="#666666"];'
    echo ""

    for edge in "${!EDGES[@]}"; do
      src="${edge%%:*}"
      tgt="${edge#*:}"
      echo "  \"$src\" -> \"$tgt\";"
    done

    echo "}"
    ;;

  stats)
    echo ""
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}  Skill Reference Statistics${NC}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Count outgoing references per skill
    echo -e "  ${BOLD}Top Referrers (outgoing):${NC}"
    declare -A OUT_COUNT
    for edge in "${!EDGES[@]}"; do
      src="${edge%%:*}"
      OUT_COUNT[$src]=$(( ${OUT_COUNT[$src]:-0} + 1 ))
    done
    for skill in "${!OUT_COUNT[@]}"; do
      echo "${OUT_COUNT[$skill]} $skill"
    done | sort -rn | head -10 | while read -r count name; do
      printf "    %-30s %s refs\n" "$name" "$count"
    done

    echo ""

    # Count incoming references per skill
    echo -e "  ${BOLD}Most Referenced (incoming):${NC}"
    declare -A IN_COUNT
    for edge in "${!EDGES[@]}"; do
      tgt="${edge#*:}"
      IN_COUNT[$tgt]=$(( ${IN_COUNT[$tgt]:-0} + 1 ))
    done
    for skill in "${!IN_COUNT[@]}"; do
      echo "${IN_COUNT[$skill]} $skill"
    done | sort -rn | head -10 | while read -r count name; do
      printf "    %-30s %s refs\n" "$name" "$count"
    done

    echo ""

    # Orphans
    echo -e "  ${BOLD}Orphans (no connections):${NC}"
    orphan_count=0
    for skill in "${SKILL_NAMES[@]}"; do
      has_ref=false
      for edge in "${!EDGES[@]}"; do
        src="${edge%%:*}"
        tgt="${edge#*:}"
        if [[ "$src" == "$skill" ]] || [[ "$tgt" == "$skill" ]]; then
          has_ref=true
          break
        fi
      done
      if ! $has_ref; then
        echo -e "    ${YELLOW}$skill${NC}"
        orphan_count=$((orphan_count + 1))
      fi
    done
    if [[ $orphan_count -eq 0 ]]; then
      echo -e "    ${GREEN}(none)${NC}"
    fi

    echo ""
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${GREEN}Skills: ${#SKILL_NAMES[@]}  |  Edges: ${#EDGES[@]}  |  Orphans: ${orphan_count}${NC}"
    echo -e "${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    ;;
esac
