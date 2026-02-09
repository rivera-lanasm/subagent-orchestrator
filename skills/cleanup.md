---
name: cleanup
description: Remove agent worktree and branch
arguments:
  - name: agent-name
    required: true
    description: Agent to clean up
  - name: keep-branch
    required: false
    description: Preserve branch for later merge
---
# /cleanup

TODO: Implement cleanup skill

## Steps
1. Verify agent exists
2. Stop agent if running (TaskStop)
3. Check for unmerged work - warn if completed but not merged
4. Remove worktree: git worktree remove <path>
5. Unless --keep-branch: delete branch git branch -d agent/<agent-name>
6. Report result
