# Creation Log: Smoke Testing Skill

Built with TDD-for-skills (superpowers:writing-skills): RED (baseline pressure scenarios
against skill-naive subagents) → GREEN (author the skill targeting the rationalizations) →
REFACTOR (close loopholes until a measurable bar is met).

## Source Material

- Design spec (v2.1): `docs/superpowers/specs/2026-06-14-smoke-testing-skill-design.md`
- Implementation plan: `docs/superpowers/plans/2026-06-14-smoke-testing-skill-implementation.md`

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

<!-- Recorded in Task 3 Step 3 -->

## REFACTOR — Closing loopholes to the measurable bar

<!-- Recorded in Task 4 -->

## Final Outcome

<!-- Recorded in Task 5 -->
