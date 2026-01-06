# AI-Dev Plugin

> Industrial-grade AI development orchestration with 7-phase gated workflow, OODA autonomous completion, knowledge management, and project context awareness.

## Features

- **7-Phase Gated Workflow**: Interview → Research → Design → Plan → Implement → Review → Release
- **OODA Autonomous Loop**: Self-referential development until `<promise>DONE</promise>`
- **Knowledge Management**: Learn from past implementations, avoid repeat mistakes
- **Pre-Implementation Check**: Detect duplicates and conflicts before coding
- **Smart Archival**: Auto-generate summaries and update knowledge base

## Installation

### From GitHub
```bash
/plugin marketplace add Foundj/azuro-marketplace
```

### Local Development
```bash
# Enable the plugin
/plugin install ai-dev@azuro
```

## Commands

### Core Workflow
| Command | Description |
|---------|-------------|
| `/ai:dev <task>` | Full 7-phase development workflow |
| `/ai:loop <task>` | Self-referential loop until DONE |
| `/ai:auto` | Auto-complete remaining tasks |

### Phase Commands
| Command | Description |
|---------|-------------|
| `/ai:interview` | Phase 1: Requirement gathering |
| `/ai:design` | Phase 2-3: Design and planning |
| `/ai:implement` | Phase 4: Implementation |
| `/ai:review` | Phase 5: Code review |

### Utility Commands
| Command | Description |
|---------|-------------|
| `/ai:check <feature>` | Pre-implementation check |
| `/ai:archive` | Archive completed changes |
| `/ai:status` | View current progress |
| `/ai:fix <issue>` | Quick bug fix |
| `/ai:research <topic>` | Competitor research |

### Knowledge Commands
| Command | Description |
|---------|-------------|
| `/ai:update-constraints` | Update coding constraints |
| `/ai:update-feature-index` | Update feature index |

## Quick Aliases
| Alias | Full Command |
|-------|--------------|
| `/dev` | `/ai:dev` |
| `/fix` | `/ai:fix` |
| `/research` | `/ai:research` |
| `/progress` | View progress |

## Workflow Modes

### Auto-Detect (based on task verb)
- `fix/update/patch` → Quick mode (skip design phases)
- `implement/build/create` → Standard workflow
- `design/architect/plan` → Extended thinking mode

### Explicit Modifiers
- `quick` / `快速` → Skip phases 0.5/1/2
- `think` / `思考` → Extended thinking mode
- `ultrathink` / `深思熟虑` → Maximum thinking budget
- `ulw` / `全力` → Ultrawork mode (parallel agents)

## Examples

```bash
# Full workflow for new feature
/ai:dev implement user authentication

# Quick fix
ai fix the login button bug

# Research before implementing
/ai:research payment gateway best practices

# Check for existing implementations
/ai:check user profile management

# Continue from previous session
/ai:auto

# Archive completed work
/ai:archive --current
```

## Skills Included

- **ai-dev**: Core orchestration skill
- **claude-reflect**: Learning and reflection system
- **project-initializer**: Project setup for long-running development
- **session-manager**: Cross-session context recovery
- **competitor-research**: Multi-backend research

## Directory Structure

```
ai-dev-plugin/
├── .claude-plugin/
│   └── plugin.json         # Plugin manifest
├── commands/               # Slash commands
│   ├── ai:dev.md
│   ├── ai:loop.md
│   └── ...
├── agents/                 # Agent definitions
│   ├── architecture/
│   ├── development/
│   ├── quality/
│   └── workflow/
├── skills/                 # Skill definitions
│   ├── ai-dev/
│   ├── claude-reflect/
│   └── ...
├── hooks/                  # Event hooks
│   ├── hooks.json
│   └── scripts/
├── scripts/                # Utility scripts
└── README.md
```

## Requirements

- Claude Code CLI
- `jq` for JSON processing
- `git` for version control

## License

MIT

## Author

foundj - https://github.com/foundj

## Contributing

1. Fork the repository
2. Create feature branch
3. Submit pull request

For issues and feature requests, please use GitHub Issues.
