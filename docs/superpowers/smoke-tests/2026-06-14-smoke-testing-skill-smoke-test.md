# Smoke Test: smoke-testing skill (self-dogfood) — 2026-06-14

**Verdict:** <computed after execution — DRAFT, stopped at human-review gate; only S0 executed (pre-approval, non-destructive)>
**Source:** docs/superpowers/specs/2026-06-14-smoke-testing-skill-design.md + docs/superpowers/plans/2026-06-14-smoke-testing-skill-implementation.md
**Environment / how to run:** Target is a file-based skill (markdown, zero runtime). "Boot" = skill installed at `~/.claude/skills/smoke-testing/` and discoverable, and `SKILL.md` YAML frontmatter parses (name + trigger description, <=1024 chars). Validation commands: `ls ~/.claude/skills/smoke-testing`; `head -4 SKILL.md`; frontmatter char-count assertion; `grep` for required template structure.
**Run mode:** interactive (stops at the human-review gate)

## Coverage map
> Every scope item maps to >=1 check. Core vs Extended marked.
- `memory: consulted` — no prior smoke-test reports or known-fragile findings exist for this net-new skill (this is its first build/run)
- Scope item A — `SKILL.md` present + valid trigger frontmatter (plan File Structure; spec §15 "Skill shape") -> S1 (happy, Core), S2 (negative, Core)
- Scope item B — `checklist-template.md` present + required structure (spec §15: Actual / Prerequisite / Defects / JSON / footer) -> S3 (happy, Core), S4 (negative, Core)
- Scope item C — colocated dev test artifacts present (`test-academic.md`, `test-pressure-1..3.md`) -> S5 (happy, Extended)
- UNCOVERED / RISK: runtime auto-trigger of the skill by the `using-superpowers` bootstrap is NOT exercised here (needs a fresh session) — source: plan / diff

## Checks
| ID | Scope item (trace) | Prerequisite | Type | Steps / command | Expected observable result | Actual (raw quoted evidence — quote it) | Status | Evidence artifact |
|----|--------------------|--------------|------|-----------------|----------------------------|-----------------------------------------|--------|-------------------|
| S0 | Boot / install + frontmatter | — | boot | `ls ~/.claude/skills/smoke-testing`; frontmatter `<=1024` assertion | both files installed; frontmatter parses, <=1024 chars | `SKILL.md` + `checklist-template.md` listed; `frontmatter chars: 312` / `OK: frontmatter <= 1024` | PASS | this session's tool output |
| S1 | A (skill shape) | S0 | happy | `head -4 skills/smoke-testing/SKILL.md` | `name: smoke-testing`; `description:` starts "Use when" | <execute after approval> | PENDING-HUMAN | |
| S2 | A (skill shape) | S0 | negative | frontmatter > 1024 chars | rejected by the `<=1024` assertion (non-zero exit) | <execute after approval> | PENDING-HUMAN | |
| S3 | B (template structure) | S0 | happy | `grep` for S0 row, Prerequisite, raw-evidence Actual header, 4 Status values, Verdict line, `## Defects`, json block, footer | all elements present | <execute after approval> | PENDING-HUMAN | |
| S4 | B (template structure) | S0 | negative | template missing a required element | `grep` reports `MISS` for that element | <execute after approval> | PENDING-HUMAN | |
| S5 | C (dev test artifacts) | S0 | happy | `ls skills/smoke-testing` | `test-academic.md` + `test-pressure-1..3.md` present | <execute after approval> | PENDING-HUMAN | |

Status is one of { PASS, FAIL, BLOCKED, PENDING-HUMAN }. A check is PASS only if the quoted Actual literally demonstrates the Expected observable. Do not infer.

## Defects  (only true FAIL items; BLOCKED is not a defect)
| Def | Check | Scope item (trace) | Severity (blocker/major/minor) | Expected | Observed | Repro (redacted) | Evidence |
|-----|-------|--------------------|--------------------------------|----------|----------|------------------|----------|
| — | — | — | — | — | — | — | none (no check beyond S0 executed) |

## Results summary
Passed: 1 (S0)   Failed: 0   Blocked: 0   Pending-human: 5   Uncovered: 1
-> Next action / handoff target: present to human for approval at the review gate, then execute S1–S5 and compute the four-state verdict.

## Machine-readable summary
```json
{
  "verdict": "",
  "passed": 1,
  "failed": 0,
  "blocked": 0,
  "uncovered": 1,
  "human_pending": 5,
  "report_path": "docs/superpowers/smoke-tests/2026-06-14-smoke-testing-skill-smoke-test.md",
  "evidence_dir": ""
}
```

---
**Secrets / PII:** Never write real credentials, tokens, session cookies, or user PII into this report or its evidence. Redact tokens in repro commands. Reference credentials by name (e.g. "test user from smoke-test.env"). Scrub or describe screenshots that expose logged-in data. (N/A here — target is public markdown.)

**Test data:** Prefer ephemeral/synthetic data and isolated test records. Any state-mutating check documents setup + teardown (or uses rollback). Note non-idempotent checks explicitly. (All checks here are read-only.)
