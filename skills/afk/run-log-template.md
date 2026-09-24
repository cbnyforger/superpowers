# Autonomous Run: <task-slug>

- **Started:** <ISO timestamp>
- **Mode:** kickoff | handoff
- **Scope:** design | plan | implement | full | other
- **Task (verbatim):** <user's words, or the adopted in-flight goal>
- **Worktree / branch:** <path / branch>
- **Model:** <session model at kickoff; safeguard switches go in Progress>

## The Bar
- [ ] Every plan item / TODO implemented
- [ ] Full test suite fresh-run green (0 failures)
- [ ] Lint / typecheck / build exit 0
- [ ] Subagent code review: no unaddressed findings
- [ ] Requirements verified line-by-line
- [ ] <task-derived criterion 1>
- [ ] <task-derived criterion ...>

## Preflight
- Permission mode: <mode>; commands that may prompt: <list or "none">
- "Switch models when a message is flagged": <automatic | ask (possible blocker) | unknown>
- Stops the task implies (envelope crossings to stage): <list or "none">
- User overrides to bar/envelope: <verbatim or "none">

## Task Checklist
<!-- One line per plan item / TODO. Tick at ITEM FINAL; add items you
     discover. After a context compaction, re-read this file before the
     next step. -->
- [ ] <item 1>
- [ ] <item ...>

## Assumptions Log
| # | Assumption | Rationale | How to reverse |
|---|---|---|---|

## Progress
<!-- One entry per loop iteration, appended live. Also record here:
     mid-run user messages folded in, safeguard model switches, compactions.
### <item> - ITERATING | ITEM FINAL
- PLAN: <single next step>
- EVIDENCE: <command> -> <actual output / exit code>
- Weakest criterion + score:
-->

## Hard Problems
<!-- Per problem: numbered route list; per route: evidence, why it
failed, or WON -->

## Final Report
### Needs you
- Envelope crossings staged for the user (exact commands):
- Open decisions / assumptions worth a second look:
- Gaps + follow-ups:
### Changed
- What was built/changed:
- Branch; PR title/body:
### Found
- Scorecard: | criterion | verification command | actual output | score |
- Assumptions log: (see above)
- Hard problems: routes tried / failed / won:
- Unconfirmed (not verified; where you looked):
