# Azuro Marketplace

[中文文档](./README.zh-CN.md)

Azuro is a Claude Code plugin marketplace providing AI development tools and workflow automation extensions.

## Quick Start

### Install Marketplace

```bash
# From GitHub
/plugin marketplace add Foundj/azuro-marketplace
```

### Install Plugin

```bash
/plugin install ai-dev@azuro
```

## Available Plugins

| Plugin | Version | Description |
|--------|---------|-------------|
| [ai-dev](./ai-dev-plugin/) | 3.2.0 | Industrial-grade AI development orchestration with 7-phase workflow, OODA loop, knowledge management |

## ai-dev Plugin Features

### Commands (25)

| Command | Description |
|---------|-------------|
| `/ai:dev` | Main entry - Start AI development workflow |
| `/ai:loop` | OODA autonomous loop |
| `/ai:auto` | Auto-complete remaining tasks |
| `/ai:check` | Pre-implementation check |
| `/ai:fix` | Quick bug fix |
| `/ai:review` | Code review |
| `/ai:design` | Design phase |
| `/ai:implement` | Implementation phase |
| `/ai:research` | Research mode |
| `/ai:interview` | Requirement gathering |
| `/ai:status` | View status |
| `/ai:archive` | Archive changes |
| `/ai:update-constraints` | Update constraints |
| `/ai:update-feature-index` | Update feature index |
| `/skill-audit` | Audit all skills in project |
| `/skill-audit:one` | Audit single skill |
| `/dev` | Quick dev alias |
| `/fix` | Quick fix alias |
| `/research` | Quick research alias |
| `/progress` | View progress |
| `/feature-list` | List features |
| `/feature-show` | Show feature details |
| `/feature-resume` | Resume feature development |
| `/feature-archive` | Archive feature |

### Agents (24)

Specialized agents for different development tasks:

- **Architecture**: code-architect, backend-architect, frontend-developer
- **Quality**: code-reviewer, quality-guardian, confidence-scorer
- **Development**: javascript-pro, typescript-pro, quick-fixer
- **Debugging**: debugger, error-detective, project-doctor
- **Planning**: feature-planner, task-decomposer, requirement-analyzer
- **Testing**: test-automator
- **Other**: api-helper, code-explorer, code-mentor, master-controller, ooda-manager, sprint-manager, task-orchestrator

### Skills (6)

| Skill | Description |
|-------|-------------|
| ai-dev | Core AI development skill, 7-phase workflow |
| claude-reflect | Session learning and reflection system |
| project-initializer | Project initialization and long-running dev mode |
| session-manager | Session management and context recovery |
| competitor-research | Competitor research |
| skill-auditor | Skill quality audit and validation |

## Directory Structure

```
azuro-marketplace/
├── .claude-plugin/
│   └── marketplace.json      # Marketplace manifest
├── ai-dev-plugin/            # AI Dev plugin
│   ├── .claude-plugin/
│   │   └── plugin.json       # Plugin manifest
│   ├── commands/             # 25 commands
│   ├── agents/               # 24 agents
│   ├── skills/               # 6 skills
│   ├── hooks/                # Hook configurations
│   └── scripts/              # Utility scripts
└── README.md
```

## Development Guide

### Adding New Plugins

1. Create plugin directory under `azuro-marketplace/`
2. Create `.claude-plugin/plugin.json`
3. Add commands/, agents/, skills/ components
4. Update root `marketplace.json`

### Local Testing

```bash
# Add local marketplace
/plugin marketplace add /path/to/azuro-marketplace

# Install plugin for testing
/plugin install ai-dev@azuro

# Restart Claude Code to apply
```

## Documentation

- [Plugins](https://code.claude.com/docs/plugins)
- [Plugin Marketplaces](https://code.claude.com/docs/plugin-marketplaces)
- [Plugins Reference](https://code.claude.com/docs/plugins-reference)
- [Slash Commands](https://code.claude.com/docs/slash-commands)
- [Sub-agents](https://code.claude.com/docs/sub-agents)
- [Agent Skills](https://code.claude.com/docs/skills)
- [Hooks](https://code.claude.com/docs/hooks)
- [MCP](https://code.claude.com/docs/mcp)

## License

MIT License

## Author

foundj - https://github.com/Foundj
