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

<!-- BEGIN_PLUGIN_TABLE -->
| Plugin | Version | Description |
|--------|---------|-------------|
| **ai-dev** | 4.1.4 | Industrial-grade AI development orchestration with 7-phase gated workflow, OODA autonomous completion, knowledge management, and project context awareness |
| **skills-audit-toolkit** | 4.1.4 | Professional quality gate system for Claude Code plugins - ensure your skills follow best practices |
| **self-learning** | 4.1.4 | Self-learning system that captures corrections during sessions and updates your project conventions |
| **research-assistant** | 4.1.4 | AI-powered competitor research and best practices analysis tool |
| **knowledge-manager** | 4.1.4 | Personal knowledge graph for projects - discover related solutions and prevent duplication |
| **thinking-toolbox** | 4.1.4 | Advanced reasoning and chain-of-thought engine for complex problem solving |
| **context-bridge** | 4.1.4 | Cross-session context management - save progress, restore and auto-continue tasks. Bridges Manus 3-file pattern with Azuro 7-phase workflow |
<!-- END_PLUGIN_TABLE -->

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
