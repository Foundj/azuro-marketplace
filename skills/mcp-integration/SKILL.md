---
name: mcp-integration
description: |
  This skill provides MCP (Model Context Protocol) server integration guidance and best practices.
  It helps configure and use external MCP servers like Context7 (documentation), Tavily (web search),
  and Sequential-Thinking (reasoning). Use when the user mentions "MCP", "Context7", "Tavily",
  "官方文档查询", "MCP配置", "外部服务集成", or wants to enhance research with external tools.
version: 5.1.4
triggers:
  - MCP
  - Context7
  - Tavily
  - mcp server
  - 官方文档查询
  - MCP配置
  - 外部服务集成
---

# MCP Integration Guide

> Connect Claude Code to external tools and services via Model Context Protocol.

## 触发词

此技能触发于: "MCP", "Context7", "Tavily", "官方文档查询", "MCP配置", "外部服务集成".

## Quick Start

```bash
# Check available MCP tools
/mcp

# Use Context7 for documentation lookup
mcp__context7__resolve-library-id "react" "how to use hooks"
mcp__context7__query-docs "/facebook/react" "useEffect cleanup"
```

## Recommended MCP Servers

| Server | Purpose | Priority | Package |
|--------|---------|----------|---------|
| **Context7** | Official documentation lookup | 🔴 High | `@upstash/context7-mcp` |
| **Tavily** | Deep web research | 🔴 High | `tavily-mcp` |
| **Sequential-Thinking** | Multi-step reasoning | 🟡 Medium | `@anthropic/sequential-thinking` |
| **Playwright** | Browser automation | 🟡 Medium | `@anthropic/mcp-playwright` |

## Configuration

### Plugin-Level MCP (`.mcp.json`)

Place in plugin root directory for bundled MCP servers:

```json
{
  "mcpServers": {
    "Context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    },
    "Tavily": {
      "command": "npx",
      "args": ["-y", "tavily-mcp"],
      "env": {
        "TAVILY_API_KEY": "${TAVILY_API_KEY}"
      }
    }
  }
}
```

### User-Level MCP

Configure in `~/.claude/settings.json`:

```json
{
  "mcpServers": {
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

## Usage Patterns

### Context7: Documentation Lookup

**When to use**: Before implementing unfamiliar APIs or libraries

```
Step 1: Resolve library ID
  mcp__context7__resolve-library-id
    - libraryName: "react"
    - query: "how to implement custom hooks"

Step 2: Query documentation
  mcp__context7__query-docs
    - libraryId: "/facebook/react"
    - query: "useEffect cleanup function best practices"
```

**Best Practice**: Always verify with official docs before implementation to prevent hallucination.

### Context7: Code Pattern Search (Semantic)

**When to use**: Finding similar code patterns in documentation

```
# Example 1: Find authentication patterns
mcp__context7__query-docs
  - libraryId: "/vercel/next.js"
  - query: "authentication middleware pattern with JWT"

# Example 2: Find error handling patterns
mcp__context7__query-docs
  - libraryId: "/expressjs/express"
  - query: "async error handling wrapper try catch"

# Example 3: Find testing patterns
mcp__context7__query-docs
  - libraryId: "/jestjs/jest"
  - query: "mock function implementation examples"
```

**Integration with ultrawork Phase 0**:
```yaml
Confidence Gate Enhancement:
  1. Before implementation, query Context7 for patterns
  2. Compare with existing codebase patterns (LSP/Grep)
  3. If both match → confidence boost +15%
  4. If mismatch → present alternatives to user
```

### Tavily: Web Research

**When to use**: Competitor research, current best practices, recent changes

```
mcp__tavily__search
  - query: "Next.js 14 app router authentication patterns 2024"
  - search_depth: "advanced"
  - include_domains: ["nextjs.org", "vercel.com"]
```

**Integration with competitor-research**: Use Tavily in Phase 0.5 for multi-source research.

### Sequential-Thinking: Complex Reasoning

**When to use**: Architecture decisions, multi-step problem solving

```
mcp__sequential-thinking__create_reasoning_chain
  - problem: "Design authentication system for microservices"
  - steps: 5
```

**Value**: 30-50% token reduction for complex reasoning tasks.

## Integration with ai-dev Workflow

### Phase 0: Context & Knowledge

```yaml
MCP Usage:
  - Context7: Query knowledge base for similar patterns
  - Sequential-Thinking: Analyze task complexity
```

### Phase 0.5: Research

```yaml
MCP Usage:
  - Tavily: Competitor research with search_depth="advanced"
  - Context7: Official documentation for technologies
```

### Phase 2: Design

```yaml
MCP Usage:
  - Context7: Verify API compatibility
  - Sequential-Thinking: Evaluate design approaches
```

## Availability Detection

Before using MCP tools, check availability:

```bash
# List available MCP servers
claude mcp list

# Check if specific server is available
claude mcp status context7
```

## Graceful Degradation (无 MCP 时的降级方案)

**重要**: MCP 是可选增强，不配置 MCP 不会影响基本功能使用。

### 降级策略表

| MCP 工具 | 降级替代方案 | 功能差异 |
|----------|--------------|----------|
| Context7 (文档) | WebFetch + 官方 URL | 需手动提供 URL，无语义搜索 |
| Context7 (文档) | WebSearch "library docs" | 结果可能不够精确 |
| Tavily (研究) | WebSearch | 无 Multi-hop，深度有限 |
| Sequential-Thinking | 直接推理 | 无 token 节省，同样有效 |

### 降级检测逻辑

```yaml
# 在技能执行前自动检测
check_mcp_availability:
  - try: mcp__context7__resolve-library-id
  - if_error: use WebFetch/WebSearch fallback
  - log: "MCP unavailable, using fallback"

# 无需用户配置，自动降级
```

### 无 MCP 时的替代流程

**文档查询** (替代 Context7):
```bash
# 直接使用 WebFetch
WebFetch({ url: "https://react.dev/reference/react/useEffect", prompt: "cleanup best practices" })

# 或使用 WebSearch
WebSearch({ query: "React useEffect cleanup official docs 2024" })
```

**竞品研究** (替代 Tavily):
```bash
# 使用 WebSearch
WebSearch({ query: "authentication best practices 2024" })

# 多次搜索获取更全面信息
WebSearch({ query: "JWT vs session authentication comparison" })
```

**结论**: 不配置 MCP 完全可以正常使用，只是失去一些高级功能（语义搜索、Multi-hop 推理）。

## Security Considerations

- **API Keys**: Store in environment variables, never in code
- **Rate Limits**: Respect server rate limits
- **Data Privacy**: Don't send sensitive data to external servers

## Red Flags

**Never:**
- Hardcode API keys in configuration
- Assume MCP server is always available
- Skip fallback mechanisms

**Always:**
- Check MCP availability before use
- Use environment variables for secrets
- Implement graceful degradation

## Agent Collaboration

| Agent | MCP Usage |
|-------|-----------|
| `@librarian` | Context7 for documentation |
| `competitor-research` | Tavily for web research |
| `@oracle` | Sequential-Thinking for reasoning |
| `confidence-gate` | Context7 to verify understanding |

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 5.0.18 | 2026-02-26 | Added Context7 semantic search patterns for code patterns |
| 5.0.7 | 2026-01-14 | Initial release with Context7, Tavily, Sequential-Thinking |

## Code Pattern Search Examples

### Finding Similar Implementations

```yaml
# Use Case: Implementing authentication
Query: "authentication middleware pattern with session validation"
Result: Official patterns from framework docs

# Use Case: Implementing error handling
Query: "error boundary pattern with fallback UI"
Result: React error boundary examples

# Use Case: Implementing caching
Query: "caching strategy with stale-while-revalidate"
Result: Next.js ISR patterns
```

### Integration with LSP-First Navigation

```yaml
Priority Order for Code Discovery:
  1. LSP tools (goToDefinition, findReferences) - project code
  2. Context7 query-docs - official patterns
  3. Grep/Glob - fallback search
  4. WebSearch - last resort

Example Flow:
  LSP.goToDefinition → Found in project? → Use it
                      → Not found? → Context7 query-docs → Found pattern? → Apply
                                  → Not found? → WebSearch
```
