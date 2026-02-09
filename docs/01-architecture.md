# Architecture

## Plugin Structure

```
subagent-orchestrator/
├── plugin.json           # plugin manifest
├── agents/               # subagent templates
│   └── worker.md         # example worker agent
├── skills/               # orchestrator commands
│   ├── spawn.md          # /spawn <agent> --task "..."
│   ├── monitor.md        # /monitor [agent]
│   ├── rollback.md       # /rollback <agent>
│   └── cleanup.md        # /cleanup <agent>
├── scripts/              # shell utilities
│   ├── worktree-create.sh
│   ├── worktree-remove.sh
│   └── status-poll.sh
├── hooks/                # lifecycle hooks
│   └── validate-scope.sh
└── README.md
```

## Components

### 1. Subagent Templates (`agents/`)
YAML frontmatter configs defining:
- Tools and permissions
- System prompt with status-reporting instructions
- Model selection
- Scope boundaries

### 2. Skills (`skills/`)
| Skill | Purpose |
|-------|---------|
| `/spawn` | Create worktree, deploy agent |
| `/monitor` | Show status of active agents |
| `/rollback` | Reset agent's worktree to checkpoint |
| `/cleanup` | Remove worktree, optionally delete branch |

### 3. Scripts (`scripts/`)
Shell utilities called by skills:
- Worktree lifecycle (create, list, remove)
- Status file polling
- Git operations (checkpoint detection, reset)

### 4. Hooks (`hooks/`)
Validation scripts for agent guardrails:
- Scope validation (agent stays in assigned dirs)
- Commit message format enforcement

## Data Flow

```
┌─────────────────────────────────┐
│  Orchestrator (main session)   │
│  invokes /spawn, /monitor, etc │
└────────────────┬────────────────┘
                 │ Task tool (background)
                 ▼
┌─────────────────┐     ┌─────────────────┐
│  Agent A        │     │  Agent B        │
│  (worktree-a)   │     │  (worktree-b)   │
└────────┬────────┘     └────────┬────────┘
         │                       │
         ▼                       ▼
   .agent/status.json      .agent/status.json
   git commits (wip:, checkpoint:, complete:)
         │                       │
         └───────────┬───────────┘
                     │ /monitor reads
                     ▼
              Status summary
```

## Worktree Convention

```
~/projects/
├── my-repo/                    # main repo
├── my-repo--agent-a/           # worktree for agent A
│   └── .agent/
│       ├── status.json
│       └── config.yaml
└── my-repo--agent-b/           # worktree for agent B
```

## Monitoring Approach (Lightweight)

Orchestrator relies on two sources:

### 1. Agent-written status (`.agent/status.json`)
- Agent updates on each significant action
- Orchestrator reads via `/monitor`
- Low context cost

### 2. Git history
- Checkpoint commits: `git log --oneline`
- Code changes: `git diff <checkpoint>..HEAD`
- Reliable, doesn't depend on agent writing status

### What orchestrator does NOT access
- Agent transcripts (too verbose)
- Task output files (only on completion/error)

### Implication
Agents must be instructed to:
- Update status.json frequently
- Use semantic commit prefixes (`wip:`, `checkpoint:`, `complete:`)
- Write meaningful progress summaries

This discipline is enforced via the agent template's system prompt.

## Status Schema

```json
{
  "agent_id": "abc123",
  "agent_type": "worker",
  "status": "running|completed|failed|blocked",
  "task": "Implement feature X",
  "progress": "3/5 subtasks complete",
  "last_checkpoint": "abc1234",
  "started_at": "2026-02-08T10:00:00Z",
  "updated_at": "2026-02-08T10:30:00Z"
}
```
