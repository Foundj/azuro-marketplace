---
description: AI-powered competitor research - multi-source best practices analysis
argument-hint: <topic> [--deep] [--save]
allowed-tools: Task, Bash, Read, Write
---

Research: $ARGUMENTS

**Goal**: Multi-source research on best practices, patterns, and pitfalls

**Step 1: Parse Options**

- `--deep`: Use all 3 backends (Gemini + Codex + Claude)
- `--save`: Save results to `codebox/research/`
- Default: Auto-select best backend

**Step 2: Execute Research**

### Standard Mode (single backend)

```bash
~/.claude/common/lib/codeagent-wrapper.sh --backend auto --yolo "
Research best practices for: $ARGUMENTS

Focus on:
1. Popular libraries and their trade-offs
2. Security considerations
3. Common implementation pitfalls
4. Production-ready patterns
5. Real-world examples

Output as structured bullet points with references.
"
```

### Deep Mode (--deep)

Launch 3 parallel research agents:

**Agent 1: Gemini (Web Search)**
```bash
~/.claude/common/lib/codeagent-wrapper.sh --backend gemini --yolo "
Web search for: $ARGUMENTS
- Latest trends and updates
- Popular solutions
- Community discussions
"
```

**Agent 2: Codex (Code Analysis)**
```bash
~/.claude/common/lib/codeagent-wrapper.sh --backend codex --yolo "
Analyze open-source implementations of: $ARGUMENTS
- GitHub repos with high stars
- Implementation patterns
- Code examples
"
```

**Agent 3: Claude (Security Review)**
```bash
~/.claude/common/lib/codeagent-wrapper.sh --backend claude --yolo "
Security and architecture review for: $ARGUMENTS
- Security best practices
- Common vulnerabilities
- Recommended architecture
"
```

**Step 3: Synthesize Results**

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

**Step 4: Save Results (if --save)**

Save to: `codebox/research/[topic]-research.json`

```json
{
  "topic": "[topic]",
  "timestamp": "ISO date",
  "sources": ["gemini", "codex", "claude"],
  "recommendations": [...],
  "libraries": [...],
  "pitfalls": [...],
  "references": [...]
}
```

**Next Step**:
> 调研完成。可继续 `/ai:interview` 进行需求沟通，或 `/ai:design` 设计评审。
