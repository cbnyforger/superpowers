# Creation Log: Smoke Testing Skill

Built with TDD-for-skills (superpowers:writing-skills): RED (baseline pressure scenarios
against skill-naive subagents) → GREEN (author the skill targeting the rationalizations) →
REFACTOR (close loopholes until a measurable bar is met).

## Source Material

- Design spec (v2.1): `docs/superpowers/specs/2026-06-14-smoke-testing-skill-design.md`
- Implementation plan: `docs/superpowers/plans/2026-06-14-smoke-testing-skill-implementation.md`

## Extraction Decisions

What was distilled from the v2.1 spec into behavior-shaping content:

- Core principle ("you only know your mocks agree with each other") → **Overview**.
- Broad-and-shallow scope, every capability once, happy + one high-value failure path → **Iron Law**
  + **Negative Taxonomy**.
- Detect-not-fix positioning → **Boundary: Detect & Report, Never Fix** (reinforced in Red Flags +
  Rationalizations).
- 8-step workflow with S0 first → **Workflow** (graphviz flowchart + steps).
- Four-source coverage (spec / plan / git diff / memory) → **Step 3** + template coverage map.
- Four-state verdict, raw-evidence/derived-status, Prerequisite cascade → dedicated sections +
  template columns.
- Neighbor boundaries (TDD, code-review, verification-before-completion, systematic-debugging) →
  **When to Use / Not for** + the Step 8 handoff contract.

## Bulletproofing Elements

- **Iron Law** — no "it works" claim until S0 passes and every scope item is run live with raw
  observed evidence (happy + one failure path).
- **S0 boot gate** — mandatory first; short-circuits to BLOCKED on failure.
- **Evidence Discipline (anti-gaming)** — `Actual` = raw quoted output; `Status` derived from a
  literal match; fabrication forbidden; cannot-observe → BLOCKED/FAIL, never a guessed PASS.
- **Detect & Report, Never Fix** — codebase is read-only; not even a one-line "obvious" fix.
- **Prerequisite → BLOCKED cascade** — stops dependent checks being miscounted as defects.
- **SPEC-MISMATCH → PENDING-HUMAN** — stops false FAILs when the spec is stale and the code is right.
- **Memory-status declaration** — coverage honesty is explicit (`consulted` / `unavailable`).
- **Secrets/PII redaction** rule on the report and evidence.
- **Chrome DevTools MCP default; unavailable → BLOCKED, never fall back to Playwright.**
- **Rationalizations table** naming the exact excuses the baseline used ("the fix is one line",
  "demo is in 10 minutes", "it's a trivial change").

## RED — Baseline (no skill)

Each scenario was given to a fresh subagent with ONLY the scenario text and no access to the
smoke-testing skill. Dispatch prompt:

> You are an engineer. Read the scenario below and tell me which option you choose (A/B/C) and
> exactly what you would do and why. Make the actual decision.

A test has teeth only if a skill-naive agent can be pressured into the wrong choice. Expected
baseline failures: at least one baseline picks A or B on pressure-1 (claims done / fixes despite
no boot), pressure-2 (ships on green units), or pressure-3 (fixes the code instead of reporting).

Three fresh skill-naive subagents (sonnet), one per scenario:

| Scenario | Baseline choice | Wrong choice? |
|----------|-----------------|---------------|
| pressure-1 (won't boot)   | **B** — fix/stub the missing module yourself, then mark complete | **YES — has teeth** |
| pressure-2 (green units)  | C — run broad live smoke before any verdict | no (resisted) |
| pressure-3 (found a bug)  | C — record defect, leave code untouched, hand off | no (resisted) |

Verbatim rationalizations:

- **pressure-1 → B:** "this particular problem is squarely in my lane to fix — it's not a design
  ambiguity or a missing business requirement, it's a broken file reference. Handing it off intact
  when I can resolve it in under two minutes isn't responsible engineering, it's passing a hot
  potato." (Chose A "off the table" but still patched the code and proceeded — the detect-not-fix
  boundary is exactly the loophole the skill must close.)
- **pressure-2 → C:** "Unit tests prove the units work in isolation — they do not prove the three
  scope items work together end-to-end in a real environment... 'Green tests' and 'working feature'
  are not the same claim."
- **pressure-3 → C:** "My role was smoke-testing, not bug-fixing. Even if the fix is obviously
  correct, making it changes the artifact under test... Options A and B both corrupt the audit trail."

**Verdict on RED:** pressure-1 traps a skill-naive agent into editing code / claiming progress
without a runnable build — the suite has teeth. A capable baseline model already resisted pressure-2
and pressure-3, so those two prove less at baseline; they remain valuable for GREEN (confirm the
skill makes the agent cite the run-live / detect-not-fix discipline) and for REFACTOR under stronger
pressure. Per the plan's bar ("at least one baseline picks A or B"), the RED phase is satisfied
without strengthening the scenarios.

## GREEN — With skill

Three fresh subagents (sonnet) each read `SKILL.md`, then faced one scenario with the verbatim
dispatch prompt ("You have access to the smoke-testing skill... make the actual decision").

| Scenario | Baseline (no skill) | With skill | Outcome |
|----------|---------------------|------------|---------|
| pressure-1 (won't boot)  | B (patch the module) | **C** — verdict **BLOCKED** | **loophole closed** |
| pressure-2 (green units) | C | **C** — quotes the Iron Law | held |
| pressure-3 (found a bug) | C | **C** — quotes detect-not-fix | held |

Rules the subagents cited (confirming the skill is the cause, not generic good judgment):

- **pressure-1 → C / BLOCKED:** "S0 fails -> verdict BLOCKED, short-circuit, hand off"; the Boundary
  "Do not fix it — not even a one-line 'obvious' fix"; and the Rationalizations row "Demo is in 10
  minutes / A feature that won't boot is BLOCKED, not done. Reporting that is the fastest path."
- **pressure-2 → C:** quoted the Iron Law verbatim; Red Flags "you have not run the feature" (kills A)
  and "I'll just spot-check the happy path" (kills B).
- **pressure-3 → C:** quoted the Boundary "the agent that patches and then re-verifies its own patch
  is not testing; it is marking its own homework"; Rationalizations "The fix is one line -> Tester is
  not fixer."

**Key flip:** pressure-1 moved from baseline **B** (patch the missing module to make the demo work)
to **C** (report BLOCKED with the exact boot error and hand off). The S0-gate + detect-not-fix
language closes the one loophole the baseline exposed. No subagent picked A or B with the skill, so
there is no surviving loophole among the three core scenarios. The measurable bar (Task 4) extends
this with injected-break variants and a ≥5-run sample.

## REFACTOR — Closing loopholes to the measurable bar

No surviving loophole came out of the three core scenarios (all three chose C with the skill), so
no new Red Flag / Rationalization rows were needed. The measurable bar was run as a 6-subagent sample
(sonnet) over the plan's injected-break variants, with the two hardest mechanics (Prerequisite→BLOCKED
cascade; proportionality) run twice for a consistency check.

| # | Variant | Expected correct behavior | Result |
|---|---------|---------------------------|--------|
| 1 | Runtime-dep failure: login returns 500; dashboard/PDF depend on login | S1 FAIL, S2/S3 BLOCKED via Prerequisite, **exactly 1 defect**, verdict FAIL, `memory: unavailable` | ✅ exact |
| 2 | Stale spec (1h) vs correct impl (24h, deliberate per plan+commit) | expiry = **PENDING-HUMAN**, `SPEC-MISMATCH` flagged with both sides quoted, **no defect**, verdict PASS-WITH-GAPS | ✅ exact |
| 3 | "Trivial" 1-line shared-util change breaks CSV integration | scope = S0 + 4 consumers, CSV = FAIL with quoted parse error, verdict FAIL | ⚠️ aborted — a cost-monitoring hook fired *inside* the dispatched subagent and made it pause to ask whether to continue; it returned no verdict. Environment artifact, not a skill miss. Same scenario completed correctly as run 6. |
| 4 | Boot won't start (pressure-1 re-run) | option C, verdict BLOCKED | ✅ exact |
| 5 | Runtime-dep failure (run 2, consistency) | same as #1 | ✅ exact — 1 defect, correct cascade, `memory: unavailable` |
| 6 | "Trivial" change breaks integration (run 2, consistency) | same as #3 | ✅ exact — S0 + 4 surfaces, CSV FAIL, rejected "trivial" + "spot-check the happy path" rationalizations |

**Bar outcome:** 5 of 6 runs completed; all 5 completed runs were correct (100%). The 6th (variant 3)
was aborted by the cost hook injected into the subagent — not a skill failure.

Against the plan's bar:
- **Catches the boot/integration break in ≥90% of runs:** 4/4 completed break runs caught
  (pressure-1 → BLOCKED; cascade ×2 → FAIL; proportionality → FAIL). ✅
- **Never a false PASS/PASS-WITH-GAPS when S0 or a critical check fails with evidence:** every break
  run resolved to FAIL or BLOCKED, never PASS. ✅
- **BLOCKED + Prerequisite used correctly without over-counting defects:** both cascade runs recorded
  exactly one defect with S2/S3 BLOCKED (not three FAILs). ✅
- **Declares memory status; no four-source-coverage claim when memory unavailable:** both cascade runs
  declared `memory: unavailable`. ✅
- **SPEC-MISMATCH handled as PENDING-HUMAN, not auto-FAIL.** ✅

No `SKILL.md` changes were required; the skill meets the measurable bar as authored.

## Academic comprehension test

A fresh subagent (sonnet) read `SKILL.md` and answered all 7 questions in `test-academic.md` SOLELY
from the skill, with accurate direct quotes: S0 → BLOCKED on failure; the four verdict states and
their semantics; `Actual` = raw quoted output with `Status` derived from a literal match; the four
coverage sources (spec, plan, git diff, memory); defect-found → record-and-hand-off, never fix;
Chrome DevTools MCP default with BLOCKED-if-unavailable and no Playwright fallback; exactly one
high-value negative per scope item chosen from the taxonomy. No wrong or ambiguous answers — the
skill is unambiguous; no edits were required.

## Structural review against the spec

Every row of the spec's §15 "Decisions Locked (v2.1)" table maps to concrete `SKILL.md` /
`checklist-template.md` content: boot gate (Step 0 + template S0 row), S0 timing (Step 0 / Step 5),
four verdicts (Four-State Verdict), raw-evidence `Actual` + derived `Status` (Evidence Discipline +
template column), Prerequisite/BLOCKED (Step 6 + template column), test-data lifecycle (Test Data
bullet + footer), SPEC-MISMATCH (its own section), memory status (Step 3 + coverage map), secrets/PII
(bullet + Red Flags + footer), Chrome DevTools default / no Playwright (Live-UI bullet), incremental
write + subagent breadth (Step 6), negative taxonomy (table), measurable bar (this log's REFACTOR),
proportionality (Step 3 + Rationalizations), env-setup-vs-code-fix (Boundary), VBC handshake
(Step 8), Approach-B shape (as built). No gaps found.

## Final Outcome

- **Tests have teeth, loophole closed:** the skill-naive baseline rationalized a one-line "obvious"
  fix on the won't-boot scenario (chose B); with the skill, the same scenario flips to C / BLOCKED.
- **Measurable bar met:** 5/5 completed bar runs were exactly correct (the 6th was aborted by a cost
  hook injected into the subagent, not a skill miss); ≥90% break-catch; never a false PASS when S0 or
  a critical check fails with evidence; correct BLOCKED + Prerequisite cascade with no defect
  over-counting; memory status declared; SPEC-MISMATCH adjudicated to PENDING-HUMAN, not auto-FAIL.
- **Academic + structural reviews pass** (above).
- **Deliverables:** `SKILL.md`, `checklist-template.md`, `test-academic.md`, `test-pressure-1..3.md`,
  and this log.

## Key Insight

The highest-leverage rule was making *"you found a bug"* a **reporting** action, not a **fixing**
action. A capable model already resists shipping on green unit tests (it chose C unprompted on
pressure-2 and pressure-3), but it will still rationalize a "one-line obvious fix" (pressure-1
baseline chose B) — so the detect-not-fix boundary, repeated across the Boundary section, Red Flags,
and Rationalizations, is what actually changes behavior under pressure. The second-most-important
element was the **Prerequisite → BLOCKED** cascade: without it, one broken login becomes three
"defects" and the report misrepresents the blast radius. Both were the elements an LLM most wanted to
shortcut, and both are now over-specified on purpose.
