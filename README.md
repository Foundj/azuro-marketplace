# Azuro Marketplace

[中文文档](./README.zh-CN.md)

Azuro is a Claude Code plugin marketplace providing industrial-grade AI development tools and workflow automation extensions.

## Quick Start

### 1. Install Marketplace

```bash
# From GitHub
/plugin marketplace add Foundj/azuro-marketplace
```

### 2. Browse & Install Plugins

```bash
# Browse available plugins
/plugin

# Install the full suite
/plugin install ai-dev@azuro-marketplace
```

## Available Plugins

The marketplace offers specialized toolkits that can be installed individually:

| Plugin | Version | Description |
|--------|---------|-------------|
| **ai-dev** | 3.5.0 | **Full Suite**: 7-phase gated workflow, OODA loop, all skills included |
| **skills-audit-toolkit** | 1.1.0 | Professional quality gate for plugin developers |
| **self-learning** | 1.3.0 | Reflection system that learns from session corrections |
| **research-assistant** | 1.0.0 | AI-powered competitor research and best practices analysis |
| **knowledge-manager** | 1.0.0 | Project-specific knowledge graph management |
| **thinking-toolbox** | 1.0.0 | Advanced CoT reasoning engine for complex logic |

## Main Plugin (ai-dev) Features

### Commands (Core)

| Command | Description |
|---------|-------------|
| `/ai:dev` | Start AI development workflow (Phases 0-6) |
| `/ai:loop` | Autonomous OODA loop execution |
| `/ai:auto` | Auto-complete remaining tasks in active change |
| `/ai:status` | View project health and agent progress |
| `/ai:fix` | Intelligent bug fix with verification loop |
| `/ai:review` | Multi-perspective code review |
| `/ai:skills-audit` | Professional skill quality validation |

### Specialized Agents (24)

- **Architecture**: `code-architect`, `backend-architect`, `frontend-developer`
- **Quality**: `code-reviewer`, `quality-guardian`, `confidence-scorer`
- **Development**: `javascript-pro`, `typescript-pro`, `quick-fixer`
- **Debugging**: `debugger`, `error-detective`, `project-doctor`
- **Planning**: `requirement-analyzer`, `feature-planner`, `task-decomposer`

### Agent Skills (9)

- `thinking-engine`: Chain-of-thought logic
- `claude-reflect`: Self-learning reflection
- `competitor-research`: Competitive analysis
- `knowledge-graph`: Solution persistence
- `skill-auditor`: Professional auditing

## Directory Structure

This project follows a "Professional Suite" layout to support multiple isolated plugins in one repository:

```
azuro-marketplace/
├── components/                # Core plugin components (shared)
│   ├── agents/                # Agent definitions
│   ├── commands/              # Slash command definitions
│   ├── hooks/                 # Event hooks and scripts
│   └── scripts/               # Internal utility scripts
├── skills/                    # Agent skills (isolated)
├── .claude-plugin/            # Marketplace configuration
├── docs/                      # Official documentation reference
├── bak/                       # Reference implementations
└── README.md
```

## Development Guide

### Version Management

The marketplace enforces a version gate. You MUST increment the version in `.claude-plugin/marketplace.json` before any commit:

```bash
# In components/hooks/scripts/
bash components/hooks/scripts/bump.sh patch
```

### Quality Gate

Any skill with a score < 80 will block the commit. Run the auditor manually:

```bash
/ai:skills-audit
```

## License

MIT License | **Author**: [foundj](https://github.com/Foundj)
