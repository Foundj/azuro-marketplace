---
name: competitor-research
description: |
  This skill provides multi-model research capabilities for gathering competitor insights and best practices.
  Use when implementing new features, researching libraries, or analyzing open-source patterns.
  Triggers on "research competitors", "analyze best practices", "compare libraries", "研究竞品", "最佳实践".
version: 5.1.18
status: ga
triggers:
  - research competitors
  - analyze best practices
  - compare libraries
  - research
  - 研究竞品
  - 最佳实践
  - 调研
  - 对比分析
---

# Competitor Research

> Multi-model research engine for gathering competitor insights and best practices

## 触发词

此技能触发于: "research competitors", "analyze best practices", "研究竞品", "最佳实践", "调研分析".

## Overview

Competitor Research gathers insights from multiple sources to improve requirement quality:

- **MCP Integration (Preferred)**: Tavily for deep web search, Context7 for official docs
- **Web Search** (Gemini): Best practices, library comparisons, security guidelines
- **Code Analysis** (Codex): Open-source patterns, implementation examples
- **Code Review** (Claude): Security review, quality assessment

---

## MCP-Enhanced Research (v5.0.8)

When MCP servers are available, use them for higher quality results:

### Tavily MCP (Deep Web Research)

```
mcp__tavily__search
  - query: "[FEATURE] best practices [TECH_STACK] 2024"
  - search_depth: "advanced"
  - include_domains: ["github.com", "stackoverflow.com"]
```

**Advantages over Gemini**:
- Multi-hop reasoning (up to 5 hops)
- Source quality scoring
- Real-time results

### Context7 MCP (Official Documentation)

```
Step 1: Resolve library
  mcp__context7__resolve-library-id
    - libraryName: "[LIBRARY]"
    - query: "[FEATURE] implementation"

Step 2: Query docs
  mcp__context7__query-docs
    - libraryId: "[RESOLVED_ID]"
    - query: "[SPECIFIC_QUESTION]"
```

**Advantages**:
- Prevents hallucination with verified docs
- Up-to-date API references
- Code examples from official sources

### Fallback Chain

```
1. Check MCP availability: mcp__tavily, mcp__context7
2. If available → Use MCP tools
3. If unavailable → Fall back to WebSearch (always available)
```

---

## When to Use

### Auto-Trigger (by ai-dev)

Activates automatically for new feature development:
- Keywords: `implement`, `build`, `create`, `design`, `实现`, `开发`, `设计`

### Manual Trigger

```bash
/research "user authentication"
/research "支付功能" --deep
帮我调研一下用户登录的最佳实践
```

### Skip Research

Skip for simple tasks:
- Keywords: `fix`, `update`, `refactor`, `typo`, `修复`, `更新`
- User says: "不需要调研" or "skip research"

---

## Usage

### Quick Research (Default)

```bash
/research "feature name"
```

Output: 3-5 bullet points with recommendations

### Deep Research

```bash
/research "feature name" --deep
```

Output: Full JSON report saved to `codebox/research/`

---

## Research Process

### Step 1: Web Search (Best Practices)

Search for best practices, popular libraries, and common pitfalls.

```
WebSearch: "[FEATURE] best practices [TECH_STACK] 2024"

Focus on:
1. Popular libraries and trade-offs
2. Security best practices
3. Common implementation pitfalls
4. Production-ready patterns
```

### Step 2: Code Examples Search

Search for implementation examples in popular projects.

```
WebSearch: "[FEATURE] implementation examples GitHub [TECH_STACK]"

Look for:
1. Common patterns and abstractions
2. Error handling approaches
3. Testing strategies
4. Performance considerations
```

### Step 3: Security Review

Review security and quality aspects of the feature implementation.

### Step 4: Synthesize Results

Combine findings into structured recommendations.

---

## Output Format

### Quick Mode

```
📊 Research: User Authentication

💡 Recommendations:
  1. Use NextAuth.js for quick setup (62% adoption)
  2. Store passwords with bcrypt + salt
  3. Implement refresh token mechanism
  4. Use httpOnly cookies for JWT storage

⚠️ Common Pitfalls:
  - Plaintext password storage
  - Missing token expiration
  - CSRF vulnerabilities

📚 References:
  - OWASP Authentication Cheatsheet
  - NextAuth.js documentation
```

### Deep Mode (JSON)

```json
{
  "feature": "user-authentication",
  "research_date": "2025-01-07",
  "alternatives": [
    {
      "name": "NextAuth.js",
      "pros": ["Built-in providers", "Session management"],
      "cons": ["Configuration complexity"],
      "adoption": "high"
    }
  ],
  "best_practices": [
    "Use httpOnly cookies for JWT storage",
    "Implement refresh token rotation"
  ],
  "common_pitfalls": [
    {
      "issue": "Plaintext password storage",
      "impact": "critical",
      "prevention": "Use bcrypt with salt"
    }
  ]
}
```

---

## Integration with ai-dev

### Pre-Interview Research Flow

```
User: "ai 实现用户登录"
         │
         ▼
┌────────────────────────────────┐
│ ai-dev detects:                │
│ - New feature (implement)      │
│ - Triggers competitor-research │
└────────────────────────────────┘
         │
         ▼
┌────────────────────────────────┐
│ competitor-research executes   │
│ - Gemini: web search           │
│ - Codex: code analysis         │
│ - Saves to codebox/research/   │
└────────────────────────────────┘
         │
         ▼
┌────────────────────────────────┐
│ requirement-interviewer uses   │
│ research results as context    │
└────────────────────────────────┘
```

### Research in Interview

```
Q1: How do you want to implement authentication?

💡 Research Insights (auto-generated):
   Based on analysis of 2,847 Next.js projects:
   
   a) Email/Password (62% adoption)
      - Traditional, users are familiar
      - Requires password reset, verification
   
   b) Third-party OAuth (28% adoption)
      - Google/GitHub/WeChat
      - Great UX, no password to remember
   
   c) Magic Links (10% adoption)
      - Passwordless, email-based
      - High security, depends on email delivery

📝 Your choice:
```

---

## Risk Detection

When research reveals significant risks:

```
⚠️ Research Found Potential Risks:

1. 🔴 Security Risk (Critical)
   - Custom crypto is a common vulnerability source
   - No major projects implement custom encryption

💡 Suggested Alternatives:
   a) Use bcrypt for password hashing
   b) Use crypto standard library for encryption
```

---

## Configuration

```json
{
  "auto_research": true,
  "auto_triggers": ["implement", "build", "create", "design"],
  "skip_triggers": ["fix", "update", "refactor", "typo"],
  "backends": {
    "web_search": "gemini",
    "code_analysis": "codex"
  },
  "default_mode": "quick",
  "results_path": "codebox/research/"
}
```

---

## Dependencies

- `WebSearch` - Built-in web search tool (always available)
- `MCP Tavily` - Optional deep research capability
- `MCP Context7` - Optional documentation lookup

## Agent Collaboration

| Agent | Role |
|-------|------|
| `ai-dev` | Triggers research in Phase 0.5 |
| `ai-dev-interview` | Uses research as context |
| `mcp-integration` | Provides MCP tool guidance |
| `@librarian` | Stores research in knowledge base |
| `@oracle` | Strategic research direction |

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 5.0.8 | 2026-01-14 | Add MCP integration (Tavily, Context7), fallback chain |
| 4.2.6 | 2026-01-13 | Add triggers, agent collaboration, version history |
| 4.0.0 | 2026-01-07 | Initial release with multi-model pipeline |

## References

See `references/research-workflow.md` for detailed workflow.
