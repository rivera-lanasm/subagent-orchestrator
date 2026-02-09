# Skills

Orchestrator commands for managing subagents.

## /spawn

Create worktree, initialize status, deploy agent.

### Usage

```
/spawn <agent-type> --task "description" [--test "command"]
```

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `agent-type` | yes | Agent template name (e.g., `worker`) |
| `--task` | yes | Task description for agent |
| `--test` | no | Success criteria command |

### Examples

```
/spawn worker --task "Add auth middleware" --test "npm test -- --grep auth"
/spawn worker --task "Fix login bug #123"
```

### Flow

1. Validate agent template exists
2. Generate unique agent name: `<type>-<short-id>`
3. Create branch: `agent/<agent-name>`
4. Create worktree: `<repo>--<agent-name>/`
5. Create `.agent/` directory in worktree
6. Initialize `.agent/status.json` with:
   - agent_id, agent_type, task, success_criteria
   - status: "running"
   - timestamps
7. Initialize empty `.agent/activity.log`
8. Spawn agent via Task tool with `run_in_background: true`
9. Return agent ID and worktree path

### Output

```
Spawned agent: worker-a1b2
Worktree: ~/projects/my-app--worker-a1b2
Branch: agent/worker-a1b2
Task: Add auth middleware
Success criteria: npm test -- --grep auth
```

---

## /monitor

View status of active agents.

### Usage

```
/monitor [agent-name]
```

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `agent-name` | no | Specific agent to inspect (shows all if omitted) |

### Examples

```
/monitor                  # all agents
/monitor worker-a1b2      # specific agent
```

### Flow

1. List worktrees matching `<repo>--*` pattern
2. For each worktree:
   - Read `.agent/status.json`
   - Run `git log --oneline -3`
3. Display summary table
4. If specific agent: show full status.json and recent activity.log

### Output (all agents)

```
AGENT          STATUS     PROGRESS              SUCCESS   LAST COMMIT
worker-a1b2    running    2/4: Writing tests    pending   checkpoint: middleware working
worker-c3d4    blocked    1/3: Reading code     pending   wip: initial exploration
worker-e5f6    completed  done                  passed    complete: api endpoint added

Blockers:
- worker-c3d4: "Need clarification on API response format"
```

### Output (specific agent)

```
Agent: worker-a1b2
Status: running
Task: Add auth middleware
Progress: 2/4: Writing tests
Success: pending (npm test -- --grep auth)

Findings:
- Found existing auth helper at src/utils/auth.ts
- Token refresh handled in src/services/token.ts

Recent commits:
  a1b2c3d checkpoint: middleware working
  d4e5f6g wip: add middleware skeleton

Recent activity:
  10:30:00Z [TEST] npm test -- PASS
  10:20:00Z [COMMIT] wip: add middleware skeleton
  10:10:00Z [FINDING] Existing token service found
```

---

## /rollback

Reset agent's worktree to last checkpoint.

### Usage

```
/rollback <agent-name> [--to <commit-sha>]
```

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `agent-name` | yes | Agent to rollback |
| `--to` | no | Specific commit SHA (defaults to last checkpoint) |

### Examples

```
/rollback worker-a1b2                    # last checkpoint
/rollback worker-a1b2 --to a1b2c3d       # specific commit
```

### Flow

1. Verify agent exists and worktree present
2. Stop agent if running (TaskStop)
3. Find target commit:
   - If `--to`: use provided SHA
   - Else: `git log --oneline --grep="checkpoint:" -1`
4. Reset: `git reset --hard <sha>`
5. Clear `.agent/status.json` (or mark stale)
6. Append to `.agent/activity.log`: `[ROLLBACK] to <sha>`
7. Report result

### Output

```
Rolled back worker-a1b2
  From: d4e5f6g (wip: broken attempt)
  To:   a1b2c3d (checkpoint: middleware working)

Agent stopped. Re-spawn to continue work.
```

### If no checkpoint found

```
No checkpoint found for worker-a1b2.
Available commits:
  d4e5f6g wip: broken attempt
  e7f8g9h wip: initial skeleton

Use /rollback worker-a1b2 --to <sha> to specify.
```

---

## /cleanup

Remove agent worktree and branch.

### Usage

```
/cleanup <agent-name> [--keep-branch]
```

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `agent-name` | yes | Agent to clean up |
| `--keep-branch` | no | Preserve branch (for later merge) |

### Examples

```
/cleanup worker-a1b2                # remove worktree and branch
/cleanup worker-a1b2 --keep-branch  # remove worktree, keep branch
```

### Flow

1. Verify agent exists
2. Stop agent if running (TaskStop)
3. Check for unmerged work:
   - If `status.json` shows `completed` + `success_criteria.passed`: warn if not merged
4. Remove worktree: `git worktree remove <path>`
5. Unless `--keep-branch`: delete branch `git branch -d agent/<agent-name>`
6. Report result

### Output

```
Cleaned up worker-a1b2
  Worktree removed: ~/projects/my-app--worker-a1b2
  Branch deleted: agent/worker-a1b2
```

### Warning (unmerged work)

```
Warning: worker-a1b2 completed successfully but branch not merged.

Commits not in main:
  a1b2c3d complete: auth middleware done
  d4e5f6g checkpoint: middleware working

Proceed anyway? [y/N]
Or use: git merge agent/worker-a1b2
```
