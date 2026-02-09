# Communication

Lightweight status reporting between agents and orchestrator.

## Principles

- Agents write, orchestrator reads
- No direct agent-to-agent communication
- Git as source of truth for code state
- Status file as source of truth for agent state
- Success criteria define "done"

## Agent → Orchestrator

### Status File (`.agent/status.json`)

Agent updates after each significant action:

```json
{
  "agent_id": "abc123",
  "agent_type": "worker",
  "status": "running",
  "task": "Implement auth middleware",
  "success_criteria": {
    "type": "test",
    "command": "npm test -- --grep 'auth middleware'",
    "passed": false
  },
  "progress": "2/4: Writing tests",
  "last_checkpoint": "a1b2c3d",
  "notes": "Auth service uses non-standard token format. Adapting approach.",
  "blockers": [],
  "findings": [
    "Found existing auth helper at src/utils/auth.ts",
    "Token refresh handled in src/services/token.ts"
  ],
  "warnings": [],
  "errors": [],
  "started_at": "2026-02-08T10:00:00Z",
  "updated_at": "2026-02-08T10:45:00Z"
}
```

### Field Reference

| Field | Type | Purpose |
|-------|------|---------|
| `status` | string | Current state (see values below) |
| `success_criteria` | object | Definition of done |
| `success_criteria.type` | string | `test`, `build`, `lint`, or `manual` |
| `success_criteria.command` | string | Command to verify success |
| `success_criteria.passed` | boolean | Whether criteria met |
| `progress` | string | Short progress indicator |
| `notes` | string | Free-form context, observations |
| `blockers` | array | Issues preventing progress |
| `findings` | array | Discoveries relevant to task |
| `warnings` | array | Concerns for orchestrator/user |
| `errors` | array | Out-of-scope failures agent cannot resolve |

### Status Values

| Status | Meaning | Orchestrator action |
|--------|---------|---------------------|
| `running` | Actively working | Monitor |
| `blocked` | Needs input, check `blockers` or `errors` | Intervene or provide guidance |
| `completed` | Task finished, `success_criteria.passed: true` | Review and merge |
| `failed` | Task failed, see `notes` and `errors` | Investigate, rollback if needed |

### Activity Log (`.agent/activity.log`)

Append-only log for audit trail:

```
2026-02-08T10:00:00Z [START] Task: Implement auth middleware
2026-02-08T10:05:00Z [READ] src/utils/auth.ts
2026-02-08T10:10:00Z [FINDING] Existing token service at src/services/token.ts
2026-02-08T10:20:00Z [COMMIT] wip: add middleware skeleton
2026-02-08T10:30:00Z [TEST] npm test -- PASS
2026-02-08T10:35:00Z [COMMIT] checkpoint: middleware + tests passing
2026-02-08T10:40:00Z [ERROR] Database connection timeout - out of scope
2026-02-08T10:40:00Z [STATUS] blocked
```

### Error Handling

When agent encounters out-of-scope failure:
1. Add to `errors` array with context
2. Update status to `blocked` or `failed`
3. Log to activity.log
4. Do not attempt to fix outside scope

Example error entry:
```json
{
  "type": "out_of_scope",
  "message": "Database connection timeout in test environment",
  "context": "Occurred while running integration tests",
  "timestamp": "2026-02-08T10:40:00Z"
}
```

### Git Commits

Commits provide code-level progress:
- `wip:` commits show incremental work
- `checkpoint:` commits mark stable states
- `complete:` commits signal finished work

## Orchestrator → Agent

Limited to initial configuration:
- Task description (injected at spawn)
- Success criteria (injected at spawn)
- Scope boundaries (in agent template)
- Status file path (convention: `.agent/status.json`)

Orchestrator cannot send messages to running agents.

## Orchestrator Controls

### Monitor (`/monitor`)
- Read `.agent/status.json` from each worktree
- Show `git log --oneline -5` per agent
- Surface blockers, warnings, and errors
- Show success criteria status
- Display summary table of all agents

### Terminate
- `TaskStop` to kill agent process
- Agent may leave incomplete state
- Use rollback if needed

### Rollback (`/rollback`)
- Find last checkpoint: `git log --grep="checkpoint:"`
- Reset: `git reset --hard <sha>`
- Status file becomes stale (orchestrator can delete)

### Cleanup (`/cleanup`)
- Remove worktree: `git worktree remove <path>`
- Delete branch: `git branch -d <branch>`
- Remove from active agents list

## Example Flow

```
1. User: /spawn worker --task "Add auth middleware" --test "npm test -- --grep auth"
2. Orchestrator: creates worktree, inits status.json with success_criteria, spawns agent
3. Agent: logs [START], updates status.json
   - status: "running"
   - progress: "1/4: Reading codebase"
4. Agent: logs [READ], [FINDING]
   - findings: ["Found auth helper at src/utils/auth.ts"]
5. Agent: commits "wip: add middleware skeleton", logs [COMMIT]
6. Agent: runs tests, logs [TEST]
   - success_criteria.passed: false (still writing)
7. Agent: commits "checkpoint: middleware + tests passing", logs [COMMIT]
   - success_criteria.passed: true
8. User: /monitor → sees status table, success criteria passing
9. Agent: updates status.json → status: "completed"
10. Agent: commits "complete: auth middleware done"
11. User: reviews, merges, runs /cleanup worker
```
