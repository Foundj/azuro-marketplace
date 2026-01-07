---
name: research
description: Multi-source research shortcut for best practices, patterns, and pitfalls
argument-hint: "<topic> [--backend] [--deep]"
allowed-tools: Bash, Read, Write
---

Research best practices for: $ARGUMENTS

**Step 1: Parse arguments and detect mode**

Check for --deep flag and extract topic:
```
DEEP_MODE: Check if $ARGUMENTS contains "--deep"
BACKEND: Extract --backend value if present, default "auto"
TOPIC: Extract topic by removing flags from $ARGUMENTS
```

**Step 2: Execute research**

For standard mode (single backend with auto-selection):

!`~/.claude/common/lib/codeagent-wrapper.sh --backend auto --yolo "Research best practices for: $ARGUMENTS

Focus on:
1. Popular libraries and trade-offs
2. Security best practices
3. Common implementation pitfalls
4. Production-ready patterns

Output as concise bullet points with references."`

For deep mode (--deep flag present), execute all three backends:

1. **Gemini - Web Search:**
   !`~/.claude/common/lib/codeagent-wrapper.sh --backend gemini --yolo "Search web for best practices: [TOPIC]"`

2. **Codex - Code Analysis:**
   !`~/.claude/common/lib/codeagent-wrapper.sh --backend codex --yolo "Analyze open-source implementations of: [TOPIC]"`

3. **Claude - Security Review:**
   !`~/.claude/common/lib/codeagent-wrapper.sh --backend claude --yolo "Review security aspects of: [TOPIC]"`

**Step 3: Synthesize results**

Compile findings into structured output:

📊 **Research: [TOPIC]**

💡 **Recommendations:**
- Key insights from research
- Best practices to follow
- Recommended libraries/tools

⚠️ **Common Pitfalls:**
- Issues to avoid
- Anti-patterns

📚 **References:**
- Sources and documentation links

**Step 4: Save deep research (if --deep)**

For deep mode, save comprehensive results to:
`codebox/research/[topic]-research.json`
