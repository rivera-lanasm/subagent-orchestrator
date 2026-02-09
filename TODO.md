# TODO

## Phase 1: Foundation

### 1.1 Initialize git repo ✓
- [x] `git init`
- [x] Create `.gitignore`
- [x] Initial commit
- [x] Push to GitHub remote

*Testing: None needed*

### 1.2 Implement `scripts/worktree-create.sh`
- [ ] Parse arguments (repo-path, agent-name)
- [ ] Create branch `agent/<agent-name>`
- [ ] Create worktree `<repo>--<agent-name>/`
- [ ] Create `.agent/` directory
- [ ] Initialize `.agent/status.json` with template
- [ ] Initialize empty `.agent/activity.log`
- [ ] Return worktree path

*Testing:*
- Unit: `./worktree-create.sh ~/projects/telefunken-sim worker-test`
- Verify: worktree exists, .agent/status.json valid, activity.log created
- Cleanup: manually remove worktree after test

### 1.3 Implement `scripts/worktree-remove.sh`
- [ ] Parse arguments (worktree-path, --keep-branch)
- [ ] Extract branch name from worktree
- [ ] Run `git worktree remove`
- [ ] Optionally delete branch

*Testing:*
- Unit: create worktree on telefunken-sim, then remove with script
- Verify: worktree gone, branch deleted (or kept with --keep-branch)
- Test both flag states

### 1.4 Implement `scripts/status-poll.sh`
- [ ] Find all worktrees matching `<repo>--*`
- [ ] Read `.agent/status.json` from each
- [ ] Output JSON array of statuses

*Testing:*
- Unit: create 2-3 worktrees on telefunken-sim with mock status.json
- Verify: JSON output contains all agents with correct fields
- Cleanup: remove test worktrees

---

## Phase 2: Core Skills

### 2.1 Implement `/spawn` skill
- [ ] Parse arguments (agent-type, --task, --test)
- [ ] Validate agent template exists
- [ ] Generate unique agent ID
- [ ] Call `worktree-create.sh`
- [ ] Inject task and success_criteria into status.json
- [ ] Spawn agent via Task tool with `run_in_background: true`
- [ ] Return agent info to user

*Testing:*
- Integration: `/spawn worker --task "Create card data model" --test "npm test"`
- Target: telefunken-sim
- Verify: worktree created, agent running, status.json has task/success_criteria

### 2.2 Implement `/monitor` skill
- [ ] Parse arguments (optional agent-name)
- [ ] Call `status-poll.sh` or read single status
- [ ] Run `git log --oneline -3` per agent
- [ ] Format and display summary table
- [ ] Show blockers/errors if present

*Testing:*
- Integration: spawn 2 agents on telefunken-sim, run `/monitor`
- Verify: table shows both agents, status accurate
- Test: `/monitor <agent-name>` shows detailed view

### 2.3 Implement `/rollback` skill
- [ ] Parse arguments (agent-name, --to)
- [ ] Stop agent if running (TaskStop)
- [ ] Find checkpoint commit or use provided SHA
- [ ] Run `git reset --hard`
- [ ] Update activity.log
- [ ] Report result

*Testing:*
- Integration: spawn agent, manually create checkpoint commit in worktree
- Run `/rollback <agent>`, verify reset to checkpoint
- Verify: activity.log shows rollback entry

### 2.4 Implement `/cleanup` skill
- [ ] Parse arguments (agent-name, --keep-branch)
- [ ] Stop agent if running
- [ ] Check for unmerged work, warn user
- [ ] Call `worktree-remove.sh`
- [ ] Report result

*Testing:*
- Integration: spawn agent, manually complete task, run `/cleanup`
- Verify: worktree removed, branch removed (unless --keep-branch)
- Test: warning appears if unmerged commits exist

---

## Phase 3: Hooks & Guardrails

### 3.1 Improve `validate-scope.sh`
- [ ] Read allowed paths from `.agent/config.yaml`
- [ ] Support glob patterns
- [ ] Better error messages

*Testing:*
- Unit: echo mock JSON | ./validate-scope.sh, check exit codes
- Integration: spawn agent with scope=src/, attempt write to docs/, verify blocked

### 3.2 Add `.agent/config.yaml` support
- [ ] Define schema (scope, allowed_paths, etc.)
- [ ] Generate during spawn
- [ ] Document in config-format.md

*Testing:*
- Unit: parse sample config, verify fields extracted
- Integration: spawn creates config, hooks read it correctly

---

## Phase 4: Testing Infrastructure

### 4.1 Set up test harness
- [ ] Create `tests/` directory
- [ ] Script to create temp git repo for testing
- [ ] Script to run all tests
- [ ] CI integration (GitHub Actions)

### 4.2 Write unit tests
- [ ] `test-worktree-create.sh`
- [ ] `test-worktree-remove.sh`
- [ ] `test-status-poll.sh`
- [ ] `test-hooks.sh`

### 4.3 Write integration tests
- [ ] `test-spawn-monitor.sh` - spawn agent, verify monitor output
- [ ] `test-rollback.sh` - spawn, commit, rollback, verify state
- [ ] `test-full-lifecycle.sh` - spawn → work → complete → cleanup

---

## Phase 5: Polish

### 5.1 Documentation
- [ ] Update README with final usage
- [ ] Add examples to each skill
- [ ] Document agent template customization

### 5.2 Additional agent templates
- [ ] `agents/researcher.md` - read-only exploration
- [ ] `agents/tester.md` - focused on test writing

### 5.3 Error handling
- [ ] Graceful failures in scripts
- [ ] Helpful error messages in skills
- [ ] Recovery instructions

---

## Test Bed: telefunken-sim ✓

Project initialized at `~/projects/telefunken-sim/`

Use this real project to validate orchestrator functionality:
- Manual worktree operations (Phase 1)
- First real subagent spawns (Phase 2)
- Full lifecycle testing (Phase 4)

See `testbed-telefunken.md` for project details and planned agent tasks.

---

## Notes

- **Start with Phase 1.2-1.4** - scripts are foundation for skills
- **Test scripts before skills** - easier to debug in isolation
- **Integration tests after Phase 2** - need working skills first
- **Use telefunken-sim** - validate against real project, not just mock repos
