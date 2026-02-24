#!/bin/bash

# MCP Setup Script for Azuro Marketplace
# Helps users configure recommended MCP servers automatically
# Supports: Context7, Tavily, Sequential-Thinking

set -euo pipefail

LOG_PREFIX="🔌 MCP-Setup"
CLAUDE_SETTINGS="${HOME}/.claude/settings.json"

log_info() {
    echo -e "\033[0;32m${LOG_PREFIX}: $1\033[0m"
}

log_warn() {
    echo -e "\033[1;33m${LOG_PREFIX} ⚠️: $1\033[0m"
}

log_error() {
    echo -e "\033[0;31m${LOG_PREFIX} ❌: $1\033[0m"
}

# ============================================================================
# Check Prerequisites
# ============================================================================

if [[ ! -f "$CLAUDE_SETTINGS" ]]; then
    log_warn "Claude settings file not found at $CLAUDE_SETTINGS"
    mkdir -p "$(dirname "$CLAUDE_SETTINGS")"
    echo '{"mcpServers": {}}' > "$CLAUDE_SETTINGS"
fi

# =0 Check for jq
if ! command -v jq &>/dev/null; then
    log_error "jq is required for this script. Please install it first."
    exit 1
fi

# ============================================================================
# Configure Servers
# ============================================================================

setup_context7() {
    log_info "Configuring Context7 MCP (Documentation)..."

    local tmp_file=$(mktemp)
    jq '.mcpServers.context7 = {
        "command": "npx",
        "args": ["-y", "@upstash/context7-mcp"]
    }' "$CLAUDE_SETTINGS" > "$tmp_file"
    mv "$tmp_file" "$CLAUDE_SETTINGS"

    log_info "✅ Context7 configured."
}

setup_sequential_thinking() {
    log_info "Configuring Sequential-Thinking MCP (Reasoning)..."

    local tmp_file=$(mktemp)
    jq '.mcpServers["sequential-thinking"] = {
        "command": "npx",
        "args": ["-y", "@anthropic/mcp-sequential-thinking"]
    }' "$CLAUDE_SETTINGS" > "$tmp_file"
    mv "$tmp_file" "$CLAUDE_SETTINGS"

    log_info "✅ Sequential-Thinking configured."
}

setup_tavily() {
    local tavily_val="${TAVILY_API_KEY:-}"

    if [[ -z "$tavily_val" ]]; then
        log_warn "TAVILY_API_KEY environment variable not found."
        echo -n "Please enter your Tavily API Key (or press enter to skip): "
        read -r input_key
        tavily_val="$input_key"
    fi

    if [[ -n "$tavily_val" ]]; then
        log_info "Configuring Tavily MCP (Research)..."
        local tmp_file=$(mktemp)
        jq --arg key "$tavily_val" '.mcpServers.tavily = {
            "command": "npx",
            "args": ["-y", "tavily-mcp"],
            "env": {
                "TAVILY_API_KEY": $key
            }
        }' "$CLAUDE_SETTINGS" > "$tmp_file"
        mv "$tmp_file" "$CLAUDE_SETTINGS"
        log_info "✅ Tavily configured."
    else
        log_warn "Skipping Tavily configuration."
    fi
}

# ============================================================================
# Main Logic
# ============================================================================

echo "----------------------------------------------------"
echo "        Azuro Marketplace MCP Auto-Setup            "
echo "----------------------------------------------------"

# Always setup these (free/npx based)
setup_context7
setup_sequential_thinking

# Optional (needs API key)
setup_tavily

log_info "MCP Setup Complete! Please restart Claude Code for changes to take effect."
echo "----------------------------------------------------"
