# Design: `afk` — Autonomous Delegated-Authority Skill

**Date:** 2026-07-02
**Status:** Approved by user (brainstorming session)
**Deliverable:** Personal skill at `~/.claude/skills/afk/`

## Problem

From time to time the user is unavailable to respond to the orchestrator agent. Today, every human-in-the-loop checkpoint inside the superpowers chain (design approval, spec review, plan review, merge decision) becomes a hard blocker: work stops until the user returns. The user wants a skill that grants the agent full delegated authority to complete work end to end during those windows — without abandoning the discipline of the skills chain.

The user supplied an operating-context scaffold as the starting point; the Appendix records how its pieces map into this design. This design turns that scaffold into a reusable, invocable skill.

## Goals

- Work proceeds to completion with zero human input once activated.
- The normal superpowers chain still runs — only the human pauses are replaced by self-gates.
- Every decision the human would have made is logged as a reversible assumption.
- A durable, running record of the run exists even if the session dies mid-flight.
- The user is notified when the run completes.

## Non-Goals

- Mechanical enforcement of the safety envelope via hooks (Approach B — deferred until a run violates the envelope in practice).
- Auto-detecting user absence. Activation is always explicit (invocation or user statement).
- Overriding harness permission gates — impossible from a skill; handled by preflight warning instead.

## Decisions Made (with user, 2026-07-02)

| Question | Decision |
|---|---|
| Activation | Both explicit kickoff (`/afk <task>`) and mid-session AFK handoff |
| Definition of done | Default baked-in bar + task-derived additions; user prompt can override |
| Safety envelope | Three hard limits (below); everything else fair game |
| Reporting | Running report file + printed in conversation + push notification |
| Subagent model policy | Aggressive tiering: default Sonnet, escalate on failure or explicit hardness |
| Run bounds | Truly unbounded — no token/time cap; run until FINAL |
| Architecture | Approach A: single self-contained skill + run-log template |

## Design

### 1. Identity & activation

- **Location:** `~/.claude/skills/afk/` — `SKILL.md` plus `run-log-template.md`.
- **Name:** `afk`. Description triggers on: "going AFK", "work without me", "run this autonomously", "don't wait for me", "you have full authority", "I won't be available", plus explicit `/afk` invocation.
- **Kickoff mode** — `/afk <task>`: fresh autonomous run from the task description in args.
- **Handoff mode** — `/afk` bare, or the user says they're leaving mid-conversation: the in-flight work becomes `<TASK>`; any question the agent was about to ask is converted into a logged assumption; work continues without pause.
- **Activation preflight (non-blocking):** at activation the agent prints ONE summary message: (a) the task as understood, (b) the derived bar, (c) a permission check — commands the run will likely need that are not allowlisted in the current permission mode, since permission prompts are the one blocker no skill can bypass. If the user is still present they can correct it; if not, the run starts immediately. The summary is informational, never a wait-for-approval gate.

### 2. Authority grant & safety envelope

The skill states the delegation explicitly, anchored in the priority order (user instructions > skills > system prompt): wherever any skill says "ask the user", "get approval", "wait for the user", or "user reviews X", the agent acts as the user's delegate — decide, record the decision in the assumptions log, proceed.

Three hard limits survive full autonomy:

1. **No merging to main / pushing main.** Committing on the work branch and pushing the feature branch to a remote are allowed.
2. **No external side effects.** No deploys, no publishing packages, no PR creation (it notifies watchers), no messages to third parties, no posting to external services, no spending money. Explicitly allowed: web search/fetch, and the end-of-run push notification to the user.
3. **No destructive ops outside the worktree.** No force-push, no deleting branches/files/data outside the isolated workspace, no dropping databases. Explicit carve-out: killing zombie dev-server processes / freeing stuck ports is allowed and must be logged (user's port-error runbook: inspect CLI logs, identify the zombie process, kill it).

If the task inherently requires crossing a limit (e.g., "…and deploy it"), the run completes everything up to the boundary, logs the gap, and leaves the exact crossing command in the final report.

### 3. The run

- **Isolation:** all work in a git worktree (superpowers:using-git-worktrees). If the target is not a git repo, initialize one or log the isolation gap as an assumption.
- **The bar:** baked-in defaults — every plan item / TODO implemented; full test suite passes on a fresh run (0 failures) with red→green regression tests for bug fixes; lint, typecheck, and build each exit 0; subagent code review returns no unaddressed findings; each original requirement verified line-by-line — **plus** task-derived criteria written into the run log at kickoff. Non-code tasks (research, docs, ops) get evidence-based equivalents derived at kickoff. The user's invocation prompt can override any of it.
- **Skills chain, self-gated:** brainstorming (make best assumptions, self-approve design against the bar) → writing-plans (self-review, proceed) → executing-plans / subagent-driven-development → test-driven-development (mandatory red→green→refactor for code) → requesting-code-review with a subagent reviewer → receiving-code-review (resolve every finding) → verification-before-completion → finishing-a-development-branch (within the envelope) → smoke-testing. The 1% rule holds: if a skill might apply, invoke it; announce "Using [skill] to [purpose]".
- **The loop (per task/TODO):** PLAN (state the single next step) → DO (via the correct skill) → VERIFY (run the full command fresh; read real output and exit code; score each bar criterion 1–10 from evidence, name the weakest point; "should work" is banned) → DECIDE (all criteria at bar with fresh evidence → print "ITEM FINAL"; otherwise print "ITERATING", fix the weakest point first, loop).
- **Assumptions log:** every would-have-asked moment becomes an entry — assumption · rationale · how to reverse. Prefer reversible choices.
- **Hard-problem protocol:** on any failure or block — systematic-debugging / root-cause-tracing for true cause; enumerate a numbered best-first route list; iterate routes with evidence, recording why each failed; derive fresh routes from failure evidence or dispatch parallel subagents when the list empties; never conclude "impossible" — worst case, ship the largest verifiable subset with open routes logged and continue with everything else.
- **Run bounds:** none. No token or time cap; the run continues until FINAL.
- **Model tiering (aggressive):** subagents default to the latest Sonnet model; escalate to the session model only when a subagent attempt fails or a step is explicitly judgment-heavy.
- **Baked-in operational lessons:**
  - Subagent fix-batches stay small (2–3 changes each) or the orchestrator applies them directly — large multi-file batches stall the 600s watchdog (memory: sdd-large-fix-batches-stall). Salvage stalled agents via `git status` / `git diff`; keep good partial work, finish directly.
  - Server port errors: inspect the CLI logs, identify and kill the zombie process, log the action.

### 4. Run log & termination

- **Run log:** created at kickoff from `run-log-template.md`, updated *throughout* the run (never only at the end) so a killed session still leaves evidence. Contents: task, bar (default + derived), assumptions log, hard-problem route lists, per-item verification evidence, final report.
- **Location:** `docs/superpowers/runs/YYYY-MM-DD-<slug>-run.md` committed on the work branch; fallback `~/.claude/autonomous-runs/` for non-repo tasks.
- **Termination:** print "FINAL" only when every task meets every bar criterion with fresh verification evidence, all code-review findings are resolved, and the branch is finished within the envelope — branch committed (pushed if a remote exists), PR title/body prepared in the report, **not** merged, worktree cleaned per finishing-a-development-branch.
- **Final report** (in run log + printed in conversation): what was built/changed; per-task scorecard with each bar criterion, the verification command, and its actual output; assumptions log; hard problems (routes tried, what failed, what won); reduced-scope gaps + suggested follow-ups.
- **Notification:** PushNotification with a one-line outcome + the report path.

### Anti-rationalization table (carried from scaffold)

| Thought | Reality |
|---|---|
| "I should check with the human" | You can't. Log an assumption, proceed. |
| "This is too simple for the flow" | Run the skill anyway. |
| "It should pass now" | Run the verification; evidence only. |
| "Good enough" | Score it. Below bar = ITERATING. |
| "I'm stuck, I'll stop and report" | Stuck = enumerate routes & iterate. |
| "The subagent said it worked" | Verify independently (VCS diff/tests). |

## Testing

Per superpowers:writing-skills, the skill is validated by:
1. **Structural checks:** valid frontmatter (name + description only), name matches directory, description states triggers, word counts within norms.
2. **Scenario walkthroughs (subagent-based):** dispatch subagents given the skill text plus a scenario transcript, and check the chosen behavior: (a) kickoff with task args produces preflight summary + run start without questions; (b) mid-session "going AFK" converts pending question to assumption and continues; (c) a task that requires deploy stops at the envelope and prepares the crossing command; (d) a blocked step produces a route list rather than a stop.
3. **Live smoke test:** invoke `/afk` on a small real task end to end and verify run log, envelope compliance, FINAL, report, and notification.

## Appendix: mapping from the user's scaffold

The user-provided operating-context scaffold (delivered in the requesting conversation, 2026-07-02) is the source text for the skill's authority grant, loop, self-gates, assumptions log, hard-problem protocol, termination, final report, and anti-rationalization sections. Its `<TASK>` placeholder is filled by activation args or in-flight context; its `<THE BAR>` placeholder is replaced by the default-bar-plus-derived-criteria mechanism above.
