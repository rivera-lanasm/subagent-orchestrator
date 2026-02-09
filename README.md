# Subagent Orchestrator

A Claude Code plugin for orchestrating parallel subagents on isolated git worktrees.

## Features

- **Spawn** subagents on isolated worktrees with defined tasks and success criteria
- **Monitor** agent status, progress, and findings
- **Rollback** to checkpoints when agents go off track
- **Cleanup** worktrees and branches when done

## Installation

```bash
# Clone to your plugins directory
git clone <repo-url> ~/.claude/plugins/subagent-orchestrator

# Or symlink for development
ln -s ~/projects/subagent-orchestrator ~/.claude/plugins/subagent-orchestrator
```

## Usage

### Spawn an agent
```
/spawn worker --task "Add auth middleware" --test "npm test -- --grep auth"
```

### Monitor progress
```
/monitor              # all agents
/monitor worker-a1b2  # specific agent
```

### Rollback to checkpoint
```
/rollback worker-a1b2
```

### Cleanup when done
```
/cleanup worker-a1b2
```

## How It Works

1. `/spawn` creates a git worktree and branch for the agent
2. Agent works in isolation, updating `.agent/status.json`
3. Commits use prefixes: `wip:`, `checkpoint:`, `complete:`
4. `/monitor` reads status files and git logs
5. `/rollback` resets to last `checkpoint:` commit
6. `/cleanup` removes worktree and merges or discards work

## Agent Templates

Define custom agents in `agents/`. See `agents/worker.md` for the default template.

## Hooks

| Hook | Purpose |
|------|---------|
| `validate-scope.sh` | Block writes outside designated scope |
| `validate-commit-msg.sh` | Enforce commit prefixes |
| `log-activity.sh` | Audit trail in `.agent/activity.log` |

## Status

**Early development** - skills and scripts are placeholders.

## Documentation

See `AgenticCode/subagent-orchestrator/` in Obsidian vault for detailed design docs.

## License

MIT
