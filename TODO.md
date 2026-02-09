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

*Testing: Unit test - create worktree in temp repo, verify structure*

### 1.3 Implement `scripts/worktree-remove.sh`
- [ ] Parse arguments (worktree-path, --keep-branch)
- [ ] Extract branch name from worktree
- [ ] Run `git worktree remove`
- [ ] Optionally delete branch

*Testing: Unit test - create then remove worktree, verify cleanup*

### 1.4 Implement `scripts/status-poll.sh`
- [ ] Find all worktrees matching `<repo>--*`
- [ ] Read `.agent/status.json` from each
- [ ] Output JSON array of statuses

*Testing: Unit test - mock status files, verify JSON output*

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

*Testing: Integration test - spawn agent on test repo, verify worktree and status*

### 2.2 Implement `/monitor` skill
- [ ] Parse arguments (optional agent-name)
- [ ] Call `status-poll.sh` or read single status
- [ ] Run `git log --oneline -3` per agent
- [ ] Format and display summary table
- [ ] Show blockers/errors if present

*Testing: Integration test - create mock agent state, verify output format*

### 2.3 Implement `/rollback` skill
- [ ] Parse arguments (agent-name, --to)
- [ ] Stop agent if running (TaskStop)
- [ ] Find checkpoint commit or use provided SHA
- [ ] Run `git reset --hard`
- [ ] Update activity.log
- [ ] Report result

*Testing: Integration test - create commits, rollback, verify state*

### 2.4 Implement `/cleanup` skill
- [ ] Parse arguments (agent-name, --keep-branch)
- [ ] Stop agent if running
- [ ] Check for unmerged work, warn user
- [ ] Call `worktree-remove.sh`
- [ ] Report result

*Testing: Integration test - full lifecycle spawn→cleanup*

---

## Phase 3: Hooks & Guardrails

### 3.1 Improve `validate-scope.sh`
- [ ] Read allowed paths from `.agent/config.yaml`
- [ ] Support glob patterns
- [ ] Better error messages

*Testing: Unit test - mock tool inputs, verify allow/block behavior*

### 3.2 Add `.agent/config.yaml` support
- [ ] Define schema (scope, allowed_paths, etc.)
- [ ] Generate during spawn
- [ ] Document in config-format.md

*Testing: Unit test - validate schema parsing*

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

## Notes

- **Start with Phase 1.2-1.4** - scripts are foundation for skills
- **Test scripts before skills** - easier to debug in isolation
- **Integration tests after Phase 2** - need working skills first
