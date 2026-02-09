---
name: ai:research
description: AI-powered competitor research - multi-source best practices analysis
argument-hint: "<topic> [--deep] [--save]"
allowed-tools: Task, Read, Write, WebSearch, WebFetch
execution-mode: subagent
internal: true
---

Research: $ARGUMENTS

**Goal**: Multi-source research on best practices, patterns, and pitfalls

---

## Execution Mode

This command runs as a **subagent** to preserve main session context.

```
/ai:research "JWT authentication"
    ↓
Launch Task tool with subagent:
  - Isolated context execution
    ↓
Subagent executes:
  - Parse options (--deep, --save)
  - Multi-source research
  - Synthesize results
    ↓
Returns Research Report to main session
```

**Advantage**: Does not consume main session context tokens.

---

## Options

- `--deep`: Comprehensive research with multiple searches
- `--save`: Save results to `codebox/research/`
- Default: Quick research with key findings

---

## Step 1: Parse Options

Extract topic from $ARGUMENTS (remove flags like --deep, --save)

## Step 2: Execute Research

### Tool Priority

1. **MCP Tavily** (if available): Deep multi-hop research
2. **MCP Context7** (if available): Library documentation
3. **WebSearch** (always available): Web search fallback

### Standard Mode (default)

Execute 2-3 WebSearch queries:

```
Query 1: "[topic] best practices 2024"
Query 2: "[topic] implementation patterns"
Query 3: "[topic] common pitfalls"
```

### Deep Mode (--deep)

Execute comprehensive research:

**Search 1: Best Practices**
```
WebSearch: "[topic] best practices production 2024"
```

**Search 2: Libraries & Tools**
```
WebSearch: "[topic] recommended libraries comparison"
```

**Search 3: Security**
```
WebSearch: "[topic] security vulnerabilities common mistakes"
```

**Search 4: Examples**
```
WebSearch: "[topic] implementation examples GitHub"
```

## Step 3: Synthesize Results

Compile findings:

```markdown
## 📊 Research: [Topic]

### 💡 Key Recommendations
1. Recommendation with rationale
2. Recommendation with rationale
3. Recommendation with rationale

### 🏆 Recommended Libraries/Tools
| Name | Pros | Cons | When to Use |
|------|------|------|-------------|

### ⚠️ Common Pitfalls
1. Pitfall and how to avoid
2. Pitfall and how to avoid

### 🔒 Security Considerations
- Consideration 1
- Consideration 2

### 📚 References
- [Link 1](url)
- [Link 2](url)
```

## Step 4: Save Results (if --save)

Save to: `codebox/research/[topic]-research.md`

**Next Step**:
> 调研完成。可继续 `/ai:interview` 进行需求沟通，或 `/ai:design` 设计评审。
