#!/bin/bash
# Version Gate - Pre-commit hook script
# 检查 marketplace.json 版本号是否更新，阻止未更新版本的提交

set -e

PLUGIN_JSON="${1:-$(dirname "$0")/../../.claude-plugin/marketplace.json}"
VERSION_CACHE="${HOME}/.claude/.version-cache"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 获取当前版本
get_current_version() {
    if [[ -f "$PLUGIN_JSON" ]]; then
        jq -r '.metadata.version' "$PLUGIN_JSON"
    else
        echo "0.0.0"
    fi
}

# 获取上次提交的版本
get_cached_version() {
    local plugin_name=$(jq -r '.name' "$PLUGIN_JSON" 2>/dev/null)
    local cache_file="${VERSION_CACHE}/${plugin_name:-unknown}.version"
    
    if [[ -f "$cache_file" ]]; then
        cat "$cache_file"
    else
        echo "0.0.0"
    fi
}

# 缓存当前版本
cache_version() {
    local version="$1"
    local plugin_name=$(jq -r '.name' "$PLUGIN_JSON" 2>/dev/null)
    local cache_file="${VERSION_CACHE}/${plugin_name:-unknown}.version"
    
    mkdir -p "$VERSION_CACHE"
    echo "$version" > "$cache_file"
}

# 比较版本号 (返回 0 如果 v1 > v2)
version_gt() {
    local v1="$1"
    local v2="$2"
    
    # 分割版本号
    IFS='.' read -ra V1 <<< "$v1"
    IFS='.' read -ra V2 <<< "$v2"
    
    for i in 0 1 2; do
        local n1=${V1[$i]:-0}
        local n2=${V2[$i]:-0}
        
        if [[ $n1 -gt $n2 ]]; then
            return 0
        elif [[ $n1 -lt $n2 ]]; then
            return 1
        fi
    done
    
    return 1  # 版本相等，返回失败
}

# 主检查逻辑
main() {
    local current_version=$(get_current_version)
    local cached_version=$(get_cached_version)
    
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                    PRE-COMMIT VALIDATION                   ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    printf "║  Cached version:  %-40s ║\n" "$cached_version"
    printf "║  Current version: %-40s ║\n" "$current_version"
    echo "╚════════════════════════════════════════════════════════════╝"

    echo -e "${YELLOW}🔍 Synchronizing documentation...${NC}"
    if [[ -f "scripts/sync-docs.sh" ]]; then
        bash scripts/sync-docs.sh
        # Auto-stage files modified by sync-docs.sh to avoid post-commit drift
        git add README.md README.zh-CN.md .claude-plugin/marketplace.json 2>/dev/null || true
        git add skills/*/SKILL.md skills/*/*/SKILL.md 2>/dev/null || true
    else
        echo -e "${RED}❌ sync-docs.sh not found${NC}"
        exit 1
    fi

    echo -e "${YELLOW}🔍 Validating marketplace.json schema...${NC}"
    if ! bash hooks/scripts/validate-marketplace.sh .claude-plugin/marketplace.json; then
        echo -e "${RED}❌ marketplace.json validation failed${NC}"
        exit 1
    fi

    echo -e "${YELLOW}🔍 Validating hooks.json...${NC}"
    if ! bash hooks/scripts/validate-hooks.sh hooks/hooks.json; then
        echo -e "${RED}❌ hooks.json validation failed${NC}"
        exit 1
    fi

    echo -e "${YELLOW}🔍 Auditing skills (incremental)...${NC}"
    local skill_fail=0
    local audit_cache_dir=".cache/skill-audit"
    mkdir -p "$audit_cache_dir"

    local audited=0
    local cached_count=0
    local total=0

    # Portable hash function (works on macOS + Linux)
    content_hash() {
        grep -v "^version:" "$1" | md5 -q 2>/dev/null || grep -v "^version:" "$1" | md5sum 2>/dev/null | cut -d' ' -f1
    }

    for skill_dir in skills/*/; do
        if [[ -d "$skill_dir" ]] && [[ -f "$skill_dir/SKILL.md" ]]; then
            total=$((total + 1))
            local skill_name=$(basename "$skill_dir")
            local cache_file="$audit_cache_dir/${skill_name}.cache"
            local current_hash
            current_hash=$(content_hash "$skill_dir/SKILL.md")

            # Check cache: line 1 = hash, line 2 = score
            local hit=false
            if [[ -f "$cache_file" ]]; then
                local cached_hash
                cached_hash=$(head -1 "$cache_file")
                local cached_score
                cached_score=$(tail -1 "$cache_file")
                if [[ "$current_hash" == "$cached_hash" ]] && [[ -n "$cached_score" ]]; then
                    hit=true
                    cached_count=$((cached_count + 1))
                    if [[ "$cached_score" -lt 80 ]]; then
                        skill_fail=1
                        echo -e "${RED}❌ Skill $skill_name quality too low: $cached_score/100 (cached)${NC}"
                    fi
                fi
            fi

            if ! $hit; then
                audited=$((audited + 1))
                set +e
                bash skills/skill-auditor/scripts/validate-skill.sh "$skill_dir" > /tmp/audit_log 2>&1
                local exit_code=$?
                set -e

                if [[ $exit_code -eq 1 ]] || [[ $exit_code -eq 2 ]]; then
                    skill_fail=1
                    echo -e "${RED}❌ Critical audit failure for $skill_name${NC}"
                    cat /tmp/audit_log
                fi

                local score
                score=$(grep "TOTAL:" /tmp/audit_log | sed 's/.*TOTAL:[[:space:]]*\([0-9]*\).*/\1/')
                if [[ -n "$score" ]]; then
                    # Update cache
                    printf '%s\n%s\n' "$current_hash" "$score" > "$cache_file"
                    if [[ "$score" -lt 80 ]]; then
                        skill_fail=1
                        echo -e "${RED}❌ Skill $skill_name quality too low: $score/100${NC}"
                        grep "TOTAL:" /tmp/audit_log
                    fi
                fi
            fi
        fi
    done

    if [[ $skill_fail -ne 0 ]]; then
        echo -e "${RED}❌ SKILL AUDIT FAILED. Please fix skills before committing.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ All skills passed quality audit (80+) [${audited} audited, ${cached_count} cached]${NC}"

    echo -e "${YELLOW}🔍 Running code review gate...${NC}"
    if [[ -f "hooks/scripts/code-review-gate.sh" ]]; then
        set +e
        bash hooks/scripts/code-review-gate.sh
        local review_exit=$?
        set -e
        if [[ $review_exit -ne 0 ]]; then
            echo -e "${RED}❌ Code review gate failed${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠️  code-review-gate.sh not found, skipping...${NC}"
    fi

    # Changelog gate: 检查 CHANGELOG.md 是否包含当前版本
    echo -e "${YELLOW}🔍 Checking CHANGELOG.md...${NC}"
    local changelog_file="CHANGELOG.md"
    if [[ -f "$changelog_file" ]]; then
        if grep -q "\[${current_version}\]" "$changelog_file"; then
            echo -e "${GREEN}✅ CHANGELOG.md contains version ${current_version}${NC}"
        else
            echo ""
            echo -e "${RED}❌ CHANGELOG GATE FAILED${NC}"
            echo ""
            echo -e "${YELLOW}CHANGELOG.md must document version ${current_version}${NC}"
            echo ""
            echo "Please add an entry like:"
            echo ""
            echo "  ## [${current_version}] - $(date +%Y-%m-%d)"
            echo ""
            echo "  ### Added/Changed/Fixed"
            echo "  - Your changes here"
            echo ""
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠️  CHANGELOG.md not found, skipping...${NC}"
    fi

    if [[ "$cached_version" == "0.0.0" ]]; then
        echo -e "${GREEN}✅ First commit - caching version${NC}"
        cache_version "$current_version"
        exit 0
    fi
    
    if version_gt "$current_version" "$cached_version"; then
        echo -e "${GREEN}✅ Version updated: $cached_version → $current_version${NC}"
        cache_version "$current_version"
        exit 0
    else
        echo ""
        echo -e "${RED}❌ VERSION GATE FAILED${NC}"
        echo ""
        echo -e "${YELLOW}Plugin version must be incremented before commit.${NC}"
        echo ""
        echo "Current version: $current_version"
        echo "Required: > $cached_version"
        echo ""
        echo "To fix, run one of:"
        echo "  bash hooks/scripts/bump.sh patch"
        echo "  bash hooks/scripts/bump.sh minor"
        echo "  bash hooks/scripts/bump.sh major"
        echo ""
        exit 1
    fi
}


# 如果直接运行（不是被 source）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
