#!/bin/bash
# check-completion.sh - Completion detection functions for OODA loop
# Part of ai-dev hooks library

# Check for explicit completion promise
check_explicit_completion() {
    local output="$1"
    
    if echo "$output" | grep -q '<promise>DONE</promise>'; then
        return 0
    fi
    return 1
}

# Check for false completion claims
detect_false_completion() {
    local output="$1"
    local remaining="$2"
    
    # Check if agent claims completion
    if echo "$output" | grep -qiE '(完成|done|finished|all tasks complete|已完成|结束)'; then
        if [[ "$remaining" -gt 0 ]]; then
            return 0  # False completion detected
        fi
    fi
    return 1
}

# Verify build and tests pass
verify_build_and_tests() {
    local project_dir="${1:-.}"
    
    # Try to find package.json
    if [[ -f "$project_dir/package.json" ]]; then
        # Run tests silently
        if ! npm test --silent 2>/dev/null; then
            return 1
        fi
        
        # Run build silently
        if ! npm run build --silent 2>/dev/null; then
            return 1
        fi
    fi
    
    return 0
}

# Generate continue prompt for unfinished tasks
generate_continue_prompt() {
    local remaining="$1"
    local tasks_file="$2"
    local remaining_list=""
    
    if [[ -f "$tasks_file" ]]; then
        remaining_list=$(grep -E '^\s*-\s*\[\s*\]' "$tasks_file" | head -5)
    fi
    
    cat << EOF
{
  "decision": "block",
  "reason": "还有 $remaining 个任务未完成:\n$remaining_list\n\n请继续执行剩余任务，完成后输出 <promise>DONE</promise>",
  "systemMessage": "🔄 TODO Continuation: 检测到未完成任务，请继续执行。"
}
EOF
}
