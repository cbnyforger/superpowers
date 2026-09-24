# superpowers extensions

This repo holds my own additions to [obra/superpowers](https://github.com/obra/superpowers). Upstream superpowers itself isn't kept here. Claude Code runs it from the official marketplace plugin (`superpowers@claude-plugins-official`), which updates itself.

## Contents

| Path | What it is | How Claude Code loads it |
|------|------------|--------------------------|
| `skills/smoke-testing/` | The `smoke-testing` skill | Symlinked as a personal skill |
| `extensions/*.md` | Standing additions to official superpowers skills, applied on top of them without editing them | Injected at session start by `extensions/session-start.sh` |
| `docs/superpowers/` | Design spec, implementation plan and test-run record for smoke-testing | Not loaded, reference only |

## Setup

```bash
REPO=/Users/cb/Storage/Codebases/utils/superpowers

# 1. Official superpowers plugin (updates itself)
claude plugin install superpowers@claude-plugins-official

# 2. smoke-testing as a personal skill (edits here take effect next session)
ln -s "$REPO/skills/smoke-testing" ~/.claude/skills/smoke-testing
```

3. Register the extensions hook in `~/.claude/settings.json` under `hooks.SessionStart`:

```json
{
  "matcher": "startup|clear|compact",
  "hooks": [{ "type": "command", "command": "/Users/cb/Storage/Codebases/utils/superpowers/extensions/session-start.sh" }]
}
```

## Why the additions are layered on, not patched in

Upstream updates overwrite the plugin cache, and they rewrite skill text often enough that re-merging a patched copy after every release becomes a chore. Each extension states its rules against stable parts of the skill it extends (for example "after the suite passes, before the options menu"), so it keeps working across upstream versions. After a major upstream release, check that the anchors an extension refers to still exist.
