# Test Bed: Telefunken Simulator

## Project Overview
A Svelte site for simulating the card game Telefunken.

### Features
- **Rules viewer**: Static pages displaying game rules
- **Simulation widgets**: Interactive tools to explore game scenarios
  - Hand probability calculator (odds of making contract)
  - Round simulator (play through a round with initial conditions)
  - Deck analyzer (visualize deck composition by player count)

### Tech Stack
- Svelte/SvelteKit
- TypeScript
- Vitest for testing

## Why This Works as Test Bed

1. **Clear task decomposition**
   - Static rules pages (simple, parallel)
   - Game logic module (core, testable)
   - UI widgets (depend on logic)

2. **Testable success criteria**
   - Unit tests for game logic
   - Build passes
   - Widgets render correctly

3. **Scope boundaries**
   - Rules viewer is isolated from simulator
   - Each widget is self-contained
   - Game logic has no UI dependencies

## Potential Subagent Tasks

| Agent | Task | Success Criteria |
|-------|------|------------------|
| worker-rules | Create static rules pages from markdown | Build passes, pages render |
| worker-cards | Implement card/deck data model | Unit tests pass |
| worker-combos | Implement set/run validation logic | Unit tests pass |
| worker-hand | Hand probability calculator widget | Component tests pass |
| worker-sim | Round simulation engine | Integration tests pass |

## Project Location
```
~/projects/telefunken-sim/
```

## Source Rules
See: `~/projects/telefunken/.claude/agent_docs/rules/`
