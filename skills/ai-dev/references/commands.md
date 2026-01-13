# Commands Reference

See `commands/README.md` for full documentation.

## Core Commands

| Command | Description |
|---------|-------------|
| `/ai:dev <feature>` | Full 7-phase development workflow |
| `/ai:dev auto` | Auto-complete remaining tasks |
| `/ai:fix <bug>` | Quick bug fix (subagent mode) |
| `/ai:status` | Check current progress |
| `/ai:status --list` | List all features |
| `/ai:session-save` | Save session progress |
| `/ai:session-resume` | Resume saved session |

## Loop Commands

| Command | Description |
|---------|-------------|
| `/ai:loop <task>` | Self-referential loop until `<promise>DONE</promise>` |
| `/ai:cancel-loop` | Cancel running loop |

## Learning Commands

| Command | Description |
|---------|-------------|
| `/reflect` | Trigger learning reflection |
| `/view-queue` | View pending reflection queue |
| `/skip-reflect` | Skip current reflection |

## Feature Management (Legacy)

| Command | Description |
|---------|-------------|
| `/feature-list` | List all features |
| `/feature-show <id>` | Show feature details |
| `/feature-resume [id]` | Resume/continue feature |
| `/feature-archive <id>` | Archive completed feature |

## Mode Flags

| Flag | Effect |
|------|--------|
| `--quick` | Skip phases 0.5, 1, 2 |
| `--think` | Extended thinking mode |
| `--ultrathink` | Maximum thinking budget |
| `--parallel` | Enable parallel agents |
| `--safe` | Conservative mode |
