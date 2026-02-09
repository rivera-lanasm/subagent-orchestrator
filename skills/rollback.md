---
name: rollback
description: Reset agent worktree to last checkpoint
arguments:
  - name: agent-name
    required: true
    description: Agent to rollback
  - name: to
    required: false
    description: Specific commit SHA (defaults to last checkpoint)
---
# /rollback

TODO: Implement rollback skill

## Steps
1. Verify agent exists and worktree present
2. Stop agent if running (TaskStop)
3. Find target commit:
   - If --to: use provided SHA
   - Else: git log --oneline --grep="checkpoint:" -1
4. Reset: git reset --hard <sha>
5. Clear .agent/status.json (or mark stale)
6. Append to .agent/activity.log: [ROLLBACK] to <sha>
7. Report result
