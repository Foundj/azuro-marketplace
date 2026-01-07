#!/bin/bash
# Version Gate - Pre-commit hook script
# 检查 plugin.json 版本号是否更新，阻止未更新版本的提交

set -e

PLUGIN_JSON="${1:-$(dirname "$0")/../../.claude-plugin/plugin.json}"
VERSION_CACHE="${HOME}/.claude/.version-cache"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 获取当前版本
get_current_version() {
    if [[ -f "$PLUGIN_JSON" ]]; then
        grep '"version"' "$PLUGIN_JSON" | sed 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/'
    else
        echo "0.0.0"
    fi
}

# 获取上次提交的版本
get_cached_version() {
    local plugin_name=$(grep '"name"' "$PLUGIN_JSON" 2>/dev/null | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
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
    local plugin_name=$(grep '"name"' "$PLUGIN_JSON" 2>/dev/null | sed 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
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
    echo "║                    VERSION GATE CHECK                      ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    printf "║  Cached version:  %-40s ║\n" "$cached_version"
    printf "║  Current version: %-40s ║\n" "$current_version"
    echo "╚════════════════════════════════════════════════════════════╝"
    
    # 首次提交，缓存版本
    if [[ "$cached_version" == "0.0.0" ]]; then
        echo -e "${GREEN}✅ First commit - caching version${NC}"
        cache_version "$current_version"
        exit 0
    fi
    
    # 检查版本是否更新
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
        echo "  bump patch  →  $(echo "$cached_version" | awk -F. '{print $1"."$2"."$3+1}')"
        echo "  bump minor  →  $(echo "$cached_version" | awk -F. '{print $1"."$2+1".0"}')"
        echo "  bump major  →  $(echo "$cached_version" | awk -F. '{print $1+1".0.0"}')"
        echo ""
        echo "Or update .claude-plugin/plugin.json manually."
        echo ""
        exit 1
    fi
}

# 如果直接运行（不是被 source）
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
