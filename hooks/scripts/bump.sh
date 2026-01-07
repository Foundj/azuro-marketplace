#!/bin/bash
# Bump version in marketplace.json
# Usage: bump.sh [patch|minor|major]

set -e

PLUGIN_JSON="${2:-$(dirname "$0")/../../.claude-plugin/marketplace.json}"
BUMP_TYPE="${1:-patch}"

# 颜色定义
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [[ ! -f "$PLUGIN_JSON" ]]; then
    echo "Error: marketplace.json not found at $PLUGIN_JSON"
    exit 1
fi

# 获取当前版本
current_version=$(grep '"version"' "$PLUGIN_JSON" | sed 's/.*"version"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')

# 分割版本号
IFS='.' read -ra VERSION <<< "$current_version"
major=${VERSION[0]:-0}
minor=${VERSION[1]:-0}
patch=${VERSION[2]:-0}

# 计算新版本
case "$BUMP_TYPE" in
    major)
        new_version="$((major + 1)).0.0"
        ;;
    minor)
        new_version="${major}.$((minor + 1)).0"
        ;;
    patch|*)
        new_version="${major}.${minor}.$((patch + 1))"
        ;;
esac

# 更新 plugin.json
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS
    sed -i '' "s/\"version\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"version\": \"$new_version\"/" "$PLUGIN_JSON"
else
    # Linux
    sed -i "s/\"version\"[[:space:]]*:[[:space:]]*\"[^\"]*\"/\"version\": \"$new_version\"/" "$PLUGIN_JSON"
fi

echo -e "${GREEN}✅ Version bumped: $current_version → $new_version${NC}"
echo ""
echo "Updated: $PLUGIN_JSON"
