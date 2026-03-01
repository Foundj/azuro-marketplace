# AI-Dev v3.0

Industrial-grade AI development orchestration for Claude Code.

## Features

- **7-Phase Gated Workflow** - Structured development with user approval gates
- **Parallel Task Subagents** - Multi-perspective exploration and research
- **OODA Autonomous Loop** - Self-completing implementation phase
- **Knowledge Management** - Pattern and error tracking across sessions
- **Integrated Learning** - Automatic capture and reflection via claude-reflect

## Quick Start

```bash
# Full development workflow
ai implement user authentication

# Quick fix
dev fix the login button bug

# Research only
/research "payment integration"

# Check progress
/ai:status

# Reflect on learnings
/reflect
```

## Installation

1. Ensure `~/.claude/skills/ai:dev/` exists
2. Run dependency check:
   ```bash
   ~/.claude/skills/ai:dev/scripts/check-dependencies.sh
   ```
3. Initialize project (optional):
   ```bash
   /init project MyProject
   ```

## 7-Phase Workflow

| Phase | Name | Gate | Description |
|-------|------|------|-------------|
| 0 | Context & Knowledge | Auto | Load project context, query knowledge base |
| 0.5 | Research | Auto/Skip | Competitor research for new features |
| 1 | Requirements | User ✓ | Multi-round interview, generate proposal.md |
| 2 | Design | User ✓ | Present approaches, user selects |
| 3 | Task Breakdown | Auto | Generate tasks.md with subtasks |
| 4 | Implementation | OODA | Autonomous execution loop |
| 5 | Quality | Auto | Code review, testing, verification |
| 6 | Finalization | User ✓ | Knowledge capture, commit |

## Agents (14)

| Agent | Purpose |
|-------|---------|
| requirement-interviewer | Multi-round interview with parallel context |
| research-coordinator | Multi-source parallel research |
| code-explorer | Multi-perspective codebase analysis |
| code-architect | Design approach generation |
| task-decomposer | Task breakdown |
| learning-coordinator | Knowledge capture and reflection |
| verification-agent | Tests, build, lint |
| code-reviewer | Issue detection |
| confidence-scorer | Quality filtering (≥80) |
| quick-fixer | Fast bug fixes |
| debugger | Deep debugging |
| api-helper | API integration |
| test-automator | Test generation |
| requirement-analyzer | Feature planning and requirement analysis |

## Directory Structure

```
ai-dev/
├── SKILL.md              # Main skill definition
├── README.md             # This file
├── agents/               # 14 agent definitions
│   ├── requirement-interviewer.md
│   ├── research-coordinator.md
│   ├── learning-coordinator.md
│   └── ...
├── references/           # 13 reference documents
│   ├── 7-phase-workflow.md
│   ├── multi-agent-patterns.md
│   ├── memory-systems.md
│   └── ...
├── hooks/
│   ├── hooks.json        # Hook configuration
│   └── ooda-stop-hook.sh
├── scripts/
│   ├── check-dependencies.sh
│   ├── scan-project.sh
│   └── ...
└── templates/
    └── codebox/          # Project template
```

## Dependencies

| Dependency | Required | Description |
|------------|----------|-------------|
| competitor-research | Yes | Phase 0.5 research |
| project-initializer | Yes | Codebox setup |
| session-manager | Yes | Cross-session continuity |
| claude-reflect | No | Learning capture |
| MCP Context7 | No | Documentation lookup |
| MCP Tavily | No | Deep web research |

## Commands

| Command | Description |
|---------|-------------|
| `ai [task]` | Start full workflow |
| `dev [task]` | Alias for `ai` |
| `/research "topic"` | Competitor research |
| `/ai:status` | Current progress |
| `/reflect` | Process learnings |
| `/init project` | Initialize new project |

## Configuration

Edit `hooks/hooks.json` to customize:

```json
{
  "config": {
    "maxIterations": 50,
    "completionPromise": "DONE",
    "logLevel": "info"
  }
}
```

## Version History

See [CHANGELOG.md](./CHANGELOG.md) for version history.

## License

MIT
