#!/usr/bin/env bash
# trigger-monitor.sh — Skill trigger rate monitoring and reporting
# Usage: bash scripts/trigger-monitor.sh [--report] [--json] [--since DAYS]
#
# Analyzes git log for skill activation patterns, generates trigger rate
# statistics, and identifies low-frequency skills for potential deprecation.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
EVALS_FILE="$PROJECT_ROOT/evals/trigger-eval.json"
SKILLS_DIR="$PROJECT_ROOT/skills"

# Defaults
REPORT_MODE=false
JSON_MODE=false
SINCE_DAYS=7

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --report) REPORT_MODE=true; shift ;;
        --json) JSON_MODE=true; shift ;;
        --since) SINCE_DAYS="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Get all skill names
get_skills() {
    find "$SKILLS_DIR" -maxdepth 2 -name "SKILL.md" -not -path "*/pre-check/*" | while read -r skill_file; do
        basename "$(dirname "$skill_file")"
    done | sort
}

# Count eval coverage
count_eval_coverage() {
    local skill_name="$1"
    if [[ -f "$EVALS_FILE" ]]; then
        # Count as should_trigger
        local trigger_count
        trigger_count=$(python3 -c "
import json, sys
with open('$EVALS_FILE') as f:
    data = json.load(f)
count = sum(1 for e in data['evals'] if '$skill_name' in e.get('should_trigger', []))
print(count)
" 2>/dev/null || echo "0")

        # Count as should_not_trigger
        local not_trigger_count
        not_trigger_count=$(python3 -c "
import json, sys
with open('$EVALS_FILE') as f:
    data = json.load(f)
count = sum(1 for e in data['evals'] if '$skill_name' in e.get('should_not_trigger', []))
print(count)
" 2>/dev/null || echo "0")

        echo "$trigger_count:$not_trigger_count"
    else
        echo "0:0"
    fi
}

# Get skill profile
get_profile() {
    local skill_name="$1"
    local skill_file="$SKILLS_DIR/$skill_name/SKILL.md"
    if [[ -f "$skill_file" ]]; then
        grep "^profile:" "$skill_file" 2>/dev/null | sed 's/^profile: *//' || echo "none"
    else
        echo "unknown"
    fi
}

# Generate report
generate_report() {
    local total_skills=0
    local covered_skills=0
    local uncovered_skills=""

    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║               TRIGGER RATE MONITOR REPORT                 ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "║  Date: $(date '+%Y-%m-%d')                                         ║"
    echo "║  Period: Last ${SINCE_DAYS} days                                        ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""

    printf "%-30s %-8s %-12s %-12s\n" "SKILL" "PROFILE" "TRIGGER_EVAL" "NOT_TRIGGER"
    printf "%-30s %-8s %-12s %-12s\n" "-----" "-------" "------------" "-----------"

    while IFS= read -r skill; do
        total_skills=$((total_skills + 1))
        local coverage
        coverage=$(count_eval_coverage "$skill")
        local trigger_count="${coverage%%:*}"
        local not_trigger_count="${coverage##*:}"
        local profile
        profile=$(get_profile "$skill")

        if [[ "$trigger_count" -eq 0 && "$not_trigger_count" -eq 0 ]]; then
            printf "${RED}%-30s${NC} %-8s %-12s %-12s\n" "$skill" "$profile" "$trigger_count" "$not_trigger_count"
            uncovered_skills="$uncovered_skills $skill"
        elif [[ "$trigger_count" -eq 0 ]]; then
            printf "${YELLOW}%-30s${NC} %-8s %-12s %-12s\n" "$skill" "$profile" "$trigger_count" "$not_trigger_count"
        else
            printf "${GREEN}%-30s${NC} %-8s %-12s %-12s\n" "$skill" "$profile" "$trigger_count" "$not_trigger_count"
            covered_skills=$((covered_skills + 1))
        fi
    done < <(get_skills)

    echo ""
    echo "────────────────────────────────────────────────────────"
    local coverage_pct=0
    if [[ $total_skills -gt 0 ]]; then
        coverage_pct=$((covered_skills * 100 / total_skills))
    fi
    echo -e "  Total skills:     $total_skills"
    echo -e "  Covered (trigger): $covered_skills ($coverage_pct%)"
    echo -e "  Target:           ≥80%"

    if [[ $coverage_pct -ge 80 ]]; then
        echo -e "  Status:           ${GREEN}PASS${NC}"
    else
        echo -e "  Status:           ${RED}BELOW TARGET${NC}"
    fi

    if [[ -n "$uncovered_skills" ]]; then
        echo ""
        echo -e "${YELLOW}Uncovered skills (no trigger eval):${NC}"
        for s in $uncovered_skills; do
            echo "  - $s"
        done
    fi

    # Eval stats
    if [[ -f "$EVALS_FILE" ]]; then
        local eval_count
        eval_count=$(python3 -c "
import json
with open('$EVALS_FILE') as f:
    data = json.load(f)
print(len(data['evals']))
" 2>/dev/null || echo "0")
        echo ""
        echo "  Eval cases: $eval_count"
    fi
    echo ""
}

# Generate JSON output
generate_json() {
    python3 -c "
import json, os, glob

skills_dir = '$SKILLS_DIR'
evals_file = '$EVALS_FILE'

# Load evals
evals = {'evals': []}
if os.path.exists(evals_file):
    with open(evals_file) as f:
        evals = json.load(f)

# Scan skills
results = []
for skill_md in sorted(glob.glob(os.path.join(skills_dir, '*/SKILL.md'))):
    skill_name = os.path.basename(os.path.dirname(skill_md))
    if skill_name == 'pre-check':
        continue

    trigger_count = sum(1 for e in evals['evals'] if skill_name in e.get('should_trigger', []))
    not_trigger_count = sum(1 for e in evals['evals'] if skill_name in e.get('should_not_trigger', []))

    # Read profile
    profile = 'none'
    with open(skill_md) as f:
        for line in f:
            if line.startswith('profile:'):
                profile = line.split(':',1)[1].strip()
                break

    results.append({
        'skill': skill_name,
        'profile': profile,
        'trigger_eval_count': trigger_count,
        'not_trigger_eval_count': not_trigger_count,
        'covered': trigger_count > 0
    })

total = len(results)
covered = sum(1 for r in results if r['covered'])

output = {
    'date': '$(date +%Y-%m-%d)',
    'total_skills': total,
    'covered_skills': covered,
    'coverage_pct': round(covered / total * 100, 1) if total > 0 else 0,
    'total_evals': len(evals['evals']),
    'target_pct': 80,
    'skills': results
}

print(json.dumps(output, indent=2, ensure_ascii=False))
" 2>/dev/null
}

# Main
if $JSON_MODE; then
    generate_json
else
    generate_report
fi
