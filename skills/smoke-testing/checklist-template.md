# Smoke Test: <Feature> — <YYYY-MM-DD>

**Verdict:** <PASS | PASS-WITH-GAPS | FAIL | BLOCKED>  ·  computed after execution
**Source:** <spec path> + <plan path>   (or: `diff-derived — coverage best-effort`)
**Environment / how to run:** <build/serve/login commands, base URL, test data, credentials-by-name>
**Run mode:** <interactive | unattended>

## Coverage map
> Every scope item maps to >=1 check. `memory:` status is mandatory. Mark Core vs Extended.
- `memory: consulted | unavailable`
- Scope item A (spec section X / plan Task 2) -> S1 (happy, Core), S2 (negative, Core)
- Scope item B (plan Task 3) -> S3 (happy, Core), S4 (negative, Extended)
- UNCOVERED / RISK: <changed surface or memory-flagged area with no check> — source: <spec|plan|diff|memory>

## Checks
| ID | Scope item (trace) | Prerequisite | Type | Steps / command | Expected observable result | Actual (raw quoted evidence — quote it) | Status | Evidence artifact |
|----|--------------------|--------------|------|-----------------|----------------------------|-----------------------------------------|--------|-------------------|
| S0 | Boot / environment | — | boot | `npm run build && npm run dev` (or equivalent) | App serves / process starts with no critical errors | | | |
| S1 | A (spec section X) | S0 | happy | <command or UI steps> | <observable> | | | |
| S2 | A (spec section X) | S0 | negative | <invalid input> | rejected with <specific error> | | | |

Status is one of { PASS, FAIL, BLOCKED, PENDING-HUMAN }. A check is PASS only if the quoted Actual literally demonstrates the Expected observable. Do not infer.

## Defects  (only true FAIL items; BLOCKED is not a defect)
| Def | Check | Scope item (trace) | Severity (blocker/major/minor) | Expected | Observed | Repro (redacted) | Evidence |
|-----|-------|--------------------|--------------------------------|----------|----------|------------------|----------|

## Results summary
Passed: _/_   Failed: _   Blocked: _   Pending-human: _   Uncovered: _
-> Next action / handoff target: <systematic-debugging | verification-before-completion>

## Machine-readable summary
```json
{
  "verdict": "PASS|PASS-WITH-GAPS|FAIL|BLOCKED",
  "passed": 0,
  "failed": 0,
  "blocked": 0,
  "uncovered": 0,
  "human_pending": 0,
  "report_path": "",
  "evidence_dir": ""
}
```

---
**Secrets / PII:** Never write real credentials, tokens, session cookies, or user PII into this report or its evidence. Redact tokens in repro commands. Reference credentials by name (e.g. "test user from smoke-test.env"). Scrub or describe screenshots that expose logged-in data.

**Test data:** Prefer ephemeral/synthetic data and isolated test records. Any state-mutating check documents setup + teardown (or uses rollback). Note non-idempotent checks explicitly.
