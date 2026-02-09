# Config Format

Basic subagent template format for orchestrator-managed agents.
See [[reference-subagents]] for full Claude Code options.

## Minimal Template

```yaml
---
name: worker
description: General-purpose worker agent. Use for isolated tasks on a worktree.
tools: Read, Edit, Write, Bash, Grep, Glob
model: sonnet
---
You are a worker agent managed by an orchestrator.

## Status Reporting
Update `.agent/status.json` after each significant action:
- When starting a subtask
- When completing a subtask
- When blocked or encountering errors

## Git Discipline
- Commit frequently with prefixes:
  - `wip:` - work in progress
  - `checkpoint:` - stable state, safe to rollback here
  - `complete:` - task finished
- Never force-push or rebase
- Stay on your assigned branch

## Scope
Only modify files relevant to your assigned task.
Do not modify files outside your designated scope.
```

## Adding Hooks

For scope validation, add a `PreToolUse` hook:

```yaml
---
name: scoped-worker
description: Worker agent with scope enforcement
tools: Read, Edit, Write, Bash, Grep, Glob
model: sonnet
hooks:
  PreToolUse:
    - matcher: "Edit|Write"
      hooks:
        - type: command
          command: ".agent/validate-scope.sh"
---
```

The validation script receives JSON via stdin with the file path in `tool_input`. Exit code 2 blocks the operation.

## Required Fields for Orchestrator

| Field | Purpose |
|-------|---------|
| `name` | Worktree naming, status tracking |
| `description` | Orchestrator knows when to suggest this agent |
| `tools` | Must include Read, Write for status.json |
| `model` | Cost/capability trade-off |

## Status Schema (agent must write)

Path: `.agent/status.json`

```json
{
  "agent_id": "<injected by spawner>",
  "agent_type": "<from template name>",
  "status": "running",
  "task": "<injected by spawner>",
  "progress": "Starting...",
  "last_checkpoint": null,
  "started_at": "<injected by spawner>",
  "updated_at": "<agent updates>"
}
```

Spawner creates initial file; agent updates `status`, `progress`, `last_checkpoint`, `updated_at`.
