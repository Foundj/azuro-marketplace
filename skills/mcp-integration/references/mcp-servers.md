# MCP Server Integration Guide

## Available MCP Servers

| Server | Purpose | Use Case |
|--------|---------|----------|
| Context7 | Documentation lookup | Query official library docs |
| Tavily | Web search | Research and documentation |
| Sequential-Thinking | Reasoning | Complex problem solving |

## Integration Patterns

### Context7 Pattern
```bash
mcp__context7__resolve-library-id "react" "how to use hooks"
mcp__context7__query-docs "/facebook/react" "useState hook examples"
```

### Tavily Pattern
```bash
mcp__tavily__search "best practices for JWT authentication"
```

## Configuration

Add to `.claude/settings.json`:
```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@anthropic/context7"]
    }
  }
}
```
