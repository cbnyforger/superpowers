# Smoke Testing Skill — Design Spec (Enhanced v2.1)

**Date:** 2026-06-14
**Status:** Approved for Implementation Planning
**Version:** 2.1 (Peer review integration — execution robustness focus)
**Target collection:** `superpowers` (net-new skill)
**Install location:** `~/.claude/skills/smoke-testing/`

---

## 1. Purpose & Positioning

A `smoke-testing` skill that drives a **broad, shallow, end-to-end pass over a freshly-built feature** to confirm the assembled thing actually runs — before anyone claims it works. Test cases are **derived from the feature's spec and implementation-plan artifacts** (falling back to the git diff and memory when artifacts are absent or stale), so that **no newly-built scope item goes unexercised**. Each scope item receives one happy path and one representative high-value failure path (negative testing). The deliverable is a **human-reviewable checklist `.md`** that, once approved, the agent executes live and turns into a **handoff-ready Smoke Test Report** with structured defects payload.

### Core Principle (First-Principles Hook)

> Passing unit tests prove the pieces work in isolation. Smoke testing proves the assembled thing turns on and stays on under representative stress. **If you never ran the feature end-to-end with observed evidence, you don't know that it works — you only know your mocks and assumptions agree with each other.**

### Name & Description (Trigger-Only)

- **Name:** `smoke-testing` (gerund/active voice).
- **Description (trigger-only):**
  > Use when a feature or change has just been built and you need to confirm the assembled thing actually runs end-to-end before claiming it works — broad shallow pass over every built capability, derived from the spec and plan, including one high-value failure path per scope item.

### Boundary vs. Neighboring Skills

| Skill | Question it answers | Depth × Breadth | Timing | Relationship to Smoke Testing |
|------------------------------|----------------------------------------------|----------------------|-----------------|-------------------------------|
| `test-driven-development` | Does *this unit* do the right thing? | deep × narrow, automated | **before** code | Precedes; smoke is post-build integration gate |
| **`smoke-testing`** | Does the *whole built feature* turn on? | **shallow × broad, run live** | **after build** | The missing "turn it on and watch every light come on" gate |
| `verification-before-completion` | Did I *run the command* before claiming? | the discipline | smoke produces evidence it demands | Consumes smoke report (concrete contract: report path + verdict) |
| `requesting-code-review` | Is the *code* good? | reads code | independent | Complements; smoke runs code |
| `systematic-debugging` | Why did this specific check fail? | deep × narrow | after FAIL/BLOCKED | Receives structured defects from smoke |

**Lifecycle position:** Fires after implementation is complete and **feeds** `verification-before-completion` → `finishing-a-development-branch`. It is the mandatory "build verification test" gate.

---

## 2. Architecture

```
smoke-testing/
  SKILL.md               # process + discipline + first-principles + prompting rubrics
  checklist-template.md  # the reusable artifact (with evidence rules, S0 block, new columns)
```

**On-disk storage:**
- Reports: `docs/superpowers/smoke-tests/YYYY-MM-DD-<feature-slug>-smoke-test.md` (or `-vN.md`)
- Evidence: `docs/superpowers/smoke-tests/YYYY-MM-DD-<feature-slug>/evidence/`

---

## 3. Workflow (The Process the Skill Drives)

**Human approval is a HARD STOP before any live execution (except S0, which may run pre-approval — see Step 0).**

**Step 0: Establish runnable environment & S0 boot check (mandatory first gate)**
Before any scope-item work, confirm the thing can even turn on.
- Discover / document build, serve, login, base URL, and test data setup (this populates the "Environment / How to Run" block).
- Run S0: Execute the minimal commands to build/boot/serve the feature (or the whole app).
- Capture evidence that the application is reachable and starts without critical errors.
- **If S0 fails → verdict = BLOCKED.** All downstream checks are meaningless. Short-circuit and hand off immediately.

S0 may run before the human review gate because booting is non-destructive (build/serve only, no feature actions, no state mutation) and is required to populate the Environment block and confirm the feature is testable. In fully unattended/orchestration mode, all checks run without a human. Environment setup actions (installing deps, setting test env vars, seeding a test DB with synthetic data) are **explicitly allowed** and distinct from code changes. "Couldn't establish runnable environment" → BLOCKED. "Ran and behaved wrong" → FAIL.

**Step 1: Locate inputs.** Find spec + plan. Fall back to `git diff` if absent/stale and warn (coverage is best-effort). Detect staleness heuristically: if diff touches surfaces the spec/plan do not mention, treat artifacts as partial and warn.

**Step 2: Extract scope items.** Enumerate every built capability from spec sections + plan Task headers (and significant distinct user-facing sub-behaviors). Assign traceability tags.

**Step 3: Coverage cross-check (four sources) + prioritization.** Reconcile against Spec, Plan, Git diff, and Memory. Flag UNCOVERED/RISK.
Declare memory source status in the Coverage Map: `memory: consulted` or `memory: unavailable`.
Propose **Core Smoke** (must-run) vs **Extended Smoke**. Human can adjust in review gate.
**Proportionality note:** Smoke breadth should scale to the diff's blast radius. A one-line change still gets S0 + the surfaces it touches, not a full 60-check sweep.

**Step 4: Draft the checklist.** Instantiate template. For each scope item: one happy path + one high-value negative. Apply check-writing rubric. Use prerequisite column for dependencies.

**Step 5: Human review gate (HARD STOP).** Human edits, promotes/demotes Core/Extended, approves. Nothing (beyond S0) executes before approval.

**Step 6: Execute live.**
- Run checks (S0 first, then Core, then Extended).
- Capture **raw quoted evidence** in Actual column.
- Derive Status from whether Actual literally contains/matches the Expected observable.
- Use `BLOCKED` status for checks that cannot run due to upstream failure (via Prerequisite column).
- **If primary UI tool (Chrome DevTools MCP) is unavailable:** Mark all UI-dependent checks as BLOCKED (flows to BLOCKED verdict). Do not silently skip or use banned alternatives.
- Write the report file **incrementally** after each check or logical group (resumable, survives context compaction).
- For very large checklists (30+ scope items), consider dispatching execution breadth to a subagent while the main agent maintains the report.

**Step 7: Produce report & machine-readable summary.** Fill results, populate Defects (only true FAIL items), compute verdict using the four-state model, append JSON summary for orchestrators.

**Step 8: Handoff.** On BLOCKED or FAIL → hand off report (no fixes). On PASS / PASS-WITH-GAPS → hand off to `verification-before-completion`.

---

## 4. Responsibility Boundary: Detect & Report, Never Fix

The skill **detects and reports** defects. It treats the **codebase as read-only** for code changes. Environment setup and ephemeral test data/fixtures are allowed and encouraged when necessary to achieve a runnable state.

**On BLOCKED / FAIL:** Return the report. Stop. Hand off. No autonomous code edits.

**Re-running:** Re-run fresh (or delta) after fixes by others. Fresh observed evidence is always required for a PASS verdict.

---

## 5. Evidence Standards & Checks Table Rules (Mandatory)

**Core rule (anti-gaming):** The `Actual` column must contain **raw quoted evidence** from tool output, screenshot description, console, response body, etc. `Status` is **derived** — a check can only be PASS if the quoted Actual literally demonstrates the Expected observable result. The model must not infer or summarize success.

**Updated Checks table columns (in template):**

| ID | Scope item (trace) | Prerequisite | Type | Steps / Command | Expected observable result | Actual (raw quoted evidence — quote it) | Status | Evidence artifact |
|----|--------------------|--------------|------|-----------------|----------------------------|-----------------------------------------|--------|-------------------|
| S0 | Boot / Environment | — | boot | `npm run build && npm run dev` or equivalent | App serves on :3000 with no critical startup errors | "Server listening on http://localhost:3000" + console excerpt | PASS / BLOCKED | screenshot or log |
| S1 | ... | S0 | happy | ... | ... | "HTTP/1.1 200 ... {\"user\":\"...\"}" | PASS | ... |
| S2 | ... | S1 | negative | ... | rejected with HTTP 401 + "invalid token" | "HTTP/1.1 401 ... {\"error\":\"invalid token\"}" | PASS | ... |

**Status values & semantics:**
- **PASS**: Raw evidence in Actual confirms the Expected observable.
- **FAIL**: Raw evidence shows the behavior did not match Expected (and it was not blocked upstream).
- **BLOCKED**: Could not execute because a prerequisite check failed or environment/tool was unavailable. Does not count as a new defect.
- **PENDING-HUMAN**: Human-only visual/UX judgment required. Contributes to PASS-WITH-GAPS.

**Negative-test generation support (in template/SKILL.md):** Include a small taxonomy by surface type to reduce LLM judgment errors:
- Auth endpoint → expired / missing / malformed token
- Form input → empty required, wrong type, oversized, SQL injection attempt (if in scope)
- Resource fetch → nonexistent ID → graceful 404 / clear error (no crash or data leak)
- File upload → wrong MIME, zero-byte, oversize
- CLI → missing required flag, conflicting flags

---

## 6. Verdict States (Four-State Model)

**PASS** — All executed checks passed with raw evidence, Core coverage complete, no UNCOVERED high-risk items, no human-only items pending.

**PASS-WITH-GAPS** — All executed checks passed with evidence, but one or more of the following exist: UNCOVERED items remain, human-only checks are PENDING-HUMAN, or memory source was unavailable. Still a usable handoff but signals incomplete confidence.

**FAIL** — One or more checks have raw evidence showing incorrect behavior (not blocked upstream). Defects table is populated.

**BLOCKED** — S0 or critical environment/tool failure prevented meaningful observation. Or too many checks are BLOCKED by upstream failures. Report still valuable for handoff but signals "could not fully evaluate."

The verdict is computed after execution and clearly stated at the top of the report.

---

## 7. Artifact Format Updates (Key Excerpts)

**Coverage Map** now includes:
- Memory source status: `memory: consulted` or `memory: unavailable`
- Explicit Core vs Extended marking
- UNCOVERED / RISK items with source (spec/plan/diff/memory)

**Defects table** only lists true FAIL items (not BLOCKED). Root cause is clearer because of Prerequisite column.

**Machine-readable summary** at end of report (for orchestrators):
```json
{
  "verdict": "PASS|PASS-WITH-GAPS|FAIL|BLOCKED",
  "passed": 12,
  "failed": 1,
  "blocked": 2,
  "uncovered": 1,
  "human_pending": 0,
  "report_path": "...",
  "evidence_dir": "..."
}
```

**Secrets / PII rule (mandatory):** Never write real credentials, tokens, session cookies, or user PII into the report or evidence artifacts. Redact tokens in repro commands. Scrub or describe screenshots that would expose logged-in user data. Reference credentials by name only (e.g., "use test user from smoke-test.env").

---

## 8. Test Data & Lifecycle Rules

- Prefer ephemeral / synthetic test data and isolated test users/records.
- Every check (or logical group) that mutates state **must** document setup and teardown steps or use transactions/rollback where possible.
- Checks should be **idempotent** or clearly document that they are not.
- Shared persistent state mutation is discouraged for smoke tests. If unavoidable, the report must note the risk and preferred cleanup method.
- "Re-running is cheap" is only true when the above rules are followed. The skill must enforce cleanup obligations in the executed report.

---

## 9. LLM Prompting Guidelines & Quality Rubrics

`SKILL.md` must include:
- Structured extraction + self-count verification first.
- Check-writing rubric emphasizing raw evidence in Actual.
- Strong repeated guardrail: "Only mark PASS if the quoted Actual literally contains the observable described in Expected. Do not infer, summarize, or 'it looks like it worked'."
- Self-critique after drafting: coverage gaps, weak negatives, SPEC-MISMATCH risk on negative tests.
- Memory consultation + status declaration.
- Negative taxonomy examples (see §5).
- Incremental writing instruction for large runs.
- Fabrication is forbidden; uncertainty or inability to observe → BLOCKED or FAIL with exact observation recorded.

---

## 10. Re-runs, Versioning & Incremental Changes

- Use `-vN.md` naming.
- On re-run after a fix: Perform a quick delta check — did the fix's diff touch surfaces outside the existing checklist scope? If yes, regenerate affected checks before re-running.
- Always require fresh evidence for PASS.

---

## 11. Integration & Handoff Points (Concrete)

The **Smoke Test Report path + final verdict** is the feature-level evidence that `verification-before-completion` consumes. This is a concrete contract, not just a lifecycle diagram.

On BLOCKED/FAIL → primary handoff target is `systematic-debugging`.

---

## 12. Discipline Elements

**Iron Law (strengthened):**
NO "IT WORKS" CLAIM UNTIL THE THING HAS PASSED S0 (BOOT) AND EVERY BUILT SCOPE ITEM HAS BEEN RUN LIVE WITH RAW OBSERVED EVIDENCE — HAPPY PATH AND ONE HIGH-VALUE FAILURE PATH.

**Violating the letter of this rule is violating the spirit of this rule.**

**Red Flags** (including execution-time ones):
- Inferring PASS from a 200 status or clean console without quoting the matching evidence in Actual.
- Treating BLOCKED checks as silent passes.
- Skipping S0 or treating environment setup failures as "not my problem."
- Using stale spec expectations without checking for SPEC-MISMATCH.
- Writing real secrets or PII into committed artifacts.
- "I found the bug, I'll just quickly fix it" → No. Record the defect, hand off. You are the smoke tester, not the fixer.

**Common Mistakes** include the structural anti-patterns the new table columns and verdict states are designed to prevent (marking PASS off logs instead of observed behavior; testing only what you changed, not what it integrates with; skipping the negative path; defaulting to Playwright MCP for UI instead of Chrome DevTools MCP; fixing instead of reporting).

---

## 13. How the Skill Itself Is Built (TDD-for-Skills — Strengthened)

**RED phase pressure scenarios** (targeted):
- Feature that fails to boot / serve (tests S0 + BLOCKED path).
- Feature with upstream dependency failure (tests Prerequisite + BLOCKED status propagation).
- Large feature (tests incremental writing + scale).
- Stale spec vs correct implementation (tests SPEC-MISMATCH handling).
- "Trivial" change that actually breaks integration (tests proportionality + coverage).
- Environment with Chrome DevTools MCP unavailable (tests fallback).
- Previous smoke report flagged fragile area (tests memory status + elevation to Core).

**Measurable pass bar for RED → GREEN transition:**
Across at least 5–7 subagent pressure runs on features with deliberately injected integration breaks or boot failures (while unit tests pass), the skill must:
- Catch the integration/boot failure in ≥ 90% of runs.
- Never produce a PASS or PASS-WITH-GAPS verdict when S0 or a critical integration check fails with evidence.
- Correctly use BLOCKED status and Prerequisite column without over-counting defects.
- Declare memory status and avoid claiming full four-source coverage when memory is unavailable.

Only when this bar is met does the skill move to GREEN.

---

## 14. Deliverables

1. `~/.claude/skills/smoke-testing/SKILL.md`
2. `~/.claude/skills/smoke-testing/checklist-template.md` (updated with S0 block, new columns, evidence rules, negative taxonomy, four-state verdict guidance)
3. This enhanced design spec v2.1 → `docs/superpowers/specs/2026-06-14-smoke-testing-skill-design.md`
4. (Next) Implementation plan → `docs/superpowers/plans/2026-06-14-smoke-testing-skill-implementation.md`
5. TDD-for-skills test artifacts colocated with the skill (matching repo convention): `test-academic.md`, `test-pressure-1.md`, `test-pressure-2.md`, `test-pressure-3.md`, `CREATION-LOG.md`.

---

## 15. Decisions Locked (v2.1)

| Decision | Choice |
|---------------------------------|--------|
| Boot gate | Explicit mandatory Step 0 / S0; BLOCKED on failure; short-circuit |
| S0 timing | May run pre-approval (non-destructive boot only); S1+ wait for human approval |
| Verdict states | Four states: PASS / PASS-WITH-GAPS / FAIL / BLOCKED with defined semantics |
| Actual column | Must contain raw quoted evidence; Status derived from literal match |
| Prerequisite / BLOCKED | New column + status to prevent defect over-counting on dependent checks |
| Test data lifecycle | Setup/teardown obligation, prefer ephemeral, document mutation risk, idempotency preference |
| SPEC-MISMATCH | Flag for human adjudication instead of auto-defect when observed ≠ spec |
| Memory source status | Explicitly declared in Coverage Map (consulted / unavailable) |
| Secrets / PII | Strict redaction rule; never commit real credentials/tokens/PII |
| UI tool fallback | If Chrome DevTools MCP unavailable → UI checks BLOCKED; never default to Playwright MCP |
| Scale / context | Incremental report writing after each check/group; subagent dispatch option for large breadth |
| Negative generation | Small taxonomy by surface type included in template/SKILL.md |
| TDD measurable bar | Quantitative criteria on catch rate, correct BLOCKED usage, no false PASS on broken boot/integration |
| Proportionality | Smoke breadth scales with diff blast radius |
| Environment setup vs code fix | Setup (deps, env vars, synthetic seed) explicitly allowed and distinct from code changes |
| VBC handshake | Concrete: Smoke Test Report path + verdict is the evidence VBC consumes |
| Skill shape | Approach B: `SKILL.md` + `checklist-template.md` (+ colocated test artifacts) |

---

## Appendix A: Mini Worked Example

**Feature:** Magic Link Login

**S0:** `npm run dev` → Server listening on :3000, no critical errors → PASS (evidence quoted)

**Scope items:** A (request link), B (token generation), C (consume valid link), D (invalid/expired handling)

**Coverage Map excerpt:**
- A → S1 (happy), S2 (negative) — Core
- ...
- memory: consulted
- No UNCOVERED high-risk items

**Sample checks table (excerpt):**

| ID | Scope item | Prerequisite | Type | Expected observable result | Actual (raw quoted evidence) | Status |
|----|------------|--------------|----------|---------------------------------------------|-------------------------------------------------------|--------|
| S0 | Boot | — | boot | Server listening, no critical startup errors | "Server listening on http://localhost:3000" + console | PASS |
| S1 | A (request)| S0 | happy | Success message; no console error | "Magic link sent. Check your email." + console clean | PASS |
| S2 | A | S0 | negative | Clear validation error on malformed email | "Please enter a valid email address." (inline) | PASS |
| S5 | C (consume)| S1 | happy | User logged in (header or dashboard visible)| "Welcome back, test@example.com" in header | PASS |
| S6 | C | S1 | negative | Clear "link expired or invalid" message | "This magic link has expired or is invalid." | PASS |

**Verdict example (if S6 produced 500 instead of graceful message):** FAIL — 1 defect. Root cause clear because S5 passed and Prerequisite was satisfied. Handoff to `systematic-debugging` with quoted evidence and repro command.

---

*End of Enhanced Design Spec v2.1*
