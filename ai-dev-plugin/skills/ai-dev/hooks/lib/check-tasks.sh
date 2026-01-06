#!/bin/bash
# check-tasks.sh - Task status checking functions for OODA loop
# Part of ai-dev hooks library

# Count remaining (unchecked) tasks
count_remaining_tasks() {
    local tasks_file="$1"
    
    if [[ ! -f "$tasks_file" ]]; then
        echo "0"
        return
    fi
    
    local total=$(grep -cE '^\s*-\s*\[' "$tasks_file" 2>/dev/null || echo 0)
    local done=$(grep -cE '^\s*-\s*\[x\]' "$tasks_file" 2>/dev/null || echo 0)
    
    echo $((total - done))
}

# Count total tasks
count_total_tasks() {
    local tasks_file="$1"
    
    if [[ ! -f "$tasks_file" ]]; then
        echo "0"
        return
    fi
    
    grep -cE '^\s*-\s*\[' "$tasks_file" 2>/dev/null || echo 0
}

# Count completed tasks
count_completed_tasks() {
    local tasks_file="$1"
    
    if [[ ! -f "$tasks_file" ]]; then
        echo "0"
        return
    fi
    
    grep -cE '^\s*-\s*\[x\]' "$tasks_file" 2>/dev/null || echo 0
}

# Get list of remaining tasks
get_remaining_tasks() {
    local tasks_file="$1"
    local limit="${2:-5}"
    
    if [[ ! -f "$tasks_file" ]]; then
        echo ""
        return
    fi
    
    grep -E '^\s*-\s*\[\s*\]' "$tasks_file" | head -"$limit"
}

# Check if all tasks are complete
all_tasks_complete() {
    local tasks_file="$1"
    local remaining=$(count_remaining_tasks "$tasks_file")
    
    [[ "$remaining" -eq 0 ]]
}

# Find active change directory
find_active_change_dir() {
    local base_dir="${1:-codebox/changes/active}"
    
    if [[ ! -d "$base_dir" ]]; then
        echo ""
        return
    fi
    
    find "$base_dir" -maxdepth 1 -type d ! -name "active" 2>/dev/null | head -1
}

# Get tasks file path from active change
get_tasks_file() {
    local active_dir=$(find_active_change_dir "$1")
    
    if [[ -n "$active_dir" && -f "$active_dir/tasks.md" ]]; then
        echo "$active_dir/tasks.md"
    else
        echo ""
    fi
}
