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

# Install the full suite (recommended)
/plugin install ai-dev@azuro-marketplace

# Or install specific standalone plugins
/plugin install context-bridge@azuro-marketplace
/plugin install skills-audit-toolkit@azuro-marketplace
```

### 3. Marketplace Management

```bash
# Update marketplace (fetch latest versions)
/plugin marketplace update azuro-marketplace

# Remove marketplace
/plugin marketplace remove azuro-marketplace

# View installed plugins
/plugin list
```

## Available Plugins

**Plugin Relationship:**
- **ai-dev** is the complete suite containing all skills, commands, agents, and hooks
- Other plugins (context-bridge, skills-audit-toolkit, etc.) are standalone alternatives for specific features
- Installing ai-dev includes all functionality; no need to install other plugins separately

<!-- BEGIN_PLUGIN_TABLE -->
| Plugin | Version | Description |
|--------|---------|-------------|
| **ai-dev** | 4.1.12 | Industrial-grade AI development orchestration with 7-phase gated workflow, OODA autonomous completion, knowledge management, and project context awareness |
| **skills-audit-toolkit** | 4.1.12 | Professional quality gate system for Claude Code plugins - ensure your skills follow best practices |
| **self-learning** | 4.1.12 | Self-learning system that captures corrections during sessions and updates your project conventions |
| **research-assistant** | 4.1.12 | AI-powered competitor research and best practices analysis tool |
| **knowledge-manager** | 4.1.12 | Personal knowledge graph for projects - discover related solutions and prevent duplication |
| **thinking-toolbox** | 4.1.12 | Advanced reasoning and chain-of-thought engine for complex problem solving |
| **context-bridge** | 4.1.12 | Cross-session context management - save progress, restore and auto-continue tasks. Bridges Manus 3-file pattern with Azuro 7-phase workflow |
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

This project follows the official Claude Code plugin standard structure:

```
azuro-marketplace/
├── .claude-plugin/            # Marketplace configuration
│   └── marketplace.json
├── agents/                    # Agent definitions (standard location)
├── commands/                  # Slash command definitions (standard location)
├── hooks/                     # Event hooks and scripts (standard location)
│   ├── hooks.json
│   └── scripts/
├── skills/                    # Agent skills (isolated)
├── components/scripts/        # Internal utility scripts
├── docs/                      # Official documentation reference
└── README.md
```

## Development Guide

### Version Management

The marketplace enforces a version gate. You MUST increment the version in `.claude-plugin/marketplace.json` before any commit:

```bash
bash hooks/scripts/bump.sh patch   # patch: x.x.X
bash hooks/scripts/bump.sh minor   # minor: x.X.0
bash hooks/scripts/bump.sh major   # major: X.0.0
```

### Quality Gate

Any skill with a score < 80 will block the commit. Run the auditor manually:

```bash
/ai:skills-audit
```

## License

MIT License | **Author**: [foundj](https://github.com/Foundj)
