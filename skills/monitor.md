---
name: monitor
description: View status of active subagents
arguments:
  - name: agent-name
    required: false
    description: Specific agent to inspect (shows all if omitted)
---
# /monitor

TODO: Implement monitor skill

## Steps
1. List worktrees matching <repo>--* pattern
2. For each worktree:
   - Read .agent/status.json
   - Run git log --oneline -3
3. Display summary table
4. If specific agent: show full status and recent activity.log
