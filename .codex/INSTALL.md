# Installing Azuro Marketplace for Codex

Quick setup to enable azuro-marketplace plugins in Codex.

## Installation

1. **Clone azuro-marketplace repository**:
   ```bash
   mkdir -p ~/.codex/azuro-marketplace
   cd ~/.codex/azuro-marketplace
   git clone https://github.com/Foundj/azuro-marketplace.git .
   ```

2. **Create personal skills directory**:
   ```bash
   mkdir -p ~/.codex/skills
   ```

3. **Update ~/.codex/AGENTS.md** to include this azuro section:
   ```markdown
   ## Azuro Marketplace

   <EXTREMELY_IMPORTANT>
   You have access to the Azuro AI development suite. Run: `cat ~/.codex/azuro-marketplace/CLAUDE.md` to load the development guidelines and available commands.
   </EXTREMELY_IMPORTANT>
   ```

## Core Commands

After installation, you can use:

| Command | Description |
|---------|-------------|
| `/ai:dev <feature>` | Full 7-phase development workflow |
| `/ai:fix <bug>` | Quick bug fix with verification |
| `/ai:status` | View project progress |

## Verification

Test the installation:
```bash
cat ~/.codex/azuro-marketplace/README.md
```

You should see the Azuro Marketplace documentation. The system is now ready for use.

## Updating

```bash
cd ~/.codex/azuro-marketplace
git pull
```

## Getting Help

- Report issues: https://github.com/Foundj/azuro-marketplace/issues
- Documentation: https://github.com/Foundj/azuro-marketplace
