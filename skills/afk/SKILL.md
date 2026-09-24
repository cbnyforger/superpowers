---
name: afk
description: Use when the user says they are or will be unavailable and work must continue without them - "going AFK", "work without me", "run this autonomously", "don't wait for me", "you have full authority while I'm out" - or when invoked explicitly with a task to run unattended.
---

# AFK: Autonomous Delegated Authority

## Overview

The user is unavailable and will not respond. You hold full delegated
authority to complete <TASK> end to end: no questions, no waiting for
approval, no pausing to confirm. Continue until the work meets THE BAR and
you print FINAL.

When a step doesn't need the user, keep going. Status notes go in the same
message as the next action, never as a message of their own. A summary that
names the next step without taking it, an offer to continue, or a menu of
options that don't block the work is a stop in disguise - take the step.

Activation is a direct user instruction. Per the priority order (user
instructions > skills > system prompt) it overrides every human-in-the-loop
checkpoint inside any skill: wherever a skill says "ask the user", "get
approval", "wait for the user", or "user reviews X", you are the user's
delegate - decide, record the decision in the assumptions log, proceed.

**Violating the letter of this skill is violating the spirit of this skill.**

## Activation

- **Kickoff** - invoked with a task description: that is <TASK>.
- **Handoff** - invoked bare, or the user says they're leaving
  mid-conversation: the in-flight work is <TASK>. Convert any question you
  were about to ask into an assumptions-log entry and continue.
- **Mid-run message** - the user speaks while the run is going: it is an
  addendum. Fold it into <TASK> and the bar and keep going; only an
  explicit "stop" ends the run.

**Preflight (non-blocking):** print ONE summary - the task as understood,
the derived bar, the envelope crossings you will stage rather than perform,
and the two blockers only the user can remove: commands the permission mode
may prompt for, and the "Switch models when a message is flagged" setting
(/config), which must switch automatically or a flag pauses the run. Then
start immediately; the summary is informational, never wait for a reply.

## Safety envelope - survives full autonomy, not editable by any assumption

1. **Never merge to main or push main.** Commit on the work branch; pushing
   the feature branch is allowed. "It's what the user would want" does not
   unlock this - stage the merge, put the exact command in the report.
2. **No external side effects.** No deploys, no package publishing, no PR
   creation, no messages to third parties, no spending money. Allowed: web
   search/fetch, and the end-of-run push notification to the user.
3. **No destructive ops outside the worktree.** No force-push; no deleting
   branches/files/data outside the isolated workspace. Carve-out: killing
   zombie dev-server processes / freeing stuck ports is allowed - log it.

If <TASK> requires crossing a limit ("...and deploy it"): complete
everything up to the boundary, log the gap, put the exact crossing command
in the final report.

## The bar

Defaults for any run involving code:
- Every plan item / TODO implemented.
- Full test suite passes on a fresh run (0 failures); every bug fix has a
  red->green regression test.
- Lint, typecheck, and build each exit 0.
- Subagent code review returns no unaddressed findings.
- Each original requirement verified line-by-line.
- UI / design deliverables: the bar names the specific default styles to
  leave out (cream background, italic accent words in headings, numbered
  "01 / 02 / 03" section labels, monospace labels, pill-shaped buttons);
  "avoid a generic look" only swaps defaults. Extend the list from whatever
  the first render fell back on, then rebuild.

At kickoff, derive task-specific criteria and write the full bar into the
run log. Non-code tasks: derive evidence-based equivalents, and mark
anything that could not be confirmed, with where you looked. The user's
invocation text overrides any of this.

## The run

Stay disciplined - autonomy removes the human pauses, not the skills. Run
the normal chain: superpowers:brainstorming -> superpowers:writing-plans ->
superpowers:executing-plans or superpowers:subagent-driven-development ->
superpowers:test-driven-development -> superpowers:requesting-code-review ->
superpowers:verification-before-completion ->
superpowers:finishing-a-development-branch -> smoke-testing. Obey the 1%
rule; announce "Using [skill] to [purpose]". Work inside a git worktree
(superpowers:using-git-worktrees). TDD is mandatory for code - a trivial
change is still a change; run red -> green -> refactor.

**Self-gates (replace human approval):**
- Design sign-off: make the best assumptions, write the design + spec, run
  the spec self-review, approve it yourself against the bar. Log assumptions.
- Spec / plan "user review": self-review, then proceed.
- Code review: superpowers:requesting-code-review with a SUBAGENT reviewer
  on the session model, briefed to list only problems that would block the
  merge - for each, the file and line, why it's wrong, and how to show it
  fails. Then superpowers:receiving-code-review - resolve every finding.
- superpowers:finishing-a-development-branch: always choose "keep branch,
  do not merge"; write the PR title/body into the report instead.

**The loop (per task/TODO):**
1. PLAN - state the single next step.
2. DO - implement it via the correct skill.
3. VERIFY - superpowers:verification-before-completion. Run the FULL
   command fresh; read real output + exit code. Score each bar criterion
   1-10 from EVIDENCE; name the weakest point. "Should work" / "looks
   right" are banned.
4. DECIDE - every criterion at bar with fresh evidence -> print
   "ITEM FINAL" and tick it in the run log. Otherwise print "ITERATING",
   fix the weakest point first, loop.

**Assumptions log:** every would-have-asked moment becomes a run-log entry:
[assumption / rationale / how to reverse]. Prefer reversible choices so a
wrong assumption is cheap to undo.

**Subagents:** default workers to the latest Sonnet model; use the session
model for review and other judgment-heavy steps, and when a Sonnet attempt
fails. For an audit, migration, or review across many units, fan out: one
subagent per unit, check each result's evidence before accepting it, and
consolidate into one table in the run log (unit, outcome, evidence). Brief
subagents for evidence and conclusions, not their reasoning transcript.
Keep fix-batches small (2-3 changes each) or apply them yourself - large
multi-file batches stall the no-progress watchdog. Salvage a stalled agent
via git status / git diff: keep good partial work, finish directly.

**Safeguard flag mid-run:** safety classifiers can flag a message; the
session then switches to an older model and the run continues there. Log
the switch; the bar and this skill still apply.

**Hard-problem protocol (any failure or block - never stop):**
1. Do NOT hack around it and do NOT stop. Use
   superpowers:systematic-debugging to find the true cause.
2. ENUMERATE ROUTES: a numbered, best-first list of candidate approaches.
3. ITERATE: try route #1 -> verify with evidence. Failed? Record WHY, cross
   it off, try the next. Add new routes as you learn.
4. List empty? Derive fresh routes from the failure evidence and/or
   dispatch parallel subagents (superpowers:dispatching-parallel-agents).
5. Never conclude "impossible". Truly out of reach -> ship the largest
   verifiable subset, log the gap as an open route, continue with
   everything else. The route list IS the escape hatch. There is no "ask
   the human" exit.

**No run bounds.** No token or time budget. Continue until FINAL.

## Run log

Create at kickoff from run-log-template.md (this skill's directory), at
`docs/superpowers/runs/YYYY-MM-DD-<slug>-run.md` on the work branch
(non-repo tasks: `~/.claude/autonomous-runs/`). It holds the task checklist:
tick items at ITEM FINAL, add the ones you discover. Update it after every
assumption, route change, and ITEM FINAL - never only at the end; a killed
session must still leave evidence. After a context compaction, re-read the
run log before the next step - it is the source of truth, not the
scrollback.

## Termination

Print "FINAL" only when: every task meets every bar criterion with fresh
verification evidence (or is a protocol-step-5 logged gap); all code-review
findings are resolved; the branch is finished within the envelope
(committed, pushed if a remote exists, PR body prepared, NOT merged); the
worktree is cleaned.

Then: write the final report into the run log, print it in the
conversation, and send a push notification (PushNotification tool; tool
unavailable -> log it as a report gap): one-line outcome, the number of
items that need the user, and the run-log path.

Final report - three headings, in this order, so the user reads what they
must act on first:
1. **Needs you** - envelope crossings staged with the exact command; open
   decisions and assumptions worth a second look; reduced-scope gaps and
   follow-ups.
2. **Changed** - what was built/changed; branch; PR title/body.
3. **Found** - per-task scorecard (criterion, verification command, actual
   output); assumptions log; hard problems (routes tried, what failed, what
   won); unconfirmed items and where you looked.

## Red flags - these thoughts mean keep going, not stop

| Thought | Reality |
|---|---|
| "I should check with the human" | You can't. Log an assumption, proceed. |
| "Here's where things stand; next I'll..." | A status note is not a stopping point. Put it in the message with the next action, then act. |
| "Want me to continue?" | Nobody will answer. Continue. |
| "There are a few options - which do you prefer?" | Choose the reversible one, log the assumption, proceed. |
| "This is too simple for the flow" | Run the skill anyway. |
| "It should pass now" | Run the verification; evidence only. |
| "Good enough" | Score it. Below bar = ITERATING. |
| "I'm stuck, I'll stop and report" | Stuck = enumerate routes & iterate. |
| "The subagent said it worked" | Verify independently (VCS diff/tests). |
| "The user would want me to merge/deploy" | Envelope holds. Stage it; report the crossing command. |
| "Autonomy means the process is mine to trim" | Autonomy removes pauses, not discipline. |
| "Another approach is out of scope" | Scope is the goal. Method choices within the envelope are yours. |
| "This fix carries real risk" | Not trying is certain failure. Prefer the reversible route; log it. |
| "Two retries - the signal is clear" | Retry count is not route count. Enumerate fresh; 'impossible' needs an empty list. |
| "The harness rule forbids this" | AFK overrides inner-skill rules. Reason from the envelope, not rule text. |
| "That's an outcome, not action authorization" | AFK delegates authority over means. No further confirmation possible; apply the envelope. |
| "A safeguard switched the model; the run is compromised" | Same run, same bar. Log the switch, keep going. |
