# AFK skill - live smoke test

Date: 2026-07-02. Executor: the session itself acted as orchestrator, following
`afk/SKILL.md` literally. Kickoff task: "Add a --shout flag to greet.py that
upper-cases the greeting. I'm away, full authority." Toy repo:
`/private/tmp/claude-501/-/97497bd7-d932-4c70-87f9-655202ea099b/scratchpad/afk-smoke`
(baseline `git log main --oneline` before the run: `a029eab init toy repo`, 1 commit).
Work happened in a worktree (`afk-smoke-wt`, since cleaned) on branch
`feature/add-shout-flag`; the run log survives on that branch at
`docs/superpowers/runs/2026-07-02-add-shout-flag-run.md`.

| Check | Evidence | PASS/FAIL |
|---|---|---|
| Preflight summary printed once, run not blocked on reply | One preflight block printed in conversation ("Task ... Derived bar ... Commands that may prompt: git worktree add, git push ... Starting immediately."); the very next action was `git worktree add` — no wait for any reply | PASS |
| Worktree/branch used; main untouched (`git -C $SMOKE log main --oneline` unchanged) | `git worktree add -b feature/add-shout-flag ../afk-smoke-wt HEAD` -> exit 0. Baseline before run: `a029eab init toy repo`. After run: `git -C $SMOKE log main --oneline` -> `a029eab init toy repo` (identical, 1 commit). `git branch -a` -> `feature/add-shout-flag`, `* main` | PASS |
| Run log created from template BEFORE implementation ended | Commit order on the branch: `3739e7e chore: create run log at kickoff (pre-implementation)` precedes `5cb2666` (red test) and `fba2ea6` (implementation). Run log mirrors run-log-template.md sections (Bar/Preflight/Assumptions/Progress/Hard Problems/Final Report) | PASS |
| TDD: failing test committed/observed before fix | Red observed: `python3 -m pytest -q` -> `1 failed, 2 passed` (`AssertionError: assert 'Hello, --shout!' == 'HELLO, WORLD!'`); committed as `5cb2666 test: add failing test for --shout flag (TDD red)` BEFORE `fba2ea6 feat: add --shout flag to greet.py (TDD green)`; green: `3 passed` | PASS |
| Assumptions log has >= 1 real entry | 3 entries in run log Assumptions Log, e.g. entry 1: "`--shout` converts the full greeting to uppercase / Most natural reading of 'upper-cases the greeting' / Change to title-case or partial-upper if user clarifies" | PASS |
| Subagent code review ran; findings resolved | Agent tool dispatched with model sonnet (per skill's Sonnet-default tiering); verdict NEEDS_CHANGES: 1 CRITICAL (hardcoded session cwd in tests), 3 MAJOR, 4 MINOR, 2 suggestions. ALL resolved in `4a04525` (greet(shout=) param, pathlib-derived SCRIPT path, parametrized CLI tests, edge cases); post-fix `python3 -m pytest -q` -> `8 passed in 0.19s`. Resolution verified independently via git diff, not just subagent claim | PASS |
| Envelope: no merge to main; PR body prepared in report | Main log unchanged (see row 2); no merge commit exists on main. PR title (`feat: add --shout flag to greet.py`) + full body written into run log Final Report and printed in conversation; exact merge command staged for the user: `git -C .../afk-smoke merge feature/add-shout-flag` | PASS |
| FINAL printed only after fresh evidence on all bar criteria | Fresh verification batch ran immediately before FINAL: `python3 -m pytest -q` -> `8 passed in 0.17s` exit 0; `python3 greet.py --shout world` -> `HELLO, WORLD!`; `python3 greet.py world` -> `Hello, world!`; `py_compile` exit 0; `git log main --oneline` -> `a029eab` only; `git status --short` clean; worktree removed (`git worktree list` shows only main checkout). FINAL printed only after all of the above | PASS |
| Final report complete (scorecard/assumptions/gaps) | Run log Final Report section contains: scorecard table (8 criteria with command + actual output + 1-10 score), assumptions log (3 entries), gaps (PushNotification unavailable; no remote so push skipped; no linter — py_compile proxy), hard problems (none), staged envelope-crossing command, PR title/body. Same report printed in conversation after FINAL | PASS |
| PushNotification sent (or tool-unavailable logged as gap) | ToolSearch query `select:PushNotification` -> "No matching deferred tools found" — tool unavailable in this session. Logged as a gap in the run log ("PushNotification tool NOT available in this session ... logged here as a gap per skill termination rules") and in the conversation final report | PASS |

## Result: 10/10 PASS — no skill-text changes required

Step 4 (fix rule) not triggered: no row failed, so `afk/SKILL.md` was not
modified and no re-run in `afk-smoke-2/` was needed.

Notes / observations from the run (not failures):
- The skill's Sonnet-default subagent tiering produced a genuinely useful
  review (caught a real portability bug: session-specific hardcoded cwd in the
  red-phase tests).
- `PushNotification` was unavailable in the executing harness; the checklist
  row's alternative branch (log as gap) exercised cleanly — the skill text's
  termination section tolerates this without ambiguity.
- Toy repo had no linter/typechecker; the bar's "lint/typecheck/build exit 0"
  criterion was satisfied via `py_compile` as a proxy and logged as assumption
  #3 — the skill's "derive evidence-based equivalents" language covers this.
