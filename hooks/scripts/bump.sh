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
current_version=$(jq -r '.metadata.version' "$PLUGIN_JSON")

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

jq ".metadata.version = \"$new_version\" | .plugins[].version = \"$new_version\"" "$PLUGIN_JSON" > "$PLUGIN_JSON.tmp" && mv "$PLUGIN_JSON.tmp" "$PLUGIN_JSON"

echo -e "${GREEN}✅ Version bumped: $current_version → $new_version${NC}"
echo ""
echo "Updated: $PLUGIN_JSON"

# 检查并更新 CHANGELOG.md
CHANGELOG_FILE="$(dirname "$0")/../../CHANGELOG.md"
if [[ -f "$CHANGELOG_FILE" ]]; then
    if ! grep -q "\[${new_version}\]" "$CHANGELOG_FILE"; then
        echo ""
        echo -e "${YELLOW}📝 Adding CHANGELOG.md entry for v${new_version}...${NC}"

        # 创建临时文件
        TEMP_FILE=$(mktemp)
        DATE_TODAY=$(date +%Y-%m-%d)

        # 在 [Unreleased] 后插入新版本条目
        awk -v ver="$new_version" -v date="$DATE_TODAY" '
        /^## \[Unreleased\]/ {
            print $0
            print ""
            print "## [" ver "] - " date
            print ""
            print "### Changed"
            print "- TODO: Describe your changes here"
            print ""
            next
        }
        { print }
        ' "$CHANGELOG_FILE" > "$TEMP_FILE"

        mv "$TEMP_FILE" "$CHANGELOG_FILE"
        echo -e "${GREEN}✅ CHANGELOG.md updated with v${new_version} template${NC}"
        echo ""
        echo -e "${YELLOW}⚠️  Remember to update the CHANGELOG entry before committing!${NC}"
    else
        echo ""
        echo -e "${GREEN}✅ CHANGELOG.md already contains v${new_version}${NC}"
    fi
else
    echo ""
    echo -e "${YELLOW}⚠️  CHANGELOG.md not found${NC}"
fi
