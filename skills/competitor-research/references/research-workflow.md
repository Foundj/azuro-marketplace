# Research Workflow Reference

> Multi-model research process for competitor-research

## Research Pipeline

```
Step 1: Web Search (Gemini)
   ↓
Step 2: Code Analysis (Codex)
   ↓
Step 3: Code Review (Claude)
   ↓
Step 4: Synthesize Results
```

## Step 1: Web Search

**Focus Areas**:
- Popular libraries and trade-offs
- Security best practices
- Common implementation pitfalls
- Production-ready patterns

## Step 2: Code Analysis

**Look For**:
- Common patterns and abstractions
- Error handling approaches
- Testing strategies
- Performance considerations

## Step 3: Code Review

**Assess**:
- Security vulnerabilities
- Quality issues
- Maintainability concerns

## Output Formats

### Quick Mode (Default)
```
📊 Research: [Feature]

💡 Recommendations:
  1. [Recommendation 1]
  2. [Recommendation 2]

⚠️ Common Pitfalls:
  - [Pitfall 1]

📚 References:
  - [Reference 1]
```

### Deep Mode (JSON)
```json
{
  "feature": "...",
  "research_date": "...",
  "alternatives": [...],
  "best_practices": [...],
  "common_pitfalls": [...]
}
```

## Trigger Keywords

**Auto-trigger**: implement, build, create, design
**Skip**: fix, update, refactor, typo
