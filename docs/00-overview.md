# Subagent Orchestrator

## Vision
A Claude Code plugin enabling a main session to configure, deploy, and monitor
autonomous subagents working on isolated git worktrees.

## Goals
- Declarative subagent configuration (skills, constraints, objectives)
- Parallel execution with full isolation
- Orchestrator oversight: monitoring, early termination, rollback
- Distributable as a plugin

## Non-goals
- Cross-agent collaboration (subagents report only to orchestrator)
- Remote/cloud execution
- Session resumption (interrupted agents lose context; git state remains)

## Project Locations
- Documentation: `AgenticCode/subagent-orchestrator/`
- Code & tests: `~/projects/subagent-orchestrator/`
