# MCP Server Configuration Examples

## Context7

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@anthropic/context7-mcp-server"]
    }
  }
}
```

## Sequential-Thinking

```json
{
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@anthropic/sequential-thinking-server"]
    }
  }
}
```

## Tavily

```json
{
  "mcpServers": {
    "tavily": {
      "command": "npx",
      "args": ["-y", "@anthropic/tavily-mcp-server"],
      "env": {
        "TAVILY_API_KEY": "your-key-here"
      }
    }
  }
}
```
