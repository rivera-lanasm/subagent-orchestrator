# Git Strategy

Worktree-based isolation for parallel subagents.
Source: https://code.claude.com/docs/en/common-workflows#run-parallel-claude-code-sessions-with-git-worktrees

## Why Worktrees

- Each agent gets isolated file state
- Changes in one worktree don't affect others
- Shared Git history and remote connections
- Orchestrator can inspect any agent without disruption

## Naming Convention

```
<repo>--<agent-name>/
```

Example:
```
~/projects/
├── my-app/                 # main repo
├── my-app--worker-auth/    # agent working on auth
└── my-app--worker-api/     # agent working on api
```

## Worktree Lifecycle

### Create
```bash
# From main repo
git worktree add ../my-app--worker-auth -b agent/worker-auth
```

### List
```bash
git worktree list
```

### Remove
```bash
git worktree remove ../my-app--worker-auth
# Optionally delete branch
git branch -d agent/worker-auth
```

## Commit Conventions

Agents must use semantic prefixes:

| Prefix | Meaning | Orchestrator action |
|--------|---------|---------------------|
| `wip:` | Work in progress | Monitor only |
| `checkpoint:` | Stable state | Safe rollback point |
| `complete:` | Task finished | Ready for review/merge |

Example:
```
wip: add auth middleware skeleton
checkpoint: auth middleware working, tests pass
complete: auth middleware with full test coverage
```

## Rollback

Orchestrator can reset to last checkpoint:
```bash
cd ../my-app--worker-auth
git log --oneline --grep="checkpoint:"
git reset --hard <checkpoint-sha>
```

## Branch Strategy

- Agent branches: `agent/<agent-name>`
- Never push to main/master
- Orchestrator merges successful work
