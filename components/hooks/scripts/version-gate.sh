#!/bin/bash
# Version Gate - Pre-commit hook script
# 检查 marketplace.json 版本号是否更新，阻止未更新版本的提交

set -e

PLUGIN_JSON="${1:-$(dirname "$0")/../../../.claude-plugin/marketplace.json}"
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
    if [[ -f "components/scripts/sync-docs.sh" ]]; then
        bash components/scripts/sync-docs.sh
    else
        echo -e "${RED}❌ sync-docs.sh not found${NC}"
        exit 1
    fi

    echo -e "${YELLOW}🔍 Validating hooks.json...${NC}"
    if ! bash components/hooks/scripts/validate-hooks.sh components/hooks/hooks.json; then
        echo -e "${RED}❌ hooks.json validation failed${NC}"
        exit 1
    fi

    echo -e "${YELLOW}🔍 Auditing all skills...${NC}"
    local skill_fail=0
    for skill_dir in skills/*/; do
        if [[ -d "$skill_dir" ]]; then
            set +e
            bash skills/skill-auditor/scripts/validate-skill.sh "$skill_dir" > /tmp/audit_log 2>&1
            local exit_code=$?
            set -e
            
            if [[ $exit_code -eq 1 ]] || [[ $exit_code -eq 2 ]]; then
                skill_fail=1
                echo -e "${RED}❌ Critical audit failure for $(basename "$skill_dir")${NC}"
                cat /tmp/audit_log
            fi
            
            local score=$(grep "TOTAL:" /tmp/audit_log | sed 's/.*TOTAL:[[:space:]]*\([0-9]*\).*/\1/')
            if [[ -n "$score" ]] && [[ "$score" -lt 80 ]]; then
                skill_fail=1
                echo -e "${RED}❌ Skill $(basename "$skill_dir") quality too low: $score/100 (Required: 80+)${NC}"
                grep "TOTAL:" /tmp/audit_log
            fi
        fi
    done

    if [[ $skill_fail -ne 0 ]]; then
        echo -e "${RED}❌ SKILL AUDIT FAILED. Please fix skills before committing.${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ All skills passed quality audit (80+)${NC}"
    
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
