#!/bin/bash
# 验证长运行项目的健康状态

set -e

echo "🔍 Validating Long-Running Project..."
echo "===================================="
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 初始化错误计数
ERRORS=0
WARNINGS=0

# 1. 检查目录结构
echo "📁 Checking directory structure..."
if [ ! -d ".agent" ]; then
  echo -e "${RED}❌ ERROR: .agent/ directory not found${NC}"
  echo "   → Run 'project-initializer' to initialize the project"
  exit 1
fi
echo -e "${GREEN}✅ .agent/ exists${NC}"

# 2. 检查必需文件
echo ""
echo "📄 Checking required files..."

REQUIRED_FILES=(
  ".agent/feature_list.json"
  ".agent/progress.txt"
  ".agent/config.json"
  ".agent/init.sh"
)

for file in "${REQUIRED_FILES[@]}"; do
  if [ ! -f "$file" ]; then
    echo -e "${RED}❌ ERROR: $file not found${NC}"
    ((ERRORS++))
  else
    echo -e "${GREEN}✅ $file exists${NC}"
  fi
done

# 3. 验证 JSON 格式
echo ""
echo "🔍 Validating JSON files..."

if ! jq empty .agent/feature_list.json 2>/dev/null; then
  echo -e "${RED}❌ ERROR: feature_list.json is invalid JSON${NC}"
  ((ERRORS++))
else
  echo -e "${GREEN}✅ feature_list.json is valid JSON${NC}"
fi

if ! jq empty .agent/config.json 2>/dev/null; then
  echo -e "${RED}❌ ERROR: config.json is invalid JSON${NC}"
  ((ERRORS++))
else
  echo -e "${GREEN}✅ config.json is valid JSON${NC}"
fi

# 4. 检查文件大小
echo ""
echo "📊 Checking file sizes..."

PROGRESS_LINES=$(wc -l < .agent/progress.txt 2>/dev/null || echo "0")
FEATURE_COUNT=$(jq '.features | length' .agent/feature_list.json 2>/dev/null || echo "0")
COMPLETED_COUNT=$(jq '.completed_features' .agent/feature_list.json 2>/dev/null || echo "0")
TOTAL_COUNT=$(jq '.total_features' .agent/feature_list.json 2>/dev/null || echo "0")

echo "   Progress: $PROGRESS_LINES lines"
echo "   Features: $FEATURE_COUNT items"
echo "   Completed: $COMPLETED_COUNT / $TOTAL_COUNT"

# 5. 文件大小警告
echo ""
echo "⚠️  Size Health Check..."

if [ "$PROGRESS_LINES" -gt 2000 ]; then
  echo -e "${YELLOW}⚠️  WARNING: progress.txt exceeds 2000 lines ($PROGRESS_LINES)${NC}"
  echo "   → Consider running: ./scripts/archive-progress.sh"
  ((WARNINGS++))
else
  echo -e "${GREEN}✅ progress.txt size healthy ($PROGRESS_LINES lines)${NC}"
fi

if [ "$FEATURE_COUNT" -gt 500 ]; then
  echo -e "${YELLOW}⚠️  WARNING: Too many features ($FEATURE_COUNT)${NC}"
  echo "   → Consider splitting into multiple projects"
  ((WARNINGS++))
else
  echo -e "${GREEN}✅ feature_list.json size healthy ($FEATURE_COUNT features)${NC}"
fi

# 6. 检查 Git 状态
echo ""
echo "🔄 Checking Git status..."

if git rev-parse --git-dir > /dev/null 2>&1; then
  echo -e "${GREEN}✅ Git repository detected${NC}"

  BRANCH=$(git branch --show-current)
  echo "   Current branch: $BRANCH"

  if git diff-index --quiet HEAD -- 2>/dev/null; then
    echo -e "${GREEN}✅ Working directory clean${NC}"
  else
    echo -e "${YELLOW}⚠️  Uncommitted changes detected${NC}"
    ((WARNINGS++))
  fi
else
  echo -e "${YELLOW}⚠️  WARNING: Not a Git repository${NC}"
  ((WARNINGS++))
fi

# 7. 检查归档目录
echo ""
echo "📦 Checking archive..."

if [ -d ".agent/archive" ]; then
  ARCHIVE_COUNT=$(ls -1 .agent/archive 2>/dev/null | wc -l)
  echo -e "${GREEN}✅ Archive directory exists ($ARCHIVE_COUNT files)${NC}"
else
  echo -e "${YELLOW}ℹ️  Archive directory not created yet${NC}"
fi

# 8. 总结
echo ""
echo "===================================="
echo "📊 Validation Summary"
echo "===================================="

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
  echo -e "${GREEN}✅ All checks passed!${NC}"
  echo ""
  echo "Project is healthy and ready to use."
  exit 0
elif [ $ERRORS -eq 0 ]; then
  echo -e "${YELLOW}⚠️  Passed with $WARNINGS warning(s)${NC}"
  echo ""
  echo "Project is functional but has some warnings."
  exit 0
else
  echo -e "${RED}❌ Validation failed with $ERRORS error(s) and $WARNINGS warning(s)${NC}"
  echo ""
  echo "Please fix the errors above before continuing."
  exit 1
fi
