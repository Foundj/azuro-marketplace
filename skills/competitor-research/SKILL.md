---
name: competitor-research
description: |
  This skill provides multi-model research capabilities for gathering competitor insights and best practices.
  Use when implementing new features, researching libraries, or analyzing open-source patterns.
  Triggers: "research competitors", "analyze best practices", "compare libraries", "研究竞品", "最佳实践".
version: 4.2.6
---

# Competitor Research

> Multi-model research engine for gathering competitor insights and best practices

## Overview

Competitor Research gathers insights from multiple sources to improve requirement quality:

- **Web Search** (Gemini): Best practices, library comparisons, security guidelines
- **Code Analysis** (Codex): Open-source patterns, implementation examples
- **Code Review** (Claude): Security review, quality assessment

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

### Step 1: Web Search (Gemini)

Search for best practices, popular libraries, and common pitfalls.

```bash
~/.claude/common/lib/codeagent-wrapper.sh --backend gemini --yolo <<'EOF'
Search for best practices for implementing [FEATURE] in [TECH_STACK].

Focus on:
1. Popular libraries and trade-offs
2. Security best practices
3. Common implementation pitfalls
4. Production-ready patterns

Output as concise bullet points.
EOF
```

### Step 2: Code Analysis (Codex)

Analyze how the feature is implemented in popular open-source projects.

```bash
~/.claude/common/lib/codeagent-wrapper.sh --backend codex --yolo <<'EOF'
Analyze how [FEATURE] is implemented in popular open-source projects.

Look for:
1. Common patterns and abstractions
2. Error handling approaches
3. Testing strategies
4. Performance considerations

Reference specific repos when possible.
EOF
```

### Step 3: Code Review (Claude)

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

- `~/.claude/common/lib/codeagent-wrapper.sh` - Multi-backend CLI wrapper
- `gemini` CLI - Web search capability
- `codex` CLI - Code analysis capability
