# Azuro Marketplace

[中文文档](./README.zh-CN.md)

Azuro is a Claude Code plugin marketplace providing industrial-grade AI development tools and workflow automation extensions.

## Quick Start

### Claude Code

```bash
# From GitHub
/plugin marketplace add Foundj/azuro-marketplace
```

### Codex

Tell Codex:
```
Fetch and follow instructions from https://raw.githubusercontent.com/Foundj/azuro-marketplace/refs/heads/main/.codex/INSTALL.md
```
**Detailed docs:** [.codex/INSTALL.md](.codex/INSTALL.md)

### OpenCode

Tell OpenCode:
```
Fetch and follow instructions from https://raw.githubusercontent.com/Foundj/azuro-marketplace/refs/heads/main/.opencode/INSTALL.md
```
**Detailed docs:** [.opencode/INSTALL.md](.opencode/INSTALL.md)

---

### Browse & Install Plugins (Claude Code)

```bash
# Browse available plugins
/plugin

# Install the full suite (recommended)
/plugin install ai-dev@azuro-marketplace

# Or install specific standalone plugins
/plugin install context-bridge@azuro-marketplace
/plugin install skills-audit-toolkit@azuro-marketplace
```

### Marketplace Management (Claude Code)

```bash
# Update marketplace (fetch latest versions)
/plugin marketplace update azuro-marketplace

# Remove marketplace
/plugin marketplace remove azuro-marketplace

# View installed plugins
/plugin list
```

## Usage with AI Agents

### Just ask Claude

The simplest approach - just tell Claude what you want:

> "Implement user authentication for my app"
> "Fix the login button bug"
> "Review my code for security issues"

Claude will automatically use the appropriate skills and agents from this marketplace.

### Core Commands

| Command | What it does |
|---------|--------------|
| `/ai:dev <feature>` | Full 7-phase development workflow |
| `/ai:fix <bug>` | Quick bug fix with verification |
| `/ai:status` | View project progress |
| `/ai:team feature <feature>` | Team collaboration development |
| `/ai:team review <path>` | Team code review |
| `/ai:team debug <issue>` | Team problem investigation |
| `/ai:dev --team <feature>` | Hybrid mode with auto-routing |

### Agent Teams (Experimental)

Enable multi-agent collaboration with Claude Code's native Agent Teams:

```json
// ~/.claude/settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

**Team modes:**
- **Feature Development** - Frontend/backend parallel development
- **Code Review** - Multi-perspective parallel review
- **Debug** - Competitive hypothesis investigation

See [Agent Teams Quickstart](docs/agent-teams-quickstart.md) for details.

### CLAUDE.md Integration

For more consistent results, add to your project's CLAUDE.md:

```markdown
## AI Development

Use `/ai:dev` for feature development. Run `/ai:status` to check progress.

Core workflow:
1. `/ai:dev "feature name"` - Start development
2. Answer interview questions
3. Review design options
4. Let AI implement and validate
```

## Available Plugins

**Plugin Relationship:**
- **ai-dev** is the complete suite containing all skills, commands, agents, and hooks
- Other plugins (context-bridge, skills-audit-toolkit, etc.) are standalone alternatives for specific features
- Installing ai-dev includes all functionality; no need to install other plugins separately

<!-- BEGIN_PLUGIN_TABLE -->
| Plugin | Version | Description |
|--------|---------|-------------|
| **ai-dev** | 6.0.19 | Industrial-grade AI development orchestration with 7-phase gated workflow, OODA autonomous completion, knowledge management, and project context awareness |
<!-- END_PLUGIN_TABLE -->

## Main Plugin (ai-dev) Features

### Commands (User-Facing)

| Command | Description |
|---------|-------------|
| `/ai:dev` | Start AI development workflow (Phases 0-6) |
| `/ai:fix` | Intelligent bug fix with verification loop |
| `/ai:status` | View project health and agent progress |
| `/ai:team` | Multi-agent team collaboration development |
| `/ai:session-save` | Save current session progress and context |
| `/ai:session-resume` | Restore and continue previous session |

> **Note**: Additional commands (like `/ai:skills-audit`, `/ai:test-web`) are internal tools triggered automatically by workflows. They are fully functional but not exposed to avoid user confusion. See [docs/INDEX.md](docs/INDEX.md) for design principles.

### Specialized Agents (20)

- **Architecture**: `code-architect`, `backend-architect`, `frontend-developer`
- **Quality**: `code-reviewer`, `quality-guardian`, `confidence-scorer`
- **Development**: `javascript-pro`, `typescript-pro`, `quick-fixer`
- **Debugging**: `debugger`, `project-doctor`
- **Planning**: `requirement-analyzer`, `task-decomposer`

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
├── scripts/                   # Internal utility scripts
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
