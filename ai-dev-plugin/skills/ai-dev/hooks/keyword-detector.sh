#!/bin/bash

# Keyword Detector Hook for ai-dev
# Type: UserPromptSubmit
# Detects keywords in user prompts and injects mode instructions
# Priority: ulw > ultrathink > think > quick
#
# Keywords:
#   - ulw/ultrawork/全力/全自动 → Ultrawork mode (parallel agents)
#   - ultrathink/好好思考/深思熟虑 → Ultra-think mode (max thinking)
#   - think/思考/想一想/仔细/深度 → Think mode (extended thinking)
#   - quick/快速/简单/快点 → Quick mode (skip phases)

set -euo pipefail

LOG_PREFIX="🔍 Keyword"

# Read hook input from stdin
HOOK_INPUT=$(cat)
USER_PROMPT=$(echo "$HOOK_INPUT" | jq -r '.prompt // empty' 2>/dev/null || echo "")

# If no prompt, allow through
if [[ -z "$USER_PROMPT" ]]; then
    exit 0
fi

# Convert to lowercase for matching
PROMPT_LOWER=$(echo "$USER_PROMPT" | tr '[:upper:]' '[:lower:]')

# Detect mode with priority order
MODE=""
INJECTION=""

# Priority 1: Ultrawork mode (highest priority)
if echo "$PROMPT_LOWER" | grep -qE '(ulw|ultrawork|全力|全自动)'; then
    MODE="ultrawork"
    INJECTION="[Ultrawork Mode 已激活]

并行执行策略:
1. 后台启动 @explore-fast 扫描项目结构
2. 后台启动 @librarian 查询知识库
3. 后台启动 @oracle 分析复杂度
4. 持续执行直到 <promise>DONE</promise>
5. 不要中途停止，完成所有任务

执行原则:
- 最大化并行 Agent 使用
- 自动继续，不等待确认
- 完成全部任务再退出"

# Priority 2: Ultra-think mode
elif echo "$PROMPT_LOWER" | grep -qE '(ultrathink|好好思考|深思熟虑)'; then
    MODE="ultrathink"
    INJECTION="[Ultra-Think Mode 已激活]

深度思考配置:
1. thinking budget 设为最大
2. 考虑多种方案并权衡利弊
3. 不要急于给出答案，充分分析
4. 每个决策都要有充分的理由

执行原则:
- 先全面分析问题
- 列出所有可能的方案
- 评估每个方案的优缺点
- 选择最优方案并解释原因"

# Priority 3: Think mode
elif echo "$PROMPT_LOWER" | grep -qE '(think|思考|想一想|仔细|深度)'; then
    MODE="think"
    INJECTION="[Think Mode 已激活]

扩展思考配置:
- 增加 thinking budget
- 先分析问题再行动
- 考虑边界情况和潜在问题"

# Priority 4: Quick mode (lowest priority)
elif echo "$PROMPT_LOWER" | grep -qE '(quick|快速|简单|快点)'; then
    MODE="quick"
    INJECTION="[Quick Mode 已激活]

快速模式配置:
- 跳过 Phase 0.5 (竞品研究)
- 跳过 Phase 1 (需求访谈)
- 跳过 Phase 2 (设计评审)
- 直接进入实现阶段"
fi

# If no mode detected, allow through without modification
if [[ -z "$MODE" ]]; then
    exit 0
fi

# Log detection
echo "${LOG_PREFIX}: Detected mode '$MODE'" >&2

# Output JSON to inject system message
jq -n \
  --arg mode "$MODE" \
  --arg injection "$INJECTION" \
  '{
    "decision": "allow",
    "systemMessage": $injection,
    "metadata": {
      "detectedMode": $mode,
      "hook": "keyword-detector"
    }
  }'

exit 0
