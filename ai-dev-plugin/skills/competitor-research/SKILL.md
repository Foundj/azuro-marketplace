---
name: competitor-research
description: |
  Multi-model research skill for gathering competitor insights and best practices.
  Uses ~/.claude/common/lib/codeagent-wrapper.sh (gemini for web search, codex for code analysis, claude for code review).
  
  **TRIGGERS**: research, 调研, 竞品, alternatives, 最佳实践, best practices
  
  **AUTO-TRIGGER**: When ai-dev detects new feature requirement
  **MANUAL**: /research "feature" or "帮我调研一下 XX"
  
  Provides structured research results to requirement-interviewer for better suggestions.
version: 1.0.0
---

# Competitor Research Skill

Research competitors and best practices to improve requirement quality.

## When to Use

### Auto-Trigger (by ai-dev)
- New feature development detected
- Keywords: `implement`, `build`, `create`, `design`, `实现`, `开发`, `设计`

### Manual Trigger
```
/research "user authentication"
/research "支付功能" --deep
帮我调研一下用户登录的最佳实践
```

### Skip Research
- Simple fixes: `fix`, `update`, `refactor`, `typo`
- User explicitly says: "不需要调研" or "skip research"

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

```bash
~/.claude/common/lib/codeagent-wrapper.sh --backend claude --yolo <<'EOF'
Review security and quality aspects of [FEATURE] implementation.

Check for:
1. Security vulnerabilities
2. Best practices compliance
3. Edge case handling
4. Error resilience

Provide actionable recommendations.
EOF
```

### Step 4: Synthesize Results

Combine web search and code analysis into structured output.

---

## Output Format

### Quick Mode (Console)
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
  "research_date": "2025-01-05",
  "tech_stack": "next.js",
  "alternatives": [
    {
      "name": "NextAuth.js",
      "pros": ["Built-in providers", "Session management"],
      "cons": ["Configuration complexity"],
      "adoption": "high",
      "recommendation": "mvp"
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
  ],
  "recommendations": {
    "for_mvp": "NextAuth.js with credentials provider",
    "for_production": "Custom JWT with refresh tokens"
  },
  "references": [
    {
      "title": "OWASP Authentication Cheatsheet",
      "url": "https://cheatsheetseries.owasp.org/..."
    }
  ]
}
```

---

## Integration with ai-dev

### Pre-Interview Research

```
User: "ai 实现用户登录"
         │
         ▼
┌────────────────────────────────┐
│ ai-dev detects:       │
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
│ for interview questions        │
└────────────────────────────────┘
```

### Research Results in Interview

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

⚠️ Research Warning:
   73% of security vulnerabilities come from custom password storage
   Recommendation: Use bcrypt + salt

📝 Your choice:
```

---

## Risk Detection & Rejection

When research reveals significant risks:

```
⚠️ Research Found Potential Risks:

You want to "implement custom encryption algorithm".
Research indicates:

1. 🔴 Security Risk (Critical)
   - Custom crypto is a common vulnerability source
   - No major projects implement custom encryption

2. 🔴 Complexity Risk (High)
   - Requires deep cryptographic knowledge
   - High maintenance burden

💡 Suggested Alternatives:
   a) Use bcrypt for password hashing
   b) Use crypto standard library for encryption
   c) Use Argon2 for key derivation

📝 Options:
   a) Accept suggestion - use standard libraries
   b) Proceed anyway - acknowledge risks (requires confirmation)
   c) Modify requirement - describe what you actually need
```

---

## Configuration

### Auto-Research Settings
```json
{
  "auto_research": true,
  "auto_triggers": ["implement", "build", "create", "design", "实现", "开发"],
  "skip_triggers": ["fix", "update", "refactor", "typo", "修复", "更新"],
  "backends": {
    "web_search": "gemini",
    "code_analysis": "codex"
  },
  "default_mode": "quick",
  "save_results": true,
  "results_path": "codebox/research/"
}
```

### Backend Requirements
- `~/.claude/common/lib/codeagent-wrapper.sh` installed and executable
- Gemini CLI available for web search (`gemini` or via npx)
- Codex CLI available for code analysis (`codex` or via npx)
- Claude CLI available for code review (`claude` or via npx)

---

## Storage

Research results are stored in:
```
codebox/research/
├── user-authentication-research.json
├── payment-integration-research.json
└── search-functionality-research.json
```

- No automatic expiration
- User can force refresh: `/research "feature" --force`
- Shows research date for user to decide freshness

---

## Examples

### Example 1: Quick Research
```
User: /research "pagination"

📊 Research: Pagination

💡 Recommendations:
  1. Use cursor-based pagination for large datasets
  2. Implement virtual scrolling for 1000+ items
  3. Consider infinite scroll for mobile UX
  4. Cache page results for back navigation

⚠️ Common Pitfalls:
  - Offset pagination breaks with concurrent inserts
  - Missing loading states frustrate users

Time: 4.2s | Sources: 3 web + 2 repos
```

### Example 2: Deep Research
```
User: /research "real-time notifications" --deep

🔍 Deep Research: Real-time Notifications
Saving to: codebox/research/real-time-notifications-research.json

Researching...
├─ Gemini: WebSocket vs SSE comparison ✓
├─ Gemini: Push notification best practices ✓
├─ Codex: Analyzing socket.io patterns ✓
├─ Codex: Analyzing Pusher implementations ✓
└─ Synthesizing results ✓

✅ Research complete (12.8s)

Summary:
- WebSocket recommended for bidirectional
- SSE sufficient for server-to-client only
- Consider Pusher/Ably for managed solution

Full report: codebox/research/real-time-notifications-research.json
```
