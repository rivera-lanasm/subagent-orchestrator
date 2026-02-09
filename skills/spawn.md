---
name: spawn
description: Create worktree and deploy a subagent
arguments:
  - name: agent-type
    required: true
    description: Agent template name (e.g., worker)
  - name: task
    required: true
    description: Task description for agent
  - name: test
    required: false
    description: Success criteria command
---
# /spawn

TODO: Implement spawn skill

## Steps
1. Validate agent template exists in agents/
2. Generate unique agent name: <type>-<short-id>
3. Create branch: agent/<agent-name>
4. Create worktree: <repo>--<agent-name>/
5. Create .agent/ directory in worktree
6. Initialize .agent/status.json
7. Initialize empty .agent/activity.log
8. Spawn agent via Task tool with run_in_background: true
9. Return agent ID and worktree path
