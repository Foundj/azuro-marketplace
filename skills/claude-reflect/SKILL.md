---
name: claude-reflect
description: |
  A self-learning system that captures user corrections and updates project rules.
  Automatically detects feedback patterns and prompts users to sync learnings to CLAUDE.md.
version: 4.2.2
---

# Claude Reflect - Self-Learning System

This skill enables a two-stage system that helps Claude Code learn from user corrections.

## How It Works

**Stage 1: Capture (Automatic)**
Hooks detect correction patterns ("no, use X", "actually...", "use X not Y") and queue them to `~/.claude/learnings-queue.json`.

**Stage 2: Process (Manual)**
The user runs `/reflect` to review and apply queued learnings to CLAUDE.md files.

## Prerequisites & Dependencies
- Python 3.6+
- `jq` for JSON processing
- Git (for post-commit hooks)
- Claude Code CLI

## Available Commands

| Command | Purpose |
|---------|---------|
| `/reflect` | Process queued learnings with human review |
| `/reflect --scan-history` | Scan past sessions for missed learnings |
| `/reflect --dry-run` | Preview changes without applying |
| `/skip-reflect` | Discard all queued learnings |
| `/view-queue` | View pending learnings without processing |

## Trigger Phrases & Synonyms
Users may trigger this skill by using phrases such as:
- "Remember this for next time"
- "Actually, I meant..."
- "No, that's wrong, use..."
- "Don't use X, use Y instead"
- "That's perfect, keep doing that"
- "From now on, always..."

## When to Remind Users
- After completing a feature or meaningful work unit.
- After corrections are made that should be remembered.
- When explicitly asked to "remember" something.

## Correction Detection Patterns
High-confidence corrections include:
- Tool rejections (user stops an action with guidance)
- "no, use X" / "don't use Y"
- "actually..." / "I meant..."
- "use X not Y" / "X instead of Y"
- "remember:" (explicit marker)

## Example Interaction

```
User: no, use gpt-5.1 not gpt-5 for reasoning tasks
Claude: Got it, I'll use gpt-5.1 for reasoning tasks.

[Hook captures this correction to queue]

User: /reflect
Claude: Found 1 learning queued. "Use gpt-5.1 for reasoning tasks"
        Scope: global
        Apply to ~/.claude/CLAUDE.md? [y/n]
```

## Workflow Integration
This skill integrates with the `ai-dev` workflow by ensuring that patterns learned during development are persisted across sessions, improving agent performance in subsequent phases.
