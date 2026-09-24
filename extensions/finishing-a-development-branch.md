# Extension: superpowers:finishing-a-development-branch

These are your human partner's standing additions to `superpowers:finishing-a-development-branch`. Follow the skill as written, and layer these on top. Where they conflict, these win.

## Offer a smoke test before the options menu

Once the full test suite passes, and **before** presenting the integration options, offer a smoke test. Unit tests passing proves the pieces work in isolation, not that the assembled feature runs end-to-end.

```
Unit tests pass. Before we merge/PR, want to smoke-test the assembled feature end-to-end
(broad, shallow live run of every built capability + one high-value failure path each)?

1. Yes — run smoke-testing now (recommended for new features / multi-file changes)
2. No — skip (trivial change, or already smoke-tested)

Which option?
```

- **Yes:** use the `smoke-testing` skill and wait for its verdict.
  - **BLOCKED or FAIL:** do not merge or open a PR. Hand off the smoke report; the work is not ready to integrate.
  - **PASS / PASS-WITH-GAPS:** continue to the options menu, and include the report in a PR if one is made.
- **No:** continue to the options menu.

## "Merge locally" also publishes and prunes

After the merged result is green, **push the base branch to origin** (see "Pushing to origin" below). Then clean up the worktree and delete the feature branch (`feature/*`, `chore/*`, `fix/*`, …) right away. The work is integrated and published, so that branch is done. Use `git branch -d`, which refuses unmerged branches. Use `-D` only after confirming the branch is merged.

If you describe this option in the menu, call it "Merge back to <base-branch> locally and push to origin".

## Pushing to origin: consent saved per project

Before any push to origin, check the project's `.claude/settings.local.json`:

1. If `permissions.allow` contains `Bash(git push origin:*)`, consent is already given. Push **without asking**.
2. Otherwise ask once:

```
Push to origin?
1. Yes, once
2. Yes — and don't ask again for this project
3. No

Which option?
```

3. On option 2, **merge** these entries into `.claude/settings.local.json`, then push. Read the file, merge, and write it back. Keep every existing setting and every existing `permissions.allow` entry.

```json
{ "permissions": { "allow": ["Bash(git push origin:*)", "Bash(git push -u origin:*)"] } }
```

This consent covers ordinary pushes only. **Never** use `--force` or `--force-with-lease` on the strength of it. Force pushes always need your human partner's explicit request.
