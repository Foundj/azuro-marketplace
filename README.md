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
/plugin install ai-dev@azuro-marketplace
```

## Available Plugins

| Plugin | Version | Description |
|--------|---------|-------------|
| ai-dev | 3.4.9 | Industrial-grade AI development orchestration with 7-phase workflow, OODA loop, knowledge management |

## ai-dev Plugin Features

### Commands (27)

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
| `/ai:quality` | Quality gate check |
| `/skill-audit` | Audit all skills in project |
| `/skill-audit:one` | Audit single skill |
| `/dev` | Quick dev alias |
| `/fix` | Quick fix alias |
| `/research` | Quick research alias |

### Agents (24)

Specialized agents for different development tasks:

- **Architecture**: code-architect, backend-architect, frontend-developer
- **Quality**: code-reviewer, quality-guardian, confidence-scorer
- **Development**: javascript-pro, typescript-pro, quick-fixer
- **Debugging**: debugger, error-detective, project-doctor
- **Planning**: feature-planner, task-decomposer, requirement-analyzer
- **Testing**: test-automator

### Skills (9)

| Skill | Description |
|-------|-------------|
| ai-dev | Core AI development skill, 7-phase workflow |
| claude-reflect | Session learning and reflection system |
| project-initializer | Project initialization and long-running dev mode |
| session-manager | Session management and context recovery |
| competitor-research | Competitor research |
| skill-auditor | Skill quality audit and validation |
| thinking-engine | Extended thinking and reasoning |
| knowledge-graph | Knowledge graph management |
| quality-gate | Code quality gate checks |

## Directory Structure

```
azuro-marketplace/
├── .claude-plugin/
│   └── marketplace.json      # Marketplace manifest (includes plugin config)
├── agents/                   # 24 agents
├── commands/                 # 27 commands
├── skills/                   # 9 skills
├── hooks/                    # Hook configurations
├── scripts/                  # Utility scripts
├── docs/                     # Documentation reference
├── bak/                      # Reference projects
└── README.md
```

## Development Guide

### Local Testing

```bash
# Add local marketplace
/plugin marketplace add /path/to/azuro-marketplace

# Install plugin for testing
/plugin install ai-dev@azuro

# Restart Claude Code to apply
```

### Version Management

```bash
# Bump version before commit
bash hooks/scripts/bump.sh patch   # 3.4.0 → 3.4.1
bash hooks/scripts/bump.sh minor   # 3.4.0 → 3.5.0
bash hooks/scripts/bump.sh major   # 3.4.0 → 4.0.0
```

### Skill Quality Audit

```bash
# Audit single skill
bash skills/skill-auditor/scripts/validate-skill.sh skills/<skill-name>

# Audit all skills
for skill in skills/*/; do
  bash skills/skill-auditor/scripts/validate-skill.sh "$skill"
done
```

## Documentation

- [Plugins](https://code.claude.com/docs/plugins)
- [Plugin Marketplaces](https://code.claude.com/docs/plugin-marketplaces)
- [Plugins Reference](https://code.claude.com/docs/plugins-reference)

## License

MIT License

## Author

foundj - https://github.com/Foundj
